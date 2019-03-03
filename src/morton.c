#include "morton.h"

static const uint64_t B[6] = {
    07777777,
    0370000000000177777,
    0370000037700000377,
    0100170017001700170017,
    0103030303030303030303,
    0111111111111111111111,
};

static const uint8_t S[5] = { 32, 16, 8, 4, 2 };

static const uint64_t M[3][2] = {
    { 0111111111111111111111,
      0666666666666666666666 },
    { 0222222222222222222222,
      0555555555555555555555 },
    { 0444444444444444444444,
      0333333333333333333333 }
};


static uint64_t split3( uint64_t x )
{
    x &= B[0];
    x = (x | (x << S[0])) & B[1];
    x = (x | (x << S[1])) & B[2];
    x = (x | (x << S[2])) & B[3];
    x = (x | (x << S[3])) & B[4];
    x = (x | (x << S[4])) & B[5];
    return x;
}


uint64_t morton_encode( int coords[3] )
{
    return split3( coords[0] )          \
        | (split3( coords[1] ) << 1)    \
        | (split3( coords[2] ) << 2);
}


uint64_t morton_neighbour( uint64_t key, int idx[3] )
{
    uint64_t new_key = key;

    for ( int i = 0; i < 3; ++i )
        switch ( idx[i] ) {
            case  1:
                new_key = ((( new_key | M[i][1] ) + 1) & M[i][0]) \
                          | ( new_key & M[i][1] );
                break;
            case -1:
                new_key = ((( new_key & M[i][0] ) - 1) & M[i][0]) \
                          | ( new_key & M[i][1] );
                break;
            default:
                continue;
        }

    return new_key;
}
