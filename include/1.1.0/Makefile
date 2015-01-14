## ====================================================================
## File: $(shell rdevar rdeinc)/Makefile
##

SHELL = /bin/bash

## ==== Basic definitions

RDE_INCLUDE := $(shell rdevar rdeinc)
ifeq (,$(RDE_DEP_SUPP_FILE))
RDE_DEP_SUPP_FILE := $(rde)/etc/rdedep.supp
endif

ROOT     := $(PWD)
BUILD    := $(ROOT)/$(shell rdevar build)
BUILDPRE := $(ROOT)/$(shell rdevar build/pre)
BUILDOBJ := $(ROOT)/$(shell rdevar build/obj)
BUILDMOD := $(ROOT)/$(shell rdevar build/mod)
BUILDLIB := $(ROOT)/$(shell rdevar build/lib)
BUILDBIN := $(ROOT)/$(shell rdevar build/bin)
BINDIR   := $(BUILDBIN)

INCSUFFIXES := $(shell rdevar rdesuffix/inc)
SRCSUFFIXES := $(shell rdevar rdesuffix/src)

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

.PHONY: help sanity links dep objloc obj_forced obj_touch qclean clean rmpo distclean

help:
	@more $(rde)/etc/rde_make_help.txt
	@echo "Raw list of Makefile targets:"
	@echo
	@.rdefindtargets
	@echo "=============================================================="

dep: 
	rm -f Makefile.dep.mk 2>/dev/null || true
	rdemkdep -v --supp $(RDE_DEP_SUPP_FILE)

sanity: Makefile Makefile.dep.mk Makefile.build.mk Makefile.rules.mk $(BUILD) $(BUILDOBJ)
links: sanity
	$(MAKE_LINKS)

Makefile:
	rdemkdep -v --supp $(RDE_DEP_SUPP_FILE)
Makefile.dep.mk:
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
			$(MAKE) $(NOPRINTDIR) _INVDEP_.$${myfile} $(MYMAKE_VARS) ;\
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
