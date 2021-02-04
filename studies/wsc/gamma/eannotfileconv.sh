#!/bin/bash
#################################################################
#
# Testing WSC annotation formats / converting to NSRR
#
#################################################################

DIR=/data/nsrr/working/wsc-scoring-annotations

ls -lR ${DIR}

for f in ${DIR}/gamma/*stg.txt
do
  id=`cut -d'/' -f7 <<< $f | cut -d'.' -f1 | awk '{print substr($1,1, length($1)-3)}'`
  ne=`luna ${DIR}/gamma/${id}.edf silent=1 -s EPOCH min | grep NE | awk '{print $6}'`
  echo ${f}
  echo $ne
  oe=`wc -l  $f | awk ' { print $1 - 1 } '`
  echo $oe
  let de=${ne}-${oe}
  echo $de
  echo "adding $de extra epochs at end of ${DIR}/gamma/${id}stg.txt"
  echo "Encoding Check"
  awk ' NR != 1 { print $2 } ' ${DIR}/gamma/${id}stg.txt | sort | uniq -c
tr -d '\r' < ${DIR}/gamma/${id}stg.txt | \
awk -v x=${de} ' BEGIN { s[0] = "wake" ; s[1]="N1"; s[2]="N2"; s[3]="N3"; s[5]="REM"; s[7]="?" } NR != 1 { print s[$2] } END { for(i=0;i<x;i++) print "?" } ' > ${id}.eannot
echo "Line Count"
wc ${id}.eannot
luna ${DIR}/gamma/${id}.edf annot-file=${id}.eannot -o out.db -s 'SPANNING & ANNOTS'
echo "From ANNOTS"
destrat out.db +ANNOTS -r ANNOT
echo "From SPANNING, i.e. epochs spanned 100%, no overlap"
destrat out.db +SPANNING | behead
done

