#include "box_and_particle.hpp"
#include "morton.h"


extern void boris_step_fortran( double r[],
                                double v[],
                                double q,
                                double m,
                                double dt,
                                double bfield[] );

extern void bfield_func( double *r, double *b );


Box::Box()
{
    m_key = EMPTY;
    m_bfield = nullptr;
}


Box::Box( uint64_t key, int coords[DIM], bool alloc )
{
    if ( key == EMPTY )
        m_key = morton_encode( coords );
    else
        m_key = key;

    for ( int i = 0; i < DIM; ++i )
        m_coords[i] = coords[i];

    if ( alloc )
        m_bfield = new double[N*N*N*DIM];
    else
        m_bfield = nullptr;
}


Box::~Box()
{
    if ( m_bfield != nullptr )
        delete[] m_bfield;
}


void Box::compute_bfield()
{
    int r[3] = { 0, 0, 0 };
    double b[3];

    for ( int i = 0; i < N; ++i )
        for ( int j = 0; j < N; ++j )
            for ( int k = 0; k < N; ++k ) {
                r[0] = i, r[1] = j, r[2] = k;
                bfield_func((double *)r, b);
                for ( int l = 0; l < DIM; ++l )
                    ARRAY_ELEMENT_4D(m_bfield, l, r) = b[l];
            }
}


Particle::Particle( double *init )
    : m_q( init[2*DIM] ), m_m( init[2*DIM+1] )
{
    for ( int i = 0; i < DIM; ++i ) {
        m_r[i] = init[i];
        m_v[i] = init[i+DIM];
    }
}


void Particle::boris_step( double *bfield, double dt )
{
    boris_step_fortran( m_r, m_v, m_q, m_m, dt, bfield );
}
