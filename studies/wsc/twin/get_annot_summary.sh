#!/bin/bash
indiv_count_file=~/wsc/twin/annot_event_count.txt
echo "ID | DESATURATION | LM | AROUSAL_SPONTANEOUS | AROUSAL RESPIRATORY | AROUSAL PLM  | HYPOPNEA | CENTRAL APNEA | OBSTRUCTIVE APNEA | MIXED APNEA" >${indiv_count_file}
for f in ~/wsc/twin/*_events_extract.txt
do
  id=`cut -d'/' -f6 <<< $f | cut -d'.' -f1 | awk '{print substr($1,1, length($1)-8)}'` #get id for each file
  echo "Working on file with id ${id}"
  row=$(echo -e "${id}\t")
  
  # Add destaturation count to the row
  desat_count=$(grep -e "DESATURATION - " $f | wc -l) 
  row=$(echo -e "${row}${desat_count}\t")

  # Add LM count to the row
  lm_count=$(grep -e "LM - " $f | wc -l)
  row=$(echo -e "${row}${lm_count}\t")

  # Add AROUSAL events counts to the row
  grep -e "AROUSAL - " $f  > arou_tmp.txt
  arou_spon_count=$(grep -e "SPONTANEOUS" arou_tmp.txt | wc -l)
  row=$(echo -e "${row}${arou_spon_count}\t")
  arou_resp_count=$(grep -e "RESPIRATORY EVENT" arou_tmp.txt | wc -l)
  row=$(echo -e "${row}${arou_resp_count}\t")
  arou_plm_count=$(grep -e "LM" arou_tmp.txt | wc -l)
  row=$(echo -e "${row}${arou_plm_count}\t")



  # Add respiratory events counts to the row
  grep -e "RESPIRATORY EVENT - " $f  > resp_tmp.txt
  hypopnea_count=$(grep -e "HYPOPNEA" resp_tmp.txt | wc -l)
  row=$(echo -e "${row}${hypopnea_count}\t")
  central_apnea_count=$(grep -e "CENTRAL APNEA" resp_tmp.txt | wc -l)
  row=$(echo -e "${row}${central_apnea_count}\t")
  obstructive_apnea_count=$(grep -e "OBSTRUCTIVE APNEA" resp_tmp.txt | wc -l)
  row=$(echo -e "${row}${obstructive_apnea_count}\t")
  mixed_apnea=$(grep -e "MIXED APNEA" resp_tmp.txt | wc -l)
  row=${row}${mixed_apnea}

  #Store the row into the file and process next file
  #echo "row is ${row}"
  echo "${row}" >> ${indiv_count_file}
done

rm arou_tmp.txt
rm resp_tmp.txt
