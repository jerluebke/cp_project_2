module lldata
    use llist, only: list_t
    implicit none

    private :: d
    integer, parameter :: d = 3

    type :: particle_t
        real(8) :: r(d), v(d), q, m
    end type particle_t

    type :: box_t
        ! TODO: key here still necessary with key also in list_t?
        integer(16) :: key
        integer(4) :: length
        type(list_t), pointer :: particles
        ! TODO
        ! real(8), dimension(:,:,:), allocatable :: b_field
    end type box_t

    type :: particle_ptr
        type(particle_t), pointer :: p
    end type particle_ptr

    type :: box_ptr
        type(box_t), pointer :: p
    end type box_ptr

contains

    function new_particle(r, v, q, m) result(p)
        real(8), dimension(d), intent(in) :: r, v
        real(8), intent(in) :: q, m
        type(particle_t) :: p
        p%r = r
        p%v = v
        p%q = q
        p%m = m
    end function new_particle

    function new_box(key, length, particles) result(b)
        integer(16), intent(in) :: key
        integer(4), intent(in) :: length
        type(list_t), pointer, intent(in), optional :: particles
        type(box_t) :: b
        b%key = key
        b%length = length
        ! allocate(initial_box%b_field(length,length,length))
        ! initial_box%b_field = 0
        if (present(particles)) then
            b%particles => particles
        else
            nullify(b%particles)
        end if
    end function new_box

end module lldata

! vim: set ff=unix tw=132 sw=4 ts=4 et ic ai : 
