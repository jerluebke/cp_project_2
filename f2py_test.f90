module f2py_test_module
    contains
    subroutine f2py_test_func(a, n, f)
        implicit none

        integer, intent(in) :: n
        real(8), intent(inout), dimension(n) :: a
        real(8) :: f
        external :: f

        a = f(a)
    end subroutine
end module
