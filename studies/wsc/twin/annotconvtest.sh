#!/bin/bash

# Folder location variable containing wsc original scoring files
DIR=/data/nsrr/working/wsc-scoring-annotations/twin

for f in ${DIR}/*allScore.txt
do

id=`cut -d'/' -f7 <<< $f | cut -d'.' -f1 | awk '{print substr($1,1, length($1)-8)}'` #get id for each file
  echo "Working on file with id ${id}"

 
tr -d '\r' <  $f | sed 's/ - /\t/g' | awk -F"\t" \
   ' BEGIN { printf "# desat | SaO2 desaturations | dur[num] min[num] drop[num]\n"; \
             printf "# arousal_spontaneous | Spon Arousal | dur[num]\n"; \
             printf "# arousal_respiratory | Resp Arousal | dur[num]\n"; \
             printf "# arousal_plm | PLM Arousal | dur[num]\n"; \
             printf "# hypopnea | Hypopnea | dur[num] desat[num]\n"; \
             printf "# apnea_obstructive | Obstructive Apnea | dur[num] desat[num] \n"; \
             printf "# apnea_central | Central Apnea | dur[num] desat[num]\n"; \
             printf "# apnea_mixed | Mixed Apnea | dur[num] desat[num]\n"; \
             printf "# lm | LM | dur[num] \n"; \
             printf "# lights_off| LIGHTS OUT \n"; \
             printf "# lights_on | LIGHTS ON \n"; \
             printf "# paused | PAUSED \n"; \
             printf "# startrecording | START RECORDING \n"; } \
         $2 == "DESATURATION" {split($3,a,":");split($4,b," ");split($5, c, " "); print "desat",".",$1,$1,a[2],b[2]b[3],c[2]c[3]} \
         $2 == "AROUSAL" && $4 == "SPONTANEOUS" {split($3,a, ":"); print "arousal_spontaneous",".",$1,$1,a[2]} \
         $2 == "AROUSAL" && $4 == "RESPIRATORY EVENT" {split($3,a,":"); print "arousal_respiratory",".",$1,$1,a[2]} \
         $2 == "AROUSAL" && $4 == "LM" {split($3, a, ":"); print "arousal_plm",".",$1,$1,a[2]} \
         $2 == "RESPIRATORY EVENT" && $4 == "HYPOPNEA" {split($3,a,":");split($5,b," "); print "hypopnea",".",$1,$1,a[2],b[2]b[3]} \
         $2 == "RESPIRATORY EVENT" && $4 == "OBSTRUCTIVE APNEA" {split($3,a,":");split($5,b," "); print "apnea_obstructive",".",$1,$1,a[2],b[2]b[3]} \
         $2 == "RESPIRATORY EVENT" && $4 == "CENTRAL APNEA" {split($3,a,":");split($5,b," "); print "apnea_central",".",$1,$1,a[2],b[2]b[3]} \
         $2 == "RESPIRATORY EVENT" && $4 == "MIXED APNEA" {split($3,a,":");split($5,b," "); print "apnea_mixed",".",$1,$1,a[2],b[2]b[3]} \
         $2 == "LM" {split($3,a,":"); print "lm",".",$1,$1,a[2]} \
         $2 == "LIGHTS OUT" {print "lights_off",".",$1,$1} \
         $2 == "LIGHTS ON" {print "lights_on",".",$1,$1} \
         $2 == "PAUSED" {print "paused",".",$1,$1} \
         $2 == "START RECORDING" {print "startrecording",".",$1,$1} ' OFS="\t" > ${DIR}/${id}.annot
done
