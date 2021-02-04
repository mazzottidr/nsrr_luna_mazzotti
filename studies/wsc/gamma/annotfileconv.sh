#!/bin/bash

DIR=/data/nsrr/working/wsc-scoring-annotations
for f in ${DIR}/gamma/*sco.txt
do
 id=`cut -d'/' -f7 <<< $f | cut -d'.' -f1 | awk '{print substr($1,1, length($1)-3)}'` #get id for each file 
tr -d ' ' < ${DIR}/gamma/${id}sco.txt | awk -F"\t" ' { printf "["$5 "]\n" } ' | sort | uniq -c #output raw annotation names 
   BEGIN { printf "# desat   | SaO2 desaturations | dur[num] min[num] drop[num]\n"; \
           printf "# arousal_spontaneous | Spon Arousal \n"; \
           printf "# arousal_standard | Standard Arousal \n"; \
           printf "# arousal_respiratory | Resp Arousal \n"; \
           printf "# arousal_plm | PLM Arousal \n"; \
           printf "# hypopnea | Hypopnea | dur[num] \n"; \
           printf "# apnea_obstructive | Obstructive Apnea | dur[num] \n"; \
           printf "# apnea_central | Central Apnea | dur[num] \n"; \
           printf "# apnea_mixed | Mixed Apnea | dur[num] \n";} \
   $5 == "SaO2" { print "desat" ,  "." , $7 , $7, $8 , $9 , $10 } \
   $5 == "SponArousal"|| $5 == "sponarousal"|| $5 == "SPONArousal" { print "arousal_spontaneous" ,  "." , $7 , $7 } \
   $5 == "Arousal" { print "arousal_standard" ,  "." , $7 , $7 } \
   $5 == "RespA"|| $5 == "resparousal"|| $5 == "RespArousal"|| $5 == "RESPArousal" { print "arousal_respiratory" ,  "." , $7 , $7 } \
   $5 == "LMA" { print "arousal_plm" ,  "." , $7 , $7 } \
   $5 == "Hypopnea"|| $5 == "CentralHypopnea"|| $5 == "Obst.Hypopnea" { print "hypopnea" ,  "." , $7 , $7, $10 } \
   $5 == "OA"|| $5 == "ObsApnea"||$5 == "Obst.Apnea"|| $5 == "ObstApnea"|| $5 == "OBSApnea"|| $5 == "Apnea" { print "apnea_obstructive" ,  "." , $7 , $7, $10 } \
   $5 == "CA"|| $5 == "CentralApnea" { print "apnea_central" ,  "." , $7 , $7, $10 } \
   $5 == "MA"|| $5 ==  "MixedApnea" { print "apnea_mixed" ,  "." , $7 , $7, $10 } '  OFS="\t" > ${id}.annot
done

#raw annotation names output to stdout, manually copied from LSF output email to rawannotnames.txt
#cat rawannotnames.txt|cut -f2|sort|uniq -c used to get list of all annotation headers
#   1827 []
#      3 [Apnea]
#     48 [Arousal]
#      3 [BadECGEpoch]
#      3 [BadSaO2Epoch]
#      5 [CA]
#    921 [CentralApnea]
#      1 [CentralHypopnea]
#   1814 [Hypopnea]
#   1795 [LM]
#   1824 [LMA]
#      1 [MA]
#   1827 [MarkerText]
#    182 [MixedApnea]
#      9 [OA]
#   1151 [ObsApnea]
#    152 [OBSApnea]
#    110 [Obst.Apnea]
#     29 [ObstApnea]
#      1 [Obst.Hypopnea]
#     14 [PLM]
#      3 [PLME]
#      4 [RespA]
#      1 [resparousal]
#    169 [RespArousal]
#    150 [RESPArousal]
#   1826 [SaO2]
#     13 [Snore]
#      1 [SnoreA]
#      4 [sponarousal]
#    184 [SponArousal]
#    155 [SPONArousal]
#for f in ${DIR}/gamma/*sco.txt
#do
#id=`cut -d'/' -f7 <<< $f | cut -d'.' -f1 | awk '{print substr($1,1, length($1)-3)}'`
#tr -d '\r' < ${DIR}/gamma/${id}sco.txt | tr -d ' ' | awk -F"\t" ' 
#   BEGIN { printf "# desat   | SaO2 desaturations | dur[num] min[num] drop[num]\n"; \
#           printf "# arousal_spontaneous | Spon Arousal \n"; \
#           printf "# arousal_standard | Standard Arousal \n"; \
#           printf "# arousal_respiratory | Resp Arousal \n"; \
#           printf "# arousal_plm | PLM Arousal \n"; \
#           printf "# hypopnea | Hypopnea | dur[num] \n"; \
#           printf "# apnea_obstructive | Obstructive Apnea | dur[num] \n"; \
#           printf "# apnea_central | Central Apnea | dur[num] \n"; \
#           printf "# apnea_mixed | Mixed Apnea | dur[num] \n";} \
#   $5 == "SaO2" { print "desat" ,  "." , $7 , $7, $8 , $9 , $10 } \
#   $5 == "SponArousal"|| $5 == "sponarousal"|| $5 == "SPONArousal" { print "arousal_spontaneous" ,  "." , $7 , $7 } \
#   $5 == "Arousal" { print "arousal_standard" ,  "." , $7 , $7 } \
#   $5 == "RespA"|| $5 == "resparousal"|| $5 == "RespArousal"|| $5 == "RESPArousal" { print "arousal_respiratory" ,  "." , $7 , $7 } \
#   $5 == "LMA" { print "arousal_plm" ,  "." , $7 , $7 } \
#   $5 == "Hypopnea"|| $5 == "CentralHypopnea"|| $5 == "Obst.Hypopnea" { print "hypopnea" ,  "." , $7 , $7, $10 } \
#   $5 == "OA"|| $5 == "ObsApnea"||$5 == "Obst.Apnea"|| $5 == "ObstApnea"|| $5 == "OBSApnea"|| $5 == "Apnea" { print "apnea_obstructive" ,  "." , $7 , $7, $10 } \
#   $5 == "CA"|| $5 == "CentralApnea" { print "apnea_central" ,  "." , $7 , $7, $10 } \
#   $5 == "MA"|| $5 ==  "MixedApnea" { print "apnea_mixed" ,  "." , $7 , $7, $10 } '  OFS="\t" > ${id}.annot
#done

