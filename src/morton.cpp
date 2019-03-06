/* morton encoding in 3 dimensions
 * for reference see:
 *  https://www.forceflow.be/2013/10/07/morton-encodingdecoding-through-bit-interleaving-implementations/
 */
#include "morton.hpp"


/* MAGIC BITS (in octal representation)
 */
// B: bit masks
static const uint64_t B[6] = {
    07777777,
    0370000000000177777,
    0370000037700000377,
    0100170017001700170017,
    0103030303030303030303,
    0111111111111111111111,
};

// S: shifts
static const uint8_t S[5] = { 32, 16, 8, 4, 2 };

// M: bit masks for neighbouring keys
static const uint64_t M[3][2] = {
    { 0111111111111111111111,
      0666666666666666666666 },
    { 0222222222222222222222,
      0555555555555555555555 },
    { 0444444444444444444444,
      0333333333333333333333 }
};


/* split3
 * in binary representation move bits of x three positions apart, e.g.
 *  0b000011 -> 0b001001
 *
 * Parameters
 * ==========
 * x    :   integer (uint64_t) to split
 *
 * Returns
 * =======
 * uint64_t, `splitted` x
 *
 */
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


/* morton_encode
 * compute morton key from 3d coordinates (x, y, z)
 *
 * Parameters
 * ==========
 * coords   :   integer-array (len 3)
 *
 * Returns
 * =======
 * uint64_t, morton key of coords
 *
 * NOTE: only the first 63 bits are actually in use
 * the foremost bit can be used as a flag (e.g. to indicate a node being empty)
 *
 */
uint64_t morton_encode( int coords[3] )
{
    return split3( coords[0] )          \
        | (split3( coords[1] ) << 1)    \
        | (split3( coords[2] ) << 2);
}


/* morton_neighbour
 * compute the neighbour of key by adding/substracting 1 to/from the bit
 * positions corresponding to the direction given by idx
 *
 * layout of idx:
 *  idx = { x, y, z }; where x, y, z in { -1, 0, 1 }
 *
 * used equations and magic bits (simplified):
 *  x-(k) = (((k & 0b001) - 1) & 0b001) | (k & 0b110)
 *  x+(k) = (((k | 0b110) + 1) & 0b001) | (k & 0b110)
 *
 * for y use 0b010 and 0b101; for z use 0b100 and 0b011
 * (note: magic bits of a coordinate are complementary)
 *
 * Parameters
 * ==========
 * key  :   uint64_t, original morton key
 * idx  :   integer-array (len 3), direction of neighbour
 *
 * Returns
 * =======
 * uint64_t, morton key of neighbour
 *
 */
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
