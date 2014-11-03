## ====================================================================
## File: $(shell rdevar rdeinc)/Makefile.rules.mk
##

SHELL = /bin/bash

## ==== Basic definitions

RDE_INCLUDE = $(shell rdevar rdeinc)

#ROOT     := $(PWD)
#BUILD    := $(ROOT)/$(shell rdevar build)
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
LCLPO = .

RCOMPIL = s.compile
RBUILD  = s.compile
FCOMPF = 
CCOMPF =
COMPF = 
FC = $(RCOMPIL) -arch $(ARCH) -abi $(ABI)  -defines "=$(DEFINE)" -O $(OPTIL) -optf="$(FFLAGS)" $(COMPF) $(FCOMPF) -src
CC = $(RCOMPIL) -arch $(ARCH) -abi $(ABI)  -defines "=$(DEFINE)" -O $(OPTIL) -optc="$(CFLAGS)" $(COMPF) $(CCOMPF) -src
FTNC = $(RCOMPIL) -arch $(ARCH) -abi $(ABI)  -defines "=$(DEFINE)" -optf="$(FFLAGS) $(CPPFLAGS)" -P $(COMPF) $(FCOMPF) -src
PTNC = sed 's/^[[:blank:]].*PROGRAM /      SUBROUTINE /' | sed 's/^[[:blank:]].*program /      subroutine /'  > $*.f

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
