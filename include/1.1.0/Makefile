## ====================================================================
## File: $(shell rdevar rdeinc)/Makefile
##

SHELL = /bin/bash

## ==== Basic definitions

RDE_INCLUDE = $(shell rdevar rdeinc)

ROOT     := $(PWD)
BUILD    := $(ROOT)/$(shell rdevar build)
#BUILDSRC = $(ROOT)/$(shell rdevar build/src)
BUILDOBJ := $(ROOT)/$(shell rdevar build/obj)
BUILDBIN := $(shell rdevar build/bin)
#BUILDLIB := $(ROOT)/$(shell rdevar build/lib)
#BUILDMOD := $(ROOT)/$(shell rdevar build/mod)
#BUILDPRE := $(ROOT)/$(shell rdevar build/pre)
BINDIR   := $(BUILDBIN)
VPATH    = $(ROOT)/$(shell rdevar build/src)
SRCPATH   = $(shell srcpath)

INCSUFFIXES = $(shell rdevar rdesuffix/inc)
SRCSUFFIXES = $(shell rdevar rdesuffix/src)

ifeq (,$(rde))
   $(error FATAL ERROR: rde is not defined)
endif
ifeq (,$(ROOT))
   $(error FATAL ERROR: ROOT is not defined)
endif
ifeq ($(ROOT),$(BUILD))
   $(error FATAL ERROR: BUILD == ROOT)
endif

VERBOSE    := -v
NOPRINTDIR := --no-print-directory

#MYTIME = time

#ifeq (,$(VERBOSE))
#.SILENT:
#endif

MAKE_LINKS := $(MYTIME) .rdeupdate_build_links.ksh

## ==== Targets

.PHONY: help dep rm_makefiles_dep objloc obj_forced obj_touch qclean clean distclean

.DEFAULT:
	$(MAKE) Makefile.dep.mk ;\
	$(MAKE_LINKS) ;\
	cd $(BUILDOBJ) ;\
	$(MAKE) $(NOPRINTDIR) $@ ROOT=$(ROOT) BINDIR=$(BINDIR)

help:
	@more $(rde)/etc/rde_make_help.txt
	@echo "Raw list of Makefile targets:"
	@echo
	@.rdefindtargets
	@echo "=============================================================="

dep: rm_makefiles_dep Makefile.dep.mk

rm_makefiles_dep:
	rm -f Makefile.dep.mk

Makefile.dep.mk:
	rdemkdep -v

links: Makefile.dep.mk
	$(MAKE_LINKS)

#Compiler uniquement les fichiers  modifies.
qobj: obj
obj:  Makefile.dep.mk
	$(MAKE_LINKS) ;\
	cd $(BUILDOBJ) ;\
	for myfile in $(foreach exte,$(SRCSUFFIXES),$(wildcard *$(exte))) ; do \
		if [[ -L $${myfile} ]] ; then \
			$(MAKE) $(NOPRINTDIR) $${myfile%.*}.o ROOT=$(ROOT) BINDIR=$(BINDIR);\
		fi ;\
	done ;\
	for myfile in $(foreach exte,$(INCSUFFIXES) $(SRCSUFFIXES),$(wildcard *$(exte))) ; do \
		if [[ -L $${myfile} ]] ; then \
			$(MAKE) $(NOPRINTDIR) $${myfile}.invdep ROOT=$(ROOT) BINDIR=$(BINDIR);\
		fi ;\
	done

objloc: obj_forced
obj_forced: obj_touch obj
obj_touch:
	touch $(wildcard *.f* *.c* *.h* *.F* *.t*) 2>/dev/null || true

qclean: clean
clean:
	chmod -R u+w $(BUILD)/* $(BUILD)/.[a-zA-Z0-9_-]* 2>/dev/null || true ;\
	rm -rf $(BUILD)/* $(BUILD)/.[a-zA-Z0-9_-]* 2>/dev/null || true
	$(MAKE_LINKS) >/dev/null 2>/dev/null || true
distclean: 
	chmod -R u+w $(BUILD)/* $(BUILD)/.[a-zA-Z0-9_-]* 2>/dev/null || true ;\
	rm -rf $(BUILD)/* $(BUILD)/.[a-zA-Z0-9_-]* 2>/dev/null || true ;\
	chmod u+w $(BINDIR)/* 2>/dev/null || true ;\
	rm  -f $(BINDIR)/* 2>/dev/null || true

## ====================================================================
