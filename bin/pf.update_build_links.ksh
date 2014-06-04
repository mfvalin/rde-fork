#!/bin/ksh
# @Object: Update files, dirs and links in Build tree for locally modified source
# @Author: S.Chamberland
# @Date:   March 2014
. pf.base.inc.ksh

DESC='Update files, dirs and links in Build tree for locally modified source'
USAGE="USAGE: ${MYSELF} [--resync]"

if [[ x$1 == x-h || x$1 == x--help ]] ; then
	 more <<EOF
$DESC

$USAGE

EOF
    exit 0
fi

EXT4MODLIST=".cdk .hf .fh .itf90 .inc .f .ftn .ptn .f90 .ftn90 .ptn90 .cdk90 .tmpl90 .F .FOR .F90"

for item in ${BUILD_SRC} ${SRC_USR} ${SRC_LIB} ; do
   if [[ ! -d ${item} || ! -w ${item} ]] ; then
	   echo "ERROR: dir does not exist or not writable ${item}"
	   echo "       Try running pf.prep"
	   echo "---- Abort ----"
	   exit 1
   fi
done

resync=0
if [[ x$1 == x--resync ]] ; then
   resync=1
fi

# INCSUFFIXES=".cdk .h .hf .fh .itf90 .inc"
# SRCSUFFIXES=".c .f .ftn .ptn .f90 .ftn90 .ptn90 .cdk90 .tmpl90 .F .FOR .F90"
# VALIDEXT=""
# for item in ${INCSUFFIXES} ${SRCSUFFIXES} ; do
#    VALIDEXT="${VALIDEXT} *${item}"
# done

#mylist=$(ls $VALIDEXT 2>/dev/null)
#modlist=$(ls *.mod 2>/dev/null)
#modnamelist=""


##
#
##
myrm_obj() {
	 _filename=$1
	 _name=${_filename%.*}
	 /bin/rm -f ${ROOT}/${BUILD_OBJ}/${_name}.o > /dev/null || true
}

