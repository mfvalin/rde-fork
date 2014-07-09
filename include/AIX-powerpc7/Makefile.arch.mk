## ====================================================================
## File: LOCALBUILD/include/Makefile.base_arch.mk (AIX-powerpc7)
##

#MAKE_ARCH = $(MAKE) $(MAKEFLAGS)
#Since we force gmake we can use:
MAKE_ARCH = $(MAKE) $(MFLAGS) --no-print-directory

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

LIBSYSOTHERS     = $(LIBMASS) $(LAPACK) $(BLAS) $(RTOOLS) $(BINDCPU) $(LLAPI) $(IBM_LD) $(HPCSPERF)

LIBSYSEXTRA = $(LIBHPC) $(LIBPMAPI)

LIBSYSPATHEXTRA = /opt/ibmhpc/ppedev.hpct/lib64

## ====================================================================
