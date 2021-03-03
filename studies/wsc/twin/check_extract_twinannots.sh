#!/bin/bash

# Folder location variable containing wsc original scoring files
DIR=/data/nsrr/working/wsc-scoring-annotations
cols_to_check=2

all_other_events=~/wsc/twin/all_other_events.txt


for f in ${DIR}/twin/*allScore.txt
do
  id=`cut -d'/' -f7 <<< $f | cut -d'.' -f1 | awk '{print substr($1,1, length($1)-8)}'` #get id for each file
  echo "Working on file with id ${id}"  
 
  # check if allscore file is tab delimited with columns equal to cols_to_check var, if not skip and log the file name
  cols_in_file=$(awk -F"\t" ' { print NF } ' ${DIR}/twin/${id}allScore.txt | sort | uniq ) 
  if [[ ! ${cols_in_file} == ${cols_to_check} ]]; then
    echo "${id}  doesn't satisfy columns check, skipping"
    continue
  fi
  
  # Get start and end time of associated EDF using Luna
  luna ${DIR}/twin/${id}.edf -s DESC > desc_out.txt 
  clocktime_line=$(grep -e "Clock time" desc_out.txt)
  clock_range=$(echo ${clocktime_line} | cut -d":" -f2)
  start_time=$(echo ${clock_range} | cut -d"-" -f1 | tr "." ":")
  # end_time=$(echo ${clock_range} | cut -d"-" -f2 | tr "." ":")
  start_time=$(date -d "${start_time}" +%s)
  # end_time=$(date -d "${end_time}" +%s)

  # extract start and end time from original scoring file
  orig_start_time=$(head -1 ${DIR}/twin/${id}allScore.txt | awk -F"\t" '{print $1}')
  # orig_end_time=$(tail -1 ${DIR}/twin/${id}allScore.txt | awk -F"\t" '{print $1}')
  orig_start_time=$(date -d "${orig_start_time}" +%s)
  # orig_end_time=$(date -d "${orig_end_time}" +%s)

  # check if clock time of EDF and original scoring file match
  if [[ ! ${orig_start_time} == ${start_time} ]]; then
     echo "Start time of EDf and original scoring file for ID ${id} doesn't match, skipping" 
    continue
  fi
  # Check if LIGHTS OUT is in original scoring file, if not skip
  check_if_lights_out=$(grep -e "LIGHTS OUT" ${DIR}/twin/${id}allScore.txt  | wc -l)
  if [ ${check_if_lights_out} -eq 0 ]; then
    echo "LIGHTS OUT check failed for id ${id}, skipping"
    continue
  fi


  # Creating extracts output folder
  #output_file=~/wsc/twin/${id}_events_extract.txt
  output_file=${DIR}/twin/${id}_events_extract.txt
  # Extract column 2 with event information
  awk -F"\t" ' { print $2 } ' ${DIR}/twin/${id}allScore.txt > tmp.txt

  # Now, extracting important events - respiratory, destat, LM and arousal
  # Also, extracting events with large occurences
  grep -e "RESPIRATORY EVENT - " -e "DESATURATION - " -e "LM - " -e "AROUSAL - " -e "NEW LOW FILTERS " -e "SA02 FROM " -e "SAO2 FROM " -e "NEW MONTAGE " -e "SAT " -e "NEW SENSITIVITY " -e "NEW HIGH FILTERS " tmp.txt >> ${output_file}

  # Extracting all other events
  grep -Fv -e "RESPIRATORY EVENT - " -e "DESATURATION - " -e "LM - " -e "AROUSAL - " -e "NEW LOW FILTERS" -e "SAO2 FROM " -e "SA02 FROM " -e "NEW MONTAGE " -e "SAT " -e "NEW SENSITIVITY " -e "NEW HIGH FILTERS " tmp.txt | sort | uniq >> ${all_other_events}

done

loop_status=$?
if [ ${loop_status} -eq 1 ]; then
  echo "Looping over all files failed, exiting now"
  exit 1
fi

# Get a count of each event across all the individuals
#all_other_events2=~/wsc/twin/all_other_events2.txt
all_other_events_count=~/wsc/twin/all_other_events_count.txt
sort ${all_other_events} | uniq -c > ${all_other_events_count}
