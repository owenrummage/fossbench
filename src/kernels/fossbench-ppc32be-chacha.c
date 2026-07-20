/*
 * Baseline 32-bit PowerPC ChaCha20 kernel.
 *
 * The Wii's Broadway CPU has no AltiVec, so this target must not use the
 * vectorized implementation emitted for 74xx PowerPC processors.  Keep the
 * byte loads and stores explicit: ChaCha20 words are little-endian while this
 * target is big-endian.
 */

#include <stdint.h>

static uint32_t load32le(const uint8_t *p)
{
	return (uint32_t)p[0] | (uint32_t)p[1] << 8 |
	       (uint32_t)p[2] << 16 | (uint32_t)p[3] << 24;
}

static void store32le(uint8_t *p, uint32_t x)
{
	p[0] = (uint8_t)x;
	p[1] = (uint8_t)(x >> 8);
	p[2] = (uint8_t)(x >> 16);
	p[3] = (uint8_t)(x >> 24);
}

static uint32_t rotl32(uint32_t x, unsigned int n)
{
	return (x << n) | (x >> (32 - n));
}

#define QR(a, b, c, d) do {                 \
	x[a] += x[b]; x[d] = rotl32(x[d] ^ x[a], 16); \
	x[c] += x[d]; x[b] = rotl32(x[b] ^ x[c], 12); \
	x[a] += x[b]; x[d] = rotl32(x[d] ^ x[a], 8);  \
	x[c] += x[d]; x[b] = rotl32(x[b] ^ x[c], 7);  \
} while (0)

uint64_t fb_chacha20(uint8_t *buf, uint64_t len,
		     const uint8_t key[32], uint64_t rounds)
{
	static const uint32_t sigma[4] = {
		0x61707865, 0x3320646e, 0x79622d32, 0x6b206574
	};
	uint32_t base[16] = {0}, x[16];
	uint32_t checksum = 0, counter = 0;
	uint64_t pass, off;
	int i, r;

	len &= ~(uint64_t)63;
	if (len == 0 || rounds == 0)
		return 0;

	for (i = 0; i < 4; i++)
		base[i] = sigma[i];
	for (i = 0; i < 8; i++)
		base[4 + i] = load32le(key + 4 * i);

	for (pass = 0; pass < rounds; pass++) {
		for (off = 0; off < len; off += 64, counter++) {
			base[12] = counter;
			for (i = 0; i < 16; i++)
				x[i] = base[i];

			for (r = 0; r < 10; r++) {
				QR(0, 4, 8, 12); QR(1, 5, 9, 13);
				QR(2, 6, 10, 14); QR(3, 7, 11, 15);
				QR(0, 5, 10, 15); QR(1, 6, 11, 12);
				QR(2, 7, 8, 13); QR(3, 4, 9, 14);
			}

			for (i = 0; i < 16; i++) {
				uint32_t word = x[i] + base[i];
				uint8_t stream[4];
				int j;

				store32le(stream, word);
				for (j = 0; j < 4; j++)
					buf[off + 4 * i + j] ^= stream[j];
				checksum ^= word;
			}
		}
	}

	return checksum;
}

#undef QR
