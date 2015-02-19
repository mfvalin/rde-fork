## ====================================================================
## File: $(shell rdevar rdeinc)/Makefile.build.mk
##

SHELL = /bin/bash

## ==== Basic definitions

BUILD    := $(ROOT)/$(shell rdevar build)
BUILDMOD := $(ROOT)/$(shell rdevar build/mod)
BUILDLIB := $(ROOT)/$(shell rdevar build/lib)
BUILDSRC := $(ROOT)/$(shell rdevar build/src)
BUILDPRE := $(ROOT)/$(shell rdevar build/pre)
BUILDBIN := $(ROOT)/$(shell rdevar build/pre)

VPATH    := $(ROOT)/$(shell rdevar build/src)
SRCPATH  := $(shell rdevar srcpath)

ifeq (,$(rde))
   $(error FATAL ERROR: rde is not defined)
endif
ifeq (,$(ROOT))
   $(error FATAL ERROR: ROOT is not defined)
endif
ifeq ($(ROOT),$(BUILD))
   $(error FATAL ERROR: BUILD == ROOT)
endif
# ifeq (,$(VPATH))
#    $(error FATAL ERROR: VPATH is not defined)
# endif

VERBOSE := -v
ifneq (,$(findstring s,$(MAKEFLAGS)))
VERBOSE := 
endif
#ifneq (,$(findstring d,$(MAKEFLAGS)))
#DEBUGMAKE := --debug
#endif
ifeq (,$(VERBOSE))
.SILENT:
endif

CPP = /lib/cpp
# ASFLAGS =  
# DOC =
AR = r.ar -arch $(ARCH)

## ==== Legacy
EC_MKL = $(RDE_MKL)

FORCE_RMN_VERSION_RC = 
RMN_VERSION = rmn_015.1$(FORCE_RMN_VERSION_RC)

LIBPATH = $(PWD) $(LIBPATH_PRE) $(BUILDLIB) $(LIBPATHEXTRA) $(LIBSYSPATHEXTRA) $(LIBPATHOTHER) $(LIBPATH_POST)
#LIBAPPL = $(LIBS_PRE) $(LIBLOCAL) $(LIBOTHERS) $(LIBEXTRA) $(LIBS_POST)
LIBAPPL = $(LIBS_PRE) $(LIBOTHERS) $(LIBEXTRA) $(LIBS_POST)
LIBSYS  = $(LIBSYS_PRE) $(LIBSYSOTHERS) $(LIBSYSEXTRA) $(LIBSYS_POST)

## ==== Compiler/linker options
OPTIL  := 2
OMP    := -openmp
MPI    := -mpi
#DEBUG  := -debug
#PROFIL := -prof
#SHARED_O_DYNAMIC := -dynamic
#SHARED_O_DYNAMIC := -shared

## Compiler
#MODEL: MODEL_FFLAGS, MODEL_CFLAGS, MODEL_CPPFLAGS
#USER:  FFLAGS, CFLAGS, CPPFLAGS

RDE_FFLAGS = $(OMP) $(MPI) -O $(OPTIL) $(DEBUG) $(SHARED_O_DYNAMIC) $(PROFIL) $(RDE_FFLAGS_ARCH) $(RDE_FFLAGS_COMP)
RDE_CFLAGS = $(OMP) $(MPI) -O $(OPTIL) $(DEBUG) $(SHARED_O_DYNAMIC) $(PROFIL) $(RDE_CFLAGS_ARCH) $(RDE_CFLAGS_COMP)

MODEL_FFLAGS1  = $(MODEL_FFLAGS) $(MODEL1_FFLAGS) $(MODEL2_FFLAGS) $(MODEL3_FFLAGS) $(MODEL4_FFLAGS) $(MODEL5_FFLAGS)
MODEL_CFLAGS1  = $(MODEL_CFLAGS) $(MODEL1_CFLAGS) $(MODEL2_CFLAGS) $(MODEL3_CFLAGS) $(MODEL4_CFLAGS) $(MODEL5_CFLAGS)
MODEL_CPPFLAGS1= $(MODEL_CPPFLAGS) $(MODEL1_CPPFLAGS) $(MODEL2_CPPFLAGS) $(MODEL3_CPPFLAGS) $(MODEL4_CPPFLAGS) $(MODEL5_CPPFLAGS)

