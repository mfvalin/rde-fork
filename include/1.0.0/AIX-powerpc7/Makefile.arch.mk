## ====================================================================
## File: LOCALBUILD/include/Makefile.base_arch.mk (AIX-powerpc7)
##

DEFINE = -DAIX_POWERPC7

LLAPI  = 
IBM_LD = 

#TODO: check if rtools and bindcpu are still useful
RTOOLS      = 
BINDCPU     = 
LIBMASSWRAP = massv_wrap
LIBMASS     = $(LIBMASSWRAP) massvp7 mass
LAPACK      = lapack_340
BLAS        = blas
LIBHPC      = hpc
LIBPMAPI    = pmapi

LIBSYSOTHERS = $(LIBMASS) $(LAPACK) $(BLAS) $(RTOOLS) $(BINDCPU) $(LLAPI) $(IBM_LD) $(HPCSPERF)

LIBSYSEXTRA = $(LIBHPC) $(LIBPMAPI)

LIBSYSPATHEXTRA = /opt/ibmhpc/ppedev.hpct/lib64

## ====================================================================
