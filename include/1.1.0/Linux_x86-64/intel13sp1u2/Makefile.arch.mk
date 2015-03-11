## ====================================================================
## File: LOCALBUILD/include/Makefile.ec_arch.mk (Linux_x86-64/intel13sp1u2)
##

#EC_MKL = -mkl
#RDE_OPTF_MODULE = -module $(BUILDMOD)
RDE_FFLAGS = -diag-disable 7713 -diag-disable 10212 -fp-model source -g -traceback
RDE_CFLAGS = -fp-model precise -g -traceback
## ====================================================================
