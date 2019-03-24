#include <random>
#include "box_and_particle.hpp"


struct RandGen {
    std::random_device m_rd;
    std::mt19937 m_gen;
    std::normal_distribution<> m_nd;

    // seeds generator with random_device
    // initializes distribution
    RandGen( double mean, double stddev )
        : m_rd(), m_gen( m_rd() ), m_nd( mean, stddev )
    {}

    // generate next random number from distribution
    double operator() ( void ) { return m_nd( m_gen ); }
};


static RandGen rg{ RANDGEN_MEAN, RANDGEN_STDDEV };


void temp_bfield_random( double *b )
{
    for ( int i = 0; i < DIM*N*N*N; ++i ) {
        b[i] = rg();
    }
}


void temp_bfield_const_z( double *b )
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
