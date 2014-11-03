#!/bin/ksh
# @Object: Update files, dirs and links in Build tree for locally modified source
# @Author: S.Chamberland
# @Date:   March 2014
. .pfbase.inc.dot

#EXT4MODLIST=".cdk .hf .fh .itf90 .inc .f .ftn .ptn .f90 .ftn90 .ptn90 .cdk90 .tmpl90 .F .FOR .F90"

#TODO: look for alternatives for links (file with file origine/rm) to avoid find operations
#TODO: bidon, empty

## Help
DESC='Update files, dirs and links in Build tree for locally modified source'
USAGE="USAGE: ${MYSELF} [-h] [-v] [-f] [--resync]"
usage_long() {
	 toto=$(echo -e $USAGE)
	 more <<EOF
$DESC

$toto

Options:
    -h, --help     : print this help
    -v, --verbose  : verbose mode
    -f, --force    : force, overwrite present installation 
                     [Not fully implemented yet]
    --resync       : re-do build/src from scratch (from src_ref, src)

EOF
}

## myrm_obj filename.ftn90
myrm_obj() {
	 /bin/rm -f ${ROOT}/${BUILD_OBJ}/${1%.*}.o > /dev/null || true
}

## myrm_pre filename.ftn90
myrm_pre() {
	 _name=${1%.*}
	 _ext=${1##*.}
	 if [[ x${_ext} == xftn ]] ; then
        /bin/rm -f ${ROOT}/${BUILD_PRE}/${_name}.f > /dev/null || true
         myecho 2 "++ rm pre/${_name}.f"
	 elif [[ x${_ext} == xftn90 || x${_ext} == xcdk90 ]] ; then
        /bin/rm -f ${ROOT}/${BUILD_PRE}/${_name}.f90 > /dev/null || true
         myecho 2 "++ rm pre/${_name}.f90"
	 fi
}

## get_modules_in_file filename.ftn90
get_modules_in_file() {
	 # _mylist=""
	 # for item in $modnamelist ; do
	 #     item2=$(grep -i $item ${1} 2>/dev/null | grep -i module | grep -v '^\s*!' | grep -v '^[c*]')
	 #     _mylist="${_mylist} ${_item2}"
	 # done
	 # echo ${_mylist}
   make -s -f ${ROOT}/${BUILD_OBJ}/Makefile.dep.mk echo_mydepvar MYVAR=FMOD_LIST_${1##*/}
}

## myrm_mod filename.ftn90
myrm_mod() {
	 _filename=$1
    #TODO: EXT4MODLIST no defined
    if [[ x"$(echo ${EXT4MODLIST} | grep '\.${_filename##*.}\ ')" == x ]] ; then
       return
    fi
	 _modlist="$(get_modules_in_file ${_filename})"
    for _mymod in ${_modlist} ; do
       for _myfile in $(ls -1 ${ROOT}/${BUILD_MOD}/) ; do
          _myname=$(echo ${_myfile##*/} |tr 'A-Z' 'a-z')
          if [[ x${_myname%.*} == x${_mymod} ]] ; then
             /bin/rm -f ${_myfile}
             myecho 2 "++ rm mod/${_myfile}"
          fi
       done
    done
}

##
myrm_bidon() {
   toto=""
   #TODO: update
	 # _list="$(grep c_to_f_sw *.c 2>/dev/null | cut -d':' -f1)"
	 # for _item in ${_list} ; do
	 #     /bin/rm -f ${_item%.*}.[co]
	 # done
}

##
myrm_empty() {
   toto=""
   #TOTO: update
}

## ====================================================================

## Inline Args
resync=0
myforce=""
while [[ $# -gt 0 ]] ; do
   case $1 in
      (-h|--help) usage_long; exit 0;;
      (-v|--verbose) ((verbose=verbose+1));;
      (-f|--force) myforce=-f;;
      (--resync) resync=1;;
      (--) shift ;;
      *) myerror "Option Not recognized: $1";;
    esac
    shift
done

pf_exit_if_not_pftopdir

#==============================================================================
myecho 1 "++ Checking changes status"
find ${SRC_USR} 2>/dev/null | sort > $TMPDIR/.pfsrcusrls
diff $TMPDIR/.pfsrcusrls ${BUILD}/.pfsrcusrls > /dev/null 2>&1
if [[ x$? == x0 && x$resync == x0 ]] ; then
   myecho 2 "++ Nothing changed since last pfupdate"
   exit 0
fi
if [[ $verbose -ge 2 ]] ; then
   diff $TMPDIR/.pfsrcusrls ${BUILD}/.pfsrcusrls
fi
myecho 2 "++ Updating build links"

myecho 1 "++ Remove dangling links and obsolete files from BUILD_SRC"
cd ${ROOT}/${BUILD_SRC}
for myrelpath in $(find . -type l) ; do
   if [[ ! -f ${ROOT}/${SRC_USR}/${myrelpath} ]] ; then
		myrm_obj $myrelpath
		myrm_pre $myrelpath
		myrm_mod $myrelpath
      /bin/rm -f $myrelpath > /dev/null || true
      myecho 2 "++ rm $myrelpath"
      if [[ -f ${ROOT}/${SRC_REF}/${myrelpath} ]] ; then
	      cp ${ROOT}/${SRC_REF}/${myrelpath} ${myrelpath}
         touch ${myrelpath}
         myecho 1 "++ cp REF $myrelpath"
      fi
   fi
done
myrm_bidon
myrm_empty

if [[ $resync == 1 ]]
then
   myecho 1 "++ reSync BUILD_SRC with src_ref"
   #TODO: remove exiting ${BUILD_SRC}?
   srcrefdirlist="$(cd $ROOT/$SRC_REF ; find -L . -type d | sort | sed 's!\(.\|./\)!!')"
   for _mydir in $BUILD_SUB_DIR_LIST ; do
      if [[ ! -d $STORAGE_BIN/$_mydir ]] ; then
         mkdir -p  $STORAGE_BIN/$_mydir 2>/dev/null || true
         myecho 2 "++ mkdir $_mydir"
      fi
   done
   for _item in ${srcrefdirlist} ; do
      for _mydir in $BUILD_SUB_DIR_LIST0 ; do
         if [[ ! -d $STORAGE_BIN/$_mydir/${_item} ]] ; then
            mkdir -p  $STORAGE_BIN/$_mydir/${_item} 2>/dev/null || true
            myecho 2 "++ mkdir $_mydir/${_item}"
         fi
      done
   done
   cd ${ROOT}/${SRC_REF}
   for item in $(ls); do
      if [[ -d $item/ ]] ; then
         cp -R $item $ROOT/$BUILD_SRC 2>/dev/null || true
         touch $ROOT/$BUILD_SRC/$item
         myecho 1 "++ cp REF $item"
      fi
   done
fi
#end if resync

cd ${ROOT}/${SRC_USR}
srcusrdirlist="$(find -L . -type d | sort | sed 's!\(.\|./\)!!')"

myecho 1 "++ Force remove restricted dirs"
for myreldir in ${srcusrdirlist} ; do
   restricfile=''
   if [[ -f ${ROOT}/${SRC_USR}/${myreldir}/.restricted ]] ; then
      restricfile=${ROOT}/${SRC_USR}/${myreldir}/.restricted
   elif [[ -f ${ROOT}/${SRC_REF}/${myreldir}/.restricted ]] ; then
      restricfile=${ROOT}/${SRC_REF}/${myreldir}/.restricted
   # else
   #    echo Not restricted: ${myreldir} $(ls ${SRC_USR}/${myreldir}/.restricted ${SRC_REF}/${myreldir}/.restricted)
   fi
   if [[ x${restricfile} != x ]] ; then
      if [[ x"$(cat ${restricfile} | grep ${BASE_ARCH}:)" == x && \
            x"$(cat ${restricfile} | grep ${EC_ARCH}:)" == x ]] ; then
         myecho 1 "++ Force remove ${BUILD}/*/${myreldir}"
         for mysubdir in ${BUILD_SUB_DIR_LIST} ; do
            rm -rf ${ROOT}/${BUILD}/${mysubdir}/${myreldir} 2>/dev/null || true
            myecho 2 "++ rm ${mysubdir}/${myreldir}"
         done
      fi
   fi
done

myecho 1 "++ Make sure all SRC_USR dir are mirrored"
for myreldir in ${srcusrdirlist} ; do
   for myreldir2 in ${BUILD_SUB_DIR_LIST0} ; do
      if [[ ! -d ${ROOT}/${BUILD}/${myreldir2}/${myreldir} ]] ; then
         mkdir -p ${ROOT}/${BUILD}/${myreldir2}/${myreldir} 2> /dev/null || true
         myecho 2 "++ mkdir ${myreldir2}/${myreldir}"
      fi
   done
done

myecho 1 "++ Force remove '.rm.*' files"
for myreldir in ${srcusrdirlist} ; do
   for myname in $(cd ${myreldir} ; ls -1 .rm.* 2> /dev/null) ; do
      myrelpath=${myreldir}/${myname#.rm.}
	   myrm_obj ${myrelpath}
	   myrm_pre ${myrelpath}
	   myrm_mod ${myrelpath}
	   /bin/rm -f ${ROOT}/${BUILD_SRC}/${myrelpath} 2> /dev/null || true
      myecho 2 "++ rm ${myrelpath}"
   done
done

myecho 1 "++ Make links to user modified source files"
for myreldir in ${srcusrdirlist} ; do
   for myname in $(cd ${myreldir} ; ls -1 2> /dev/null) ; do
      myrelpath=${myreldir}/${myname}
      if [[ -f ${myrelpath} ]] ; then
         if [[ x"$(true_path ${ROOT}/${SRC_USR}/${myrelpath} 2>/dev/null)" != x"$(true_path ${ROOT}/${BUILD_SRC}/${myrelpath} 2>/dev/null)" ]] ; then
            /bin/rm -f ${ROOT}/${BUILD_SRC}/${myrelpath} 2> /dev/null || true
            ln -s ${ROOT}/${SRC_USR}/${myrelpath} ${ROOT}/${BUILD_SRC}/${myrelpath}
            myecho 1 "++ ln USR $myrelpath"
         fi
      fi
   done
done

if [[ -f .pf.flatsrc ]] ; then
   pflinkflat
fi

mv $TMPDIR/.pfsrcusrls ${ROOT}/${BUILD}/.pfsrcusrls 2>/dev/null
