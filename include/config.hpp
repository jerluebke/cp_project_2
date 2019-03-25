#pragma once

/*========================================================================*/
/* NUMERICAL CONSTANTS                                                    */
/*========================================================================*/

// spatial dimensions
#define DIM     3
// particle grid points per box
#define N       64
// box grid
#define M       8
// morton key of empty box
#define EMPTY   1ULL << 0x3F



/*========================================================================*/
/* E- AND B-FIELD                                                         */
/*========================================================================*/

// enable E-field when calculating particle movement
#define EFIELD 0

// which bfield-function to use
// options:
//  * `temp_bfield_const_z`
//  * `temp_bfield_random`
#define BFIELD_FUNC temp_bfield_random

// mean and stddev of normal distribution from which to draw random numbers
#define RANDGEN_MEAN    0.0f
#define RANDGEN_STDDEV  0.5f



/*========================================================================*/
/* 4-DIM ARRAY SUBSCRIPT                                                  */
/*========================================================================*/

#define _ARRAY_ELEMENT_4D(a, w, x, y, z, nw, nx, ny) \
    (a)[(w) + (nw) * (x) + (nw) * (nx) * (y) + (nw) * (nx) * (ny) * (z)]
#define ARRAY_ELEMENT_4D(a, c, r) \
    _ARRAY_ELEMENT_4D((a), (c), (r)[0], (r)[1], (r)[2], DIM, N, N)

