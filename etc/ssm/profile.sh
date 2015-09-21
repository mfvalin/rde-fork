#!/bin/ksh
export rde_bndl=DEV_BNDL
export rde_version=${rde_bndl##*/}
#export rde=/users/dor/armn/sch/SsmBundles/data/rde/${rde_version}
#export rde=/users/dor/armn/env/SsmBundles/ENV/d/x/rde/${rde_version}
export rde=DEV_DIR
. $rde/bin/.rde.env_setup.dot rde ${rde_version} all $rde $rde
