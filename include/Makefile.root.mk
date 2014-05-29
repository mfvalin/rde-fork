## ====================================================================
## File: $purplefrog/include/Makefile.root.mk
##

SHELL = /bin/bash

ROOT  = $(PWD)
BUILD = $(ROOT)/$(shell pf.model_link build)
BUILDBIN = $(ROOT)/$(shell pf.model_link build/bin)
BUILDLIB = $(ROOT)/$(shell pf.model_link build/lib)
BUILDMOD = $(ROOT)/$(shell pf.model_link build/mod)
BUILDOBJ = $(ROOT)/$(shell pf.model_link build/obj)
BUILDPRE = $(ROOT)/$(shell pf.model_link build/pre)
BUILDSRC = $(ROOT)/$(shell pf.model_link build/src)
VPATH = $(BUILDSRC)
VERBOSE = -v
NJOBS = 12
#DEP_DUP_OK = --dup_ok
#DEP_FLAT = --flat
#PERLPROF = perl -d:DProf $(purplefrog)/bin/
# with PERLPROF, look at results with: dprofpp $(BUILDSRC)/tmon.out

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
ifneq (,$(wildcard $(ROOT)/Makefile.user.mk))
	include $(ROOT)/Makefile.user.mk
endif

#ifeq (,$(VERBOSE))
#.SILENT:
#endif

.PHONY: all links links_forced sanity sanity_nodep_force dep versionfiles clean distclean distclean+ distclean++

.DEFAULT: 
	$(MAKE_ARCH) $(BUILDOBJ)/Makefile.dep.mk links
	cd $(BUILDOBJ);\
	$(MAKE_ARCH) -j $(NJOBS) $@ ROOT=$(ROOT) VPATH=$(VPATH)

all:
	$(MAKE_ARCH) $(BUILDOBJ)/Makefile.dep.mk links
	cd $(BUILDOBJ);\
	$(MAKE_ARCH) -j $(NJOBS) $@ ROOT=$(ROOT) VPATH=$(VPATH)

links: | sanity
	pf.update_build_links.ksh
links_forced:
	rm -f $(BUILDOBJ)/Makefile*
	$(MAKE) links

sanity: $(BUILDOBJ)/Makefile 
sanity_nodep_force:
	rm -f $(BUILDOBJ)/Makefile $(BUILDOBJ)/Makefile.build.mk $(BUILDOBJ)/Makefile.local.mk $(BUILDOBJ)/Makefile.rules.mk $(BUILDOBJ)/Makefile.base_arch.mk $(BUILDOBJ)/Makefile.ec_arch.mk
	$(MAKE) links

Makefile.user.mk:
	touch Makefile.user.mk
$(BUILDOBJ)/Makefile: Makefile.user.mk $(BUILDOBJ)/Makefile.local.mk $(BUILDOBJ)/Makefile.rules.mk $(BUILDOBJ)/Makefile.base_arch.mk $(BUILDOBJ)/Makefile.ec_arch.mk $(BUILDOBJ)/Makefile.dep.mk
	cp $(purplefrog)/include/Makefile.build.mk $(BUILDOBJ)/ 2>/dev/null || true
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
	cp $(purplefrog)/include/Makefile.rules.mk $@ 2>/dev/null || true
	touch $@
$(BUILDOBJ)/Makefile.base_arch.mk:
	cp $(purplefrog)/include/$(BASE_ARCH)/Makefile.arch.mk $@ 2>/dev/null || true
	touch $@
$(BUILDOBJ)/Makefile.ec_arch.mk:
	cp $(purplefrog)/include/$(EC_ARCH)/Makefile.arch.mk $@ 2>/dev/null || true
	touch $@

$(BUILDOBJ)/Makefile.dep.mk:
	pf.update_build_links.ksh
	cd $(BUILDSRC) ;\
	pf.dependencies.pl $(VERBOSE) --deep-include --soft-restriction $(DEP_DUP_OK) $(DEP_FLAT) --out=$(BUILDOBJ)/Makefile.dep.mk --any --short --inc=`find * -type d -name include|tr '\n' ':'` `find * -type d|grep -v include`
	#TODO: remove --any when code is clean from cross dir includes

dep: 
	echo "Re-Building dependency list"
	rm -f $(BUILDOBJ)/Makefile.dep.mk $(BUILDOBJ)/Makefile.local.mk
	$(MAKE_ARCH) $(BUILDOBJ)/Makefile.dep.mk $(BUILDOBJ)/Makefile.local.mk

versionfiles:
	for mydir in `ls $(BUILDSRC)` ; do \
		if [[ -d $${mydir} ]] ; then \
			pf.mk_version_file "$${mydir}" "$(ATM_MODEL_VERSION)" $(BUILDSRC)/$${mydir}/include ;\
			pf.mk_version_file "$${mydir}" "$(ATM_MODEL_VERSION)" $(BUILDSRC)/$${mydir}/include c ;\
			pf.mk_version_file "$${mydir}" "$(ATM_MODEL_VERSION)" $(BUILDSRC)/$${mydir}/include f ;\
		fi ;\
	done
	pf.mk_version_file "$(ATM_MODEL_NAME)" "$(ATM_MODEL_VERSION)" "$(BUILDSRC)"
	pf.mk_version_file "$(ATM_MODEL_NAME)" "$(ATM_MODEL_VERSION)" "$(BUILDSRC)" c
	pf.mk_version_file "$(ATM_MODEL_NAME)" "$(ATM_MODEL_VERSION)" "$(BUILDSRC)" f

clean: sanity
	cd $(BUILDOBJ);\
	$(MAKE_ARCH) $@ ROOT=$(ROOT) VPATH=$(VPATH)
distclean:
	for mydir in $(shell pf.model_link -l build) ; do \
		if [[ $${mydir} != src ]] ; then \
			cd $(BUILD)/$${mydir} ;\
			chmod -R u+w . 2> /dev/null || true ;\
			`find . -type f -exec rm -f {} \; ` ;\
		fi ;\
	done
distclean+:
	cd $(BUILD) ;\
	chmod -R u+w . 2> /dev/null || true ;\
	`find . -type f -exec rm -f {} \; `
	#TODO: need to re-run pf.linkit, no more src
distclean++:
	cd $(BUILD) ;\
	chmod -R u+w . 2> /dev/null || true ;\
	rm -rf * 2> /dev/null || true
	#TODO: need to re-run pf.linkit, no more dir and src

## ====================================================================
