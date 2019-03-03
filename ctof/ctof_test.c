#include <stdlib.h>
#include <stdio.h>
#include "config.h"

extern void ctof_array(double *arr);

void print_arr_2d(double *arr, int n, int m)
{
    for ( int i = 0; i < n; ++i )
        for ( int j = 0; j < m; ++j )
            printf("%f%s", arr[j+m*i], j == m-1 ? "\n" : ", ");
    printf("\n");
}

int main()
{
    double *a = (double *)malloc(sizeof(double)*N*N);

    for ( int i = 0; i < N*N; ++i )
        a[i] = (double) i;

    printf("in c: a = \n");
    print_arr_2d(a, N, N);

    ctof_array(a);

    printf("in c: a = \n");
    print_arr_2d(a, N, N);

    free(a);

    return 0;
}
