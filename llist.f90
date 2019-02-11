! MODULE: llist
! simple linked list implementation taken from
!   http://fortranwiki.org/fortran/show/gen_list
! and slightly modified
!
! PUBLIC VARIABLES
! ================
! list_data
!
! TYPES
! =====
! list_t
!
! PROCEDURES
! ==========
! list_init
! list_free
! list_insert_data
! list_insert_node
! list_pop_next
! list_remove_next
! 
module llist
    implicit none

    ! public variable for casting an argument of arbitrary type to list_t's 
    ! data member, i.e. use as `mold` for the intrinsic function `transfer()`
    integer, dimension(:), allocatable :: list_data


    ! TYPE: list_t
    ! a single node of the linked list
    !
    ! MEMBERS
    ! =======
    ! data  :   pointer to integer array holding the nodes data
    ! next  :   pointer to list_t, the next node in the linked list
    type :: list_t
        integer(16) :: key
        integer :: coords(3)
        integer, dimension(:), pointer :: data => null()
        type(list_t), pointer :: next => null()
    end type list_t

contains

    ! SUBROUTINE: list_init
    ! initialize head node `self` with optional `data`
    !
    ! PARAMETERS
    ! ==========
    ! self  :   pointer to list_t, head node of new list
    ! data  :   integer array, optional, data to be stored in self
    subroutine list_init(self, data)
        type(list_t), pointer :: self
        integer, dimension(:), intent(in), optional :: data

        allocate(self)
        nullify(self%next)

        if (present(data)) then
            allocate(self%data(size(data)))
            self%data = data
        else
            nullify(self%data)
        end if
    end subroutine list_init


    ! SUBROUTINE: list_free
    ! free enitre list (including its data) with head node self
    !
    ! PARAMETERS
    ! ==========
    ! self  :   pointer to list_t, head node of list to be freed
    subroutine list_free(self)
        type(list_t), pointer :: self, current, next

        current => self
        do while (associated(current))
            next => current%next
            if (associated(current%data)) then
                deallocate(current%data)
                nullify(current%data)
            end if
            deallocate(current)
            nullify(current)
            current => next
        end do
    end subroutine list_free


    ! SUBROUTINE: list_insert_data
    ! create a new node with `data` (if present) and insert it after `self`
    ! 
    ! PARAMETERS
    ! ==========
    ! self  :   pointer to list_t, node after which to insert the new node
    ! data  :   integer array, optional, data to be stored in new node
    subroutine list_insert_data(self, data)
        type(list_t), pointer :: self
        integer, dimension(:), intent(in), optional :: data
        type(list_t), pointer :: next

        allocate(next)

        if (present(data)) then
            allocate(next%data(size(data)))
            next%data = data
        else
            nullify(next%data)
        end if

        next%next => self%next
        self%next => next
    end subroutine list_insert_data


    ! SUBROUTINE: list_insert_node
    ! insert a node (which must not be null!) after `self`
    !
    ! PARAMETERS
    ! ==========
    ! self  :   pointer to list_t, node after which to insert the new node
    ! next  :   pointer to list_t, new node which is to be inserted
    !           MUST NOT BE NULL
    subroutine list_insert_node(self, next)
        type(list_t), pointer :: self, next
        next%next => self%next
        self%next => next
    end subroutine list_insert_node


    ! FUNCTION: list_pop_next
    ! remove node after `self` from list and return it
    !
    ! PARAMETERS
    ! ==========
    ! self  :   pointer to list_t
    !
    ! RETURNS
    ! =======
    ! next  :   pointer to list_t, node after `self`
    function list_pop_next(self) result(next)
        type(list_t), pointer :: self, next

        next => self%next
        if (associated(next)) then
            self%next => next%next
            nullify(next%next)
        else
            nullify(self%next)
        end if
    end function list_pop_next


    ! SUBROUTINE: list_remove_next
    ! deallocate and nullify node after `self` and its data (if present)
    !
    ! PARAMETERS
    ! ==========
    ! self  :   pointer to list_t, self%next will be removed
    subroutine list_remove_next(self)
        type(list_t), pointer :: self, next

        next => self%next
        if (associated(next)) then
            self%next => next%next
            if (associated(next%data)) then
                deallocate(next%data)
                nullify(next%data)
            end if
            deallocate(next)
            nullify(next)
        end if
    end subroutine list_remove_next


    ! SUBROUTINE: list_put
    ! store `data` in node `self`
    !
    ! PARAMETERS
    ! ==========
    ! self  :   pointer to list_t, node in which to store the data
    ! data  :   interger array, data to be stored in given node
    subroutine list_put(self, data)
        type(list_t), pointer :: self
        integer, dimension(:), intent(in) :: data

        if (associated(self%data)) then
            deallocate(self%data)
            nullify(self%data)
        end if
        self%data = data
    end subroutine


end module llist

! vim: set ff=unix tw=132 sw=4 ts=4 et ic ai :
