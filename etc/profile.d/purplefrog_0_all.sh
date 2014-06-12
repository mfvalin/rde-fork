#!/bin/ksh
export purplefrog_bndl=${1}
export purplefrog_version=${1##*/}
export purplefrog=/users/dor/armn/sch/SsmBundles/data/purplefrog/${purplefrog_version}
export PATH=$purplefrog/bin:$PATH
