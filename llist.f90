module llist_module
    implicit none

    private

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


    ! SUBROUTINE: list_insert
    ! take a given node `next` or allocate it newly if `next .eq. null()` and
    !   insert it after `self`.
    ! if `data` is given, put it in `next`.
    ! if `next` already has data, it will be deleted first!
    !
    ! PARAMETERS
    ! ==========
    ! self  :   pointer to list_t, node after which to insert the new node
    ! next  :   pointer to list_t, new node, might be `null()`
    ! data  :   integer array, optional, data to be stored in new node
    subroutine list_insert(self, next, data)
        type(list_t), pointer :: self, next
        integer, dimension(:), intent(in), optional :: data
        logical :: allocated_next = .false.

        ! no node was given, allocate it
        if (.not. associated(next)) then
            allocate(next)
            allocated_next = .true.
        end if

        ! insert data into next
        if (present(data)) then
            ! next already has data, deallocate it first
            if (associated(next%data)) then
                deallocate(next%data)
                nullify(next%data)
            end if
            allocate(next%data(size(data)))
            next%data = data

        ! next was newly allocated and no data was given
        else if (allocated_next) then
            nullify(next%data)
        end if

        ! insert next after self
        next%next => self%next
        self%next => next
    end subroutine list_insert


    function list_pop(self) result(data)
        type(list_t), pointer :: self, next
        integer, dimension(:), pointer :: data, ndata

        next = self%next
        ndata = next%data

        if (associated(ndata)) then
            allocate(data(size(ndata)))
            data = ndata
            deallocate(ndata)
            nullify(ndata)
        else
            nullify(data)
        end if

        self%next => next%next
        nullify(next%next)
        deallocate(next)
    end function list_pop


    function list_pop(self) result(next)
        type(list_t), pointer :: self, next
        next => self%next
        self%next => next%next
        nullify(next%next)
    end function list_pop


end module llist_module

! vim: set ff=unix tw=132 sw=4 ts=4 et ic ai :
