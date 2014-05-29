## ====================================================================
## File: $purplefrog/include/Makefile.rules.mk
##

INCSUFFIXES = .cdk .h .hf .fh .itf90 .inc 
SRCSUFFIXES = .c .f .ftn .ptn .f90 .ftn90 .ptn90 .cdk90 .tmpl90 .F .FOR .F90

.SUFFIXES :
.SUFFIXES : $(INCSUFFIXES) $(SRCSUFFIXES) .o 

RCOMPIL = pf.compile $(MPI) $(OMP) -includes ./ $(INCLUDE_PATH) $(INCLUDE_MOD)  $(DEBUGCOMPFLAGS)
RBUILD  = pf.compile $(DEBUGLINKFLAGS) -libpath ./ $(LIBRARY_PATH)
FCOMPF = 
CCOMPF =
COMPF = 
FC   = $(RCOMPIL) -defines "=$(DEFINE)" -O $(OPTIL) -optf="$(FFLAGS)" $(COMPF) $(FCOMPF) -src
FTNC = $(RCOMPIL) -defines "=$(DEFINE)"             -optf="$(FFLAGS) $(CPPFLAGS)" -P $(COMPF) $(FCOMPF) -src
CC   = $(RCOMPIL) -defines "=$(DEFINE)" -O $(OPTIL) -optc="$(CFLAGS)" $(COMPF) $(CCOMPF) -src

BUILDPRE = $(ROOT)/$(shell pf.model_link build/pre)
BUILDMOD = $(ROOT)/$(shell pf.model_link build/mod)

RBUILD3MPI = \
	status=0 ;\
	pf.makemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ; \
	$(MAKE) bidon_$${MAINSUBNAME}.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}.f90 ;\
	$(RBUILD) -obj *.o -o $@ $(OMP) $(MPI) \
		-libpath $(LIBPATH) \
		-libappl $(LIBAPPL) \
		-librmn $(RMN_VERSION) \
		-libsys $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optf "=$(LFLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

RBUILD3NOMPI = \
	status=0 ;\
	pf.makemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ; \
	$(MAKE) bidon_$${MAINSUBNAME}.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}.f90 ;\
	$(RBUILD) -obj *.o -o $@ $(OMP) \
		-libpath $(LIBPATH) \
		-libappl $(LIBAPPL) $${COMM_stubs1} \
		-librmn $(RMN_VERSION) \
		-libsys $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optf "=$(LFLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

RBUILD3NOMPI_C = \
	status=0 ;\
	pf.makemodelbidon -c $${MAINSUBNAME} > bidon_$${MAINSUBNAME}_c.c ; \
	$(MAKE) bidon_$${MAINSUBNAME}_c.o >/dev/null || status=1 ; \
	rm -f bidon_$${MAINSUBNAME}_c.c ;\
	$(RBUILD) -obj *.o -o $@ $(OMP) -conly \
		-libpath $(LIBPATH) \
		-libappl $(LIBAPPL) $${COMM_stubs1} \
		-librmn $(RMN_VERSION) \
		-libsys $(LIBSYS) \
		-codebeta $(CODEBETA) \
		-optc "=$(LCLAGS)"  || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}_c.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

.c.o:
	cd $(dir $@) ;\
	$(CC) $<
	#.c.o
.f.o:
	cd $(dir $@) ;\
	$(FC) $<
	#.f.o
.f90.o:
	cd $(dir $@) ;\
	$(FC) $<
	#.f90.o:
.F.o:
	s.f77 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)
.F90.o:
	s.f90 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)
.ftn.o:
	rm -f $*.f
	cd $(dir $@) ;\
	$(FTNC) $<
	mv -f $*.f $(BUILDPRE)/$*.f
	cd $(dir $@) ;\
	$(FC) $(BUILDPRE)/$*.f
	#.ftn.o
.ftn90.o:
	rm -f $*.f90
	cd $(dir $@) ;\
	$(FTNC) $<
	mv -f $*.f90 $(BUILDPRE)/$*.f90
	cd $(dir $@) ;\
	$(FC) $(BUILDPRE)/$*.f90
	#.ftn90.o
