#pragma once

#include <cstdint>

#include <forward_list>
#include <vector>

#define DIM 3
#define N   256

#define EMPTY   1ULL << 0x3F
#define IS_SET  ~(EMPTY)

#define _ARRAY_ELEMENT_3D(a, x, y, z, nx, ny) \
    (a)[(x) + (nx) * (y) + (nx) * (ny) * (z)]
#define ARRAY_ELEMENT_3D(a, t) \
    _ARRAY_ELEMENT_3D((a), (t)[0], (t)[1], (t)[2], N, N)
