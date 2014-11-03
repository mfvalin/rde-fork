#!/bin/ksh
#
# s.f90

# set EC_LD_LIBRARY_PATH and EC_INCLUDE_PATH using LD_LIBRARY_PATH
# export EC_LD_LIBRARY_PATH=`s.generate_ec_path --lib`
# export EC_INCLUDE_PATH=`s.generate_ec_path --include`

COMPILING_FORTRAN=YES
. s.get_compiler_rules.dot

[[ -n $Verbose ]] && set -x

$F90C ${SourceFile} ${FC_options} ${FFLAGS} \
	$(s.prefix "${Dprefix}" ${DEFINES} ) \
	$(s.prefix "${Iprefix}" ${INCLUDES} ${EC_INCLUDE_PATH}) \
	$(s.prefix "${Lprefix}" ${LIBRARIES_PATH} ${EC_LD_LIBRARY_PATH}) \
	$(s.prefix "${lprefix}" ${LIBRARIES} ${SYSLIBS} ) \
	"$@"
