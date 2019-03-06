# -*- coding: utf-8 -*-
"""python wrapper for c++ class `Propagator` using cython"""

from cpp_propagator cimport *

import cython
import numpy as np
cimport numpy as np


cdef class PyPropagator:
    """PyPropagator hold a `Propagator`-instance and wraps its `timestep`
    function, which returns the coordinates of contained particles and boxes
    (correctly reshaped) after a timestep was performed"""
    cdef Propagator *this_ptr
    cdef np.ndarray part_coords
    cdef np.ndarray box_coords

    @cython.boundscheck(False)
    @cython.wraparound(False)
    def __cinit__(self,
                  np.ndarray[double, ndim=2, mode='c'] init not None,
                  np.ndarray[int, ndim=1, mode='c'] init_box not None,
                  double dt = 0.1):
        """PyPropagator(init, init_box, dt = 0.1)

        Parameters
        ==========
        init        :   ndarray, ndim=2, c-contiguous with shape 
                        (number_of_particles, 8) holding the initial particle 
                        data
                        layout:
                            >>> [...
                                 [posx, posy, posz, vx, vy, vz, q, m],
                                 ...]

        init_box    :   ndarray, ndim=1, c-contiguous with size 3 holding the
                        coordinates of the initial box
        dt          :   double, timestep

        Methods
        =======
        timestep

        """
        a, b = init.shape[0], init.shape[1]
        if b % 8 != 0:
            raise ValueError(
                "init needs shape (a, 8), but (a, %d) was received!" % b)

        # create memoryviews of input arrays
        cdef double[::1] init_mv = init.reshape(a*b)
        cdef int[::1] init_box_mv = init_box

        # construct Propagator instance
        self.this_ptr = new Propagator(&init_mv[0], a, &init_box_mv[0], dt)
        if self.this_ptr is NULL:
            raise MemoryError


    def __dealloc__(self):
        """destructor"""
        del self.this_ptr


    @cython.boundscheck(False)
    @cython.wraparound(False)
    def timestep(self):
        """timestep()

        calls Propagators timestep to advance the particles and update the list
        organizing them, retrieves the new coordinates of particles and boxes,
        reshapes the arrays correctly.

        Parameters
        ==========
        None

        Returns
        =======
        tuple (particle_coordinates, box_coordinates)

        """
        self.this_ptr.timestep()
        self.part_coords = np.array(self.this_ptr.get_part_coords(), ndmin=2)
        self.part_coords = np.reshape(self.part_coords,
                                      (self.part_coords.size//3, 3))
        self.box_coords = np.array(self.this_ptr.get_box_coords(), ndmin=2)
        self.box_coords = np.reshape(self.box_coords,
                                     (self.box_coords.size//3, 3))
        return (self.part_coords, self.box_coords)

