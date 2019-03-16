#pragma once

#include <cstdint>
#include <list>
#include "config.hpp"


#define _ARRAY_ELEMENT_4D(a, w, x, y, z, nw, nx, ny) \
    (a)[(w) + (nw) * (x) + (nw) * (nx) * (y) + (nw) * (nx) * (ny) * (z)]
#define ARRAY_ELEMENT_4D(a, c, r) \
    _ARRAY_ELEMENT_4D((a), (c), (r)[0], (r)[1], (r)[2], DIM, N, N)


struct Particle
{
    Particle( double init[2*DIM+2] );

    double m_r[DIM], m_v[DIM], m_q, m_m;

    void boris_step( double *bfield, double dt );
};


struct Box
{
    Box();
    Box( uint64_t key, int coords[DIM], bool alloc );
    ~Box();

    uint64_t m_key;
    int m_coords[DIM];
    double *m_bfield;
    std::list<Particle> m_particles;

    friend bool operator==( const Box& l, const Box& r ) {
        return l.m_key == r.m_key;
    }
    friend bool operator!=( const Box& l, const Box& r ) { return !(l == r); }
    friend bool operator< ( const Box& l, const Box& r ) {
        return l.m_key < r.m_key;
    }
    friend bool operator> ( const Box& l, const Box& r ) { return r < l; }
    friend bool operator<=( const Box& l, const Box& r ) { return !(l > r); }
    friend bool operator>=( const Box& l, const Box& r ) { return !(l < r); }

    void compute_bfield();
};

