#pragma once

#include <cstdint>


#define _ARRAY_ELEMENT_4D(a, w, x, y, z, nw, nx, ny) \
    (a)[(w) + (nw) * (x) + (nw) * (nx) * (y) + (nw) * (nx) * (ny) * (z)]
#define ARRAY_ELEMENT_4D(a, c, r) \
    _ARRAY_ELEMENT_4D((a), (c), (r)[0], (r)[1], (r)[2], DIM, N, N)


const int DIM   = 3;
const int N     = 16;
const int M     = 16;
const uint64_t EMPTY = 1ULL << 0x3F;

