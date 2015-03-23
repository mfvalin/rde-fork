ifneq (,$(DEBUGMAKE))
$(info ## ====================================================================)
$(info ## File: Makefile.rules.mk)
$(info ## )
endif

ifeq (,$(CONST_BUILD))
   ifneq (,$(DEBUGMAKE))
      $(info include $(ROOT)/include $(MAKEFILE_CONST))
   endif
   include $(ROOT)/$(MAKEFILE_CONST)
endif

INCSUFFIXES = $(CONST_RDESUFFIXINC)
SRCSUFFIXES = $(CONST_RDESUFFIXSRC)

.SUFFIXES :
.SUFFIXES : $(INCSUFFIXES) $(SRCSUFFIXES) .o 

## ==== compilation / load macros

RDEFTN2F = rde.ftn2f $(VERBOSEV2) $(OMP)
RDEFTN902F90 = rde.ftn2f -f90 $(VERBOSEV2) $(OMP)
RDEF77 = rde.f77 $(VERBOSEV2)
RDEF90 = rde.f90 $(VERBOSEV2)
RDEF90_LD = rde.f90_ld $(VERBOSEV2)
RDEFTN77 = rde.ftn77 $(VERBOSEV2)
RDEFTN90 = rde.ftn90 $(VERBOSEV2)
RDECC = rde.cc $(VERBOSEV2)

FTNC77 = export EC_LD_LIBRARY_PATH="" ; $(RDEFTN2F) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) -src
FTNC90 = export EC_LD_LIBRARY_PATH="" ; $(RDEFTN902F90) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) -src
FC77 = export EC_LD_LIBRARY_PATH="" ; $(RDEF77) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_FFLAGS) -c -src
FC90a = $(RDEF90) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_FFLAGS) -c -src
FC90 = export EC_LD_LIBRARY_PATH="" ; $(FC90a)
FC95 = $(FC90)
FC03 = $(FC90)

FTNC77FC77 = $(RDEFTN77) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_FFLAGS) -c -src
FTNC90FC90 = $(RDEFTN90) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_FFLAGS) -c -src

CC = $(RDECC) $(RDEALL_DEFINES) $(RDEALL_INCLUDES) $(RDEALL_CFLAGS) -c -src

# PTNC = sed 's/^[[:blank:]].*PROGRAM /      SUBROUTINE /' | sed 's/^[[:blank:]].*program /      subroutine /'  > $*.f


BUILDFC = export EC_INCLUDE_PATH="" ; $(RDEF90_LD) $(RDEALL_LFLAGS) $(RDEALL_LIBPATH)
BUILDCC = export EC_INCLUDE_PATH="" ; $(RDECC)  $(RDEALL_LFLAGS) $(RDEALL_LIBPATH)
BUILDFC_NOMPI = export EC_INCLUDE_PATH="" ; $(RDEF90_LD) $(RDEALL_LFLAGS_NOMPI) $(RDEALL_LIBPATH)
BUILDCC_NOMPI = export EC_INCLUDE_PATH="" ; $(RDECC)  $(RDEALL_LFLAGS_NOMPI) $(RDEALL_LIBPATH)

DORBUILD4BIDONF = \
	mkdir .bidon 2>/dev/null ; cd .bidon ;\
	.rdemakemodelbidon $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.f90 ;\
	$(FC90a) bidon_$${MAINSUBNAME}.f90 >/dev/null || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.f90 ;\
	cd ..
DORBUILD4BIDONC = \
	mkdir .bidon 2>/dev/null ; cd .bidon ;\
	.rdemakemodelbidon -c $${MAINSUBNAME} > bidon_$${MAINSUBNAME}.c ;\
	$(CC) bidon_$${MAINSUBNAME}.c >/dev/null || status=1 ;\
	rm -f bidon_$${MAINSUBNAME}.c ;\
	cd ..
DORBUILD4EXTRAOBJ = \
	RBUILD_EXTRA_OBJ1="`ls $${RBUILD_EXTRA_OBJ:-_RDEBUILDNOOBJ_} 2>/dev/null`"
DORBUILD4COMMSTUBS = \
	lRBUILD_COMM_STUBS="" ;\
	if [[ x"$${RBUILD_COMM_STUBS}" != x"" ]] ; then \
	   lRBUILD_COMM_STUBS="-l$${RBUILD_COMM_STUBS}";\
	fi
DORBUILDEXTRALIBS = \
	lRBUILD_EXTRA_LIB="" ;\
	if [[ x"$${RBUILD_EXTRA_LIB}" != x"" ]] ; then \
		for mylib in $${RBUILD_EXTRA_LIB} ; do \
	   	lRBUILD_EXTRA_LIB="$${lRBUILD_EXTRA_LIB} -l$${mylib}";\
		done ;\
	fi
DORBUILDLIBSAPPL = \
	lRBUILD_LIBAPPL="" ;\
	if [[ x"$${RBUILD_LIBAPPL}" != x"" ]] ; then \
		for mylib in $${RBUILD_LIBAPPL} ; do \
	   	lRBUILD_LIBAPPL="$${lRBUILD_LIBAPPL} -l$${mylib}";\
		done ;\
	fi
DORBUILD4FINALIZE = \
	rm -f .bidon/bidon_$${MAINSUBNAME}.o 2>/dev/null || true ;\
	if [[ x$${status} == x1 ]] ; then exit 1 ; fi

