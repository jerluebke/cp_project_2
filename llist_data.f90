module data_module
    use llist_module, only: list_t
    implicit none

    type :: particle_t
        real(8) :: r(3), v(3), q, m
    end type particle_t

    type :: field_t
        ! integer :: length
        type(list_t), pointer :: particles
        ! TODO
        ! double b_field(length,length,length)
    end type field_t

    type :: particle_ptr
        type(particle_t), pointer :: p
    end type particle_ptr

    type :: field_prt
        type(field_t), pointer :: p
    end type field_prt
end module data_module

! vim: set ff=unix tw=132 sw=4 ts=4 et ic ai : 
