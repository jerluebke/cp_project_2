# -*- coding: utf-8 -*-

from libcpp.vector cimport vector

cdef extern from "propagator.hpp":
    cdef cppclass Propagator:
        Propagator(double *init,
                   int particle_numbers,
                   int *init_box,
                   double dt)
        void timestep()
        vector[int]& get_part_coords()
        vector[int]& get_box_coords()
