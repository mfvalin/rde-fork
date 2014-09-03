## ====================================================================
## File: $purplefrog/include/Makefile.root.mk
##

SHELL = /bin/bash

ROOT  := $(PWD)
SRC_USR := $(ROOT)/$(shell pfmodel_link local/src)
BUILD := $(ROOT)/$(shell pfmodel_link build)
BUILDBIN := $(ROOT)/$(shell pfmodel_link build/bin)
BUILDLIB := $(ROOT)/$(shell pfmodel_link build/lib)
BUILDMOD := $(ROOT)/$(shell pfmodel_link build/mod)
BUILDOBJ := $(ROOT)/$(shell pfmodel_link build/obj)
BUILDPRE := $(ROOT)/$(shell pfmodel_link build/pre)
BUILDSRC := $(ROOT)/$(shell pfmodel_link build/src)
VPATH := $(BUILDSRC)
VERBOSE := -v
NOPRINTDIR = --no-print-directory
#DEP_DUP_OK = --dup_ok
#DEP_FLAT = --flat
#PERLPROF = perl -d:DProf $(purplefrog)/bin/
# with PERLPROF, look at results with: dprofpp $(BUILDSRC)/tmon.out
PFDEP_SUPP_FILE := $(purplefrog)/etc/pfdependencies.supp

ifeq (,$(purplefrog))
   $(error FATAL ERROR: purplefrog is not defined)
endif
ifeq (,$(ROOT))
   $(error FATAL ERROR: ROOT is not defined)
endif
ifeq ($(ROOT),$(BUILD))
   $(error FATAL ERROR: BUILD == ROOT)
endif


ifneq (,$(wildcard $(BUILDOBJ)/Makefile.base_arch.mk))
	include $(BUILDOBJ)/Makefile.base_arch.mk
endif
ifneq (,$(wildcard $(BUILDOBJ)/Makefile.ec_arch.mk))
	include $(BUILDOBJ)/Makefile.ec_arch.mk
endif
# ifneq (,$(wildcard $(ROOT)/Makefile.user.mk))
# 	include $(ROOT)/Makefile.user.mk
# endif
# ifneq (,$(wildcard $(ROOT)/Makefile.user.$(COMP_ARCH).mk))
# 	include $(ROOT)/Makefile.user.$(COMP_ARCH).mk
# endif

#ifeq (,$(VERBOSE))
#.SILENT:
#endif

## ==== Phony targets

.PHONY: all help rm_makefiles rm_makefiles2 rm_makefiles_dep links0 links links_forced sanity sanity_nodep_force dep versionfiles clean distclean distclean+ distclean++ obj_touch obj_forced objloc lib_rm lib_forced bin_rm bin_forced all_forced

MAKE_LINKS  := .pfupdate_build_links.ksh ; $(BUILDOBJ)/Makefile

.DEFAULT:
	.pfupdate_build_links.ksh ;\
	cd $(BUILDOBJ) ;\
	$(MAKE) $(NOPRINTDIR) $@ ROOT=$(ROOT) VPATH=$(VPATH)

all:
	.pfupdate_build_links.ksh ;\
	cd $(BUILDOBJ) ;\
	$(MAKE) $(NOPRINTDIR) $@ ROOT=$(ROOT) VPATH=$(VPATH)

obj_touch:
	@find $(SRC_USR) -type f -exec touch {} \;
obj_forced: obj_touch obj
objloc: obj_forced

lib_rm:
	@rm -f $(BUILDLIB)/lib*.a 
lib_forced: lib_rm lib

