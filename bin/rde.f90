#!/bin/ksh
#
# s.f90

# set EC_LD_LIBRARY_PATH and EC_INCLUDE_PATH using LD_LIBRARY_PATH
#export EC_LD_LIBRARY_PATH=`s.generate_ec_path --lib`
#export EC_INCLUDE_PATH=`s.generate_ec_path --include`

COMPILING_FORTRAN=YES
. rde.get_compiler_rules.dot

_mydefines="$(s.prefix "${Dprefix}" ${DEFINES} )"
_myincludes="$(s.prefix "${Iprefix}" ${INCLUDES} ${EC_INCLUDE_PATH})"
_mylibpath="$(s.prefix "${Lprefix}" ${LIBRARIES_PATH} ${EC_LD_LIBRARY_PATH})"
_mylibs="$(s.prefix "${lprefix}" ${LIBRARIES} ${SYSLIBS} )"

if [[ -n $Verbose ]] ; then
   cat <<EOF

$F90C ${SourceFile} ${FC_options} ${FFLAGS} \\
	$_mydefines \\
	$_myincludes \\
	$_mylibpath \\
	$_mylibs \\
	"$@"

EOF
fi

$F90C ${SourceFile} ${FC_options} ${FFLAGS} \
	$_mydefines \
	$_myincludes \
	$_mylibpath \
	$_mylibs \
	"$@"
