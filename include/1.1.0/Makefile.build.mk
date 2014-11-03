## ====================================================================
## File: $(shell rdevar rdeinc)/Makefile.build.mk
##

SHELL = /bin/bash

## ==== Basic definitions

RDE_INCLUDE = $(shell rdevar rdeinc)

#ROOT     := $(PWD)
BUILD    := $(ROOT)/$(shell rdevar build)
#BUILDSRC = $(ROOT)/$(shell rdevar build/src)
#BUILDBIN := $(ROOT)/$(shell rdevar build/bin)
#BUILDLIB := $(ROOT)/$(shell rdevar build/lib)
BUILDMOD := $(ROOT)/$(shell rdevar build/mod)
#BUILDPRE := $(ROOT)/$(shell rdevar build/pre)
#BINDIR   := $(BUILDBIN)
VPATH     = $(ROOT)/$(shell rdevar build/src)
SRCPATH   = $(shell rdevar srcpath)

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

OPTIL  = 2
OMP    = -openmp
MPI    = -mpi

LFLAGS = $(OMP) $(EC_MKL)

#BLAS     = blas
FORCE_RMN_VERSION_RC = 
RMN_VERSION = rmn_015$(FORCE_RMN_VERSION_RC)

#INCLUDES = $(shell .pfdir_with_files -n $(VPATH))
#INCLUDES = $(shell find $(VPATH) -type d |tr '\n' ' ')
#INCLUDES = $(shell find $(VPATH) -type d |tr '\n' ' ' | grep '/include')
#TODO: INCLUDE only /include when code is clean from cross dir includes

INCLUDE_PATH=". $(INCLUDES)"
INCLUDE_MOD="$(BUILDMOD)"

LIBDIR = $(BUILDLIB)
BINDIR = $(BUILDBIN)
LIBDEP_ALL =  Makefile.dep.mk

LIBPATH = $(PWD) $(LIBPATH_PRE) $(BUILDLIB) $(LIBPATHEXTRA) $(LIBSYSPATHEXTRA) $(LIBPATHOTHER) $(LIBPATH_POST)
#LIBAPPL = $(LIBS_PRE) $(LIBLOCAL) $(LIBOTHERS) $(LIBEXTRA) $(LIBS_POST)
LIBAPPL = $(LIBS_PRE) $(LIBOTHERS) $(LIBEXTRA) $(LIBS_POST)
LIBSYS  = $(LIBSYS_PRE) $(LIBSYSOTHERS) $(LIBSYSEXTRA) $(LIBSYS_POST)

## ==== Arch specific and Local/user definitions, targets and overrides

ifneq (,$(wildcard $(RDE_INCLUDE)/Makefile.rules.mk))
   $(info include $(RDE_INCLUDE)/Makefile.rules.mk)
   include $(RDE_INCLUDE)/Makefile.rules.mk
endif

ifneq (,$(wildcard $(RDE_INCLUDE)/$(BASE_ARCH)/Makefile.base_arch.mk))
   $(info include $(RDE_INCLUDE)/$(BASE_ARCH)/Makefile.base_arch.mk)
   include $(RDE_INCLUDE)/$(BASE_ARCH)/Makefile.base_arch.mk
endif
ifneq (,$(wildcard $(RDE_INCLUDE)/$(EC_ARCH)/Makefile.ec_arch.mk))
   $(info include $(RDE_INCLUDE)/$(EC_ARCH)/Makefile.ec_arch.mk)
   include $(RDE_INCLUDE)/$(EC_ARCH)/Makefile.ec_arch.mk
endif

#LOCALMAKEFILES := $(foreach mydir,$(SRCPATH),$(shell if [[ -f $(mydir)/Makefile.local.mk ]] ; then echo $(mydir)/Makefile.local.mk ; fi))
LOCALMAKEFILES0 := $(foreach mydir,$(SRCPATH),$(mydir)/Makefile.local.mk)
LOCALMAKEFILES  := $(wildcard $(LOCALMAKEFILES0))
ifneq (,$(LOCALMAKEFILES))
   $(info include $(LOCALMAKEFILES))
   include $(LOCALMAKEFILES)
endif

ifneq (,$(wildcard $(ROOT)/Makefile.dep.mk))
   $(info include $(ROOT)/Makefile.dep.mk)
   include $(ROOT)/Makefile.dep.mk
endif

ifneq (,$(wildcard $(ROOT)/Makefile.user.mk))
   $(info include $(ROOT)/Makefile.user.mk)
   include $(ROOT)/Makefile.user.mk
endif
ifneq (,$(wildcard $(ROOT)/Makefile.user.$(COMP_ARCH).mk))
   $(info include $(ROOT)/Makefile.user.$(COMP_ARCH).mk )
   include $(ROOT)/Makefile.user.$(COMP_ARCH).mk
endif

#.SILENT:

## ==== Targets

.DEFAULT: 
	rdeco -q $@ || true

.PHONY: #TODO

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

# lib: Makefile.dep.mk $(OBJECTS) $(ALL_LIBS)

# all: Makefile.dep.mk $(OBJECTS) $(ALL_LIBS) $(ALL_BINS)
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
