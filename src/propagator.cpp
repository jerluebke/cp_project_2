#include <algorithm>
#include <cassert>
#include <climits>
#include "propagator.hpp"
#include "morton.hpp"


/* Propagator
 * ==========
 *
 *
 * Constructor Parameters
 * ======================
 * init             :   double array, initial particle data
 *                      layout:
 *                          [ x1, y1, z1, vx1, vy1, vz1, q1, m1,
 *                            ...
 *                            xn, ..., mn ]
 *                      length: (2*DIM+2) * particle_numbers
 *
 * particle_numbers :   size_t, number of particles
 *
 * init_box_coords  :   int array, initial coords of the initial box
 *                      length: DIM
 *
 * dt               :   double, time step
 *
 *
 * Members
 * =======
 * m_particle_numbers   :   size_t, number of particles in system
 *
 * m_dt                 :   double, time step
 *
 * m_boxes              :   list of active Boxes
 *
 * m_temp               :   list of boxes to temporarily store displaced
 *                          particles
 *
 * m_particle_coords    :   vector<int> (1 dim) holding the coordinates of the
 *                          particles in the system (particle-reference-frame)
 *                          layout:
 *                              [ x1, y1, z1,
 *                                x2, y2, z3,
 *                                ...
 *                                xn, yn, zn ]
 *
 * m_box_coords         :   vector<int> (1 dim) holding the coordinates of
 *                          the active boxes (box-reference-frame)
 *                          layout: see `m_particle_coords`
 *
 *
 * public Methods
 * ==============
 * timestep     :   perform one timestep, call `advance`, `reinsert` and
 *                  `get_coords`
 *
 * private Methods
 * ==============
 * advance      :   advance each particle one timestep
 * reinsert     :   reinsert displaced particles into active boxes
 * get_coords   :   write coordinates from lists into vectors
 *
 */
Propagator::Propagator( double *init,
                        int particle_numbers,
                        int init_box_coords[DIM],
                        double dt )
    : m_particle_numbers( particle_numbers ), m_dt( dt )
{
    // create initial box (key will be computed from coords)
    m_boxes.emplace_back( EMPTY, init_box_coords, true );
    // create empty temp box (placeholder, list must not be empty)
    m_temp.emplace_back();

    // get reference to particle-list of first box
    auto& p_list = m_boxes.back().m_particles;
    // end pointer of `init`
    double *end = init + (2 * DIM + 2) * particle_numbers;

    // create particles from array and place in list
    while ( init != end ) {
        p_list.emplace_back( init );
        init += (2 * DIM + 2);
    }
}


/* advance
 *
 *  for each box:
 *      compute bfield
 *
 *      for each particle in box:
 *          perform boris-step
 *
 *          check wether particle went out of box
 *          if it did, compute new box
 *              if new box is out of bounds, remove particle
 *              else place particle in temp box (with new key)
 *
 *      end particle-loop
 *
 *  end box-loop
 *
 */
