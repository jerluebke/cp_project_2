#pragma once

#include "box_and_particle.hpp"


class Propagator
{
public:
    Propagator();
    ~Propagator();

    void timestep();
    std::vector<int> get_part_coords();
    std::vector<int> get_box_coords();

private:
    double m_dt, m_tmax;
    std::forward_list<Box> m_boxes;
    std::forward_list<Box> m_temp;
    std::vector<int> m_particle_coords;
    std::vector<int> m_box_coords;

    void advance();
    void reinsert();
    void get_coords();
};
