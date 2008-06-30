!=======================================================================
! Fiscm Polymorphic Type
! Copyright:    2008(c)
!
! THIS IS A DEMONSTRATION RELEASE. THE AUTHOR(S) MAKE NO REPRESENTATION
! ABOUT THE SUITABILITY OF THIS SOFTWARE FOR ANY OTHER PURPOSE. IT IS
! PROVIDED "AS IS" WITHOUT EXPRESSED OR IMPLIED WARRANTY.
!
! THIS ORIGINAL HEADER MUST BE MAINTAINED IN ALL DISTRIBUTED
! VERSIONS.
!
! Comments:     FISCM Polymorphic Type and associated functions
!=======================================================================

Module mod_pvar


Use gparms
Implicit None

Integer, parameter :: itype = 1
Integer, parameter :: ftype = 2
Integer, parameter :: ltype = 3
Integer, parameter :: ctype = 4


!-------------------------------------------------------
!Polymorphic Type
!-------------------------------------------------------
type pvar
  integer :: idim
  integer :: istype
  logical :: isintern
  character(len=cstr) :: varname
  character(len=cstr) :: longname
  character(len=cstr) :: units
  character(len=cstr) :: from_extern_var
  integer             :: output
  integer,  allocatable, dimension(:) :: ivar
  real(sp), allocatable, dimension(:) :: fvar
end type pvar
  
!-------------------------------------------------------
!Polymorphic Type - Node (for linked-list)
!-------------------------------------------------------
type pvar_node
  type(pvar) :: v
  type(pvar_node), pointer :: next
end type pvar_node

!-------------------------------------------------------
!Linked List of polymorphic types
!-------------------------------------------------------
type pvar_list
  type(pvar_node), pointer :: begin
end type pvar_list
  
contains

!-------------------------------------------------------
! initialize a pvar_list
!-------------------------------------------------------
function pvar_list_() result(plist)
  type(pvar_list) :: plist
  integer :: astat
  allocate(plist%begin,stat=astat)
  if(astat /= 0)then
	write(*,*)'error creating linked list of state variables'
	stop
  endif
  nullify(plist%begin%next)
end function pvar_list_

!-------------------------------------------------------
! add a new node to the list
!-------------------------------------------------------
subroutine add_pvar_node(plist,p)
  type(pvar_list) :: plist
  type(pvar)      :: p
  type(pvar_node), pointer :: plst,pnew

  write(*,*)p%idim
  plst => plist%begin
  pnew => plst%next
  do 
   if(.not.associated(pnew))then
	 write(*,*)'added a node to state var link list'
     allocate(plst%next)
     write(*,*)'allocated it',p%idim
     allocate(plst%next%v%fvar(p%idim))
     write(*,*)'allocated that'
     plst%next%v = p
     write(*,*)'did it',plst%next%v%varname
     nullify(plst%next%next)
     exit
   endif

   plst => pnew
   pnew  => pnew%next
 end do

end subroutine add_pvar_node
  
 
!-------------------------------------------------------
!Search linked-list for a particular variable by name
! and pass pointer to data
!-------------------------------------------------------
function get_pvar(plist,vname) result(p)
  type(pvar), pointer :: p
  type(pvar_list) :: plist
  character(len=*), intent(in) :: vname
  logical :: found
  type(pvar_node), pointer :: plst,pnew
  integer :: i
  found = .false.
  
  plst => plist%begin
  pnew => plst%next
  if(.not.associated(plst%next))then
	write(*,*)'plist has no nodes'
	stop
  endif
	
  
  
  do 
	if(.not.associated(plst%next)) exit
	
	if(pnew%v%varname == vname)then
      p => plst%next%v
      found = .true.
      exit
	else
	  plst => pnew
	  pnew => pnew%next
	endif

  end do

  if(.not.found)then
    write(*,*)'variable: ',trim(vname),' is not a member of state vector for group: '
    stop
  endif
  

end function get_pvar
    
End Module mod_pvar








