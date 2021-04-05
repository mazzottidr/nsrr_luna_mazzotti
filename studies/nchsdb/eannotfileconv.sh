#!/bin/bash

#################################################################
#
# NCHSDB annotations - converting to NSRR eannots
#
#################################################################

DIR=/data/nsrr/working/nchsdb/Sleep_Data/

for f in ${DIR}/*.tsv
do
  id=`cut -d'/' -f8 <<< $f | cut -d'.' -f1` #get ID for each file
  echo "Working with ID ${id}"

  ne=`luna ${DIR}/${id}.edf silent=1 -s EPOCH min`
  echo $ne
  oe=`grep -e "Sleep stage" -e "move" -e "mvmnt" -e "mvmt"  $f | wc -l`
  echo $oe
  let de=${ne}-${oe}
  echo $de
  echo "adding $de extra epochs (other than stages) at end of ${id}.eannot"
 
  awk -F"\t" -v x=${de} \
     ' BEGIN {}\
       $3 == "Sleep stage W" {print "wake"} \
       $3 == "Sleep stage N1" || $3 == "Sleep stage 1" {print "NREM1"} \
       $3 == "Sleep stage N2" || $3 == "Sleep stage 2" {print "NREM2"} \
       $3 == "Sleep stage N3" || $3 == "Sleep stage 3" {print "NREM3"} \
       $3 == "Sleep stage R" {print "REM"} \
       $3 == "Sleep stage ?" {print "?"} \
       $3 == "move" || $3 == "mvmnt" || $3 == "mvmt" {print "movement"} \
       END { for(i=0;i<x;i++) print "?" }'  OFS="\t" $f > ${DIR}/final/${id}.eannot

  luna ${DIR}/${id}.edf annot-file=${DIR}/final/${id}.eannot -o out.db -s 'SPANNING & ANNOTS'
  echo "From ANNOTS"
  destrat out.db +ANNOTS -r ANNOT
  echo "From SPANNING, i.e. epochs spanned 100%, no overlap"
  destrat out.db +SPANNING | behead

done

# Remove tmp files
rm out.db
