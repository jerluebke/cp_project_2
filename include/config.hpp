#pragma once

#include <cstdint>

#include <forward_list>
#include <vector>


#define _ARRAY_ELEMENT_3D(a, x, y, z, nx, ny) \
    (a)[(x) + (nx) * (y) + (nx) * (ny) * (z)]
#define ARRAY_ELEMENT_3D(a, t) \
    _ARRAY_ELEMENT_3D((a), (t)[0], (t)[1], (t)[2], N, N)


const int DIM   = 3;
const int N     = 16;
const int M     = 16;
const uint64_t EMPTY = 1ULL << 0x3F;

