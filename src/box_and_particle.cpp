#include "box_and_particle.hpp"

extern void boris_step_fortran( double r[],
                                double v[],
                                double q,
                                double m,
                                double dt,
                                double bfield[] );
extern double bfield_func(double *r);


Box::Box( uint64_t key, int coords[DIM], bool alloc )
    : m_key( key )
{
    for ( int i = 0; i < DIM; ++i )
        m_coords[i] = coords[i];

    if ( alloc )
        m_bfield = new double[N*N*N];
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

    for ( int i = 0; i < N; ++i )
        for ( int j = 0; j < N; ++j )
            for ( int k = 0; k < N; ++k ) {
                r[0] = i, r[1] = j, r[2] = k;
                ARRAY_ELEMENT_3D(m_bfield, r) = bfield_func((double *)r);
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
