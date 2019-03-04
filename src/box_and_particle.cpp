#include "box_and_particle.hpp"
#include "morton.h"


extern "C" {
void boris_step_fortran( double r[],
                         double v[],
                         double q,
                         double m,
                         double dt,
                         double bfield[] );
}

extern void temp_bfield_func( double *b );


Box::Box() : m_key( EMPTY ), m_bfield( nullptr ) {}


Box::Box( uint64_t key, int coords[DIM], bool alloc )
{
    if ( key == EMPTY )
        m_key = morton_encode( coords );
    else
        m_key = key;

    for ( int i = 0; i < DIM; ++i )
        m_coords[i] = coords[i];

    if ( alloc )
        m_bfield = new double[DIM*N*N*N];
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
    temp_bfield_func( m_bfield );
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
