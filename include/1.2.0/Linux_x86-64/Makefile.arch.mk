## ====================================================================
## File: LOCALBUILD/include/Makefile.base_arch.mk (Linux_x86-64)
##

DEFINE = -DLINUX_X86_64

LAPACK   = lapack
BLAS     = blas

#LIBMASS  = massv_wrap
LIBMASS = modelutils_massvp4

LIBSYSOTHERS = $(LIBMASS) $(LAPACK) $(BLAS) $(HPCSPERF)
## ====================================================================
