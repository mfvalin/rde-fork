## ====================================================================
## File: LOCALBUILD/include/Makefile.ec_arch.mk (Linux_x86-64/intel13sp1u2)
##
LAPACK  = 
BLAS    = 
RDE_MKL      = -mkl
RDE_FP_MODEL = -fp-model source
#RDE_OPTF_MODULE = -module $(BUILDMOD)
RDE_INTEL_DIAG_DISABLE = -diag-disable 7713 -diag-disable 10212
RDE_FFLAGS_COMP = $(RDE_INTEL_DIAG_DISABLE) $(RDE_MKL) $(RDE_FP_MODEL)
RDE_CFLAGS_COMP = $(RDE_INTEL_DIAG_DISABLE) $(RDE_MKL) $(RDE_FP_MODEL)
RDE_LFLAGS_COMP = $(RDE_INTEL_DIAG_DISABLE) $(RDE_MKL) $(RDE_FP_MODEL)
## ====================================================================
