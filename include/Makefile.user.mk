ifneq (,$(DEBUGMAKE))
$(info ## ====================================================================)
$(info ## File: Makefile.user.mk)
$(info ## )
endif

#VERBOSE = 1
#OPTIL   = 2
#OMP     = -openmp
#MPI     = -mpi
#LFLAGS = 
#ifeq (intel13sp1u2,$(CONST_RDE_COMP_ARCH))
#FFLAGS  = -C -g -traceback -warn all
#else
#FFLAGS  = -C -g -traceback
#endif
#CFLAGS  =
#LIBAPPL = 
#LIBPATH_USER = 

ifneq (,$(DEBUGMAKE))
$(info ## ==== Makefile.user.mk [END] ========================================)
endif
