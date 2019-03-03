void bfield_func( double *r, double *b )
{
    (void) r;   /* unused... */
    b[0] = b[1] = 0.0;
    b[2] = 0.1;
}
