#!/bin/ksh
# @Object: Update files, dirs and links in Build tree for locally modified source
# @Author: S.Chamberland
# @Date:   March 2014
. .rdebase.inc.dot

## Help
DESC='Update files, dirs and links in Build dir for locally modified source'
USAGE="USAGE: ${MYSELF} [-h] [-v] [-f]"
usage_long() {
	 toto=$(echo -e $USAGE)
	 more <<EOF
$DESC

$toto

Options:
    -h, --help     : print this help
    -v, --verbose  : verbose mode
    -f, --force    : force update build links

EOF
}

rde_exit_if_not_rdetopdir

## Inline Args
myforce=0
while [[ $# -gt 0 ]] ; do
   case $1 in
      (-h|--help) usage_long; exit 0;;
      (-v|--verbose) ((verbose=verbose+1));;
      (-f|--force) myforce=1;;
      (--) shift ;;
      *) myerror "Option Not recognized: $1";;
    esac
    shift
done

## ====================================================================

## myrm_obj filename.ftn90
myrm_obj() {
	 _filename=$1
	 _name=${_filename%.*}
	 /bin/rm -f ${_name}.o
    myecho 2 "++ rm ${_name}.o"
}

## myrm_pre filename.ftn90
myrm_pre() {
	 _filename=$1
	 _name=${_filename%.*}
	 _ext=${_filename##*.}
	 if [[ x${_ext} == xftn ]] ; then
		  /bin/rm -f ${_name}.f
        myecho 2 "++ rm ${_name}.f"
	 elif [[ x${_ext} == xftn90 ||  x${_ext} == xcdk90 ]] ; then
		  /bin/rm -f ${_name}.f90
        myecho 2 "++ rm ${_name}.f90"
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
   make -s -f ${ROOT}/Makefile.dep.mk echo_mydepvar MYVAR=FMOD_LIST_${1##*/}
}

## myrm_mod filename.ftn90
myrm_mod() {
	 _filename=$1
    # if [[ x"$(echo ${EXT4MODLIST} | grep '\.${_filename##*.}\ ')" == x ]] ; then
    #    return
    # fi
	 _modlist="$(get_modules_in_file ${_filename})"
    for _mymod in ${_modlist} ; do
       for _myfile in $(ls -1) ; do
          _myname=$(echo ${_myfile##*/} |tr 'A-Z' 'a-z')
          if [[ x${_myname%.*} == x${_mymod} ]] ; then
             /bin/rm -f ${_myfile}
             myecho 2 "++ rm ${_myfile}"
          fi
       done
    done
}

## get_dep_list filename.ftn90
get_dep_list() {
	 _filename=$1
	 _deplist=""
    #TODO: update
	 # if [[ -r make_cdk ]] ; then
	 #     _name=${_filename%.*}
	 #     _ext=${_filename##*.}
	 #     _filename2=${_name}.a${_ext}
	 #     _deplist=`make -f ${ROOT}/make_cdk -n ${_filename2} | cut -d" " -f2`
	 # fi
	 echo ${_deplist}
}


## myrm_dep filename.ftn90
myrm_dep() {
	 _filename=$1
    #TODO: update
	 # _deplist="$(get_dep_list ${_filename})"
	 # for _item in ${_deplist} ; do
	 #     myrm_obj ${_item}
	 #     myrm_pre ${_item}
	 #     myrm_mod ${_item}
	 #     /bin/rm -f ${_item}
    #     myecho 2 "++ rm ${_item}"
	 # done
}

##
myrm_bidon() {
	 _list="`grep c_to_f_sw *.c 2>/dev/null | cut -d':' -f1`"
	 for _item in ${_list} ; do
		  /bin/rm -f ${_item%.*}.[co]
        myecho 2 "++ rm ${_item%.*}.[co]"
	 done
}

##
myrm_empty() {
   toto=""
   #TOTO: update
}

## ====================================================================
#VALIDEXTWILD="*.F *.F90 *.f *.f90 *.ftn *.ftn90 *.cdk *.cdk90 *.fh* *.inc *.h* *.c *.cpp"
VALIDEXTWILD="$(echo $VALIDEXT | sed 's/\./*./g')"

mylist="$(ls $SRC_PATH_FILE Makefile.build.mk Makefile.rules.mk Makefile.dep.mk Makefile.user.mk $VALIDEXTWILD 2>/dev/null | sort)"

BUILDSRC=$(rdevar build/src)
cd ${BUILDSRC}

## Checking changes status
echo $mylist > $TMPDIR/.rdesrcusrls
diff $TMPDIR/.rdesrcusrls .rdesrcusrls > /dev/null 2>&1
if [[ x$? == x0 && $myforce == 0 ]] ; then
   /bin/rm -f Makefile
   ln -s Makefile.build.mk Makefile
   myecho 1 "++ Nothing changed since last rdeupdate"
   exit 0
fi
myecho 2 "++ Updating build links"

## Remove dangling links and obsolete files
for item in * ; do
	 if [[ -L $item ]] ; then
		  if [[ ! -f $ROOT/$item ]] ; then
				myrm_obj $item
				myrm_pre $item
				myrm_mod $item
				myrm_dep $item #when $item is .cdk or .cdk90... need to remove .o, .mod of files having it as a dependency, use make_cdk for that
				/bin/rm -f $item
		  fi
	 fi
done
myrm_bidon
myrm_empty

## re-make links to source files
for item in $mylist ; do
	 /bin/rm -f $item
	 ln -s ${ROOT}/$item $item
done

/bin/rm -f Makefile
ln -s Makefile.build.mk Makefile

mv $TMPDIR/.rdesrcusrls . 2>/dev/null
