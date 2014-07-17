## ====================================================================
## File: Makefile.user.mk 
##

#VERBOSE = -v
#OPTIL   = 2
#OMP     = -openmp
#MPI     = -mpi
#FFLAGS  = '-g -C -traceback'
#CFLAGS  =
#LFLAGS  = 
#MKL     = -mkl

## Sample dummy target

.PHONY: mydummyall
mydummyall: dep objects libs allbin

## Sample abs/binary targets

MYDUMMY_DEPLIST = modelutils vgrid rpn_comm rpn_comm_stubs massv_wrap envhpcs
MYDUMMY_BINDEP  = $(addprefix $(LIBDIR)/lib,$(addsuffix .a,$(MYDUMMY_DEPLIST)))

mydummyabs: $(BINDIR)/mydummyabs.Abs
$(BINDIR)/mydummyabs.Abs: $(MYDUMMY_BINDEP)
	export ATM_MODEL_NAME=mydummy ;\
	export MAINSUBNAME=mydummy_mainsub ;\
	COMM_stubs1=rpn_comm_stubs ;\
	LIBLOCAL="modelutils" ;\
	$(RBUILD3NOMPI)

mydummyabsmpi: $(BINDIR)/mydummyabsmpi.Abs
$(BINDIR)/mydummyabsmpi.Abs: $(MYDUMMY_BINDEP)
	export ATM_MODEL_NAME=mydummy ;\
	export MAINSUBNAME=mydummy_mainsub ;\
	LIBLOCAL="modelutils" ;\
	$(RBUILD3MPI)

## Sample automated list of abs/binary targets
# 1) set MY_PROG_LIST_NOMPI, MY_PROG_LIST_MPI with the list of sub 
#    you'd like to make a program of
# 2) set dependencies in USER_DEPLIST_MPI, USER_DEPLIST_NOMPI
# 3) make mysub1.Abs #or# make my_allbin

# MY_PROG_LIST_NOMPI = mysub1 mysub2
# MY_PROG_LIST_MPI   = mympisub1 mympisub2
MY_DEPLIST_MPI   = modelutils vgrid rpn_comm massv_wrap envhpcs
MY_DEPLIST_NOMPI = $(MY_DEPLIST_MPI) rpn_comm_stubs

MY_PROG_LIST_NOMPI1 = $(addsuffix .Abs,$(MY_PROG_LIST_NOMPI))
MY_PROG_LIST_MPI1   = $(addsuffix .Abs,$(MY_PROG_LIST_MPI))
MY_PROG_LIST_NOMPI2 = $(addprefix $(BINDIR)/,$(MY_PROG_LIST_NOMPI1))
MY_PROG_LIST_MPI2   = $(addprefix $(BINDIR)/,$(MY_PROG_LIST_MPI1))
MY_BINDEP_NOMPI   = $(addprefix $(LIBDIR)/lib,$(addsuffix .a,$(MY_DEPLIST_NOMPI)))
MY_BINDEP_MPI     = $(addprefix $(LIBDIR)/lib,$(addsuffix .a,$(MY_DEPLIST_MPI)))

.PHONY: my_allbin $(MY_PROG_LIST_NOMPI1) $(MY_PROG_LIST_MPI1)
my_allbin: $(MY_PROG_LIST_NOMPI2) $(MY_PROG_LIST_MPI2)

$(foreach prog,$(MY_PROG_LIST_NOMPI1),$(eval $(prog): $(BINDIR)/$(prog)))
$(foreach prog,$(MY_PROG_LIST_MPI1),$(eval $(prog): $(BINDIR)/$(prog)))

$(MY_PROG_LIST_NOMPI2): $(MY_BINDEP_NOMPI)
	export MAINSUBNAME=$(basename $(notdir $@)) ;\
	COMM_stubs1=rpn_comm_stubs ;\
	LIBLOCAL="$(MY_DEPLIST_NOMPI)" ;\
	$(RBUILD3NOMPI) && ls -l $@
$(MY_PROG_LIST_MPI2): $(MY_BINDEP_MPI)
	export MAINSUBNAME=$(basename $(notdir $@)) ;\
	LIBLOCAL="$(MY_DEPLIST_MPI)" ;\
	$(RBUILD3MPI) && ls -l $@

## ====================================================================