RDEALL_FFLAGS = $(RDE_FFLAGS) $(MODEL_FFLAGS1) $(FFLAGS) $(RDE_OPTF_MODULE) $(COMPF) $(FCOMPF)
RDEALL_CFLAGS = $(RDE_CFLAGS) $(MODEL_CPPFLAGS1) $(MODEL_CFLAGS1) $(CPPFLAGS) $(CFLAGS) $(COMPF) $(CCOMPF)

## Linker
#MODEL: MODEL_LFLAGS
#USER:  LFLAGS

RDE_LFLAGS       = $(OMP) $(MPI) $(DEBUG) $(SHARED_O_DYNAMIC) $(PROFIL) $(RDE_LFLAGS_ARCH) $(RDE_LFLAGS_COMP)
RDE_LFLAGS_NOMPI = $(OMP) $(DEBUG) $(SHARED_O_DYNAMIC) $(PROFIL) $(RDE_LFLAGS_ARCH) $(RDE_LFLAGS_COMP)

MODEL_LFLAGS1    = $(MODEL_LFLAGS) $(MODEL1_LFLAGS) $(MODEL2_LFLAGS) $(MODEL3_LFLAGS) $(MODEL4_LFLAGS) $(MODEL5_LFLAGS)

RDEALL_LFLAGS       = $(RDE_LFLAGS) $(MODEL_LFLAGS1) $(LFLAGS)
RDEALL_LFLAGS_NOMPI = $(RDE_LFLAGS_NOMPI) $(MODEL_LFLAGS1) $(LFLAGS)

## ==== Defines
#MODEL: MODEL_DEFINE
#USER:  DEFINE

RDE_DEFINES   = $(RDE_DEFINES_ARCH) $(RDE_DEFINES_COMP)

MODEL_DEFINE1 = $(MODEL_DEFINE) $(MODEL1_DEFINE) $(MODEL2_DEFINE) $(MODEL3_DEFINE) $(MODEL4_DEFINE) $(MODEL5_DEFINE)

# RDEALL_DEFINES_NAMES = $(RDE_DEFINES) $(MODEL_DEFINE1) $(DEFINE)
# RDEALL_DEFINES       = $(foreach item,$(RDEALL_DEFINES_NAMES),-D$(item))
RDEALL_DEFINES       = $(RDE_DEFINES) $(MODEL_DEFINE1) $(DEFINE)

## ==== Includes
#MODEL: MODEL_INCLUDE_PRE MODEL_INCLUDE MODEL_INCLUDE_POST
#USER:  INCLUDES_PRE INCLUDES INCLUDES_POST

RDE_INCLUDE0 := $(shell rdevar rdeinc)
RDE_INCLUDE_MOD = "$(BUILDMOD)"
RDE_INCLUDE     = $(RDE_INCLUDE_COMP) $(RDE_INCLUDE_ARCH) $(RDE_INCLUDE0) $(PWD) $(RDE_INCLUDE_MOD)

INCLUDES1      = $(INCLUDES_PRE) $(INCLUDES) $(INCLUDES_POST)
RDE_INCLUDE1   = $(RDE_INCLUDE_PRE) $(RDE_INCLUDE) $(RDE_INCLUDE_POST)
MODEL_INCLUDE1 = $(MODEL_INCLUDE_PRE) $(MODEL_INCLUDE) $(MODEL1_INCLUDE) $(MODEL2_INCLUDE) $(MODEL3_INCLUDE) $(MODEL4_INCLUDE) $(MODEL5_INCLUDE) $(MODEL_INCLUDE_POST)

