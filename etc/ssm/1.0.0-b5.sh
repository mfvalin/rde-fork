#!/bin/ksh
export rde_bndl=ENV/x/rde/1.0.0-b5 #${1}
export rde_version=${rde_bndl##*/}
#export rde=/users/dor/armn/sch/SsmBundles/data/rde/${rde_version}
export rde=/users/dor/armn/env/SsmBundles/ENV/d/x/rde/${rde_version}
export RDE_COMPILER_VERSION=1.3.0
export PATH=.:$rde/bin:$PATH
if [[ x$BASE_ARCH == xAIX-powerpc7 ]] ; then
   s.use gmake as make
fi
