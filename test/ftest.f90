#include "config.hpp"

! compile with
!   C:\> gcc -I../include -E -P -cpp boris.f90 -o boris_pp.f90
!   C:\> gfortran boris_pp.f90 -o boris_test.exe
program test
    use boris_module
    implicit none

    integer :: i, j, k
    real(8),dimension(3) :: idx
    real(8) :: dt = 0.1d0
    real(8),dimension(3) :: r = [1.0d0, 1.0d0, 2.0d0], &
                            v = [0.0d0, 1.0d0, 0.0d0]
    real(8),dimension(3,N,N,N) :: b

    do i=1,N
        do j=1,N
            ! do k=1,3
                k = 2
                idx = real([i, j, k])
                b(:, i, j, k) = b_field_const_z(idx, 0d0)
            ! end do
        end do
    end do

    do i=1,100
        call boris_step_fortran(r, v, 1.0d0, 1.0d0, 0.1d0, b)
        print *, r
    end do
end program test
