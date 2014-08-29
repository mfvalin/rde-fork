## ====================================================================
## File: LOCALBUILD/include/Makefile.build.mk
##

SHELL = /bin/bash

ifeq (,$(ROOT))
   $(error FATAL ERROR: ROOT is not defined)
endif
ifeq (,$(VPATH))
   $(error FATAL ERROR: VPATH is not defined)
endif

## Basic definitions
OPTIL  = 2
OMP    = -openmp
MPI    = -mpi

LFLAGS = $(OMP) $(MKL)

BUILD = $(ROOT)/$(shell pfmodel_link build)
BUILDBIN = $(ROOT)/$(shell pfmodel_link build/bin)
BUILDLIB = $(ROOT)/$(shell pfmodel_link build/lib)
BUILDMOD = $(ROOT)/$(shell pfmodel_link build/mod)
BUILDPRE = $(ROOT)/$(shell pfmodel_link build/pre)
BINDIR   = $(BUILDBIN)
VPATH    = $(ROOT)/$(shell pfmodel_link build/src)

#BLAS     = blas

INCLUDES = $(shell .pfdir_with_files -n $(VPATH))
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

SUBDIRLIST  = $(foreach mydir,$(wildcard $(VPATH)/*),$(notdir $(mydir)))
SUBDIRLIST2 = $(foreach mydir,$(SUBDIRLIST),$(shell if [[ -f $(VPATH)/$(mydir)/include/Makefile.local.mk ]] ; then echo $(mydir) ; fi))
ALL_BINS = $(foreach mydir,$(SUBDIRLIST2),allbin_$(mydir))
ALL_BINS_CHECK = $(foreach mydir,$(SUBDIRLIST2),allbincheck_$(mydir))

## Arch specific and Local/user definitons, targets and overrides
ifneq (,$(wildcard Makefile.dep.mk))
	include Makefile.dep.mk
endif
ifneq (,$(wildcard Makefile.rules.mk))
	include Makefile.rules.mk
endif
ifneq (,$(wildcard Makefile.base_arch.mk))
	include Makefile.base_arch.mk
endif
ifneq (,$(wildcard Makefile.ec_arch.mk))
	include Makefile.ec_arch.mk
endif
ifneq (,$(wildcard Makefile.local.mk))
	include Makefile.local.mk
endif
ifneq (,$(wildcard $(ROOT)/Makefile.user.mk))
	include $(ROOT)/Makefile.user.mk
endif
ifneq (,$(wildcard $(ROOT)/Makefile.user.$(COMP_ARCH).mk))
	include $(ROOT)/Makefile.user.$(COMP_ARCH).mk
endif

#.SILENT:

## Basic Targets

.DEFAULT: all

.PHONY: all allbin allbincheck lib obj objloc clean0 clean check_inc_dup

obj: Makefile.dep.mk $(OBJECTS)
objloc: obj

lib: Makefile.dep.mk $(OBJECTS) $(ALL_LIBS)

all: Makefile.dep.mk $(OBJECTS) $(ALL_LIBS) $(ALL_BINS)
bin: all
bin_check: $(ALL_BINS_CHECK)

clean0:
	chmod -R u+w . 2> /dev/null || true  ;\
	for mydir in `find . -type d` ; do \
		for ext in $(INCSUFFIXES) $(SRCSUFFIXES) .o .[mM][oO][dD]; do \
			rm -f $${mydir}/*$${ext} 2>/dev/null ;\
		done ;\
	done ;\
	for mydir in $(BUILDMOD) $(BUILDPRE) ; do \
		cd $${mydir} ;\
		chmod -R u+w . 2> /dev/null || true ;\
		`find . -type f -exec rm -f {} \; ` ;\
	done

#TODO: get .o .mod from lib again after make clean?
#TODO: should we keep .mod after make clean?

clean:
	chmod -R u+w . $(BUILDMOD) $(BUILDPRE) 2> /dev/null || true ;\
	rm -f $(foreach mydir,. * */* */*/* */*/*/* */*/*/*/*,$(foreach exte,$(INCSUFFIXES) $(SRCSUFFIXES) .o .[mM][oO][dD],$(mydir)/*$(exte))) 2>/dev/null || true  ;\
	rm -f $(foreach mydir,. * */* */*/* */*/*/* */*/*/*/*,$(foreach mydir0,$(BUILDMOD) $(BUILDPRE),$(mydir0)/$(mydir)/*)) 2>/dev/null || true

check_inc_dup: links
	echo "Checking for duplicated include files" ;\
	pfcheck_dup -r --src=$(VPATH) --ext="$(INCSUFFIXES)" . $(INCLUDES) $(EC_INCLUDE_PATH) #$(shell s.generate_ec_path --include)

## ====================================================================
