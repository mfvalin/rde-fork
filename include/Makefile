## ====================================================================
## File: RDEINC/Makefile
##

SHELL = /bin/bash

## ==== Basic definitions

ifneq (,$(DEBUGMAKE))
	VERBOSE = 1
   MYTIME  = time
endif
ifneq (,$(MYTIME))
   MYTIMEX = set -x ; time
endif

ROOT := $(PWD)
MAKEFILE_CONST := $(shell rdevar Makefile_const)

ifeq (,$(wildcard $(MAKEFILE_CONST)))
   $(info Building $(MAKEFILE_CONST))
   $(info $(shell $(MYTIMEX) rdevar --mkfile))
endif
ifeq (,$(CONST_BUILD))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/include $(MAKEFILE_CONST))
   endif
   include $(ROOT)/$(MAKEFILE_CONST)
endif

ifeq (,$(RDE_DEP_SUPP_FILE))
   RDE_DEP_SUPP_FILE := $(rde)/etc/rdedep.supp
endif

BUILD    := $(ROOT)/$(CONST_BUILD)
BUILDPRE := $(ROOT)/$(CONST_BUILDPRE)
BUILDOBJ := $(ROOT)/$(CONST_BUILDOBJ)
BUILDMOD := $(ROOT)/$(CONST_BUILDMOD)
BUILDLIB := $(ROOT)/$(CONST_BUILDLIB)
BUILDBIN := $(ROOT)/$(CONST_BUILDBIN)
BINDIR   = $(BUILDBIN)

MAKEFILEDEP := $(CONST_MAKEFILE_DEP)

INCSUFFIXES := $(CONST_RDESUFFIXINC)
SRCSUFFIXES := $(CONST_RDESUFFIXSRC)
RDE_BASE_ARCH := $(CONST_RDE_BASE_ARCH)
RDE_ARCH_LIST := $(CONST_RDE_LINKED_ARCH_LIST)
ifeq (,$(RDE_ARCH_LIST))
RDE_ARCH_LIST := $(CONST_RDE_KNOWN_BASE_ARCH_LIST)
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

ifneq (,$(findstring s,$(MAKEFLAGS)))
   VERBOSE = 
endif
ifneq (,$(VERBOSE))
   VERBOSEV  := -v
ifeq (2,$(VERBOSE))
   VERBOSEVV := -v -v
endif
endif
ifeq (,$(DEBUGMAKE))
   NOPRINTDIR := --no-print-directory
endif

MAKE_LINKS = $(MYTIMEX) .rdeupdate_build_links.ksh $(VERBOSEVV)
#MYMAKE_VARS = ROOT=$(ROOT) RDE_BASE_ARCH=$(RDE_BASE_ARCH) BINDIR=$(BINDIR) DEBUGMAKE=$(DEBUGMAKE) MYTIME="$(MYTIME)" MAKEFILE_CONST=$(MAKEFILE_CONST)
MYMAKE_VARS = ROOT=$(ROOT) RDE_BASE_ARCH=$(RDE_BASE_ARCH) BINDIR=$(BINDIR) MAKEFILE_CONST=$(MAKEFILE_CONST)
#MYMAKE_VARS = ROOT=$(ROOT) RDE_BASE_ARCH=$(RDE_BASE_ARCH) MAKEFILE_CONST=$(MAKEFILE_CONST)

RDE_TARGET_OBJ = obj
RDE_TARGET_OBJ_FORCES = obj_forced
RDE_TARGET_OBJ_TOUCH = obj_touch
RDE_TARGET_CLEAN = clean
RDE_TARGET_BUILDCLEAN = buildclean
RDE_TARGET_BUILDCLEAN0 = buildclean0
RDE_TARGET_DISTCLEAN = distclean

ifneq (,$(wildcard $(ROOT)/Makefile.user.root.mk))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/Makefile.user.root.mk)
   endif
   include $(ROOT)/Makefile.user.root.mk
endif

## ==== Targets

RDE_TARGET_ALL = all
$(RDE_TARGET_ALL): obj

.SUFFIXES:

.DEFAULT: 
	$(MAKE) $(NOPRINTDIR) sanity
	$(MAKE_LINKS) ;\
	cd $(BUILDOBJ) ;\
	$(MYTIME) $(MAKE) $(NOPRINTDIR) $@ $(MYMAKE_VARS)

.PHONY: help sanity links dep deplocal objloc obj_forced obj_touch clean rmpo cleanbuild cleanbuild0 cleanall

help:
	@more $(rde)/etc/rde_make_help.txt
	@echo "Raw list of Makefile targets:"
	@echo
	@.rdefindtargets | more
	@echo "=============================================================="

tags:
	echo "Building the tag file for ${EDITOR:-vi} code navigation"
	echo "You may set the EDITOR env. var. to make the tag file for that editor"
	$(MYTIME) rdemktags -v

deplocal: #$(MAKEFILE_CONST)
	rm -f $(MAKEFILEDEP) 2>/dev/null || true
	$(MYTIME) rdemkdep -v --supp $(RDE_DEP_SUPP_FILE)
dep: #$(MAKEFILE_CONST)
	rm -f Makefile.dep.*.mk 2>/dev/null || true
	$(MYTIME) rdemkdep -v --supp $(RDE_DEP_SUPP_FILE) --arch "$(RDE_ARCH_LIST)"

