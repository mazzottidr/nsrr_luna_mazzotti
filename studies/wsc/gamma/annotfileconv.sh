#!/bin/bash

DIR=/data/nsrr/working/wsc-scoring-annotations

for f in ${DIR}/gamma/*sco.txt
do
 id=`cut -d'/' -f7 <<< $f | cut -d'.' -f1 | awk '{print substr($1,1, length($1)-3)}'` #get id for each file 
 echo "Working with id ${id}"
 
 tr -d ' ' < $f | awk -F"\t" \
  'function timeadd(t, dur){ 
        start_time="jan 1 1970 + ";
        end="seconds";
        cmd="date -d ";
        space=" ";
        q="\"";
        format=" +\"%H:%M:%S.%2N\"" 
        (cmd q t space start_time dur end q format) | getline end_date;
        return end_date;
   }
   BEGIN { printf "# desat | SaO2 desaturations | min[num] drop[num]\n"; \
          printf "# arousal_spontaneous | Spontaneous Arousal\n"; \
          printf "# arousal_standard | Standard Arousal\n"; \
          printf "# arousal_respiratory | Resp Arousal\n"; \
          printf "# arousal_plm | PLM Arousal\n"; \
          printf "# hypopnea | Hypopnea | min[num]\n"; \
          printf "# apnea_obstructive | Obstructive Apne | min[num]\n"; \
          printf "# apnea_central | Central Apnea | min[num]\n"; \
          printf "# apnea_mixed | Mixed Apnea | min[num]\n";} \ 
      $5 == "SaO2" { print "desat" ,  ".", ".", $7, timeadd($7, $10), $8"|"$9} \
      $5 == "Spon Arousal"|| $5 == "spon arousal"|| $5 == "SPON Arousal" { print "arousal_spontaneous" ,  ".", ".", $7, $7, "." } \
      $5 == "Arousal" { print "arousal_standard" , ".",  "." , $7 , $7, "." } \
      $5 == "RespA"|| $5 == "resp arousal"|| $5 == "Resp Arousal"|| $5 == "RESP Arousal" { print "arousal_respiratory" , ".", "." , $7 , $7, "."} \
      $5 == "LMA" { print "arousal_plm" , ".", "." , $7 , $7, "." } \
      $5 == "Hypopnea"|| $5 == "Central Hypopnea"|| $5 == "Obst. Hypopnea" { print "hypopnea" , ".", "." , $7 , timeadd($7, $10), $8} \
      $5 == "OA"|| $5 == "Obs Apnea"||$5 == "Obst. Apnea"|| $5 == "Obst Apnea"|| $5 == "OBS Apnea"|| $5 == "Apnea" { print "apnea_obstructive" , ".", "." , $7, timeadd($7, $10), $8 } \
      $5 == "CA"|| $5 == "CentralApnea" { print "apnea_central" , ".", "." , $7, timeadd($7, $10), $8} \
      $5 == "MA"|| $5 ==  "MixedApnea" { print "apnea_mixed" , ".", "." , $7, timeadd($7, $10), $8} '  OFS="\t" > ${DIR}/gamma/${id}.annot
done
