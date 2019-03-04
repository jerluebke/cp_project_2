#include "box_and_particle.hpp"

void temp_bfield_func( double *b )
{
    int r[3] = { 0, 0, 0 };

    for ( int i = 0; i < N; ++i )
        for ( int j = 0; j < N; ++j )
            for ( int k = 0; k < N; ++k ) {
                r[0] = k, r[1] = j, r[2] = i;
                ARRAY_ELEMENT_4D(b, 0, r) = 0.0;
                ARRAY_ELEMENT_4D(b, 1, r) = 0.0;
                ARRAY_ELEMENT_4D(b, 2, r) = 0.1;
            }
}