RDEALL_INCLUDE_NAMES = $(INCLUDES1) $(MODEL_INCLUDE1) $(RDE_INCLUDE1)
RDEALL_INCLUDES      = $(foreach item,$(RDEALL_INCLUDE_NAMES),-I$(item))

## ==== Libpath
#MODEL: MODEL_LIBPATH_PRE MODEL_LIBPATH MODEL_LIBPATH_POST
#USER:  LIBPATH_PRE LIBPATH_USER LIBPATH_POST
#LEGACY:LIBDIR LIBPATHEXTRA LIBSYSPATHEXTRA LIBPATHOTHER

RDE_LIBPATH_LEGACY = $(LIBDIR) $(LIBPATHEXTRA) $(LIBSYSPATHEXTRA) $(LIBPATHOTHER)
RDE_LIBPATH        = $(RDE_LIBPATH_COMP) $(RDE_LIBPATH_ARCH) $(PWD) $(BUILDLIB) $(RDE_LIBPATH_LEGACY)

LIBPATH1       = $(LIBPATH_PRE) $(LIBPATH_USER) $(LIBPATH_POST)
RDE_LIBPATH1   = $(RDE_LIBPATH_PRE) $(RDE_LIBPATH) $(RDE_LIBPATH_POST)
MODEL_LIBPATH1 = $(MODEL_LIBPATH_PRE) $(MODEL_LIBPATH)  $(MODEL1_LIBPATH)  $(MODEL2_LIBPATH)  $(MODEL3_LIBPATH)  $(MODEL4_LIBPATH)  $(MODEL5_LIBPATH) $(MODEL_LIBPATH_POST)

RDEALL_LIBPATH_NAMES = $(LIBPATH1) $(MODEL_LIBPATH1) $(RDE_LIBPATH1)
RDEALL_LIBPATH       = $(foreach item,$(RDEALL_LIBPATH_NAMES),-L$(item))

## ==== Libs
#MODEL: MODEL_LIBPRE MODEL_LIBAPPL MODEL_LIBPOST
#       MODEL_LIBSYSPRE MODEL_LIBSYS MODEL_LIBSYSPOST
#USER:  LIBS_PRE LIBAPPL LIBS_POST LIBRMN LIBSYS_PRE LIBSYS LIBSYS_POST
#LEGACY:RMN_VERSION LIBOTHERS LIBSYSUTIL LIBSYSEXTRA, CODEBETA
#       LIBCOMM LIBVGRID LIBEZSCINT LIBUTIL 
#       LIBMASS LAPACK BLAS RTOOLS BINDCPU LIBHPCSPERF LLAPI IBM_LD
#       LIBHPC LIBPMAPI

LIBOTHERS          = $(LIBCOMM) $(LIBVGRID) $(LIBEZSCINT) $(LIBUTIL)
RDE_LIBAPPL_LEGACY = $(LIBOTHERS)
RDE_LIBAPPL1       = $(RDE_LIBAPPL) $(RDE_LIBAPPL_LEGACY)

LIBSYSUTIL         = $(LIBMASS) $(LAPACK) $(BLAS) $(RTOOLS) $(BINDCPU)  $(LIBHPCSPERF) $(LLAPI) $(IBM_LD)
LIBSYSEXTRA        = $(LIBHPC) $(LIBPMAPI)
RDE_LIBSYS_LEGACY  = $(LIBSYSUTIL) $(LIBSYSEXTRA)
RDE_LIBSYS         = $(RDE_LIBSYS_LEGACY) $(LIBSYSUTIL) 

RDEALL_LIBAPPL_PRE  = $(LIBS_PRE) $(MODEL_LIBPRE) $(RDE_LIBPRE)
RDEALL_LIBAPPL_POST = $(LIBS_POST) $(MODEL_LIBPOST) $(RDE_LIBPOST)
RDEALL_LIBAPPL      =  $(RDEALL_LIBAPPL_PRE) $(LIBAPPL) $(MODEL_LIBAPPL) $(MODEL5_LIBAPPL) $(MODEL4_LIBAPPL) $(MODEL3_LIBAPPL) $(MODEL2_LIBAPPL) $(MODEL1_LIBAPPL) $(RDE_LIBAPPL1) $(RDEALL_LIBAPPL_POST)

