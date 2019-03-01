#include <array>
#include "structs.h"

extern void boris_step(ParticleIterator p, double *bfield);
extern uint64_t morton_neighbour(uint64_t key, int idx[DIM]);
extern void compute_bfield(double *bfield);


void Workspace::advance()
{
    int i;
    std::array<int, DIM> idx;

    // iterate over all boxes
    for ( auto& box : boxes ) {

        compute_bfield(box.bfield);

        // iterate over all particles in current box
        for ( auto p_it = box.particles.begin();
                p_it != box.particles.end(); ++p_it ) {

            // advance current particle
            boris_step(p_it, box.bfield);

            // bounds check: iterate over all dimensions
            for ( i = 0; i < DIM; ++i ) {
                switch ( (int) p_it->r[i] ) {
                    case INT_MIN ... -1:    idx[i] = -1;  break;
                    case N ... INT_MAX:     idx[i] = 1;   break;
                    default: idx[i] = 0;
                }
                // compute coordinates in new box
                p_it->r[i] -= idx[i] * N;
            }

            // check if the the bounds check failed
            if ( std::any_of(idx.begin(), idx.end(),
                        [](int i){ return i != 0; }) ) {

                // compute morton key of new box
                uint64_t new_key = morton_neighbour(box.key, idx.data());
                auto temp_it = temp.begin();
                auto temp_end = temp.end();

                // find temp box with new_key
                // temp_it = std::find(temp_it, temp_end, Box(new_key));
                temp_it = std::find_if(temp_it, temp_end,
                        [new_key](Box val){ return val.key == new_key; });

                // if none was found, find empty temp box
                if ( temp_it->key != new_key ) {
                    // temp_it = std::find(temp.begin(), temp_end, Box(EMPTY));
                    temp_it = std::find_if(temp.begin(), temp_end,
                            [](Box val){ return val.key == EMPTY; });

                    // if none is empty, create new temp box
                    if ( temp_it->key != EMPTY )
                        temp_it = temp.emplace_after(temp_end, new_key);

                    // empty box was found, set its key to new_key
                    else
                        temp_it->key = new_key;
                }

                // move current particle (given by p_it) from current box to
                // temp box
                temp_it->particles.splice_after(
                        temp_it->particles.begin(),
                        box.particles,
                        p_it);
            }

        }   // end particle loop
    }   // end box loop
}


void Workspace::reinsert()
{
    // iterate over temp boxes, i.e. displaced particles
    for ( auto& temp_box : temp ) {

        // find box with same key as current temp box
        auto box_it = std::find_if(boxes.begin(), boxes.end(),
                [temp_box](Box val){ return val.key == temp_box.key; });

        // if none was found, create new box
        if ( box_it->key != temp_box.key )
            box_it = boxes.emplace_after(boxes.end(), temp_box.key);

        // move all particles from temp box to corresponding box
        box_it->particles.emplace_after(
                box_it->particles.end(),
                temp_box.particles);

        // mark temp box as empty
        temp_box.key = EMPTY;
    }

    // TODO: comparision?
    boxes.sort();
}


void Workspace::get_coords()
{

}


void Workspace::timestep()
{
    advance();
    reinsert();
    get_coords();
}
