module morton
    implicit none

    private

    integer(8), dimension(6), parameter ::  &
        B = [                               &
            ! int(z'1F FFFF', 8),
            int(o'7 777 777', 8),                   &
            ! int(z'1F 0000 0000 FFFF', 8),
            int(o'370 000 000 000 177 777', 8),     &
            ! int(z'1F 0000 FF00 00FF', 8),
            int(o'370 000 037 700 000 377', 8),     &
            ! int(z'100F 00F0 0F00 F00F', 8),
            int(o'100 170 017 001 700 170 017', 8), &
            ! int(z'10C3 0C30 C30C 30C3', 8),
            int(o'103 030 303 030 303 030 303', 8), &
            ! int(z'1249 2492 4924 9249', 8)
            int(o'111 111 111 111 111 111 111, 8'), &
        ]
    integer, dimension(5), parameter :: S = [32, 16, 8, 4, 2]
    integer(8), dimension(2,3), parameter ::        &
        M = reshape([                               &
            int(o'111 111 111 111 111 111 111', 8), &
            int(o'666 666 666 666 666 666 666', 8), &
            int(o'222 222 222 222 222 222 222', 8), &
            int(o'555 555 555 555 555 555 555', 8), &
            int(o'444 444 444 444 444 444 444', 8), &
            int(o'333 333 333 333 333 333 333', 8)  &
        ], [2, 3])


contains

    function morton_encode(coords) result(key)
        integer(8), dimension(3), intent(in) :: coords
        integer(8) :: key

        key = split3(coords(1))
        key = ior(key, ishft(split3(coords(2)), 1))
        key = ior(key, ishft(split3(coords(3)), 2))
    end function morton_encode


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