RBUILD_EXTRA_OBJ0 = *.o

RBUILD4objMPI = RBUILD_EXTRA_OBJ=$(RBUILD_EXTRA_OBJ0) ; $(RBUILD4MPI)
RBUILD4MPI = \
	status=0 ;\
	$(DORBUILD4BIDONF) ;\
	$(DORBUILD4EXTRAOBJ) ;\
	$(DORBUILDLIBSAPPL) ; $(DORBUILDEXTRALIBS) ;\
	$(BUILDFC) -mpi -o $@ $${lRBUILD_EXTRA_LIB} $${lRBUILD_LIBAPPL} $(RDEALL_LIBS) \
	   .bidon/bidon_$${MAINSUBNAME}.o $${RBUILD_EXTRA_OBJ1} $(CODEBETA) || status=1 ;\
	$(DORBUILD4FINALIZE)

RBUILD4objNOMPI = RBUILD_EXTRA_OBJ=$(RBUILD_EXTRA_OBJ0) ; $(RBUILD4NOMPI)
RBUILD4NOMPI = \
	status=0 ;\
	$(DORBUILD4BIDONF) ;\
	$(DORBUILD4EXTRAOBJ) ;\
	$(DORBUILD4COMMSTUBS) ;\
	$(DORBUILDLIBSAPPL) ; $(DORBUILDEXTRALIBS) ;\
	$(BUILDFC_NOMPI) -o $@ $${lRBUILD_EXTRA_LIB} $${lRBUILD_LIBAPPL} $(RDEALL_LIBS) $${lRBUILD_COMM_STUBS}\
	   .bidon/bidon_$${MAINSUBNAME}.o $${RBUILD_EXTRA_OBJ1} $(CODEBETA) || status=1 ;\
	$(DORBUILD4FINALIZE)

RBUILD4objMPI_C = RBUILD_EXTRA_OBJ=$(RBUILD_EXTRA_OBJ0) ; $(RBUILD4MPI_C)
RBUILD4MPI_C = \
	status=0 ;\
	$(DORBUILD4BIDONC) ;\
	$(DORBUILD4EXTRAOBJ) ;\
	$(DORBUILDLIBSAPPL) ; $(DORBUILDEXTRALIBS) ;\
	$(BUILDCC)  -mpi -o $@ $${lRBUILD_EXTRA_LIB} $${lRBUILD_LIBAPPL} $(RDEALL_LIBS) \
	   .bidon/bidon_$${MAINSUBNAME}.o $${RBUILD_EXTRA_OBJ1} $(CODEBETA) || status=1 ;\
	$(DORBUILD4FINALIZE)

RBUILD4objNOMPI_C = RBUILD_EXTRA_OBJ=$(RBUILD_EXTRA_OBJ0) ; $(RBUILD4NOMPI_C)
RBUILD4NOMPI_C = \
	status=0 ;\
	$(DORBUILD4BIDONC) ;\
	$(DORBUILD4EXTRAOBJ) ;\
	$(DORBUILD4COMMSTUBS) ;\
	$(DORBUILDLIBSAPPL) ; $(DORBUILDEXTRALIBS) ;\
	$(BUILDCC_NOMPI) -o $@ $${lRBUILD_EXTRA_LIB} $${lRBUILD_LIBAPPL} $(RDEALL_LIBS) $${lRBUILD_COMM_STUBS}\
	   .bidon/bidon_$${MAINSUBNAME}.o $${RBUILD_EXTRA_OBJ1} $(CODEBETA) || status=1 ;\
	$(DORBUILD4FINALIZE)


## ==== Implicit Rules

# .ptn.o:
# 	#.ptn.o:
# 	rm -f $*.f
# 	$(FC77) $< && touch $*.f

# .ptn.f:
# 	#.ptn.f:
# 	rm -f $*.f
# 	$(FTNC77) $<

#TODO: .FOR.o
#TODO: .tmpl90.o

.ftn.o:
	#.ftn.o:
	rm -f $*.f
	$(FTNC77FC77) $< && touch $*.f
.ftn.f:
	#.ftn.f:
	rm -f $*.f
	$(FTNC77) $<
.f90.o:
	#.f90.o:
	$(FC90) $<
.F90.o:
	#.F90.o:
	$(FC90) $<
.F95.o:
	#.F95.o:
	$(FC95) $<
.F03.o:
	#.F03.o:
	$(FC03) $<
.f.o:
	#.f.o:
	$(FC77) $<
.ftn90.o:
	#.ftn90.o:
	rm -f $*.f90
	$(FTNC90FC90) $< && touch $*.f90
.cdk90.o:
	#.cdk90.o:
	$(FTNC90FC90) $< && touch $*.f90
.cdk90.f90:
	#.cdk90.f90:
	rm -f $*.f90
	$(FTNC90) $<
.ftn90.f90:
	#.ftn90.f90:
	rm -f $*.f90
	$(FTNC90) $<

.c.o:
	#.c.o:
	$(CC) $<

# .s.o:
# 	#.s.o:
# 	$(AS) -c $(CPPFLAGS) $(ASFLAGS) $<

ifneq (,$(DEBUGMAKE))
$(info ## ==== Makefile.rules.mk [END] =======================================)
endif
