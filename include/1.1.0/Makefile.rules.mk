## ====================================================================
## File: $(shell rdevar rdeinc)/Makefile.rules.mk
##

SHELL = /bin/bash

## ==== Basic definitions

RDE_INCLUDE = $(shell rdevar rdeinc)

BUILDSRC := $(ROOT)/$(shell rdevar build/src)
BUILDMOD := $(ROOT)/$(shell rdevar build/mod)
BUILDPRE := $(ROOT)/$(shell rdevar build/pre)

INCSUFFIXES = $(shell rdevar rdesuffix/inc)
SRCSUFFIXES = $(shell rdevar rdesuffix/src)

.SUFFIXES :
.SUFFIXES : $(INCSUFFIXES) $(SRCSUFFIXES) .o 


SHELL = /bin/sh
CPP = /lib/cpp
# COMPILE = compile
# DEFINE =  
# FFLAGS =  
# CFLAGS = -I$(ARMNLIB)/include
# CPPFLAGS = -I$(ARMNLIB)/include
# ASFLAGS =  
# DOC =
# LABASE = base
# MALIB =  malib.a
# IGNORE_ERRORS = set -e
# MAKE = $(IGNORE_ERRORS) ; make ARCH=$(ARCH)
AR = r.ar -arch $(ARCH)

RCOMPIL = s.compile
RBUILD  = s.compile
FCOMPF = 
CCOMPF =
COMPF = 
FC = $(RCOMPIL) -abi $(ABI)  -defines "=$(DEFINE)" -O $(OPTIL) -optf="$(FFLAGS)" $(COMPF) $(FCOMPF) -src
CC = $(RCOMPIL) -abi $(ABI)  -defines "=$(DEFINE)" -O $(OPTIL) -optc="$(CFLAGS)" $(COMPF) $(CCOMPF) -src
FTNC = $(RCOMPIL) -abi $(ABI)  -defines "=$(DEFINE)" -optf="$(FFLAGS) $(CPPFLAGS)" -P $(COMPF) $(FCOMPF) -src
PTNC = sed 's/^[[:blank:]].*PROGRAM /      SUBROUTINE /' | sed 's/^[[:blank:]].*program /      subroutine /'  > $*.f

RBUILD3MPI = \
	status=0 ;\
	.pfmakemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ; \
	$(MAKE) bidon_$${MAINSUBNAME}.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}.f90 ;\
	$(RBUILD) -obj bidon_$${MAINSUBNAME}.o -o $@ $(OMP) $(MPI) \
		-libpath $(LIBPATH) \
		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
		-librmn $(RMN_VERSION) \
		-libsys $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optf "=$(LFLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

RBUILD3NOMPI = \
	status=0 ;\
	.pfmakemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ; \
	$(MAKE) bidon_$${MAINSUBNAME}.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}.f90 ;\
	$(RBUILD) -obj bidon_$${MAINSUBNAME}.o -o $@ $(OMP) \
		-libpath $(LIBPATH) \
		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
		-librmn $(RMN_VERSION) \
		-libsys $${COMM_stubs1} $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optf "=$(LFLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

RBUILD3NOMPI_C = \
	status=0 ;\
	.pfmakemodelbidon -c $${MAINSUBNAME} > bidon_$${MAINSUBNAME}_c.c ; \
	$(MAKE) bidon_$${MAINSUBNAME}_c.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}_c.c ;\
	$(RBUILD) -obj bidon_$${MAINSUBNAME}_c.o -o $@ $(OMP) -conly \
		-libpath $(LIBPATH) \
		-libappl $(LIBS_PRE) $${LIBLOCAL} $(LIBAPPL) \
		-librmn $(RMN_VERSION) \
		-libsys $${COMM_stubs1} $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optc "=$(LCLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}_c.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

.ptn.o:
	rm -f $*.f
	$(FC) $< 

.ptn.f:
	rm -f $*.f
	$(FTNC) $<

.ftn.o:
	rm -f $*.f
	$(FC) $<
.ftn.f:
	rm -f $*.f
	$(FTNC) $<
.f90.o:
	$(FC) $<
.F90.o:
	$(FC) $<
.F95.o:
	$(FC) $<
.F03.o:
	$(FC) $<
.f.o:
	$(FC) $<
.ftn90.o:
	rm -f $*.f90
	$(FC) $<
.cdk90.o:
	$(FC) $<
.cdk90.f90:
	rm -f $*.f90
	$(FTNC) $<
.ftn90.f90:
	rm -f $*.f90
	$(FTNC) $<

.c.o:
	$(CC) $<

.s.o:
	$(AS) -c $(CPPFLAGS) $(ASFLAGS) $<


## ====================================================================
