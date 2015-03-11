## ====================================================================
## File: RDEINC/Makefile
##

SHELL = /bin/bash

## ==== Basic definitions

ROOT := $(PWD)
RDE_BASE_ARCH := $(shell rdevar rde_base_arch)

ifeq (,$(wildcard Makefile.const.$(RDE_BASE_ARCH).mk))
$(info Building Makefile.const.$(RDE_BASE_ARCH).mk)
$(info $(shell rdevar --mkfile))
endif

ifneq (,$(DEBUGMAKE))
	$(info $(ROOT)/include Makefile.const.$(BASE_ARCH).mk)
endif
include $(ROOT)/Makefile.const.$(BASE_ARCH).mk

ifeq (,$(RDE_DEP_SUPP_FILE))
RDE_DEP_SUPP_FILE := $(rde)/etc/rdedep.supp
endif

BUILD    := $(ROOT)/$(CONST_BUILD)
BUILDPRE := $(ROOT)/$(CONST_BUILDPRE)
BUILDOBJ := $(ROOT)/$(CONST_BUILDOBJ)
BUILDMOD := $(ROOT)/$(CONST_BUILDMOD)
BUILDLIB := $(ROOT)/$(CONST_BUILDLIB)
BUILDBIN := $(ROOT)/$(CONST_BUILDBIN)
BINDIR   := $(BUILDBIN)

MAKEFILEDEP := $(CONST_MAKEFILE_DEP)

INCSUFFIXES := $(CONST_RDESUFFIXINC)
SRCSUFFIXES := $(CONST_RDESUFFIXSRC)
RDE_ARCH_LIST := $(CONST_SRCPATH_ARCH_LIST)
ifeq (,$(RDE_ARCH_LIST))
RDE_ARCH_LIST := $(CONST_RDE_BASE_ARCH_LIST)
endif

RDE_INCLUDE0 := $(CONST_RDEINC)

ifeq (,$(rde))
   $(error FATAL ERROR: rde is not defined)
endif
ifeq (,$(ROOT))
   $(error FATAL ERROR: ROOT is not defined)
endif
ifeq ($(ROOT),$(BUILD))
   $(error FATAL ERROR: BUILD == ROOT)
endif

VERBOSE = -v
ifneq (,$(findstring s,$(MAKEFLAGS)))
VERBOSE = 
endif
ifeq (,$(VERBOSE))
.SILENT:
endif
NOPRINTDIR := --no-print-directory

#MYTIME = time

MAKE_LINKS := $(MYTIME) .rdeupdate_build_links.ksh
MYMAKE_VARS = ROOT=$(ROOT) BINDIR=$(BINDIR)

ifneq (,$(wildcard $(ROOT)/Makefile.user.root.mk))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/Makefile.user.root.mk)
   endif
   include $(ROOT)/Makefile.user.root.mk
endif

## ==== Targets

all: obj

.SUFFIXES:

.DEFAULT: 
	$(MAKE) $(NOPRINTDIR) sanity
	$(MAKE_LINKS) ;\
	cd $(BUILDOBJ) ;\
	$(MAKE) $(NOPRINTDIR) $@ $(MYMAKE_VARS)

.PHONY: help sanity links dep deplocal objloc obj_forced obj_touch qclean clean rmpo distclean

help:
	@more $(rde)/etc/rde_make_help.txt
	@echo "Raw list of Makefile targets:"
	@echo
	@.rdefindtargets
	@echo "=============================================================="

deplocal: 
	rm -f $(MAKEFILEDEP) 2>/dev/null || true
	rdemkdep -v --supp $(RDE_DEP_SUPP_FILE)
dep: 
	rm -f Makefile.dep.*.mk 2>/dev/null || true
	rdemkdep -v --supp $(RDE_DEP_SUPP_FILE) --arch "$(RDE_ARCH_LIST)"

sanity: $(MAKEFILEDEP) Makefile.build.mk Makefile.rules.mk $(BUILD) $(BUILDOBJ)
links: sanity
	$(MAKE_LINKS)

$(MAKEFILEDEP):
	rdemkdep -v --supp $(RDE_DEP_SUPP_FILE)
Makefile.build.mk:
	rdemklink $(VERBOSE)
Makefile.rules.mk:
	rdemklink $(VERBOSE)
$(BUILD):
	rdemklink $(VERBOSE)
$(BUILDOBJ):
	rdemklink $(VERBOSE)

#Compiler uniquement les fichiers  modifies.
qobj: obj
obj:  sanity
	$(MAKE_LINKS) ;\
	cd $(BUILDOBJ) ;\
	for myfile in $(foreach exte,$(SRCSUFFIXES),$(wildcard *$(exte))) ; do \
		if [[ -L $${myfile} ]] ; then \
			$(MAKE) $(NOPRINTDIR) $${myfile%.*}.o $(MYMAKE_VARS) ;\
			if [[ $${?} != 0 ]] ; then exit 1 ; fi ;\
		fi ;\
	done ;\
	for myfile in $(foreach exte,$(INCSUFFIXES) $(SRCSUFFIXES),$(wildcard *$(exte))) ; do \
		if [[ -L $${myfile} ]] ; then \
			$(MAKE) $(NOPRINTDIR) _invdep_.$${myfile} $(MYMAKE_VARS) ;\
			if [[ $${?} != 0 ]] ; then exit 1 ; fi ;\
		fi ;\
	done

objloc:
	@echo
	@echo "WARNING, objloc is deprecated, use: make obj"
	@echo
obj_forced: obj_touch obj
obj_touch:
	touch $(wildcard *.f* *.c* *.h* *.F* *.t*) 2>/dev/null || true

qclean: clean
clean: sanity
	@echo
	@echo "WARNING, To remove *.o *.mod               use: make rmpo"
	@echo "........ To remove the whole build content use: make distclean"
	@echo "........ For more details                  use: make help"
	@echo
rmpo: sanity
	chmod -R u+w $(BUILDOBJ)/*.o $(BUILDMOD)/*.[Mm][Oo][Dd] 2>/dev/null || true ;\
	rm -rf       $(BUILDOBJ)/*.o $(BUILDMOD)/*.[Mm][Oo][Dd] 2>/dev/null || true
distclean: sanity
	for mydir in $(BUILDPRE) $(BUILDOBJ) $(BUILDMOD) $(BUILDLIB) $(BUILDBIN) ;do\
	   chmod u+w $${mydir}/* $${mydir}/.[a-zA-Z0-9_-]* 2>/dev/null || true ;\
		rm -f     $${mydir}/* $${mydir}/.[a-zA-Z0-9_-]* 2>/dev/null || true ;\
	done

## ====================================================================
