#!/bin/bash

start_time=$(date +%F_%H-%M-%S)

NAP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

## --------------------------------------------------------------------------------
##
## Arguments
##
## --------------------------------------------------------------------------------

if [[ $# -lt 2 ]]; then
    echo " error: expecting 2-3 arguments"
    echo " usage: ./nap.sh run-label folder [alternate-config-file]"
    exit 1
fi


#
# arg 1 : run label
#

run=$1


#
# arg 2 : root data (upload) folder
#

input=$2


#
# create primary NAP output folder
#

output=${input}/nap/

mkdir -p ${output}

#
# arg 3 : (optional) alternate configuration file
#

conf2=""
if [[ $# -eq 3 ]]; then
    conf2=$3
fi



## --------------------------------------------------------------------------------
##
## Log info
##
## --------------------------------------------------------------------------------

dt=$(date '+%d/%m/%Y %H:%M:%S');

echo "--------------------------------------------------------------------------------" 
echo "NAP v0.02 |  process started: ${dt} "                                            
echo "--------------------------------------------------------------------------------" 


## --------------------------------------------------------------------------------
##
## Configuration file(s)
##
## --------------------------------------------------------------------------------

# default configuration file; options set here can be overwritten if
# an optional config file is specified on command line

conf=${NAP_DIR}/default.conf

# read environment variables from default (and optional) config files
# allexport ensure that environment variables are exported to the current shell

set -o allexport

# echo all commands to log from this point

set -x

test -f ${conf} && source ${conf}

if [[ ! -z "${conf2}" ]]; then
    test -f ${conf2} && source ${conf2}
fi

set +x

set +o allexport

#cat $conf

## --------------------------------------------------------------------------------
##
## Create Luna sample-list, if it doesn't already exist in the upload
##  i.e. allow users to supply their own s.lst file to link EDFs and annotations,
##       or to specify alternate IDs, if the EDFs/IDs/ANNOTs can not be automatically
##       linked via a standard 'build' 
##
## --------------------------------------------------------------------------------

echo 

# create sample list s.lst if it does not already exist
# the default Luna --build option is supplemented by any specofied additional flags
# as defined in NAP_SLST_BUILD_FLAGS: e.g. -ext=-nsrr.xml

if [[ ! -f "${input}/s.lst" ]]; then
 echo "Compiling sample list :  ${input}/s.lst "
 luna --build ${input} ${NAP_SLST_BUILD_FLAGS} | sed 's/\.\///g' > ${input}/s.lst
 # check that this worked
 if [[ ! -f "${input}/s.lst" ]]; then
    echo "could not find sample-list ${input}, bailing"
    exit 1
 elif [ -f /usr/local/bin/aws ]; then
    s_path="$(echo ${NAP_DIR} |  cut -d'/' -f4-5)"
    echo "Copying sample list now"
    aws s3 --profile s3tolocal cp s.lst s3://nap-nsrr/${s_path}"/"
 else
    echo "aws cli is not installed, skipping upload of sample list from NAP"
 fi
else
 echo "Using existing sample list :  ${input}/s.lst " 
fi

slist="${input}/s.lst"

## --------------------------------------------------------------------------------
##
## Extract each EDF and run nap.sh, aiming for N-fold parallelism
##
## --------------------------------------------------------------------------------


echo "LSF qute [${NAP_LSF_NODES}]"

## default queue is 'medium'  NAP_QUEUE

##
## Split up input into 'm' jobs each of size 'n', aiming for ${njobs}-fold parallelization 
##

njobs=${NAP_JOBN}

l=`awk ' NF>0 ' ${slist} | wc -l`
n=`awk ' NF>0 ' ${slist} | wc -l | awk ' function ceiling(x){return x%1 ? int(x)+1 : x}  $1 == 0 { print 0 } $1 > 0 { print ceiling( $1 / k ) } ' k=${njobs} `
m=`awk ' NF>0 ' ${slist} | wc -l | awk ' function ceiling(x){return x%1 ? int(x)+1 : x}  $1 == 0 { print 0 } $1 > 0 { print ceiling( $1/ ceiling( $1 / k ) ) } ' k=${njobs} `

##
## Process each of 'm' jobs, each of of 'n' individual jobs
##

let i=1
for j in `seq 1 $m`
do
let i2=$i+$n-1

if [[ $i2 -gt $l ]]; then
i2=$l
fi

b=$(echo $j | awk '{printf("%05d", $1)}') 
echo " submitting batch ${b} ... individuals m=${i} to n=${i2}"


cmdline="${NAP_DIR}/napn.sh ${run} ${input} $i $i2 $conf2"

# if NAP_JOBN==1 then simple BASH submission; i.e. no parrelisms
if [[ ${NAP_JOBN} -eq 1 ]]; then
 echo $cmdline | bash
else  # use LSF
#echo "$cmdline" | bsub ${NAP_LSF_QUEUE} -n 1 \
#                       ${NAP_LSF_RUSAGE} \
#                       ${NAP_LSF_NODES} \
#                       -o ${output}/tmp/batch${b}.out \
#                       -e ${output}/tmp/batch${b}.err

echo "$cmdline" | bsub -q medium -n 1 -R 'rusage[mem=8000]' -m "cn075 cn076" \
                       -o ${output}/tmp/batch${b}.out \
                       -e ${output}/tmp/batch${b}.err

fi

let i=$i+$n
done

# NAP_OUTPUT argument is helpful in use-cases (ex: Seven Bridges) where there is a need to write output to the home folder
if [[ ! -z "${NAP_OUTPUT}" ]]; then
  if [[ "${NAP_OUTPUT}" == "FILE" ]]; then
    # Create NAP output as tar file with run name and start time info, in the home folder
    output_file=~/${run}'_'${start_time}'_output.tar.gz'
    tar cvzf ${output_file} ${output} && rm -R ${output}
  elif [[ "${NAP_OUTPUT}" == "DIRECTORY" ]]; then
    # Create an output directory with run name and start time info, in the home folder
    output_folder=~/${run}'_'${start_time}'_output'
    mkdir -p ${output_folder}
    mv ${output}* ${output_folder}
  else
    echo "Ignoring NAP_OUTPUT as it is not set to FILE or DIRECTORY"
  fi
fi

## --------------------------------------------------------------------------------
##
## All done
##
## --------------------------------------------------------------------------------

dt=$(date '+%d/%m/%Y %H:%M:%S');

echo "--------------------------------------------------------------------------------" 
echo "NAP v0.02 |  process finished : ${dt} "                                            
echo "--------------------------------------------------------------------------------" 
echo 


## --------------------------------------------------------------------------------
##
## Clean up and quit
##
## --------------------------------------------------------------------------------
