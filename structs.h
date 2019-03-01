#include <forward_list>
#include <cstdint>

#define DIM 3
#define N   256

#define EMPTY   1ULL << 0x3F
#define IS_SET  ~(EMPTY)

#define ARRARY_ACCESS_3D(a, x, y, z) (a)[(x) + N * (y) + N*N * (z)]

struct Particle
{
    double r[DIM], v[DIM], q, m;
};

struct Box
{
    Box(uint64_t key) : key(key) {}
    friend bool operator==(const Box& l, const Box& r) { return l.key == r.key; }
    uint64_t key;
    // double bfield[N*N*N];
    double *bfield;
    std::forward_list<Particle> particles;
};

struct Workspace
{
    std::forward_list<Box> boxes, temp;
    double *particle_coords, *box_coords;
    void advance();
};
