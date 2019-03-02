#include <algorithm>
#include "propagator.hpp"

extern uint64_t morton_neighbour( uint64_t key, int idx[DIM] );


void Propagator::advance()
{
    int idx[3] = { 0, 0, 0 };

    // iterate over all boxes
    for ( auto& box : m_boxes ) {

        box.compute_bfield();

        // iterate over all particles in current box
        for ( auto p_it = box.m_particles.begin();
                p_it != box.m_particles.end(); ++p_it ) {

            // advance current particle
            p_it->boris_step( box.m_bfield, m_dt );

            // bounds check: iterate over all dimensions
            for ( int i = 0; i < DIM; ++i ) {
                switch ( (long) p_it->m_r[i] ) {
                    case LONG_MIN ... -1:   idx[i] = -1;    break;
                    case N ... LONG_MAX:    idx[i] = 1;     break;
                    default: idx[i] = 0;
                }
                // compute coordinates in new box
                p_it->m_r[i] -= idx[i] * N;
            }

            // check if the the bounds check failed
            if ( idx[0] || idx[1] || idx[2] ) {

                // compute coordinates of new box
                for ( int j = 0; j < DIM; ++j )
                    idx[j] += box.m_coords[j];

                // compute morton key of new box
                uint64_t new_key = morton_neighbour( box.m_key, idx );
                auto temp_it = m_temp.begin();
                auto temp_end = m_temp.end();

                // find temp box with new_key
                temp_it = std::find_if( temp_it, temp_end,
                        [new_key](Box& val){ return val.m_key == new_key; } );

                // if none was found, find empty temp box
                if ( temp_it->m_key != new_key ) {
                    temp_it = std::find_if( m_temp.begin(), temp_end,
                            [](Box& val){ return val.m_key == EMPTY; } );

                    // if none is empty, create new temp box
                    if ( temp_it->m_key != EMPTY )
                        temp_it = m_temp.emplace_after( temp_end,
                                new_key, idx, false );

                    // empty box was found, set its key to new_key
                    else
                        temp_it->m_key = new_key;
                }

                // move current particle (pointed to by p_it) from current box
                // to temp box
                temp_it->m_particles.splice_after(
                        temp_it->m_particles.begin(),
                        box.m_particles,
                        p_it);
            }

        }   // end particle loop
    }   // end box loop
}


void Propagator::reinsert()
{
    // iterate over temp boxes, i.e. displaced particles
    for ( auto& temp_box : m_temp ) {

        // find box with same key as current temp box
        auto box_it = std::find( m_boxes.begin(), m_boxes.end(), temp_box );

        // if none was found, create new box
        if ( box_it->m_key != temp_box.m_key )
            box_it = m_boxes.emplace_after( m_boxes.end(),
                    temp_box.m_key, temp_box.m_coords, true );

        // move all particles from temp box to corresponding box
        box_it->m_particles.splice_after(
                box_it->m_particles.end(),
                temp_box.m_particles);

        // mark temp box as empty
        temp_box.m_key = EMPTY;
    }

    // removing empty boxes
    m_boxes.remove_if( [](Box& val){ return val.m_particles.empty(); } );

    // sort list of boxes according to their morton keys
    m_boxes.sort();
}


void Propagator::get_coords()
{
    // make sure, coordinate vectors are clear
    m_box_coords.clear();
    m_particle_coords.clear();

    for ( auto& box : m_boxes ) {
        // write coordinates of each box into corresp vector
        for ( int i = 0; i < DIM; ++i )
            m_box_coords.push_back( box.m_coords[i] );

        // iterate over particles of each box to get their coordiantes as well
        for ( auto& part : box.m_particles ) {
            for ( int j = 0; j < DIM; ++j )
                m_particle_coords.push_back( (int) part.m_r[j] );
        }
    }
}


void Propagator::timestep()
{
    advance();
    reinsert();
    get_coords();
}


std::vector<int> Propagator::get_box_coords()
{
    return m_box_coords;
}


std::vector<int> Propagator::get_part_coords()
{
    return m_particle_coords;
}
