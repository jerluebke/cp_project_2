#pragma once

#include <cstdint>

uint64_t morton_encode( int coords[3] );
uint64_t morton_neighbour( uint64_t key, int idx[3] );

