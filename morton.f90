! MODULE: morton
! morton encoding in 3 dimensions
! for reference see:
!   https://www.forceflow.be/2013/10/07/morton-encodingdecoding-through-bit-interleaving-implementations/
!
! PROCEDURES
! ==========
! morton_encode
! morton_neighbour
! split3
module morton
    implicit none

    private

    public :: morton_encode, morton_neighbour


    ! MAGIC BITS (in octal representation)
    ! B: bit masks
    integer(8), dimension(6), parameter ::      &
        B = [                                   &
            int(o'7777777', 8),                 &
            int(o'370000000000177777', 8),      &
            int(o'370000037700000377', 8),      &
            int(o'100170017001700170017', 8),   &
            int(o'103030303030303030303', 8),   &
            int(o'111111111111111111111', 8)    &
        ]

    ! S: shifts
    integer, dimension(5), parameter :: S = [32, 16, 8, 4, 2]

    ! M: bit masks for neighbouring keys
    integer(8), dimension(2,3), parameter ::    &
        M = reshape([                           &
            int(o'111111111111111111111', 8),   &
            int(o'666666666666666666666', 8),   &
            int(o'222222222222222222222', 8),   &
            int(o'555555555555555555555', 8),   &
            int(o'444444444444444444444', 8),   &
            int(o'333333333333333333333', 8)    &
        ], [2, 3])


contains

    ! FUNCTION: morton_encode
    ! compute morton key from 3d coordinates (x, y, z)
    !
    ! PARAMETERS
    ! ==========
    ! coords    :   integer-array (1d, len 3)
    !
    ! RETURNS
    ! =======
    ! 64bit-integer, morton key of coords
    !
    ! NOTE: only the first 63 bits are actually in use
    function morton_encode(coords) result(key)
        integer(8), dimension(3), intent(in) :: coords
        integer(8) :: key

        key = split3(coords(1))
        key = ior(key, ishft(split3(coords(2)), 1))
        key = ior(key, ishft(split3(coords(3)), 2))
    end function morton_encode


    ! FUNCTION: split3
    ! in binary representation move bits of i three positions apart, e.g.
    !   0b000011 -> 0b001001
    !
    ! PARAMETERS
    ! ==========
    ! i     :   integer to split
    !
    ! RETURNS
    ! =======
    ! 64bit-integer
    function split3(i) result(x)
        integer(8), intent(in) :: i
        integer(8) :: x

        x = iand(i, B(1))   ! only take first 21 bits
        x = iand(ior(x, ishft(x, S(1))), B(2))
        x = iand(ior(x, ishft(x, S(2))), B(3))
        x = iand(ior(x, ishft(x, S(3))), B(4))
        x = iand(ior(x, ishft(x, S(4))), B(5))
        x = iand(ior(x, ishft(x, S(5))), B(6))
    end function split3


    ! FUNCTION: morton_neighbour
    ! compute the neighbour of key by adding/substracting 1 to/from the
    !  bit positions in key corresponding to the direction given by idx
    ! general layout: idx = [x, y, z]; x, y, z in {-1, 0, +1}
    !
    ! used equations (simplified):
    !   x+(k) = (((k & 0b001) - 1) & 0b001) | (k & 0b110)
    !   x-(k) = (((k | 0b110) - 1) & 0b001) | (k & 0b110)
    !
    ! for y use 0b010, 0b101; for z use 0b100, 0b011
    !
    ! PARAMETERS
    ! ==========
    ! key   :   64bit-integer, original morton key
    ! idx   :   integer-array (1d, len 3), direction of neighbour
    !
    ! RETURNS
    ! =======
    ! 64bit-integer, new morton key
    function morton_neighbour(key, idx) result(nk)
        integer(8), intent(in) :: key
        integer, dimension(3), intent(in) :: idx
        integer(8) :: nk

        integer :: i
        nk = key
        do i=1,3
            select case (idx(i))
            case (1)
                nk = ior(iand(ior(nk, M(2,i))+1, M(1,i)), iand(nk, M(2,i)))
            case (-1)
                nk = ior(iand(iand(nk, M(1,i))-1, M(1,i)), iand(nk, M(2,i)))
            case default
                cycle
            end select
        end do
    end function morton_neighbour


end module morton

! vim: set ff=unix tw=132 sw=4 ts=4 et ic ai :
