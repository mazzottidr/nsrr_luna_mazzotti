#!/bin/bash

#Create a list of unique channel names for all files in a folder


start_time=$(date +%F_%H-%M-%S)
NAP_OUTPUT="FILE"

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
output=${input_folder}/processed
mkdir -p $output


## --------------------------------------------------------------------------------
##
## Log info
##
## --------------------------------------------------------------------------------

mkdir -p ${input_folder}/log

LOG=${input}/log/run.log
ERR=${input}/log/run.err

dt=$(date '+%d/%m/%Y %H:%M:%S');

## --------------------------------------------------------------------------------
##
## Catch errors and clean up 
##
## --------------------------------------------------------------------------------

set -e

cleanup() {
    echo >> $LOG
    echo " *** encountered an error in NAP" >> $LOG
    echo " *** see ${ERR} for more details" >> $LOG
    echo >> $LOG

    echo >> $ERR
    echo " *** encountered an error in NAP *** " >> $ERR
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


# create sample list s.lst if it does not already exist
if [[ ! -f "${input_folder}/s.lst" ]]; then
 echo "Compiling sample list :  ${input_folder}/s.lst " >> $LOG
 luna --build ${input_folder} | sed 's/\.\///g' > ${input_folder}/s.lst
 # check that this worked
 if [[ ! -f "${input_folder}/s.lst" ]]; then
    echo "could not find sample-list ${input}, bailing"
    exit 1
 fi
else
 echo "Using existing sample list :  ${input}/s.lst " >> $LOG
fi


# Run headers pipeline
echo "Running HEADERS..." >> $LOG
luna ${input_folder}/s.lst -o $output/$run_label.db -s HEADERS 2>> $ERR
destrat $output/$run_label.db +HEADERS -r CH -v SR > $output/$run_label.headers.txt 

# Identify unique channel names and save
cut -f 2 $output/$run_label.headers.txt | sort | uniq -u > $output/$run_label.unique_channel_names.txt

echo "File $output/$run_label.unique_channel_names.txt has been created"  >> $LOG

echo "Moving output to the home folder"
mv $output/$run_label.unique_channel_names.txt .
mv $LOG . # run.log
mv $ERR . # run.err
