#include <iostream>
#include "box_and_particle.hpp"
#include "propagator.hpp"

extern "C" {
void boris_step_fortran( double r[],
                         double v[],
                         double q,
                         double m,
                         double dt,
                         double bfield[] );
}

extern void temp_bfield_func( double *b );


int main()
{
    int i;
    int coords[3] = { 0, 0, 0 };
    double init[16] = {
        // particle 1
        1.0, 1.0, 2.0,
        0.0, 1.0, 0.0,
        1.0, 1.0,

        // particle 2
        2.0, 1.0, 2.0,
        0.0, 0.0, 2.0,
        1.0, 1.0
    };

#if 1
    Particle p( &init[0] );
    Box b( EMPTY, coords, true );
    b.compute_bfield();

    std::cout << "struct Particle, 100 timesteps:\n";
    for ( i = 0; i < 100; ++i ) {
        p.boris_step( b.m_bfield, 0.1 );
        std::cout << p.m_r[0] << '\t' << p.m_r[1] << '\t' << p.m_r[2] << '\n';
    }
    std::cout << "\n===\n\n";
#endif

#if 1
    Propagator pg( init, 1, coords, 0.1 );
    std::vector<int> pc, bc;

    std::cout << "class Propagator, 100 timesteps:\n";
    std::cout << "particle 1\t|\tparticle 2\n";
    for ( i = 0; i < 100; ++i ) {
        pg.timestep();
        pc = pg.get_part_coords();
        bc = pg.get_box_coords();
        std::cout << pc[0] << '\t' << pc[1] << '\t' << pc[2] << " --- "
            << bc[0] << ' ' << bc[1] << ' ' << bc[2] << "\n";
    }
    std::cout << std::endl;
#endif

    return 0;
}