#$(MAKEFILE_CONST) 
sanity: $(MAKEFILEDEP) Makefile.build.mk Makefile.rules.mk $(BUILD) $(BUILDOBJ)
links: sanity
	$(MAKE_LINKS)

.PHONY: Makefile.const
Makefile.const: 
	$(info Building Makefile Constants: $(MAKEFILE_CONST))
	$(MYTIME) rdevar --mkfile
$(MAKEFILE_CONST): $(CONST_SRCPATHFILE) $(CONST_RDE_CONFIG_FILE)
	$(info Building Makefile Constants: $(MAKEFILE_CONST))
	$(MYTIME) rdevar --mkfile


$(MAKEFILEDEP):
	$(MYTIME) rdemkdep -v --supp $(RDE_DEP_SUPP_FILE)
Makefile.build.mk:
	$(MYTIME) rdemklink $(VERBOSEV)
Makefile.rules.mk:
	$(MYTIME) rdemklink $(VERBOSEV)
$(BUILD):
	$(MYTIME) rdemklink $(VERBOSEV)
$(BUILDOBJ):
	$(MYTIME) rdemklink $(VERBOSEV)

#Compiler uniquement les fichiers  modifies.
$(RDE_TARGET_OBJ):  sanity
	$(MAKE_LINKS) ;\
	cd $(BUILDOBJ) ;\
	localfiles="" ;\
	for myfile in $(foreach exte,$(SRCSUFFIXES),$(wildcard *$(exte))) ; do \
		if [[ -L $${myfile} ]] ; then \
			localfiles="$${localfiles} $${myfile%.*}.o _invdep_.$${myfile}" ;\
		fi ;\
	done ;\
	for myfile in $(foreach exte,$(INCSUFFIXES),$(wildcard *$(exte))) ; do \
		if [[ -L $${myfile} ]] ; then \
			localfiles="$${localfiles} _invdep_.$${myfile}" ;\
		fi ;\
	done ;\
	$(MYTIME) $(MAKE) $(NOPRINTDIR) $${localfiles} $(MYMAKE_VARS)

$(RDE_TARGET_OBJ_FORCES): $(RDE_TARGET_OBJ_TOUCH) 
	$(MYTIME) $(MAKE) $(NOPRINTDIR) $(RDE_TARGET_OBJ) $(MYMAKE_VARS)
$(RDE_TARGET_OBJ_TOUCH):
	touch `ls *.f* *.c* *.h* *.F* *.t* 2>/dev/null` 2>/dev/null || true

rmpo: $(RDE_TARGET_CLEAN)
$(RDE_TARGET_CLEAN): 
	chmod -R u+w $(BUILDOBJ)/*.o $(BUILDMOD)/*.[Mm][Oo][Dd] 2>/dev/null || true ;\
	rm -rf       $(BUILDOBJ)/*.o $(BUILDMOD)/*.[Mm][Oo][Dd] 2>/dev/null || true
	cd $(BUILDPRE) ;\
	for myfile in $(foreach exte,$(SRCSUFFIXES) $(INCSUFFIXES),$(wildcard *$(exte))) ; do \
		if [[ ! -L $${myfile} ]] ; then \
			chmod u+w $${myfile} ; rm -f  $${myfile};\
		fi ;\
	done ;\


$(RDE_TARGET_BUILDCLEAN): 
	chmod u+w -R $(BUILD) $(BUILDPRE) $(BUILDOBJ) $(BUILDMOD) $(BUILDLIB) $(BUILDBIN) 2>/dev/null || true
	rm -rf $(BUILD)/* $(BUILDPRE)/* $(BUILDOBJ)/* $(BUILDMOD)/* $(BUILDLIB)/* $(BUILDBIN)/* 2>/dev/null || true
	mkdir -p $(BUILD) $(BUILDPRE) $(BUILDOBJ) $(BUILDMOD) $(BUILDLIB) $(BUILDBIN) 2>/dev/null || true

$(RDE_TARGET_BUILDCLEAN0): 
	for mydir in $(BUILDPRE) $(BUILDOBJ) $(BUILDMOD) $(BUILDLIB) $(BUILDBIN) ;do\
	   chmod u+w $${mydir}/* $${mydir}/.[a-zA-Z0-9_-]* 2>/dev/null || true ;\
		rm -f     $${mydir}/* $${mydir}/.[a-zA-Z0-9_-]* 2>/dev/null || true ;\
	done

$(RDE_TARGET_DISTCLEAN): $(RDE_TARGET_BUILDCLEAN)
	for item in `rdevar RDEROOTLINKS` ; do \
		if [[ -L $${item} ]] ; then \
			rm -f $${item} 2>/dev/null || true; \
		fi ;\
	done
	chmod u+w .`rdevar RDEROOTFILES` 2>/dev/null || true
	rm -f `rdevar RDEROOTFILES` 2>/dev/null || true
	chmod -R u+w `rdevar RDEDIRS` 2>/dev/null || true
	rm -rf `rdevar RDEDIRS` 2>/dev/null || true
	for item in $(RDE_ARCH_LIST) ; do \
		buildlink=$$(rdevar --arch $${item} build) ;\
		if [[ -d $${buildlink:-__no-such-link__} ]] ; then \
			rm -rf $${buildlink:-__no-such-link__}/* ;\
		fi ;\
		rm -f $${buildlink:-__no-such-link__} ;\
	done

## ====================================================================
