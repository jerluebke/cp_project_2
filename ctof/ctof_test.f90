#include "config.h"

module ctof
public
contains
subroutine ctof_array(a) bind(c)
    use iso_c_binding
    implicit none
    character(len=16) :: fmtstr = '(8(2X, F5.0))'
    real(c_double), intent(inout), dimension(N, N) :: a
    print *, "in fortran: a = "
    print fmtstr, a
    a = a**2
    print *, "in fortran: a*a = "
    print fmtstr, a
end subroutine ctof_array
end module ctof
