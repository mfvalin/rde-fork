# @Object: Basic definitions and functions
# @Author: S.Chamberland
# @Date:   March 2014
# @USAGE: . pf.base.inc.ksh

if [[ x"${0##*/}" == x"pf.base.inc.ksh" ]] ; then
   cat<<EOF
=======================================
ERROR: This script should be sourced
       . $0
=======================================
EOF
   exit 1
fi

MYSELF=${0##*/}
COMP_ARCH=${COMP_ARCH:-${EC_ARCH#*/}}
STORAGE_BIN=$(model_path storage)/${COMP_ARCH}
ROOT=$(pwd)
BUILD=$(pf.model_link build)
BUILD_SUB_DIR_LIST="$(pf.model_link -l build)"
BUILD_BIN=$(pf.model_link build/bin)
BUILD_LIB=$(pf.model_link build/lib)
BUILD_MOD=$(pf.model_link build/mod)
BUILD_OBJ=$(pf.model_link build/obj)
BUILD_PRE=$(pf.model_link build/pre)
BUILD_SRC=$(pf.model_link build/src)
SRC_LIB=$(pf.model_link src)
SRC_USR=$(pf.model_link local)
verbose=0

##
#
##
myerror() {
	more <<EOF

ERROR: $1

EOF
   usage_long
   exit 1
}

##
#
##
myecho() {
   if [[ $verbose -ge $1 ]] ; then
      shift
      echo $@ 2>&1
   fi
}
mystdout() {
   myecho $@
}
mystderr() {
   if [[ $verbose -ge $1 ]] ; then
      shift
      echo $@ 1>&2
   fi
}



##
#
##
find_src_local_file() {
   find_src_file ${SRC_USR} $@
}
find_src_lib_file() {
   find_src_file ${SRC_LIB} $@
}
find_src_build_file() {
   find_src_file ${BUILD_SRC} $@
}
find_src_pre_file() {
   find_src_file ${BUILD_PRE} $@
}

find_src_file() {
   _mydir=$1
   _myfile=$2
   _here=$(pwd)
   cd ${ROOT}/${_mydir}
   if [[ -f ${_myfile} ]] ; then
      echo ${_myfile}
   else
      _mypath="$(find -L . -name ${_myfile} -type f 2>/dev/null)"
      echo ${_mypath#./}
   fi
   cd ${_here}
}

find_src() {
   _mydir=$1
   _myfile=$2
   _here=$(pwd)
   cd ${ROOT}/${_mydir}
   if [[ -r ${_myfile} ]] ; then
      echo ${_myfile}
   else
      _mypath="$(find -L . -name ${_myfile} 2>/dev/null)"
      echo ${_mypath#./}
   fi
   cd ${_here}
}

find_src_file_list() {
   _mydir=$1
   _myfile=$2
   _here=$(pwd)
   cd ${ROOT}/${_mydir}
   if [[ -f ${_myfile} ]] ; then
      echo ${_myfile}
   elif [[ -d ${_myfile} ]] ; then
      _mypath="$(find -L ${_myfile} -type f 2>/dev/null)"
      for _myfile2 in $_mypath ; do
         echo ${_myfile2#./}
      done
   else
      _mypath="$(find -L . -name ${_myfile} -type f 2>/dev/null)"
      echo ${_mypath#./}
   fi
   cd ${_here}
}
##
#
##
echo_deleted_tag() {
   _myfile=$1
   _itempath=${_myfile%/*}
   _itemname=${_myfile##*/}
   _itemname2=${_itemname#.rm.}
   echo ${_itempath}/.rm.${_itemname2}
}

echo_undeleted_tag() {
   _myfile=$1
   _itempath=${_myfile%/*}
   _itemname=${_myfile##*/}
   _itemname2=${_itemname#.rm.}
   echo ${_itempath}/${_itemname2}
}

is_src_local_deleted() {
   _myfile=$1
   _itempath=${_myfile%/*}
   _itemname=${_myfile##*/}
   _itemname2=${_itemname#.rm.}
   if [[ -f ${ROOT}/${SRC_LIB}/${_itempath}/${_itemname2}  && \
         -f ${ROOT}/${SRC_USR}/${_itempath}/.rm.${_itemname2} \
         ]] ; then
      echo ${_itempath}/${_itemname2}
   fi
   echo ""
}
