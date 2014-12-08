## ====================================================================
## File: LOCALBUILD/include/Makefile.ec_arch.mk (Linux_x86-64/intel13sp1u2)
##

LAPACK     = 
BLAS       = 
EC_MKL     = -mkl -fp-model precise
#RDE_OPTF_MODULE = -module $(BUILDMOD)
RDE_FFLAGS = -diag-disable 7713 -g -traceback $(EC_MKL)
## ====================================================================