void Propagator::advance()
{
    int idx[3] = { 0, 0, 0 };

    // iterate over all boxes
    for ( Box& box : m_boxes ) {

        // TODO: compute b-field each time step anew or compute only once
        // (frozen flux) ?
        // box.compute_bfield();

        // iterate over all particles in current box
        for ( auto p_it = box.m_particles.begin();
                p_it != box.m_particles.end(); ++p_it ) {

            // advance current particle
            p_it->boris_step( box.m_bfield, m_dt );

            // bounds check: iterate over all dimensions
            for ( int i = 0; i < DIM; ++i ) {
                // check in which direction the current component went out of
                // bounds
                idx[i] = ( p_it->m_r[i] < 0 ) ? -1 : \
                         ( p_it->m_r[i] >= N ) ? 1 : 0;
                // compute coordinates in new box
                p_it->m_r[i] -= idx[i] * N;
            }

            // check if the the bounds check failed
            if ( idx[0] || idx[1] || idx[2] ) {

                // compute morton key of new box
                uint64_t new_key = morton_neighbour( box.m_key, idx );
                auto temp_it = m_temp.begin();

                // compute coordinates of new box
                // remove particle if new box is out of bounds
                for ( int j = 0; j < DIM; ++j ) {
                    idx[j] += box.m_coords[j];
                    if ( idx[j] < 0 || idx[j] >= M ) {
                        p_it = box.m_particles.erase( p_it );
                        --m_particle_numbers;
                        goto next;
                    }
                }

                // find temp box with new_key
                temp_it = std::find_if( temp_it, (m_temp.end())--,
                        [new_key](Box& val){ return val.m_key == new_key; } );

                // if none was found, find empty temp box
                if ( temp_it->m_key != new_key ) {
                    temp_it = std::find_if( m_temp.begin(), (m_temp.end())--,
                            [](Box& val){ return val.m_key == EMPTY; } );

                    // if none is empty, create new temp box
                    if ( temp_it->m_key != EMPTY )
                        temp_it = m_temp.emplace( m_temp.end(),
                                new_key, idx, false );

                    // empty box was found, set its key to new_key and its
                    // coordinates to newly computed coordinates
                    else {
                        temp_it->m_key = new_key;
                        std::copy( idx, idx+DIM, temp_it->m_coords );
                    }
                }

                // move current particle (pointed to by p_it) from current box
                // to temp box.
                // save temporary iterator to box.m_particles (otherwise
                // p_it points to different list).
                auto p_prev = p_it;
                --p_prev;
                temp_it->m_particles.splice(
                        temp_it->m_particles.end(),
                        box.m_particles,
                        p_it );
                p_it = ++p_prev;
            }

next:
            continue;

        }   // end particle loop
    }   // end box loop
}


/* reinsert
 *
 *  for each temp box (i.e. displaced particles)
 *      find or create active box with corresp. key
 *      move particles from temp to active box
 *  end temp-box-loop
 *
 *  remove empty active boxes
 *
 */
void Propagator::reinsert()
{
    // iterate over temp boxes, i.e. displaced particles
    for ( Box& temp_box : m_temp ) {

        if ( temp_box.m_key == EMPTY )
            continue;

        // find box with same key as current temp box
        auto box_it = std::find( m_boxes.begin(), (m_boxes.end())--, temp_box );

        // if none was found, create new box
        if ( box_it->m_key != temp_box.m_key )
            box_it = m_boxes.emplace( m_boxes.end(),
                    temp_box.m_key, temp_box.m_coords, true );

        // move all particles from temp box to corresponding box
        box_it->m_particles.splice(
                box_it->m_particles.end(),
                temp_box.m_particles );

        // mark temp box as empty
        temp_box.m_key = EMPTY;
    }

    // removing empty boxes
    m_boxes.remove_if( [](Box& box){ return box.m_particles.empty(); } );

    // sort list of boxes according to their morton keys
    // TODO: necessary?
    // m_boxes.sort();
}


/* get_coords
 *
 *  iterate over boxes and their particles
 *      write coordinates of each into corresp. vector
 *
 */
void Propagator::get_coords()
{
    m_box_coords.clear();
    m_particle_coords.resize( DIM * m_particle_numbers );

    auto part_it = m_particle_coords.begin();
#ifndef NDEBUG
    auto part_end = part_it + DIM * m_particle_numbers;
#endif

    for ( Box& box : m_boxes ) {
        // write coordinates of each box into corresp vector
        for ( int i = 0; i < DIM; ++i ) {
            // use push_back for automatic reallocation as number of boxes
            // might change
            m_box_coords.push_back( box.m_coords[i] );
        }

        // iterate over particles of each box to get their coordiantes as well
        for ( Particle& part : box.m_particles ) {
            for ( int j = 0; j < DIM; ++j ) {
                // global particle coordinates
                // write in vector using iterators as number of particles
                // should not change (perhaps decrease, if some particles went
                // out of bounds...)
                assert( part_it != part_end );
                *part_it++ = N * box.m_coords[j] + static_cast<int>( part.m_r[j] );
            }
        }
    }
}


/* timestep - public
 *
 * putting the timestep routine together:
 *  advancing particles (incl. bounds check and displacement)
 *  reinserting of displaced particles
 *  writing coordinates from lists into vectors
 *
 */
void Propagator::timestep()
{
    advance();
    reinsert();
    get_coords();
}


std::vector<int>& Propagator::get_box_coords()
{
    return m_box_coords;
}


std::vector<int>& Propagator::get_part_coords()
{
    return m_particle_coords;
}
