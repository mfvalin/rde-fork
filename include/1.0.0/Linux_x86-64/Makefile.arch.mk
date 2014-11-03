## ====================================================================
## File: LOCALBUILD/include/Makefile.base_arch.mk (Linux_x86-64)
##

DEFINE = -DLINUX_X86_64

LIBMASS  = massv_wrap
LAPACK   = lapack
BLAS     = blas

LIBSYSOTHERS = $(LIBMASS) $(LAPACK) $(BLAS) $(HPCSPERF)
## ====================================================================
