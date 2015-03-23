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
#FFLAGS  = '-g -C -traceback -warn all'
#CFLAGS  =
#LIBAPPL = 
#LIBPATH_USER = 

ifneq (,$(DEBUGMAKE))
$(info ## ==== Makefile.user.mk [END] ========================================)
endif
