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
#MASSLIBWRAP = modelutils_massvp7_wrap
MASSLIB     = $(MASSLIBWRAP) massvp7 mass #TODO: massv?
LAPACK      = lapack_340
LIBHPC      = hpc
LIBPMAPI    = pmapi

LIBSYSOTHERS     = $(MASSLIB) $(LAPACK) $(BLAS) $(RTOOLS) $(BINDCPU) $(LLAPI) $(IBM_LD) $(HPCSPERF)

LIBSYSEXTRA = $(LIBHPC) $(LIBPMAPI)

LIBSYSPATHEXTRA = /opt/ibmhpc/ppedev.hpct/lib64

## ====================================================================
