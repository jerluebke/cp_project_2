program llist_test
    use llist_module
    use data_module
    implicit none

    type(list_t), pointer :: la => null(), node => null()
    type(particle_t), target :: pa, pb, pc
    type(particle_ptr) :: p_ptr
    type(field_t), target :: fa, fb
    type(field_prt) :: f_ptr

    fa%particles => null()
    fb%particles => null()

    pa%r = [1.0d0, 0.0d0, 0.0d0]
    pa%v = [0.0d0, 1.0d0, 0.0d0]
    pa%q = 1.0d0
    pa%m = 1.0d0
    pb%r = [0.0d0, 1.0d0, 0.0d0]
    pb%v = [0.0d0, 0.0d0, 1.0d0]
    pb%q = 1.0d0
    pb%m = 1.0d0
    pc%r = [1.0d0, 0.0d0, 1.0d0]
    pc%v = [1.0d0, 0.0d0, 0.0d0]
    pc%q = -1.0d0
    pc%m = 10.0d0

    f_ptr%p => fa
    call list_init(la, data=transfer(f_ptr, list_data))
    print *, 'Initializing field list la with field fa'

    f_ptr%p => fb
    call list_insert_data(la, data=transfer(f_ptr, list_data))
    print *, 'Inserting field fb in list la'

    p_ptr%p => pa
    call list_init(fa%particles, data=transfer(p_ptr, list_data))
    print *, 'Initializing particle list of fa with particle at ', p_ptr%p%r

    p_ptr%p => pb
    call list_insert_data(fa%particles, data=transfer(p_ptr, list_data))
    print *, 'In fa, inserting particle at ', p_ptr%p%r

    call list_init(fb%particles)
    print *, 'Initializing particle list of fb with null'

    p_ptr%p => pc
    call list_insert_data(fb%particles, data=transfer(p_ptr, list_data))
    print *, 'In fb, inserting particle at ', p_ptr%p%r

    node => list_pop_next(fa%particles)
    f_ptr = transfer(la%next%data, f_ptr)
    call list_insert_node(f_ptr%p%particles%next, node)
    p_ptr = transfer(node%data, p_ptr)
    print *, 'Moved particle at ', p_ptr%p%r, ' from fa to fb'

    node => list_pop_next(fb%particles)

    print *, 'freeing all lists...'
    call list_free(fa%particles)
    call list_free(fb%particles)
    call list_free(la)

    if (associated(node)) then
        p_ptr = transfer(node%data, p_ptr)
        print *, 'node with particle at ', p_ptr%p%r, ' still exists!'
        deallocate(node)
    else
        print *, 'node is null'
    end if

    print *, 'terminating test program...'

end program llist_test

! vim: set ff=unix tw=132 sw=4 ts=4 et ic ai : 
