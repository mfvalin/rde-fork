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

BUILD = $(ROOT)/$(shell pf.model_link build)
BUILDBIN = $(ROOT)/$(shell pf.model_link build/bin)
BUILDLIB = $(ROOT)/$(shell pf.model_link build/lib)
BUILDMOD = $(ROOT)/$(shell pf.model_link build/mod)
BUILDPRE = $(ROOT)/$(shell pf.model_link build/pre)
BINDIR   = $(BUILDBIN)
VPATH    = $(ROOT)/$(shell pf.model_link build/src)

LIBLOCAL = local
#BLAS     = blas


INCLUDES = $(shell find $(VPATH) -type d |tr '\n' ' ')
#INCLUDES = $(shell find $(VPATH) -type d |tr '\n' ' ' | grep '/include')
#TODO: INCLUDE only /include when code is clean from cross dir includes

INCLUDE_PATH=". $(INCLUDES)"
INCLUDE_MOD="$(BUILDMOD)"

LIBPATH = $(PWD) $(LIBPATH_PRE) $(BUILDLIB) $(LIBPATHEXTRA) $(LIBSYSPATHEXTRA) $(LIBPATHOTHER) $(LIBPATH_POST)
LIBAPPL = $(LIBS_PRE) $(LIBLOCAL) $(LIBOTHERS) $(LIBEXTRA) $(LIBS_POST)
LIBSYS  = $(LIBSYS_PRE) $(LIBSYSOTHERS) $(LIBSYSEXTRA) $(LIBSYS_POST)

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

#.SILENT:

## Basic Targets

.DEFAULT: all

.PHONY: all allbin allbincheck libs objects 

all: objects libs allbin

objects: $(OBJECTS)

LIBLOCALDEP = $(BUILDLIB)/liblocal.a
libs: $(BUILDLIB)/liblocal.a
libssplit:
	for mydir in `ls -d *` ; do \
		if [[ -d $${mydir} ]] ; then \
			rm -f $(BUILDLIB)/lib$${mydir}.a ;\
			ar r $(BUILDLIB)/lib$${mydir}.a `find $${mydir} -name '*.o'` ;\
		fi ;\
	done
$(BUILDLIB)/liblocal.a: $(OBJECTS) Makefile.dep.mk
	rm -f $@ 2>/dev/null || true
	ar r $@ `find . -name '*.o'`

#TODO: what about $(VPATH)/include ?
allbin: $(BUILDLIB)/liblocal.a
	for mydir in `ls $(VPATH)` ; do \
		if [[ -f $(VPATH)/$${mydir}/include/Makefile.local.mk ]] ; then \
			$(MAKE) allbin_$${mydir##*/} BINDIR=$(BUILDBIN) LIBPATHEXTRA=$(BUILDLIB) LIBLOCALDEP=$(LIBLOCALDEP) || exit 1;\
		fi ;\
	done
#		   mydir_uc=`echo $${mydir##*/} | tr 'a-z' 'A-Z'` ;\
#			$(MAKE) allbin_subdir SUBDIR_BINLIST=$(eval \$\($${mydir_uc}_BINLIST\)) BINDIR=$(BUILDBIN) LIBPATHEXTRA=$(BUILDLIB) LIBLOCALDEP=$(LIBLOCALDEP) || exit 1;\
# allbin_subdir:
# 	status=0 ;\
# 	for item in $(SUBDIR_BINLIST); do \
# 		$(MAKE) $(BINDIR)/$${item} || status=1 ;\
# 	done ;\
# 	exit $${status}

allbincheck:
	for mydir in `ls $(VPATH)` ; do \
		if [[ -f $(VPATH)/$${mydir}/include/Makefile.local.mk ]] ; then \
			$(MAKE) allbincheck_$${mydir##*/} BINDIR=$(BUILDBIN) LIBPATHEXTRA=$(BUILDLIB) LIBLOCALDEP=$(LIBLOCALDEP) || exit 1;\
		fi ;\
	done
allbinsplit: $(BUILDLIB)/liblocal.a
	for mydir in `ls $(VPATH)` ; do \
		if [[ -f $(VPATH)/$${mydir##*/}/include/Makefile.local.mk ]] ; then \
			$(MAKE) allbin_$${mydir##*/} BINDIR=$(BUILDBIN)/$${mydir##*/} LIBPATHEXTRA="$(BUILDLIB) $(BUILDLIB)/$${mydir##*/}" LIBLOCALDEP=$(LIBLOCALDEP) || exit 1;\
		fi ;\
	done

.PHONY: clean check_inc_dup
clean:
	chmod -R u+w . 2> /dev/null || true
	for mydir in `find . -type d` ; do \
		for ext in $(INCSUFFIXES) $(SRCSUFFIXES) .o .[mM][oO][dD]; do \
			rm -f $${mydir}/*$${ext} 2>/dev/null ;\
		done ;\
	done
	for mydir in $(BUILDMOD) $(BUILDPRE) ; do \
		cd $${mydir} ;\
		chmod -R u+w . 2> /dev/null || true ;\
		`find . -type f -exec rm -f {} \; ` ;\
	done
	#TODO: get .o .mod from libs again?

check_inc_dup: links
	echo "Checking for duplicated include files:"
	pf.check_dup -r --src=$(VPATH) --ext="$(INCSUFFIXES)" . $(INCLUDES) $(EC_INCLUDE_PATH) #$(shell s.generate_ec_path --include)

## ====================================================================
