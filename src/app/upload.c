/* Upload results if the user wants to. */

static void json_escape(const char *src, char *dst, size_t cap)
{
	size_t used = 0;
	while (*src && used + 1 < cap) {
		unsigned char c = (unsigned char)*src++;
		const char *esc = NULL;
		if (c == '\"') esc = "\\\"";
		else if (c == '\\') esc = "\\\\";
		else if (c == '\n') esc = "\\n";
		else if (c == '\r') esc = "\\r";
		else if (c == '\t') esc = "\\t";
		if (esc) {
			size_t n = strlen(esc); if (used + n >= cap) break;
			memcpy(dst + used, esc, n); used += n;
		} else if (c >= 0x20) dst[used++] = (char)c;
	}
	dst[used] = '\0';
}

/* Extract a simple JSON string field from the upload response. */
static int json_string_field(const char *json, const char *field, char *dst, size_t cap)
{
	char key[64];
	const char *p;
	size_t used = 0;

	if (cap == 0 || snprintf(key, sizeof(key), "\"%s\"", field) < 0)
		return 0;
	p = strstr(json, key);
	if (!p) return 0;
	p += strlen(key);
	while (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n') p++;
	if (*p++ != ':') return 0;
	while (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n') p++;
	if (*p++ != '"') return 0;
	while (*p && *p != '"' && used + 1 < cap) {
		if (*p == '\\' && p[1]) p++;
		dst[used++] = *p++;
	}
	dst[used] = '\0';
	return *p == '"' && used > 0;
}

#if !defined(_WIN32)
/* Load the certificates included with the program. */
static int load_embedded_ca_bundle(SSL_CTX *ctx)
{
	X509_STORE *store = SSL_CTX_get_cert_store(ctx);
	BIO *bio = BIO_new_mem_buf(fb_ca_bundle_pem, -1);
	X509 *cert;
	int loaded = 0;

	if (!bio) return 0;
	while ((cert = PEM_read_bio_X509(bio, NULL, NULL, NULL)) != NULL) {
		if (X509_STORE_add_cert(store, cert)) loaded++;
		X509_free(cert);
	}
	BIO_free(bio);
	ERR_clear_error();	/* Reaching the end sets an error, which is fine. */
	return loaded > 0;
}
#endif

#if defined(_WIN32)
/* Check if WinHTTP found a certificate problem. */
static int is_winhttp_secure_error(DWORD err)
{
	switch (err) {
	case ERROR_WINHTTP_SECURE_CERT_DATE_INVALID:
	case ERROR_WINHTTP_SECURE_CERT_CN_INVALID:
	case ERROR_WINHTTP_SECURE_INVALID_CA:
	case ERROR_WINHTTP_SECURE_CERT_REV_FAILED:
	case ERROR_WINHTTP_SECURE_CHANNEL_ERROR:
	case ERROR_WINHTTP_SECURE_INVALID_CERT:
	case ERROR_WINHTTP_SECURE_CERT_REVOKED:
	case ERROR_WINHTTP_SECURE_FAILURE:
	case ERROR_WINHTTP_SECURE_CERT_WRONG_USAGE:
	case ERROR_WINHTTP_SECURE_FAILURE_PROXY:
		return 1;
	default:
		return 0;
	}
}

/* Send the request with Windows networking. */
static int winhttp_post(const char *host, const char *port, const char *path,
			 int use_tls, const char *payload, int payload_len,
			 const char *auth_header, int *out_status,
			 char *response, size_t response_cap)
{
	wchar_t whost[256], wpath[512], wheaders[700];
	char header_buf[700];
	HINTERNET hsession = NULL, hconnect = NULL, hrequest = NULL;
	INTERNET_PORT wport = (INTERNET_PORT)atoi(port);
	DWORD status = 0, status_size = sizeof(status);
	int ok = 0;

	if (MultiByteToWideChar(CP_UTF8, 0, host, -1, whost, sizeof whost / sizeof whost[0]) == 0 ||
	    MultiByteToWideChar(CP_UTF8, 0, path, -1, wpath, sizeof wpath / sizeof wpath[0]) == 0)
		return 0;
	snprintf(header_buf, sizeof(header_buf), "Content-Type: application/json\r\n%s", auth_header);
	if (MultiByteToWideChar(CP_UTF8, 0, header_buf, -1, wheaders, sizeof wheaders / sizeof wheaders[0]) == 0)
		return 0;

	hsession = WinHttpOpen(L"fossbench", WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
			       WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
	if (!hsession) {
		fprintf(stderr, "  upload error: cannot initialize WinHTTP\n");
		return 0;
	}
	hconnect = WinHttpConnect(hsession, whost, wport, 0);
	if (!hconnect) {
		fprintf(stderr, "  upload error: cannot connect to %s:%s\n", host, port);
		goto done;
	}
	hrequest = WinHttpOpenRequest(hconnect, L"POST", wpath, NULL, WINHTTP_NO_REFERER,
				      WINHTTP_DEFAULT_ACCEPT_TYPES,
				      use_tls ? WINHTTP_FLAG_SECURE : 0);
	if (!hrequest) {
		fprintf(stderr, "  upload error: cannot create HTTP request\n");
		goto done;
	}
	if (!WinHttpSendRequest(hrequest, wheaders, (DWORD)-1L, (LPVOID)payload,
				(DWORD)payload_len, (DWORD)payload_len, 0)) {
		if (is_winhttp_secure_error(GetLastError()))
			fprintf(stderr, "  upload error: TLS connection or certificate verification failed\n");
		else
			fprintf(stderr, "  upload error: send failed\n");
		goto done;
	}
	if (!WinHttpReceiveResponse(hrequest, NULL)) {
		if (is_winhttp_secure_error(GetLastError()))
			fprintf(stderr, "  upload error: TLS connection or certificate verification failed\n");
		else
			fprintf(stderr, "  upload error: no server response\n");
		goto done;
	}
	if (!WinHttpQueryHeaders(hrequest, WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER,
				 WINHTTP_HEADER_NAME_BY_INDEX, &status, &status_size,
				 WINHTTP_NO_HEADER_INDEX)) {
		fprintf(stderr, "  upload error: no server response\n");
		goto done;
	}
	*out_status = (int)status;
	if (response_cap > 0) {
		size_t used = 0;
		while (used + 1 < response_cap) {
			DWORD available = 0, got = 0;
			DWORD room = (DWORD)(response_cap - used - 1);
			if (!WinHttpQueryDataAvailable(hrequest, &available) || available == 0)
				break;
			if (available > room) available = room;
			if (!WinHttpReadData(hrequest, response + used, available, &got) || got == 0)
				break;
			used += got;
		}
		response[used] = '\0';
	}
	ok = 1;
done:
	if (hrequest) WinHttpCloseHandle(hrequest);
	if (hconnect) WinHttpCloseHandle(hconnect);
	WinHttpCloseHandle(hsession);
	return ok;
}
#endif

static int upload_results(const struct system_info *info, double score,
			  double singlecore_score, const struct result *multi,
			  const struct result *single, uint64_t duration_ms,
			  const struct background_metrics *background)
{
	char host[256], port[16], path[512], payload[16384];
	char auth_header[600], response_body[2048], claim_url[1024];
	char cpu[512], model[512], os[512], compiler[256], kernel[256];
	const char *base = FB_API_BASE_URL, *p, *slash, *colon;
	int use_tls, status = 0, payload_len;
#if !defined(_WIN32)
	char request[20000], response[4096];
	struct addrinfo hints, *addresses = NULL, *a;
	SSL_CTX *tls_ctx = NULL;
	SSL *tls = NULL;
	int fd = -1, request_len;
#endif

	if (!strncmp(base, "https://", 8)) {
		use_tls = 1; p = base + 8; strcpy(port, "443");
	} else if (!strncmp(base, "http://", 7)) {
		use_tls = 0; p = base + 7; strcpy(port, "80");
	} else {
		fprintf(stderr, "  upload error: unsupported URL scheme\n");
		return 0;
	}
	slash = strchr(p, '/');
	if (!slash) slash = p + strlen(p);
	colon = memchr(p, ':', (size_t)(slash - p));
	if (colon) {
		size_t hn = (size_t)(colon - p), pn = (size_t)(slash - colon - 1);
		if (hn >= sizeof(host) || pn == 0 || pn >= sizeof(port)) return 0;
		memcpy(host, p, hn); host[hn] = '\0'; memcpy(port, colon + 1, pn); port[pn] = '\0';
	} else {
		size_t hn = (size_t)(slash - p); if (hn >= sizeof(host)) return 0;
		memcpy(host, p, hn); host[hn] = '\0';
	}
	{
		int base_path_len = (int)strlen(slash);
		while (base_path_len > 0 && slash[base_path_len - 1] == '/') base_path_len--;
		snprintf(path, sizeof(path), "%.*s/api/v1/submissions", base_path_len, slash);
	}

	json_escape(info->cpu, cpu, sizeof(cpu));
	json_escape(info->model, model, sizeof(model));
	json_escape(info->operating_system, os, sizeof(os));
	json_escape(info->compiler, compiler, sizeof(compiler));
	json_escape(info->kernel, kernel, sizeof(kernel));
	/* The server still calls this field fossmark_version. */
	payload_len = snprintf(payload, sizeof(payload),
		"{\"cpu\":\"%s\",\"model\":\"%s\",\"cpu_cores\":%ld,\"cpu_threads\":%ld,"
		"\"memory_mb\":%ld,\"operating_system\":\"%s\",\"compiler\":\"%s\","
		"\"fossmark_version\":\"%s\",\"score\":%.17g,\"duration_ms\":%llu,"
		"\"score_details\":{\"scoring_method\":\"weighted_geometric_mean\","
		"\"target_score\":%.17g,\"multicore_score\":%.17g,\"singlecore_score\":%.17g,"
		"\"minimum_test_seconds\":%.17g,\"repeats\":%d,"
		"\"system_environment\":{\"kernel\":\"%s\",\"sample_seconds\":%d,"
		"\"background_cpu_average_percent\":%.17g,\"background_cpu_peak_percent\":%.17g,"
		"\"available_memory_mb\":%ld,\"process_count\":%ld},\"tests\":[",
		cpu, model, info->cpu_cores, info->cpu_threads, info->memory_mb, os, compiler,
		FB_VERSION, score, (unsigned long long)duration_ms, FB_TARGET_SCORE, score,
		singlecore_score, MIN_SECONDS, REPEATS, kernel, background->samples,
		background->average_cpu_percent, background->peak_cpu_percent,
		background->available_memory_mb, background->process_count);
	if (payload_len < 0 || (size_t)payload_len >= sizeof(payload)) return 0;
	{
		size_t used = (size_t)payload_len;
		size_t i;
		for (i = 0; i < NTESTS; i++) {
			int n = snprintf(payload + used, sizeof(payload) - used,
				"%s{\"name\":\"%s\",\"detail\":\"%s\",\"unit\":\"%s\","
				"\"start_iterations\":%llu,\"work_per_iteration\":%.17g,"
				"\"reference_rate\":%.17g,\"weight\":%.17g,"
				"\"multicore\":{\"display_metric\":%.17g,\"rate\":%.17g,\"score\":%.17g,"
				"\"seconds\":%.17g,\"iterations\":%llu,\"threads\":%d,\"checksum\":\"%llu\"},"
				"\"singlecore\":{\"display_metric\":%.17g,\"rate\":%.17g,\"score\":%.17g,"
				"\"seconds\":%.17g,\"iterations\":%llu,\"threads\":%d,\"checksum\":\"%llu\"}}",
				i ? "," : "", tests[i].name, tests[i].detail, tests[i].unit,
				(unsigned long long)tests[i].start_n, tests[i].work_per_n,
				tests[i].ref_rate, tests[i].weight,
				display_metric(&tests[i], &multi[i]), multi[i].rate, multi[i].score,
				multi[i].seconds, (unsigned long long)multi[i].iters, multi[i].threads,
				(unsigned long long)multi[i].checksum,
				display_metric(&tests[i], &single[i]), single[i].rate, single[i].score,
				single[i].seconds, (unsigned long long)single[i].iters, single[i].threads,
				(unsigned long long)single[i].checksum);
			if (n < 0 || (size_t)n >= sizeof(payload) - used) return 0;
			used += (size_t)n;
		}
		if (used + 3 >= sizeof(payload)) return 0;
		memcpy(payload + used, "]}}", 4);
		payload_len = (int)(used + 3);
	}

	/* Every upload is anonymous and claim-based. */
	auth_header[0] = '\0';
	response_body[0] = '\0';
#if !defined(_WIN32)
	request_len = snprintf(request, sizeof(request),
		"POST %s HTTP/1.1\r\nHost: %s:%s\r\nContent-Type: application/json\r\n"
		"Content-Length: %d\r\nConnection: close\r\n%s\r\n%s",
		path, host, port, payload_len, auth_header, payload);
	if (request_len < 0 || (size_t)request_len >= sizeof(request)) return 0;

	memset(&hints, 0, sizeof(hints)); hints.ai_socktype = SOCK_STREAM; hints.ai_family = AF_UNSPEC;
	if (getaddrinfo(host, port, &hints, &addresses) != 0) { fprintf(stderr, "  upload error: cannot resolve %s\n", host); return 0; }
	for (a = addresses; a; a = a->ai_next) {
		fd = socket(a->ai_family, a->ai_socktype, a->ai_protocol);
		if (fd >= 0 && connect(fd, a->ai_addr, a->ai_addrlen) == 0) break;
		if (fd >= 0) close(fd);
		fd = -1;
	}
	freeaddrinfo(addresses);
	if (fd < 0) { fprintf(stderr, "  upload error: cannot connect to %s:%s\n", host, port); return 0; }
	if (use_tls) {
		tls_ctx = SSL_CTX_new(TLS_client_method());
		if (!tls_ctx) {
			fprintf(stderr, "  upload error: cannot initialize TLS trust store\n");
			goto upload_failed;
		}
		SSL_CTX_set_default_verify_paths(tls_ctx);	/* Try system certificates too. */
		if (!load_embedded_ca_bundle(tls_ctx)) {
			fprintf(stderr, "  upload error: cannot initialize TLS trust store\n");
			goto upload_failed;
		}
		SSL_CTX_set_verify(tls_ctx, SSL_VERIFY_PEER, NULL);
		tls = SSL_new(tls_ctx);
		if (!tls || !SSL_set_tlsext_host_name(tls, host) ||
		    !SSL_set1_host(tls, host) || !SSL_set_fd(tls, fd) ||
		    SSL_connect(tls) != 1) {
			fprintf(stderr, "  upload error: TLS connection or certificate verification failed\n");
			goto upload_failed;
		}
	}
	{
		size_t sent = 0;
		while (sent < (size_t)request_len) {
			int n = use_tls ? SSL_write(tls, request + sent, (int)((size_t)request_len - sent)) :
				(int)send(fd, request + sent, (size_t)request_len - sent, 0);
			if (n <= 0) { fprintf(stderr, "  upload error: send failed\n"); goto upload_failed; }
			sent += (size_t)n;
		}
	}
	{
		size_t used = 0;
		int n;
		do {
			n = use_tls ? SSL_read(tls, response + used, (int)(sizeof(response) - used - 1)) :
				(int)recv(fd, response + used, sizeof(response) - used - 1, 0);
			if (n > 0) used += (size_t)n;
		} while (n > 0 && used + 1 < sizeof(response));
		if (used == 0) { fprintf(stderr, "  upload error: no server response\n"); goto upload_failed; }
		response[used] = '\0';
		if (sscanf(response, "HTTP/%*s %d", &status) != 1) status = 0;
		{
			char *body = strstr(response, "\r\n\r\n");
			if (body) snprintf(response_body, sizeof(response_body), "%s", body + 4);
		}
	}
	if (tls) { SSL_shutdown(tls); SSL_free(tls); }
	if (tls_ctx) SSL_CTX_free(tls_ctx);
	close(fd);
#else
	if (!winhttp_post(host, port, path, use_tls, payload, payload_len, auth_header,
			  &status, response_body, sizeof(response_body)))
		return 0;
#endif
	if (status == 401) {
		fprintf(stderr, "  upload failed: API token was rejected (HTTP 401)\n");
		return 0;
	}
	if (status == 422) {
		fprintf(stderr, "  upload failed: server rejected the submission as invalid (HTTP 422)\n");
		return 0;
	}
	if (status < 200 || status >= 300) { fprintf(stderr, "  upload failed: server returned HTTP %d\n", status); return 0; }
	if (!json_string_field(response_body, "claim_url", claim_url, sizeof(claim_url))) {
		fprintf(stderr, "  upload failed: server did not return a claim link\n");
		return 0;
	}
	printf("  Results uploaded (HTTP %d).\n", status);
	{
		const char *claim_code = strrchr(claim_url, '/');
		printf("  Claim code: %s\n", claim_code && claim_code[1] ? claim_code + 1 : claim_url);
	}
	printf("  Claim your result: %s\n", claim_url);
	return 1;

#if !defined(_WIN32)
upload_failed:
	if (tls) SSL_free(tls);
	if (tls_ctx) SSL_CTX_free(tls_ctx);
	if (fd >= 0) close(fd);
	return 0;
#endif
}