##
#
##
myrm_pre() {
	 _filename=$1
	 _name=${_filename%.*}
	 _ext=${_filename##*.}
	 if [[ x${_ext} == xftn ]] ; then
		  _name2=${_name}.f
        /bin/rm -f ${ROOT}/${BUILD_PRE}/${_name2} > /dev/null || true
	 elif [[ x${_ext} == xftn90 ||  x${_ext} == xcdk90 ]] ; then
		  _name2=${_name}.f90
        /bin/rm -f ${ROOT}/${BUILD_PRE}/${_name2} > /dev/null || true
	 fi
}

##
#
##
get_present_modules() {
	 _filename=$1
	 _mylist=""
	 for item in $modnamelist ; do
		  item2=$(grep -i $item ${_filename} 2>/dev/null | grep -i module | grep -v '^\s*!' | grep -v '^[c*]')
		  _mylist="${_mylist} $_item2}"
	 done
	 echo ${_mylist}
}

##
#
##
myrm_mod() {
	 _filename=$1
    if [[ x"$(echo "${EXT4MODLIST} " | grep '\.${_filename##*.}\ ')" == x ]] ; then
       return
    fi
	 _modlist=$(get_present_modules ${_filename})
	 for _item in ${_modlist} ; do
	 	  #find . -depth 1 -iname ${_item}.mod -delete 2>/dev/null
		  for _item2 in ${modlist} ; do
				_item2i=$(echo ${_item2} |tr 'A-Z' 'a-z')
				if [[ x${_item2i} == x${_item} ]] ; then
					 /bin/rm -f ${_item2}
				fi
		  done
	 done
}

##
#
##
get_dep_list() {
	 _filename=$1
	 _deplist=""
	 if [[ -r make_cdk ]] ; then
		  _name=${_filename%.*}
		  _ext=${_filename##*.}
		  _filename2=${_name}.a${_ext}
		  _here=$(pwd)
		  cd /
		  _deplist=$(make -f ${_here}/make_cdk -n ${_filename2} | cut -d" " -f2)
		  cd ${_here}
	 fi
	 echo ${_deplist}
}


##
#
##
myrm_dep() {
	 _filename=$1
	 _deplist=$(get_dep_list ${_filename})
	 for _item in ${_deplist} ; do
		  myrm_obj ${_item}
		  myrm_pre ${_item}
		  myrm_mod ${_item}
		  /bin/rm -f ${_item}
	 done
}

##
#
##
myrm_bidon() {
   #TOTO: update
	 # _list="$(grep c_to_f_sw *.c 2>/dev/null | cut -d':' -f1)"
	 # for _item in ${_list} ; do
	 #     /bin/rm -f ${_item%.*}.[co]
	 # done
}

##
#
##
myrm_empty() {
   #TOTO: update
}

#==============================================================================

#remove links and obsolete files
if [[ -d ${ROOT}/${BUILD_SRC} ]] ; then
   cd ${ROOT}/${BUILD_SRC}
   myfilelist="$(find . -type l)"
   for item in ${myfilelist} ; do
      if [[ ! -f ${ROOT}/${SRC_USR}/${item} ]] ; then
		   myrm_obj $item
		   myrm_pre $item
		   myrm_mod $item
         /bin/rm -f $item > /dev/null || true
         if [[ -f ${ROOT}/${SRC_LIB}/${item} ]] ; then
	         cp ${ROOT}/${SRC_LIB}/${item} ${item}
            touch ${item}
         fi
      fi
   done
   myrm_bidon
   myrm_empty
fi

#sync build_src with src_lib
if [[ $resync -eq 1 ]] ; then
   #TODO: remove exiting ${BUILD_SRC}?
   mkdir -p ${ROOT}/${BUILD_SRC} 2>/dev/null || true
   find ${ROOT}/${BUILD_SRC} -type l -exec rm -f {} \;
   cd ${ROOT}/${SRC_LIB}
   for item in $(ls); do
      if [[ -d $item/ ]] ; then
         cp -R $item $ROOT/$BUILD_SRC 2>/dev/null || true
      fi
   done
fi

#Force remove specially marked source dirs
for mydir in ${SRC_LIB} ${SRC_USR} ; do
   cd ${ROOT}/${mydir}
   for item in $(find -L . -name .restricted -type f) ; do
      if [[ x"$(cat $item | grep ${BASE_ARCH}:)" == x && \
            x"$(cat $item | grep ${EC_ARCH}:)" == x ]] ; then
         for mysubdir in ${BUILD_SUB_DIR_LIST} ; do
            rm -rf ${ROOT}/${BUILD}/${mysubdir}/${item%/*} 2>/dev/null || true
         done
      fi
   done
done

cd ${ROOT}/${SRC_USR}

#Force remove specially marked source files
myfilelist="$(find . -type f -name '.rm.*')"
for item0 in ${myfilelist} ; do
    itempath=${item0%/*}
    itemname=${item0##*/}
    item=${itempath}/${itemname#.rm.}
	 myrm_obj $item
	 myrm_pre $item
	 myrm_mod $item
	 /bin/rm -f ${ROOT}/${BUILD_SRC}/${item} > /dev/null || true
done

#re-make links to source files
myfilelist="$(find . -type f)"
for item in ${myfilelist} ; do
    itemname=${item##*/}
    if [[ x$(echo $itemname | cut -c1) != x. ]] ; then
	    /bin/rm -f ${ROOT}/${BUILD_SRC}/${item} > /dev/null || true
       for mydir in ${BUILD_SUB_DIR_LIST} ; do
          if [[ ! -d ${ROOT}/${BUILD}/${mydir}/${item%/*} ]] ; then
             mkdir -p ${ROOT}/${BUILD}/${mydir}/${item%/*} > /dev/null || true
          fi
       done
	    ln -sf ${ROOT}/${SRC_USR}/${item} ${ROOT}/${BUILD_SRC}/${item}
    fi
done

