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

INCLUDES = $(shell pfdir_with_files -n $(VPATH))
#INCLUDES = $(shell find $(VPATH) -type d |tr '\n' ' ')
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

.PHONY: all allbin allbincheck libs objects objloc

all: objects libs allbin

objects: $(OBJECTS)
objloc: objects

libs: $(OBJECTS) Makefile.dep.mk
	status=0;\
	for mydir in `ls` ; do \
		if [[ -d $${mydir} ]] ; then \
			$(MAKE_ARCH) $(BUILDLIB)/lib$${mydir}.a MYCOMPONENT=$${mydir} || status=1;\
		fi ;\
	done ;\
	exit $${status}
$(BUILDLIB)/lib$(MYCOMPONENT).a: $(OBJECTS) Makefile.dep.mk
	status=0;\
	if [[ -d $(MYCOMPONENT) ]] ; then \
		rm -f $@  2>/dev/null || true ;\
		ar r $@ `find $(MYCOMPONENT) -name '*.o'` || status=1;\
	fi ;\
	exit $${status}

LIBLOCAL = local
LIBLOCALDEP = $(BUILDLIB)/lib$(LIBLOCAL).a
libs0: $(LIBLOCALDEP)
libs0split: $(OBJECTS)
	for mydir in `ls -d *` ; do \
		if [[ -d $${mydir} ]] ; then \
			rm -f $(BUILDLIB)/lib$${mydir}.a ;\
			ar r $(BUILDLIB)/lib$${mydir}.a `find $${mydir} -name '*.o'` ;\
		fi ;\
	done
$(LIBLOCALDEP): $(OBJECTS) Makefile.dep.mk
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
clean0:
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

clean:
	chmod -R u+w . $(BUILDMOD) $(BUILDPRE) 2> /dev/null || true
	rm -f $(foreach mydir,. * */* */*/* */*/*/* */*/*/*/*,$(foreach exte,$(INCSUFFIXES) $(SRCSUFFIXES) .o .[mM][oO][dD],$(mydir)/*$(exte))) 2>/dev/null || true
	rm -f $(foreach mydir,. * */* */*/* */*/*/* */*/*/*/*,$(foreach mydir0,$(BUILDMOD) $(BUILDPRE),$(mydir0)/$(mydir)/*)) 2>/dev/null || true

	# for mydir in `find . -type d` ; do \
	# 	for ext in $(INCSUFFIXES) $(SRCSUFFIXES) .o .[mM][oO][dD]; do \
	# 		rm -f $${mydir}/*$${ext} 2>/dev/null ;\
	# 	done ;\
	# done

	# for mydir in $(BUILDMOD) $(BUILDPRE) ; do \
	# 	cd $${mydir} ;\
	# 	`find . -type f -exec rm -f {} \; ` ;\
	# done
	#TODO: get .o .mod from libs again?

check_inc_dup: links
	echo "Checking for duplicated include files"
	pfcheck_dup -r --src=$(VPATH) --ext="$(INCSUFFIXES)" . $(INCLUDES) $(EC_INCLUDE_PATH) #$(shell s.generate_ec_path --include)

## ====================================================================
