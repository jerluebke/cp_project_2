#pragma once

#include <vector>
#include "box_and_particle.hpp"


class Propagator
{
public:
    Propagator( double *init,
                int particle_numbers,
                int init_box_coords[DIM],
                double dt );

    void timestep();
    std::vector<int>& get_part_coords();
    std::vector<int>& get_box_coords();

private:
    size_t m_particle_numbers;
    double m_dt;
    std::list<Box> m_boxes;
    std::list<Box> m_temp;
    std::vector<int> m_particle_coords;
    std::vector<int> m_box_coords;

    void advance();
    void reinsert();
    void get_coords();
};
