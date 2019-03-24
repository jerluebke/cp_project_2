#include "box_and_particle.hpp"
#include "morton.hpp"


extern "C" {
void boris_step_fortran( double r[],
                         double v[],
                         double q,
                         double m,
                         double dt,
                         double bfield[] );
}

extern void temp_bfield_const_z( double *b );
extern void temp_bfield_random( double *b );



/*==========================================================================*/
/*  Constructor/Destructor Box:                                             */
/*      (conditional) initialization and (de-)allocation of memory          */
/*==========================================================================*/

Box::Box() : m_key( EMPTY ), m_bfield( nullptr ) {}


Box::Box( uint64_t key, int coords[DIM], bool alloc )
{
    if ( key == EMPTY )
        m_key = morton_encode( coords );
    else
        m_key = key;

    std::copy( coords, coords+DIM, m_coords );

    if ( alloc ) {
        m_bfield = new double[DIM*N*N*N];
        BFIELD_FUNC( m_bfield );
    } else {
        m_bfield = nullptr;
    }
}


Box::~Box()
{
    if ( m_bfield != nullptr )
        delete[] m_bfield;
}


// compute B-field array of Box
// TODO: implement `real` B-field function
void Box::compute_bfield()
{
    BFIELD_FUNC( m_bfield );
}


/*==========================================================================*/


/*==========================*/
/* Constructor Particle     */
/*==========================*/

Particle::Particle( double *init )
    : m_q( init[2*DIM] ), m_m( init[2*DIM+1] )
{
    std::copy( init, init+DIM, m_r );
    std::copy( init+DIM, init+(2*DIM), m_v);
}


// compute coordinates and velocities of particle after one timestep using the
// boris-scheme
//
// wrapper for fortran-subroutine
void Particle::boris_step( double *bfield, double dt )
{
    boris_step_fortran( m_r, m_v, m_q, m_m, dt, bfield );
}
