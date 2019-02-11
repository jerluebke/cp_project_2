! MODULE: boris_module
!
! compilation with f2py:
!   C:\> python -m numpy.f2py -c -m boris boris.f90 only: boris_step
!
! functions
! =========
! boris_step
! cross3
! Efield
! Bfield
module boris_module
    implicit none

    private

    public :: boris_step

contains

    ! FUNCTION: boris_step
    ! boris scheme for computing the movement of a charged particle in an
    !  electro-magnetic field.
    ! the explicit forms of the E- and B-field are given in the funcions
    !  `Efield` and `Bfield`.
    !
    ! Params
    ! ======
    ! r     :   real array, dimension(3), location (will be modified!)
    ! v     :   real array, dimension(3), velocity (will be modified!)
    ! q     :   real, charge of particle
    ! m     :   real, mass of particle
    ! dt    :   real, time step
    ! t     :   real, current time (is passed to `Efield` and `Bfield` in
    !            case of time dependance)
    !
    ! Returns
    ! =======
    ! res   :   real array, dimension(3), new location after time step
    function boris_step(r, v, q, m, dt, t) result(res)
        implicit none
        ! dimension
        integer, parameter :: d = 3
        ! arguments
        real(8), dimension(d), intent(inout) :: r, v
        real(8), intent(in)     :: q, m, dt, t
        ! result
        real(8), dimension(d)   :: res
        ! helper variables
        real(8)                 :: dtqm, a_sq
        real(8), dimension(d)   :: E, B, p, v_prime

        dtqm = q / m * dt

        ! compute half time-step with given velocity
        r = r + 0.5d0 * dt * v

        ! compute E- and B-field at new (half time-step) location
        E = Efield(r, t)
        B = Bfield(r, t)

        ! helper vector p = q*B*dt/(2*m)
        p = 0.5d0 * dtqm * B

        ! a = tan(theta/2), theta = angle(v-, v+)
        ! a_sq = a**2
        a_sq = 0.25d0 * dtqm * dtqm * dot_product(B, B)

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

        res = r
    end function boris_step


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
    function Efield(r, t) result(e)
        implicit none
        real(8),dimension(:),intent(inout) :: r
        real(8),intent(in) :: t
        real(8),dimension(3) :: e
        ! e = [0.0d0, 0.0d0, 0.0d0]
        e = e_field_const_y(r, t)
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
    function Bfield(r, t) result(b)
        implicit none
        real(8),dimension(:),intent(inout) :: r
        real(8),intent(in) :: t
        real(8),dimension(3) :: b
        ! b = zylindrical_b_field(r, t)
        ! b = b_field_magnetic_mirror(r, t)
        b = b_field_const_z(r, t)
    end function Bfield


    ! zylindrical b_field
    ! B = 1/d * e_rho, d = sqrt(x**2 + y**2)
    function b_field_zylindrical(r, t) result(b)
        implicit none
        real(8),dimension(:),intent(inout) :: r
        real(8),intent(in) :: t
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
    function b_field_magnetic_mirror(r, t) result(b)
        implicit none
        real(8), parameter :: PI = 4 * atan(1.0d0)
        real(8), dimension(3), intent(in) :: r
        real(8), intent(in) :: t
        real(8), dimension(3) :: b
        real(8) :: rho, zarg, bz, brho
        zarg = PI / 10.0d0 * r(3)
        bz = 2.0d0 - cos(zarg)**2
        rho = sqrt(r(1)**2 + r(2)**2)
        brho = -0.5d0 * (2 * cos(zarg) * sin(zarg) * PI / 10.0d0) * rho
        b = [ brho * r(1) / (rho + 1e-6), brho * r(2) / (rho + 1e6), bz ]
    end function b_field_magnetic_mirror


    ! constant b-field in z direction
    function b_field_const_z(r, t) result(b)
        implicit none
        real(8), dimension(3), intent(in) :: r
        real(8), intent(in) :: t
        real(8), dimension(3) :: b
        real(8) :: b0z = 0.1d0
        b = [ 0.0d0, 0.0d0, b0z ]
    end function b_field_const_z


    ! constant e-field in y direction
    function e_field_const_y(r, t) result(e)
        implicit none
        real(8), dimension(3), intent(in) :: r
        real(8), intent(in) :: t
        real(8), dimension(3) :: e
        real(8) :: e0y = 1.0d0
        e = [ 0.0d0, e0y, 0.0d0 ]
    end function e_field_const_y


end module boris_module


program test
    use boris_module
    ! use field_func_module
    implicit none

    integer :: i
    real(8) :: dt = 0.1d0, t = 0.0d0
    real(8),dimension(3) :: res, &
                            r = [1.0d0, 0.0d0, 0.0d0], &
                            v = [0.0d0, 1.0d0, 0.0d0]
    do i=1,100
        t = t + 0.5d0 * dt
        res = boris_step(r, v, 1.0d0, 1.0d0, 0.1d0, t)
        print *, r
        t = t + 0.5d0 * dt
    end do
end program test
