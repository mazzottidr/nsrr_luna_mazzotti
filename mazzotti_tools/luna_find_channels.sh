#!/bin/bash

#Create a list of unique channel names for all file sin a folder

run_label=$1
input_folder=$2
output=${input_folder}/processed

mkdir -p $output

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
luna ${input_folder}/s.lst -s DESC
luna ${input_folder}/s.lst -o $output/$run_label.db -s HEADERS
destrat $output/$run_label.db +HEADERS -r CH -v SR > $output/$run_label.headers.txt

# Identify unique channel names and save
cut -f 2 $output/$run_label.headers.txt | sort | uniq -u > $output/$run_label.unique_channel_names.txt


# NAP_OUTPUT argument is helpful in use-cases (ex: Seven Bridges) where there is a need to write output to the home folder
# if [[ ! -z "${NAP_OUTPUT}" ]]; then
#   if [[ "${NAP_OUTPUT}" == "FILE" ]]; then
#     echo "Creating NAP output as tar file with run name and start time info, in the home folder"
#     output_file=~/${run}'_'${start_time}'_output.tar.gz'
#     tar cvzf ${output_file} -C ${output} . && rm -R ${output}
#   elif [[ "${NAP_OUTPUT}" == "DIRECTORY" ]]; then
#     echo "Creating an output directory with run name and start time info, in the home folder"
#     output_folder=~/${run}'_'${start_time}'_output'
#     mkdir -p ${output_folder}
#     mv ${output}* ${output_folder}
#   else
#     echo "Ignoring NAP_OUTPUT as it is not set to FILE or DIRECTORY"
#   fi
# fi



# Move to home folder for output
mv $output/$run_label.unique_channel_names.txt ./

