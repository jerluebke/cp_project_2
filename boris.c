#define SQ(x) (x)*(x)

struct particle_s {
    double r[3], v[3], q, m;
};

typedef struct particle_s particle_t;

typedef double *(*field_func)(double *, double *, double);

double dot3(double *a, double *b)
{
    int i;
    double res = 0;

    for ( i = 0; i < 3; ++i )
        res += a[i] * b[i];

    return res;
}

double *boris_step(
    particle_t *part,
    double dt, double t,
    field_func E_field,
    field_func B_field )
{
    int i;
    double E[3], B[3], p[3];
    double a_sq;
    double dtqm = part->q / part->m * dt;

    for ( i = 0; i < 3; ++i )
        part->r[i] = part->r[i] + 0.5 * dt * part->v[i];

    E_field(E, part->r, t);
    B_field(B, part->r, t);

    for ( i = 0; i < 3; ++i )
        p[i] = 0.5 * dtqm * B[i];

    a_sq = 0.25 * SQ(dtqm) * dot3(B, B);

    /* for ( ) */

}