bin: all
bin_rm:
	@rm -f $(BUILDBIN)/* 
bin_forced: bin_rm bin

all_forced: obj_forced lib_forced bin_forced

help:
	@more $(purplefrog)/etc/pf_make_help.txt
	@echo "Raw list of Makefile targets:"
	@echo
	@.pffindtargets
	@echo "=============================================================="

rm_makefiles:
	rm -f $(BUILDOBJ)/Makefile*
rm_makefiles2:
	rm -f $(BUILDOBJ)/Makefile $(BUILDOBJ)/Makefile.build.mk $(BUILDOBJ)/Makefile.local.mk $(BUILDOBJ)/Makefile.rules.mk $(BUILDOBJ)/Makefile.base_arch.mk $(BUILDOBJ)/Makefile.ec_arch.mk
rm_makefiles_dep:
	rm -f $(BUILDOBJ)/Makefile.dep.mk $(BUILDOBJ)/Makefile.local.mk

links0:
	.pfupdate_build_links.ksh
links: links0 $(BUILDOBJ)/Makefile
links_forced: rm_makefiles links

sanity: $(BUILDOBJ)/Makefile
sanity_forced: rm_makefiles2 sanity

dep: rm_makefiles_dep links

versionfiles:
	for mydir in `ls $(BUILDSRC)` ; do \
		if [[ -d $${mydir} && ! -f $${mydir}/.version_file ]] ; then \
			for item in $(cat $${mydir}/.version_file) ; do \
			   pfmk_version_file "$${mydir}" "$(ATM_MODEL_VERSION)" $(BUILDSRC)/$${mydir}/include $${item} ;\
		   done ;\
		fi ;\
	done

clean: sanity
	cd $(BUILDOBJ) ;\
	$(MAKE) $(NOPRINTDIR) $@ ROOT=$(ROOT) VPATH=$(VPATH)
distclean:
	for mydir in $(shell pfmodel_link -l build) ; do \
		if [[ $${mydir} != src ]] ; then \
			cd $(BUILD)/$${mydir} ;\
			chmod -R u+w . 2> /dev/null || true ;\
			`find . -type f -exec rm -f {} \; ` ;\
		fi ;\
	done ;\
	cd $(ROOT) ;\
	touch $(BUILDOBJ)/Makefile.dep.mk ;\
	$(MAKE_LINKS) ;\
	rm -f $(BUILDOBJ)/Makefile.dep.mk
distclean+:
	cd $(BUILD) ;\
	chmod -R u+w . 2> /dev/null || true ;\
	`find . -type f -exec rm -f {} \; `
	#TODO: need to re-run pfinit, no more src
distclean++:
	cd $(BUILD) ;\
	chmod -R u+w . 2> /dev/null || true ;\
	rm -rf * 2> /dev/null || true
	#TODO: need to re-run pfinit, no more dir and src


## ====  Real Targets and Dependencies

Makefile.user.mk:
	if [[ -f $(purplefrog)/etc/$@ && ! -f $@ ]] ; then \
	   cp $(purplefrog)/etc/$@ $@ ;\
	else \
	   touch $@ ;\
	fi
Makefile.user.$(COMP_ARCH).mk:
	if [[ -f $(purplefrog)/etc/$@ && ! -f $@ ]] ; then \
	   cp $(purplefrog)/etc/$@ $@ ;\
	else \
	   touch $@ ;\
	fi

$(BUILDOBJ)/Makefile: Makefile.user.mk $(BUILDOBJ)/Makefile.local.mk $(BUILDOBJ)/Makefile.rules.mk $(BUILDOBJ)/Makefile.base_arch.mk $(BUILDOBJ)/Makefile.ec_arch.mk $(BUILDOBJ)/Makefile.dep.mk
	cp $(purplefrog)/include/Makefile.build.mk $(BUILDOBJ)/ 2>/dev/null || true ;\
	ln -sf $(BUILDOBJ)/Makefile.build.mk $@
$(BUILDOBJ)/Makefile.local.mk:
	touch $@
	cd $(BUILDSRC) ;\
	for mydir in `find . -type d -name include` ; do \
		for item in . $(BASE_ARCH) $(EC_ARCH) $(BASE_ARCH)_$(COMP_ARCH) ; do \
			if [[ -f $${mydir}/$${item}/Makefile.local.mk ]] ; then \
				echo include $(BUILDSRC)/$${mydir}/$${item}/Makefile.local.mk >> $@ ;\
			fi ;\
			if [[ -f $${mydir}/Makefile_$${item} ]] ; then \
				echo include $(BUILDSRC)/$${mydir}/Makefile_$${item} >> $@ ;\
			fi ;\
			if [[ -f $${mydir}/Makefile.$${item}.mk ]] ; then \
				echo include $(BUILDSRC)/$${mydir}/Makefile.$${item}.mk >> $@ ;\
			fi ;\
		done ;\
	done
$(BUILDOBJ)/Makefile.rules.mk:
	cp $(purplefrog)/include/Makefile.rules.mk $@ 2>/dev/null || true ;\
	touch $@
$(BUILDOBJ)/Makefile.base_arch.mk:
	cp $(purplefrog)/include/$(BASE_ARCH)/Makefile.arch.mk $@ 2>/dev/null || true ;\
	touch $@
$(BUILDOBJ)/Makefile.ec_arch.mk:
	cp $(purplefrog)/include/$(EC_ARCH)/Makefile.arch.mk $@ 2>/dev/null || true ;\
	touch $@
$(BUILDOBJ)/Makefile.dep.mk:
	cd $(BUILDSRC) ;\
	$(PERLPROF)pfdependencies.pl $(VERBOSE) --deep-include --soft-restriction $(DEP_DUP_OK) $(DEP_FLAT) --out=$(BUILDOBJ)/Makefile.dep.mk --any --short --supp=$(PFDEP_SUPP_FILE) --inc=`find * -type d -name include|tr '\n' ':'` `find * -type d|grep -v include`

#TODO: remove --any when code is clean from cross dir includes

## ====================================================================
