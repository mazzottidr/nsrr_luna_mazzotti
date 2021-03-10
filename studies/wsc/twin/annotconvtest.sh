#!/bin/bash

# Folder location variable containing wsc original scoring files
DIR=/data/nsrr/working/wsc-scoring-annotations/twin

for f in ${DIR}/*allScore.txt
do

id=`cut -d'/' -f7 <<< $f | cut -d'.' -f1 | awk '{print substr($1,1, length($1)-8)}'` #get id for each file
  echo "Working on file with id ${id}"

 
tr -d '\r' <  $f | sed 's/ - /\t/g' | awk -F"\t" \
   ' function timeadd(t, dur){
        gsub(/SEC./,"",dur); 
        start_time="jan 1 1970 + ";
        end="seconds";
        cmd="date -d ";
        space=" ";
        q="\"";
        format=" +\"%H:%M:%S.%2N\"" 
        (cmd q t spac start_time dur end q format) | getline end_date;
        return end_date;
    }
    function set_start(s_t_sec){
        start_seconds=s_t_sec
    }
    function elapsed_time(curr_time){
        split(curr_time,ann_event_t,":")
        curr_seconds=(ann_event_t[1] * 3600) + (ann_event_t[2] * 60) + ann_event_t[3]
        elapsed_t=curr_seconds-start_seconds
        if( elapsed_t < 0 )
            elapsed_t=elapsed_t+86400
        return elapsed_t
    }    
     BEGIN { printf "# desat | instance | channel | start | stop | elapsed[num] min[num] drop[num]\n"; \
             printf "# arousal_spontaneous | instance | channel | start | stop | elapsed[num]\n"; \
             printf "# arousal_respiratory | instance | channel | start | stop | elapsed[num]\n"; \
             printf "# arousal_plm | instance | channel | start | stop | elapsed[num]\n"; \
             printf "# hypopnea | instance | channel | start | stop | elapsed[num] desat[num]\n"; \
             printf "# apnea_obstructive | instance | channel | start | stop | elapsed[num] desat[num] \n"; \
             printf "# apnea_central | instance | channel | start | stop | elapsed[num] desat[num]\n"; \
             printf "# apnea_mixed | instance | channel | start | stop | elapsed[num] desat[num]\n"; \
             printf "# lm | instance | channel | start | stop | elapsed[num] \n"; \
             printf "# lights_off| instance | channel | start | stop | elapsed[num]\n"; \
             printf "# lights_on | instance | channel | start | stop | elapsed[num]\n"; \
             printf "# paused| instance | channel | start | stop | elapsed[num]\n"; \
             printf "# startrecording | instance | channel | start | stop | elapsed[num]\n"; } \
         $2 == "DESATURATION" {split($3,a,":");split($4,b," ");split($5, c, " "); print "desat",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)"|min="b[2]"|drop="c[2]} \
         $2 == "AROUSAL" && $4 == "SPONTANEOUS" {split($3,a, ":"); print "arousal_spontaneous",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)} \
         $2 == "AROUSAL" && $4 == "RESPIRATORY EVENT" {split($3,a,":"); print "arousal_respiratory",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)} \
         $2 == "AROUSAL" && $4 == "LM" {split($3, a, ":"); print "arousal_plm",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)} \
         $2 == "RESPIRATORY EVENT" && $4 == "HYPOPNEA" {split($3,a,":");split($5,b," "); print "hypopnea",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)"|desat="b[2]} \
         $2 == "RESPIRATORY EVENT" && $4 == "OBSTRUCTIVE APNEA" {split($3,a,":");split($5,b," "); print "apnea_obstructive",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)"|desat="b[2]} \
         $2 == "RESPIRATORY EVENT" && $4 == "CENTRAL APNEA" {split($3,a,":");split($5,b," "); print "apnea_central",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)"|desat="b[2]} \
         $2 == "RESPIRATORY EVENT" && $4 == "MIXED APNEA" {split($3,a,":");split($5,b," "); print "apnea_mixed",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)"|desat="b[2]} \
         $2 == "LM" {split($3,a,":"); print "lm",".",".",$1,timeadd($1,a[2]),"elapsed="elapsed_time($1)} \
         $2 == "LIGHTS OUT" {print "lights_off",".",".",$1,$1,"elapsed="elapsed_time($1)} \
         $2 == "LIGHTS ON" {print "lights_on",".",".",$1,$1,"elapsed="elapsed_time($1)} \
         $2 == "PAUSED" {print "paused",".",".",$1,$1,"elapsed="elapsed_time($1)} \
         $2 == "START RECORDING" {split($1,s_t,":");  set_start((s_t[1] * 3600) + (s_t[2] * 60) + s_t[3])} \
         $2 == "START RECORDING" {print "startrecording",".",".",$1,$1,"elapsed="elapsed_time($1)} ' OFS="\t" > ${DIR}/${id}.annot
done 
