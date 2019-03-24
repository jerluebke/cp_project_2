#include "config_pp.hpp"

! MODULE: boris_module
!
! functions
! =========
! boris_step
! cross3
! Efield
! Bfield
!
module boris_module
    implicit none

    private

    public :: boris_step_fortran, b_field_const_z

contains

    ! FUNCTION: boris_step
    ! boris scheme for computing the movement of a charged particle in an
    !  electro-magnetic field.
    ! the B-field is given explicitly in form of a 4 dimensional array 
    !  specifying the fields (vector-) values at each point of the 3
    !  dimensional grid.
    ! the E-field is given via the function `Efield` found in this module.
    !
    ! Params
    ! ======
    ! r     :   real array, dimension(3), location (will be modified!)
    ! v     :   real array, dimension(3), velocity (will be modified!)
    ! q     :   real, charge of particle
    ! m     :   real, mass of particle
    ! dt    :   real, time step
    ! bfield:   real array, dimension(N, N, N, 3), array giving the magnetic
    !            field
    !
    ! Returns
    ! =======
    ! res   :   real array, dimension(3), new location after time step
    !
    subroutine boris_step_fortran(r, v, q, m, dt, bfield_arr) bind(c)
        use iso_c_binding, only: c_double, c_int
        implicit none
        ! dimension
        integer, parameter :: d = 3
        ! arguments
        real(c_double), dimension(d), intent(inout) :: r, v
        real(c_double), intent(in), value :: q, m, dt
        real(c_double), dimension(d,N,N,N), intent(in) :: bfield_arr
        ! helper variables
        real(c_double) :: dtqm, a_sq
        real(c_double), dimension(d) :: E, B, p, v_prime
        integer(c_int), dimension(d) :: idx

        dtqm = q / m * dt

        ! compute half time-step with given velocity
        r = r + 0.5d0 * dt * v

        ! cast r to int and compute r mod N to use as indices for bfield_arr
        idx = mod(int(r), N) + 1

        ! compute E- and B-field at new (half time-step) location
#ifndef NOEFIELD
        E = Efield(r, 0.0d0)
#else
        E = 0
#endif
        ! B = Bfield(r, 0.0d0)
        B = bfield_arr(:, idx(1), idx(2), idx(3))

        ! helper vector p = q*B*dt/(2*m)
        p = 0.5d0 * dtqm * B

        ! a = tan(theta/2), theta = angle(v-, v+)
        ! a_sq = a**2
        a_sq = 0.25d0 * dtqm ** 2 * dot_product(B, B)

        ! v- = v + q*E*dt/(2*m)
        v = v + 0.5d0 * dtqm * E

        ! v_prime
        v_prime = v + cross3(v, p)

        ! v+ = v- 2*(v' x p)/(1+a**2)
        v = v + 2.0d0 * cross3(v_prime, p) / (1 + a_sq)

        ! new velocity after full time-step
        ! v = v+ + q*E*dt/(2*m)
        v = v + 0.5d0 * dtqm * E

        ! new location after full time-step
        r = r + 0.5d0 * dt * v

    end subroutine boris_step_fortran


    !===================!
    ! PRIVATE FUNCTIONS !
    !===================!

    ! FUNCTION: cross3
    ! cross product of two real vectors in R^3
    !
    ! Params
    ! ======
    ! a, b  :   real array, dimension(3)
    !
    ! Returns
    ! =======
    ! c = a x b
    !
    function cross3(a, b) result(c)
        implicit none
        real(8),dimension(3),intent(in) :: a, b
        real(8),dimension(3) :: c
        c(1) = a(2) * b(3) - a(3) * b(2)
        c(2) = a(3) * b(1) - a(1) * b(3)
        c(3) = a(1) * b(2) - a(2) * b(1)
    end function cross3


    ! FUNCTION: Efield
    ! gives e-field for use in `boris_step`
    !
    ! Params
    ! ======
    ! r     :   real array, dimension(3), location
    ! t     :   real, time
    !
    ! Returns
    ! =======
    ! E(r, t)   :   real array, dimension(3), E-field at r and t
    !
    function Efield(r, t) result(e)
        implicit none
        real(8),dimension(:),intent(inout) :: r
        real(8),intent(in) :: t
        real(8),dimension(3) :: e
        ! e = [0.0d0, 0.0d0, 0.0d0]
        e = e_field_const_y(r)
    end function Efield


    ! FUNCTION: Bfield
    ! gives b-field for use in `boris_step`
    !
    ! Params
    ! ======
    ! r     :   real array, dimension(3), location
    ! t     :   real, time
    !
    ! Returns
    ! =======
    ! B(r, t)   :   real array, dimension(3), B-field at r and t
    !
    function Bfield(r, t) result(b)
        implicit none
        real(8),dimension(:),intent(inout) :: r
        real(8),intent(in) :: t
        real(8),dimension(3) :: b
        ! b = zylindrical_b_field(r)
        ! b = b_field_magnetic_mirror(r)
        b = b_field_const_z(r)
    end function Bfield


    ! zylindrical b_field
    ! B = 1/d * e_rho, d = sqrt(x**2 + y**2)
    function b_field_zylindrical(r) result(b)
        implicit none
        real(8),dimension(:),intent(inout) :: r
        real(8),dimension(3) :: b
        real(8) :: d, b0
        d = sqrt(r(1)**2 + r(2)**2)
        b0 = 1/d
        b = [-b0*r(2)/d, b0*r(1)/d, 0.5d0]
    end function b_field_zylindrical


    ! magnetic mirror
    !
    ! condition:
    !   div B = 0 => B_rho = -rho / 2 * dB_z/dz
    !
    ! here:
    !   B_z = 2 - cos(pi*z/10)
    !   B_rho = -rho / 2 * (2 * cos(pi*z/10) * sin(pi*z/10) * pi / 10)
    !
    function b_field_magnetic_mirror(r) result(b)
        implicit none
        real(8), parameter :: PI = 4 * atan(1.0d0)
        real(8), dimension(3), intent(in) :: r
        real(8), dimension(3) :: b
        real(8) :: rho, zarg, bz, brho
        zarg = PI / 10.0d0 * r(3)
        bz = 2.0d0 - cos(zarg)**2
        rho = sqrt(r(1)**2 + r(2)**2)
        brho = -0.5d0 * (2 * cos(zarg) * sin(zarg) * PI / 10.0d0) * rho
        b = [ brho * r(1) / (rho + 1e-6), brho * r(2) / (rho + 1e6), bz ]
    end function b_field_magnetic_mirror


    ! constant b-field in z direction
    function b_field_const_z(r) result(b)
        implicit none
        real(8), dimension(3), intent(in) :: r
        real(8), dimension(3) :: b
        real(8) :: b0z = 0.1d0
        b = [ 0.0d0, 0.0d0, b0z ]
    end function b_field_const_z


    ! constant e-field in y direction
    function e_field_const_y(r) result(e)
        implicit none
        real(8), dimension(3), intent(in) :: r
        real(8), dimension(3) :: e
        real(8) :: e0y = 1.0d0
        e = [ 0.0d0, e0y, 0.0d0 ]
    end function e_field_const_y


end module boris_module