LIBRMN           = $(RMN_VERSION)

RDEALL_LIBSYS_PRE   = $(LIBSYS_PRE) $(MODEL_LIBSYSPRE) $(RDE_LIBSYSPRE)
RDEALL_LIBSYS_POST  = $(LIBSYS_POST) $(MODEL_LIBSYSPOST) $(RDE_LIBSYSPOST)
RDEALL_LIBSYS       = $(RDEALL_LIBSYS_PRE) $(LIBSYS) $(MODEL_LIBSYS) $(MODEL5_LIBSYS) $(MODEL4_LIBSYS) $(MODEL3_LIBSYS) $(MODEL2_LIBSYS) $(MODEL1_LIBSYS) $(RDE_LIBSYS) $(RDEALL_LIBSYS_POST)

RDEALL_LIBS_NAMES = $(RDEALL_LIBAPPL) $(LIBRMN) $(RDEALL_LIBSYS)
RDEALL_LIBS       = $(foreach item,$(RDEALL_LIBS_NAMES),-l$(item))

## ==== Constants for Makefile.dep.$(BASE_ARCH).mk

## all libs tagets have a dependency on LIBDEP_ALL
LIBDEP_ALL =  Makefile.dep.$(BASE_ARCH).mk
## Local Libraries are created in LIBDIR
LIBDIR = $(BUILDLIB)
## Local Abs are created in BINDIR
BINDIR = $(BUILDBIN)

## ==== Pkg Building Macros

rdeuc = $(shell echo $(1) | tr 'a-z' 'A-Z')

LIB_template1 = \
$$(LIBDIR)/lib$(1)_$$($(2)_VERSION).a: $$(OBJECTS_$(1)) ; \
rm -f $$@ $$@_$$$$$$$$; \
ar r $$@_$$$$$$$$ $$(OBJECTS_$(1)); \
mv $$@_$$$$$$$$ $$@

LIB_template2 = \
$$(LIBDIR)/lib$(1).a: $$(LIBDIR)/lib$(1)_$$($(2)_VERSION).a ; \
cd $$(LIBDIR) ; \
rm -f $$@ ; \
ln -s lib$(1)_$$($(2)_VERSION).a $$@

## ==== Arch specific and Local/user definitions, targets and overrides

ifneq (,$(wildcard $(ROOT)/Makefile.rules.mk))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/Makefile.rules.mk)
   endif
   include $(ROOT)/Makefile.rules.mk
endif

ifneq (,$(wildcard $(RDE_INCLUDE0)/$(BASE_ARCH)/Makefile.arch.mk))
   ifneq (,$(DEBUGMAKE))
      $(info include $(RDE_INCLUDE0)/$(BASE_ARCH)/Makefile.arch.mk)
   endif
   include $(RDE_INCLUDE0)/$(BASE_ARCH)/Makefile.arch.mk
endif
ifneq (,$(wildcard $(RDE_INCLUDE0)/$(EC_ARCH)/Makefile.arch.mk))
   ifneq (,$(DEBUGMAKE))
      $(info include $(RDE_INCLUDE0)/$(EC_ARCH)/Makefile.arch.mk)
   endif
   include $(RDE_INCLUDE0)/$(EC_ARCH)/Makefile.arch.mk
endif

#LOCALMAKEFILES := $(foreach mydir,$(SRCPATH),$(shell if [[ -f $(mydir)/Makefile.local.mk ]] ; then echo $(mydir)/Makefile.local.mk ; fi))
LOCALMAKEFILES0 := $(foreach mydir,$(SRCPATH),$(mydir)/Makefile.local.mk $(mydir)/$(BASE_ARCH)/Makefile.arch.mk $(mydir)/$(EC_ARCH)/Makefile.arch.mk $(mydir)/$(EC_ARCH)/Makefile.comp.mk)
LOCALMAKEFILES  := $(wildcard $(LOCALMAKEFILES0))
ifneq (,$(LOCALMAKEFILES))
   ifneq (,$(DEBUGMAKE))
      $(info include $(LOCALMAKEFILES))
   endif
   include $(LOCALMAKEFILES)
