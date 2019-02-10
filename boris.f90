module boris_module

    contains
    function cross3(a, b) result(c)
        implicit none

        real(8),dimension(3),intent(in) :: a, b
        real(8),dimension(3) :: c

        c(1) = a(2) * b(3) - a(3) * b(2)
        c(2) = a(3) * b(1) - a(1) * b(3)
        c(3) = a(1) * b(2) - a(2) * b(1)
    end function cross3

    function boris_step(r, v, Ef, Bf, q, m, dt, t) result(res)
        implicit none

        integer, parameter :: d = 3

        real(8),dimension(d),intent(inout) :: r, v
        ! real(8) :: Ef, Bf
        ! external :: Ef, Bf
        real(8),intent(in) :: q, m, dt, t

        real(8),dimension(d) :: res

        real(8) :: dtqm, a_sq
        real(8),dimension(d) :: E, B, p, v_prime

        interface
            function Ef(r, t) result(e)
                real(8),dimension(:),intent(inout) :: r
                real(8),intent(in) :: t
                real(8),dimension(3) :: e
            end function Ef
            function Bf(r, t) result(b)
                real(8),dimension(:),intent(inout) :: r
                real(8),intent(in) :: t
                real(8),dimension(3) :: b
            end function Bf
        end interface

        dtqm = q / m * dt

        r = r + 0.5d0 * dt * v
        E = Ef(r, t)
        B = Bf(r, t)
        p = 0.5d0 * dtqm * B
        a_sq = 0.25d0 * dtqm * dtqm * dot_product(B, B)
        v = v + 0.5d0 * dtqm * E
        v_prime = v + cross3(v, p)
        v = v + 2.0d0 * cross3(v_prime, p) / (1 + a_sq)
        v = v + 0.5d0 * dtqm * E
        r = r + 0.5d0 * dt * v

        res = r
    end function boris_step

end module boris_module


module field_func_module
    contains
end module field_func_module


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
        res = boris_step(r, v, Efunc, Bfunc, 1.0d0, 1.0d0, 0.1d0, t)
        print *, r
        t = t + 0.5d0 * dt
    end do

contains
    function Efunc(r, t) result(e)
        implicit none
        real(8),dimension(:),intent(inout) :: r
        real(8),intent(in) :: t
        real(8),dimension(3) :: e
        e = [0.0d0, 0.0d0, 0.0d0]
    end function Efunc

    function Bfunc(r, t) result(b)
        implicit none
        real(8),dimension(:),intent(inout) :: r
        real(8),intent(in) :: t
        real(8),dimension(3) :: b
        real(8) :: d, b0
        d = sqrt(r(1)**2 + r(2)**2)
        b0 = 1/d
        b = [-b0*r(2)/d, b0*r(1)/d, 0.5d0]
    end function Bfunc

end program test
