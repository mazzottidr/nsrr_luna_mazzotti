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
output_root=output
mkdir -p $output_root
mkdir -p ${output_root}/desc
mkdir -p ${output_root}/results

## --------------------------------------------------------------------------------
##
## Log info
##
## --------------------------------------------------------------------------------

mkdir -p ${output_root}/log

LOG=${output_root}/log/run.log
ERR=${output_root}/log/run.err

dt=$(date '+%d/%m/%Y %H:%M:%S');

## --------------------------------------------------------------------------------
##
## Catch errors and clean up 
##
## --------------------------------------------------------------------------------

#set -e

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
#echo "  - collating results in ${output}/" >> $LOG
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

FILES=$input_folder/*


for f in $FILES
do
    echo "Processing $f ..." #>> $LOG
    
    filename="${f##*/}"
    prefix="${filename%.*}"
    
    luna $f -s DESC > ${output_root}/desc/${prefix}.DESC.txt 2>> $ERR
    if [ $? -eq 0 ]; then
        echo "File ${output_root}/desc/${prefix}.txt has been created"  >> $LOG
    else
        rm ${output_root}/desc/${prefix}.DESC.txt
        echo "Something went wrong with file: $f - adding to ${output_root}/results/${run_label}.bad_samples.txt"
        echo $prefix >> ${output_root}/results/${run_label}.bad_samples.txt
    fi
done

# Create outputs
echo "Creating sample list..."
luna --build ${input_folder} | sed 's/\.\///g' > ${output_root}/results/${run_label}.sample.lst

echo "Creating bad samples list..."
echo ${run_label}.bad_samples.txt

echo "Preparing output"
mv ${output_root}/results/${run_label}.sample.lst . # sample list
mv ${output_root}/results/${run_label}.bad_samples.txt . # sample list
mv $LOG . # run.log
mv $ERR . # run.err