.cdk90.o:
	rm -f $*.f90
	cd $(dir $@) ;\
	$(FTNC) $<
	mv -f $*.f90 $(BUILDPRE)/$*.f90
	cd $(dir $@) ;\
	$(FC) $(BUILDPRE)/$*.f90
	cd $(dir $@) ;\
	mv -f *.[mM][oO][dD] $(BUILDMOD) 2>/dev/null || true
	#TODO: mv -f *.[mM][oO][dD] is dangerous with parallel make [-j]
	#.cdk90.o:
.tmpl90.o:
	s.tmpl90.ftn90 < $<  > $*.ftn90
	s.ftn90 -c -o $@ -src $(EC_ARCH)/$*.ftn90 $(COMPILE_FLAGS) $(FFLAGS)
	#.tmpl90.o

.ftn.f:
	rm -f $*.f
	cd $(dir $@) ;\
	$(FTNC) $<
	mv -f $*.f $(BUILDPRE)/$*.f 2>/dev/null || true
	#.ftn.o
.ftn90.f90:
	rm -f $*.f90
	cd $(dir $@) ;\
	$(FTNC) $<
	mv -f $*.f90 $(BUILDPRE)/$*.f90 2>/dev/null || true
	#.ftn90.o
.cdk90.f90:
	rm -f $*.f90
	cd $(dir $@) ;\
	$(FTNC) $<
	mv -f $*.f90 $(BUILDPRE)/$*.f90 2>/dev/null || true
# .tmpl90.ftn90:
# 	s.tmpl90.ftn90 < $<  > $@

# EXTRACTSRC0 = if [[ ! -f $@ ]] ; then omd_exp $@ ; fi ; if [[ ! -f $@ ]] ; then exit 1 ; fi
# EXTRACTSRC = if [[ ! -f $@ ]] ; then e2.co $@ ; fi ; if [[ ! -f $@ ]] ; then exit 1 ; fi
# %.c:
# 	$(EXTRACTSRC)
# %.f:
# 	$(EXTRACTSRC)
# %.ftn:
# 	$(EXTRACTSRC)
# %.ptn:
# 	$(EXTRACTSRC)
# %.f90:
# 	$(EXTRACTSRC)
# %.ftn90:
# 	$(EXTRACTSRC)
# %.ptn90:
# 	$(EXTRACTSRC)
# %.cdk:
# 	$(EXTRACTSRC)
# %.cdk90:
# 	$(EXTRACTSRC)
# %.tmpl90:
# 	$(EXTRACTSRC)
# %.F:
# 	$(EXTRACTSRC)
# %.FOR:
# 	$(EXTRACTSRC)
# %.F90:
# 	$(EXTRACTSRC)
# %.h:
# 	$(EXTRACTSRC)
# %.hf:
# 	$(EXTRACTSRC)
# %.fh:
# 	$(EXTRACTSRC)
# %.itf90:
# 	$(EXTRACTSRC)
# %.inc:
# 	$(EXTRACTSRC)

# .ftn90.itf90:
# 	$(FTNC) $< -defines =-DAPI_ONLY ; mv -f $*.f90 $*.itf90
# 	#mu.ftn2f -f90 -defines "=$(DEFINE)" -optf="$(FFLAGS) $(CPPFLAGS)" -P $(COMPF) $(FCOMPF) -src $<  > $@
# 	#r.gppf -lang-f90+ -chop_bang -gpp -F -D__FILE__=\"#file\" -D__LINE__=#line $
#{vincludes[@]} -DAPI_ONLY $< > $@

# .c.o:
# 	s.cc -c -o $@ -src $< $(COMPILE_FLAGS) $(CFLAGS) 
# .f.o:
# 	s.f77 -c -o $@ -src $< $(COMPILE_FLAGS) $(FFLAGS)
# .f90.o:
# 	s.f90 -c -o $@ -src $< $(COMPILE_FLAGS) $(FFLAGS)
# .ftn.o:
# 	s.ftn -c -o $@ -src $< $(COMPILE_FLAGS) $(FFLAGS)
# .ftn90.o:
# 	s.ftn90 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)
# .cdk90.o:
# 	s.ftn90 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)
.for.o:
	s.f77 -c -o $@ -src $< $(COMPILE_FLAGS) $(FFLAGS)
.FOR.o:
	s.f77 -c -o $@ -src $<  $(COMPILE_FLAGS) $(FFLAGS)

#%_interface.cdk90 : %.tmpl90
#	FileName=$@ ; cat $< | r.tmpl90.ftn90 - $${FileName%.ftn90}

## ====================================================================
