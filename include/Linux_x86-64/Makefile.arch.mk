## ====================================================================
## File: LOCALBUILD/include/Makefile.base_arch.mk (Linux_x86-64)
##
RDE_DEFINES_ARCH = -DLINUX_X86_64
LAPACK      = lapack
BLAS        = blas
LIBMASSWRAP =  
LIBMASS     = $(LIBMASSWRAP) massv_p4

# LIBSYSOTHERS = $(LIBMASS) $(LAPACK) $(BLAS) $(HPCSPERF)
## ====================================================================
