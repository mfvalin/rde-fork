## ====================================================================
## File: LOCALBUILD/include/Makefile.base_arch.mk (AIX-powerpc7)
##
RDE_DEFINES_ARCH = -DAIX_POWERPC7
LAPACK = lapack-3.4.0
BLAS   = essl
LLAPI  = 
IBM_LD = 
LIBHPC   = hpc
LIBPMAPI = pmapi
LIBMASSWRAP =  modelutils_massvp7_wrap
LIBMASS  = $(LIBMASSWRAP) massvp7 mass
RDE_LIBPATH_ARCH = /opt/ibmhpc/ppedev.hpct/lib64

# LIBSYSOTHERS = $(LIBMASS) $(LAPACK) $(BLAS) $(RTOOLS) $(BINDCPU) $(LLAPI) $(IBM_LD) $(HPCSPERF)

# LIBSYSEXTRA = $(LIBHPC) $(LIBPMAPI)

# LIBSYSPATHEXTRA = /opt/ibmhpc/ppedev.hpct/lib64

## ====================================================================