endif

#Override model's components Makefile.local.mk LCLPO=malib$(EC_ARCH)
LCLPO = .

ifneq (,$(wildcard $(ROOT)/Makefile.dep.$(BASE_ARCH).mk))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/Makefile.dep.$(BASE_ARCH).mk)
   endif
   include $(ROOT)/Makefile.dep.$(BASE_ARCH).mk
endif

ifneq (,$(wildcard $(ROOT)/Makefile.user.mk))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/Makefile.user.mk)
   endif
   include $(ROOT)/Makefile.user.mk
endif
ifneq (,$(wildcard $(ROOT)/Makefile.user.$(COMP_ARCH).mk))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/Makefile.user.$(COMP_ARCH).mk )
   endif
   include $(ROOT)/Makefile.user.$(COMP_ARCH).mk
endif

## ==== Targets

.DEFAULT: 
	@rdeco -q $@ || true

.PHONY: objexp #TODO

#Produire les objets de tous les fichiers de l'experience qu'ils soient checkout ou non
objexp: objects
objects: $(OBJECTS)

# genlib: $(OBJECTS)
# #Creer une programmatheque ayant pour nom $MALIB et incluant TOUS les fichiers objets
# majlib: objloc
# #Mise a jour de la programmatheque $MALIB a partir de tous les fichers .o affectes par les dernieres modifications
# qmajlib: qobj
# #Mise a jour de la programmatheque $MALIB a partir de tous les fichers .o presents dans le repertoire courant
# libexp: sortirtout objexp
# #Mettre tous les objets de l experience en cours dans la programmatheque $MALIB
# extractall:

# lib: Makefile.dep.$(BASE_ARCH).mk $(OBJECTS) $(ALL_LIBS)

# all: Makefile.dep.$(BASE_ARCH).mk $(OBJECTS) $(ALL_LIBS) $(ALL_BINS)
# bin: all
# bin_check: $(ALL_BINS_CHECK)

# clean0:
# 	chmod -R u+w . 2> /dev/null || true  ;\
# 	for mydir in `find . -type d` ; do \
# 		for ext in $(INCSUFFIXES) $(SRCSUFFIXES) .o .[mM][oO][dD]; do \
# 			rm -f $${mydir}/*$${ext} 2>/dev/null ;\
# 		done ;\
# 	done ;\
# 	for mydir in $(BUILDMOD) $(BUILDPRE) ; do \
# 		cd $${mydir} ;\
# 		chmod -R u+w . 2> /dev/null || true ;\
# 		`find . -type f -exec rm -f {} \; ` ;\
# 	done

# #TODO: get .o .mod from lib again after make clean?
# #TODO: should we keep .mod after make clean?

# clean:
# 	chmod -R u+w . $(BUILDMOD) $(BUILDPRE) 2> /dev/null || true ;\
# 	rm -f $(foreach mydir,. * */* */*/* */*/*/* */*/*/*/*,$(foreach exte,$(INCSUFFIXES) $(SRCSUFFIXES) .o .[mM][oO][dD],$(mydir)/*$(exte))) 2>/dev/null || true  ;\
# 	rm -f $(foreach mydir,. * */* */*/* */*/*/* */*/*/*/*,$(foreach mydir0,$(BUILDMOD) $(BUILDPRE),$(mydir0)/$(mydir)/*)) 2>/dev/null || true

# check_inc_dup: links
# 	echo "Checking for duplicated include files" ;\
# 	pfcheck_dup -r --src=$(VPATH) --ext="$(INCSUFFIXES)" . $(INCLUDES) $(EC_INCLUDE_PATH) #$(shell s.generate_ec_path --include)

## ====================================================================
