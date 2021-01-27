#!/bin/bash

NAP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# napn.sh {run-label} {folder} {n1} {n2} {alternate-config} 

# this file is called by nap.sh
# napn.sh is the job sent to LSF, containing njobs calls to nap1.sh, from n1 to n2 in the sample list

run=$1
input=$2
n=$3
m=$4
conf2=$5

for j in `seq $n $m`
do

 # get ID from s.lst
 id=`awk -F"\t" ' NR==j { print $1 }' j=${j} ${input}/s.lst`

 # run primary NAP1 script for this indiv
 bash ${NAP_DIR}/nap1.sh ${run} ${input} ${id} {$conf2} 

done

