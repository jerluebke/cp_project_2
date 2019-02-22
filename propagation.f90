! TODO
! clean up this code
! consider splitting `time_step` into multiple smaller subroutines
! clean up list_t interface
! clean up lldata
!
! write small test program
! fix ll-text program
!
module propagation
    use llist
    use lldata
    use morton
    implicit none

    private

    integer(4), parameter :: d = 3
    integer(4), parameter :: box_length = 16

    ! arrays containing the coordinates of particles and relevant boxes
    ! used for interaction with python
    integer, dimension(:,:), allocatable :: particle_coords, boxes_coords

    ! linked list containing the boxes which contain particles
    type(list_t), pointer :: boxes_ll => null() 

    ! linked list as temporary storage for particles being moved between boxes
    type(list_t), pointer :: tmp_ll => null()

contains

    subroutine prop_init(n, particle_data, initial_box_coords, domain_size)
        integer, intent(in) :: n, domain_size
        real(8), dimension(d+d+2,n), intent(in) :: particle_data
        integer, dimension(d), intent(in) :: initial_box_coords

        type(box_t), target :: initial_box
        integer :: i

        initial_box = new_box(key=morton_encode(initial_box_coords), &
                              length=box_length)
        call list_init(initial_box%particles)   ! implicitly add first element as buffer

        do i=1,n
            call list_insert_data(              &
                initial_box%particles,          &
                data = transfer(new_particle(   &
                    r = particle_data(1:3,i),   &
                    v = particle_data(4:6,i),   &
                    q = particle_data(5,i),     &
                    m = particle_data(6,i)      &
                ), list_data))
        end do

        call list_init(boxes_ll)    ! implicitly add first element as buffer (data .eq. null)
        call list_insert_data(boxes_ll, data=transfer(initial_box, list_data))
        call list_init(tmp_ll)

        allocate(particle_coords(d,n))
        allocate(boxes_coords(d,domain_size))
    end subroutine prop_init


    subroutine time_step()
        ! current pointers
        type(list_t), pointer :: c_box_p, c_part_p, c_part_prev, tmp_part
        type(box_t) :: c_box
        type(particle_t) :: c_part
        integer :: i, n(3)

        c_box_p => boxes_ll%next    ! first element is buffer
        do while (associated(c_box_p))  ! box loop
            ! compute b-field

            c_box = transfer(c_box_p%data, c_box)
            c_part_prev => c_box%particles
            c_part_p => c_part_prev%next    ! first element is buffer
            do while (associated(c_part_p)) ! particle loop
                c_part = transfer(c_part_p%data, c_part)
                call boris_step(c_part)     ! do time step

                do i=1,d    ! bound check loop
                    select case (int(c_part%r(i)))
                        case ( : 0)
                            n(i) = -1
                            c_part%r(i) = c_part%r(i) + box_length
                        case (1 : box_length)
                            n(i) = 0
                        case (box_length+1 : )
                            n(i) = 1
                            c_part%r(i) = c_part%r(i) - box_length
                    end select
                end do

                if (any(n .ne. 0)) then ! move particle
                    tmp_part => list_pop_next(c_part_prev)
                    tmp_part%key = morton_neighbour(c_part_p%key, n)
                    ! TODO: insert sorted according to its morton key
                    call list_insert_node(tmp_ll, tmp_part)
                    c_part_p => c_part_prev%next
                else
                    call list_put(c_part_p, data=transfer(c_part, list_data))
                    c_part_prev => c_part_p
                    c_part_p => c_part_p%next
                end if

            end do  ! end particle loop

            c_box_p => c_box_p%next
        end do  ! end box loop

        ! move particles from the tmp list back to the box list
        c_part_prev => tmp_ll
        c_part_p => c_part_prev%next
        do while (associated(c_part_p))
            ! TODO move each particle to the box corresponding to its morton code
            c_part_prev => c_part_p
            c_part_p => c_part_p%next
        end do

        ! write box coordinates into array, remove empty boxes
        i = 1
        boxes_coords = 0
        ! particle_coords = 0
        c_box_prev => boxes_ll
        c_box_p => c_box_prev%next
        do while (associated(c_box_p))
            j = 1
            c_box = transfer(c_box_p%data, c_box)
            ! TODO: does this make sense?
            ! c_part_p => c_box%particles%next
            ! do while (associated(c_part_p))     ! there are particles left in this box
            !     particle_coords(:,j) = c_part_p%coords
            !     c_part_p => c_part_p%next
            !     j = j + 1
            ! end do
            if (j .eq. 1) then      ! the box is empty
                call list_remove_next(c_box_prev)
            else
                particle_coords(:,i) = c_box_p%coords
            end if
            i = i + 1
            c_box_prev => c_box_p
            c_box_p => c_box_p%next
        end do
    end subroutine time_step


    subroutine cleanup
        ! TODO
    end subroutine cleanup

end module propagation

! vim: set ff=unix tw=132 sw=4 ts=4 et ic ai : 
