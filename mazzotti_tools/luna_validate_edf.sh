#!/bin/bash

# Run descriptives in a per sample basis, and create s.lst with valid files only

start_time=$(date +%F_%H-%M-%S)


## --------------------------------------------------------------------------------
##
## Arguments 
##
## --------------------------------------------------------------------------------

#Run label
run_label=$1

# Folder with input data
input_folder=$2

# Prepare output folder
output=output
mkdir -p $output


## --------------------------------------------------------------------------------
##
## Log info
##
## --------------------------------------------------------------------------------

mkdir -p ${output}/log

LOG=${output}/log/run.log
ERR=${output}/log/run.err

dt=$(date '+%d/%m/%Y %H:%M:%S');

## --------------------------------------------------------------------------------
##
## Catch errors and clean up 
##
## --------------------------------------------------------------------------------

set -e

cleanup() {
    echo >> $LOG
    echo " *** encountered an error" >> $LOG
    echo " *** see ${ERR} for more details" >> $LOG
    echo >> $LOG

    echo >> $ERR
    echo " *** encountered an error *** " >> $ERR
    echo >> $ERR
}

trap "cleanup" ERR


echo "--------------------------------------------------------------------------------" > $LOG
echo " process started: ${dt} "                                                         >> $LOG
echo "--------------------------------------------------------------------------------" >> $LOG

echo >> $LOG

echo "  - input folder is ${input_folder}" >> $LOG
echo "  - collating results in ${output}/" >> $LOG
echo "  - writing LOG to ${LOG}" >> $LOG
echo "  - writing stderr to ${ERR}" >> $LOG
echo >> $LOG


# # create sample list s.lst if it does not already exist
# if [[ ! -f "${input_folder}/s.lst" ]]; then
#  echo "Compiling sample list :  ${input_folder}/s.lst " >> $LOG
#  luna --build ${input_folder} | sed 's/\.\///g' > ${input_folder}/s.lst
#  # check that this worked
#  if [[ ! -f "${input_folder}/s.lst" ]]; then
#     echo "could not find sample-list ${input_folder}, bailing"
#     exit 1
#  fi
# else
#  echo "Using existing sample list :  ${input_folder}/s.lst " >> $LOG
# fi


# Run DESC, one by one
echo "Running DESC..." >> $LOG

luna --build ${input_folder} | sed 's/\.\///g' > ${input_folder}/s.lst
FILES=$input_folder/*


for f in $FILES
do
    echo "Processing $f ..." #>> $LOG
    
    filename="${f##*/}"
    prefix="${filename%.*}"
    
    luna $f -s DESC > $output/${prefix}.DESC.txt 2>> $ERR
    
    echo "File  $output/${prefix}.txt has been created"  >> $LOG
done






echo "Moving output to the home folder"
mv $output/$run_label.headers.txt . #output
mv $LOG . # run.log
mv $ERR . # run.err
