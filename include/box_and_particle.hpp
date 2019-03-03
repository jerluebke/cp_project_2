#pragma once

#include <list>
#include "config.hpp"


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

