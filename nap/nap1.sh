#!/bin/bash

NAP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


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


## --------------------------------------------------------------------------------
##
## Arguments
##
## --------------------------------------------------------------------------------

if [[ $# -lt 3 ]]; then
    echo " error: expecting 3+ arguments"
    echo " usage: ./nap.sh project root ID [config-file]"    
    exit 1
fi

#
# arg 1 : run label/group
#

run=$1

#
# arg 2 : root data (upload) folder
#

input=$2

#
# create primary NAP output folder, if doesn't already exist
#

output=${input}/nap/

mkdir -p ${output}

#
# arg 3 : EDF ID in s.lst  (i.e. to select one out of the 1+ EDFs in the upload folder)
#

id=$3

#
# arg 4 : (optional) alternate configuration file
#

conf2=""
if [[ $# -eq 4 ]]; then
    conf2=$4
fi


## --------------------------------------------------------------------------------
##
## Configuration file(s)
##
## --------------------------------------------------------------------------------

# default configuration file; options set here can be overwritten if
# an optional config file is specified on command line

conf="default.conf"

# echo all commands to log from this point

set -x

# read environment variables from default (and optional) config files
# allexport ensure that environment variables are exported to the current shell

set -o allexport

test -f ${conf} && source ${conf}

if [[ ! -z "${conf2}" ]]; then
    test -f ${conf2} && source ${conf2}
fi

set +o allexport



## --------------------------------------------------------------------------------
##
## Log info
##
## --------------------------------------------------------------------------------

mkdir -p ${input}/nap/${id}/

LOG=${input}/nap/${id}/nap.log
ERR=${input}/nap/${id}/nap.err

dt=$(date '+%d/%m/%Y %H:%M:%S');


echo "--------------------------------------------------------------------------------" > $LOG
echo "NAP ${NAP_VERSION} | ${id} | process started: ${dt} "                           >> $LOG
echo "--------------------------------------------------------------------------------" >> $LOG


## --------------------------------------------------------------------------------
##
## Create Luna sample-list, if it doesn't already exist in the upload
##  i.e. allow users to supply their own s.lst file to link EDFs and annotations,
##       or to specify alternate IDs, if the EDFs/IDs/ANNOTs can not be automatically
##       linked via a standard 'build' 
##
## --------------------------------------------------------------------------------

echo >> $LOG

echo "Processing EDF ${id}" >> $LOG
echo "  - input folder is ${input}" >> $LOG
echo "  - collating results in ${output}/${id}" >> $LOG
echo "  - writing LOG to ${LOG}" >> $LOG
echo "  - writing stderr to ${ERR}" >> $LOG
echo "  - using NAP resources located at ${NAP_RESOURCE_DIR}" >> $LOG
echo >> $LOG

# create sample list s.lst if it does not already exist

if [[ ! -f "${input}/s.lst" ]]; then
 echo "Compiling sample list :  ${input}/s.lst " >> $LOG
 ${NAP_LUNA} --build ${input} ${NAP_SLST_BUILD_FLAGS} | sed 's/\.\///g' > ${input}/s.lst
 # check that this worked
 if [[ ! -f "${input}/s.lst" ]]; then
    echo "could not find sample-list ${input}, bailing"
    exit 1
 fi
else
 echo "Using existing sample list :  ${input}/s.lst " >> $LOG
fi



## --------------------------------------------------------------------------------
##
## Template
##
## --------------------------------------------------------------------------------

# echo "Running <command>..." >> $LOG
# <command> <input folder/id> <output> 2>> $ERR

#  ${input}         input folder (with 1 or more EDFs/annotations)
#  ${input}/s.lst   Luna format sample list (for 1 or more EDFs in this folder)
#  ${id}            ID of EDF (fileroot, id.edf)
#  ${output}        output folder
#  $ERR             standard error, redirected to:  ${output}/nap.err

# all output to ${output} should be tab-delimited files, adhering to naming
# convention described on the merge confluence page

echo "Logging for [ ${id} ] to [ ${input} ]" 2> $ERR


## --------------------------------------------------------------------------------
##
## Assumptions
##
## --------------------------------------------------------------------------------

# 1) NAP 0.02 assumes that manual staging is present, with at least some NREM2/3
#    epochs present

# 2) Assumes a canonical signal definition file ${NAP_DEF_DIR)/sigs.canonical

# 3) Assumes that the 'run label' matches the GROUP in the canonical definitions file


## --------------------------------------------------------------------------------
##
## Output file name conventions
##
## --------------------------------------------------------------------------------

# <domain>_<group>_<command>.txt
# <domain>_<group>_<command>_F1_F2.txt
# <domain>_<group>_<command>_F1-C3_F2-22.txt
# <domain>_<group>_<command>_F1-C3_F2--22.txt  // allowed --> F2 is '-22'


## --------------------------------------------------------------------------------
##
## A canonical signal definition file is required
##
## --------------------------------------------------------------------------------

if [[ -f "${NAP_DEF_DIR}/sigs.canonical" ]]; then
  echo "Found canonical signal definitions : ${NAP_DEF_DIR}/sigs.canonical" >> $LOG
else
  echo "Could not find a canonical signal definition file, expected at : ${NAP_DEF_DIR}/sigs.canonical" >> $LOG
  echo "NAP requires a canonical signal definition... bailing" >> $LOG
  exit 0
fi


## --------------------------------------------------------------------------------
##
## NAP annotations will be deposited here
##
## --------------------------------------------------------------------------------


mkdir -p ${output}/${id}/annots

## --------------------------------------------------------------------------------
##
## For parsing output, use domain+group+file+{factors}.txt convention [ for dmerge tool ]
## For convenience, create some variables here, using tt-prepend
##
## --------------------------------------------------------------------------------

# Basic EDF : HEADERS, CANONICAL, FLIP
dom_core="tt-prepend=luna_core_"

# Signal stats : STATS, SIGSTATS
dom_stats="tt-prepend=luna_stats_"

# HYPNO
dom_macro="tt-prepend=luna_macro_"

# SUDS and SOAP-SUDS
dom_suds="tt-prepend=luna_suds_"

# spectral (PSD & MTM)
dom_spec="tt-prepend=luna_spec_"

# spindles and slow oscillations: SPINDLES SO
dom_spso="tt-prepend=luna_spso_"


## --------------------------------------------------------------------------------
##
## Basic QC (on original EDF)
##
## --------------------------------------------------------------------------------

echo "Running HEADERS..." >> $LOG
${NAP_LUNA} ${input}/s.lst ${id} ${NAP_LUNA_ARGS} -t ${output} ${dom_core} -s HEADERS 2>> $ERR

echo "Running HYPNO..." >> $LOG
${NAP_LUNA} ${input}/s.lst ${id} ${NAP_LUNA_ARGS} -t ${output} ${dom_macro} -s HYPNO 2>> $ERR

echo "Running SIGSTATS..." >> $LOG
${NAP_LUNA} ${input}/s.lst ${id} ${NAP_LUNA_ARGS} -t ${output} ${dom_stats} -s 'SIGSTATS epoch sr-over=50' 2>> $ERR

echo "Running STATS..." >> $LOG
${NAP_LUNA} ${input}/s.lst ${id} ${NAP_LUNA_ARGS} -t ${output} ${dom_stats} -s 'STATS epoch sr-under=50' 2>> $ERR


## --------------------------------------------------------------------------------
##
## MTM spectrograms (original EDF, all channels with SR>50)
##
## --------------------------------------------------------------------------------

echo "Running MTM EEG spectrograms..." >> $LOG
${NAP_LUNA} ${input}/s.lst ${id} ${NAP_LUNA_ARGS} \
	    fs=${NAP_MTM_MIN_SAMPLE_RATE} \
	    -t ${output} ${dom_spec} -s 'MTM segment-sec=30 segment-inc=10 min=0.5 max=25 nw=15 epoch sr=${fs}' 2>> $ERR


## --------------------------------------------------------------------------------
##
## Compile SIGSTATS and MTM spectograms results into R dataframes for viewing (luna/shiny)
##
## --------------------------------------------------------------------------------

echo "Compiling SIGSTATS and MTM spectrograms into RData files..." >> $LOG

# i.e.     path/to/folder/text.txt
# becomes  path/to/folder/text.txt-tab.RData
#      or  path/to/folder/text.txt-fig.RData
# luna-shiny then automatically loads any *-tab.RData and *-fig.RData files
 
# See example of MTM plot for how to save / attach images, points to .png files, 
# which can either be created in coda1.R based
#  on summary stats, or indpendently (in which case a *-fig.RData file is created
#  which just points to the existing .png

${NAP_R} ${NAP_DIR}/coda1.R ${NAP_DIR} ${NAP_RESOURCE_DIR} ${output}/${id} >> $ERR 2>&1


## --------------------------------------------------------------------------------
##
## Diagnose any potential EEG polarity issues (for csEEG only)
##
## --------------------------------------------------------------------------------

echo "Attempting to determine EEG polarity (of canonical EEG only)..." >> $LOG

# write to a temporary, use pol.db rather than a text-table
# expecting csEEG

${NAP_LUNA} ${input}/s.lst ${id} ${NAP_LUNA_ARGS} \
             csfile=${NAP_DEF_DIR}/sigs.canonical \
             group=${run} \
            -o ${output}/${id}/pol.db \
	    -s 'MASK all & MASK unmask-if=N2,N3 & RE & 
                CANONICAL file=${csfile} group=${group} &
                CHEP-MASK sig=csEEG ep-th=2 & 
                CHEP sig=csEEG epochs & RE & 
                SPINDLES sig=csEEG fc=15 so mag=2 &
                POL sig=csEEG '

# SO:       expect longer SO peak : output if NEG_DUR POS_DUR in cols 3 and 4
# SPINDLES: expect COUPL_ANGLE 180 < X < 360 
# POL       expect a **negative** (urgh...) T_DIFF statistic
# take best of 3 vote for switching

${NAP_DESTRAT} ${output}/${id}/pol.db +SPINDLES -r CH F -v COUPL_ANGLE \
 | awk ' NR != 1 && $4 < 180 { print $2 } ' > ${output}/${id}/neg.chs

${NAP_DESTRAT} ${output}/${id}/pol.db +SPINDLES -r CH -v SO_NEG_DUR SO_POS_DUR \
 | awk ' NR != 1 && $3 > $4 { print $2 } ' >> ${output}/${id}/neg.chs

${NAP_DESTRAT} ${output}/${id}/pol.db +POL -r CH -v T_DIFF \
 | awk ' NR != 1 && $3 > 0 { print $2 } ' >> ${output}/${id}/neg.chs

# repeat, for output
echo | awk ' { print "ID" , "CH" , "METHOD" , "POL" } ' OFS="\t" \
 > ${output}/${id}/luna_core_FLIP_CH_METHOD.txt

${NAP_DESTRAT} ${output}/${id}/pol.db +SPINDLES -r CH F -v COUPL_ANGLE | \
     awk ' NR != 1 { print $1,$2,"COUPL" , ($4 < 180 ) ? "-ve" : "+ve"  } ' OFS="\t" \
 >> ${output}/${id}/luna_core_FLIP_CH_METHOD.txt

${NAP_DESTRAT} ${output}/${id}/pol.db +SPINDLES -r CH -v SO_NEG_DUR SO_POS_DUR  | \
     awk ' NR != 1 { print $1,$2,"SO", ( $3>$4 ) ? "-ve" : "+ve"  } ' OFS="\t" \
 >> ${output}/${id}/luna_core_FLIP_CH_METHOD.txt

${NAP_DESTRAT} ${output}/${id}/pol.db +POL -r CH -v T_DIFF | \
     awk ' NR != 1 { print $1,$2,"POL", ($3>0) ? "-ve" : "+ve"  } ' OFS="\t" \
 >> ${output}/${id}/luna_core_FLIP_CH_METHOD.txt

# get command-delimited list of channels to flip (nb: here, it will only be 'csEEG' or nothing
sort ${output}/${id}/neg.chs | uniq -c | awk ' $1 >= 2 { print $2 } ' | paste -s -d ',' - | awk ' NF != 0 ' > ${output}/${id}/neg.chs.tmp
mv ${output}/${id}/neg.chs.tmp ${output}/${id}/neg.chs 

# if nothing to flip, set to '__dummy__'  (i.e. string we do not expect to match a channel name)
flip=`wc -l ${output}/${id}/neg.chs | awk ' { print $1 }' `
if [[ $flip -eq 0 ]]; then
echo "__dummy__" > ${output}/${id}/neg.chs
fi


## --------------------------------------------------------------------------------
##
## Create a canonical EDF, flipping csEEG signals as needed, and BP-filter EEG
##
## --------------------------------------------------------------------------------

echo "Creating a canonical EDF: ${output}/${id}/${id}-canonical.edf" >> $LOG

rm -rf ${output}/${id}/canonical.lst

${NAP_LUNA} ${input}/s.lst ${id} ${NAP_LUNA_ARGS} \
	    csfile=${NAP_DEF_DIR}/sigs.canonical \
	    group=${run} \
	    outdir=${output}/${id} \
	    flipchs=`cat ${output}/${id}/neg.chs` \
       -t ${output} ${dom_core} \
       -s 'CANONICAL file=${csfile} group=${group} & 
           FLIP sig=${flipchs} & 
           SIGNALS keep=csEEG,csLOC,csROC,csEMG,csECG &
           FILTER bandpass=0.3,35 tw=0.5 ripple=0.02 sig=csEEG,csLOC,csROC &
           WRITE edf-dir=${outdir}/ edf-tag=canonical with-annots sample-list=${outdir}/canonical.lst' 2>> $ERR

canonical=${output}/${id}/canonical.lst


## --------------------------------------------------------------------------------
##
## Masking for canonical EEG
##
## --------------------------------------------------------------------------------

# replace w/ canonical signals (this writes to an annotation file)

echo "Running ARTIFACTS csEEG (across all epochs)..." >> $LOG

${NAP_LUNA} ${canonical} ${id} ${NAP_LUNA_ARGS} \
	    apath=${output}/${id}/annots \
	    -s 'TAG SIGNAL/EEG &
                ARTIFACTS sig=csEEG & 
                CHEP-MASK sig=csEEG  clipped=0.1 flat=0.1 max=500,0.01 ep-th=3,3 & 
                CHEP sig=csEEG epochs &
                MASK regional=3,5 &
                DUMP-MASK path=${apath} tag=NAP_mask no-id' > /dev/null 2>> $ERR


## --------------------------------------------------------------------------------
##
## SUDS 
##
## --------------------------------------------------------------------------------

echo "Looking for a SUDS training data at ${NAP_SUDS_DIR}"

if [ -d "${NAP_SUDS_DIR}" ] 
then

    echo "Running SUDS on csEEG w/ default parameteres"
    
    ${NAP_LUNA} ${canonical} ${id} ${NAP_LUNA_ARGS} \
		tpath=${NAP_SUDS_DIR} \
		apath=${output}/${id}/annots \
		-t ${output} ${dom_suds} \
		-s 'SUDS db=${tpath} sig=csEEG zpsd=1 robust=0.01 lambda=1 th-hjorth=5 wgt-exp=4' > /dev/null 2>> $ERR

    # urgh... text-table fix rows required
    ${NAP_FIXROWS} ID   < ${output}/${id}/luna_suds_SUDS.txt > ${output}/${id}/fixed_SUDS.txt
    mv ${output}/${id}/fixed_SUDS.txt ${output}/${id}/luna_suds_SUDS.txt
    
    ${NAP_FIXROWS} ID SS < ${output}/${id}/luna_suds_SUDS_SS.txt > ${output}/${id}/fixed_SUDS_SS.txt
    mv ${output}/${id}/fixed_SUDS_SS.txt ${output}/${id}/luna_suds_SUDS_SS.txt
    
else
    echo "Skipping SUDS: no training data present"
fi


## --------------------------------------------------------------------------------
##
## NREM PSD
##
## --------------------------------------------------------------------------------

echo "Running N2/N3 PSD..." >> $LOG

${NAP_LUNA} ${canonical} ${id} ${NAP_LUNA_ARGS} -t ${output} ${dom_spec} tt-append=_SS-N2 \
 -s 'MASK ifnot=N2 & RE & PSD sig=csEEG dB max=25 spectrum' 2>> $ERR

${NAP_LUNA} ${canonical} ${id} ${NAP_LUNA_ARGS} -t ${output} ${dom_spec} tt-append=_SS-N3 \
 -s 'MASK ifnot=N3 & RE & PSD sig=csEEG dB max=25 spectrum' 2>> $ERR


## --------------------------------------------------------------------------------
##
## SOAP (single EEG channel only)
##
## --------------------------------------------------------------------------------

echo "Checking if STAGES are present" >> $LOG
set +e
${NAP_LUNA} ${output}/${id}/canonical.lst ${id} -s 'CONTAINS stages' 2>> $ERR
STAGES_EXISTS=$?
set -e
if [[ ${STAGES_EXISTS} -eq 1 ]]; then
  echo "STAGES missing, skipping SOAP command..." >> $LOG
else
  echo "Running SOAP command..." >> $LOG
  ${NAP_LUNA} ${output}/${id}/canonical.lst ${id} ${NAP_LUNA_ARGS} \
      adir=${output}/${id}/annots/ \
      -t ${output} ${dom_suds} \
      -s 'SOAP sig=csEEG nc=10 th=5 lambda=1 epoch annot=NAP_soap annot-dir=${adir}' 2>> $ERR

  # hack to unf*ck row-order formatting issue w/ -t option for some Luna commands
  # not needed for 'E'
  ${NAP_FIXROWS} ID   < ${output}/${id}/luna_suds_SOAP.txt > ${output}/${id}/fixed_SOAP.txt
  mv ${output}/${id}/fixed_SOAP.txt ${output}/${id}/luna_suds_SOAP.txt

  ${NAP_FIXROWS} ID SS < ${output}/${id}/luna_suds_SOAP_SS.txt > ${output}/${id}/fixed_SOAP_SS.txt
  mv ${output}/${id}/fixed_SOAP_SS.txt ${output}/${id}/luna_suds_SOAP_SS.txt
fi

## --------------------------------------------------------------------------------
##
## Micro-architecture: spindles, slow oscillations and coupling
##
## --------------------------------------------------------------------------------

echo "Running SPINDLES (N2)..." >> $LOG

${NAP_LUNA} ${canonical} ${id} ${NAP_LUNA_ARGS} \
            -t ${output} ${dom_spso} tt-append=_SS-N2 \
	    adir=${output}/${id}/annots/ \
	    -s 'MASK ifnot=N2 & RE & 
                CHEP-MASK sig=csEEG ep-th=3,3 & RE & 
                SPINDLES sig=csEEG fc=11,15 so mag=2 nreps=10000 annot=NAP_spin-N2 annot-dir=${adir}' 2>> $ERR

echo "Running SPINDLES (N2+N3)..." >> $LOG

${NAP_LUNA} ${canonical} ${id} ${NAP_LUNA_ARGS} \
            adir=${output}/${id}/annots/ \
            -t ${output} ${dom_spso} tt-append=_SS-N23 \
	    -s 'MASK all & MASK unmask-if=N2,N3 & RE & 
                CHEP-MASK sig=csEEG ep-th=3,3 & RE & 
                SPINDLES sig=csEEG fc=11,15 so mag=2 nreps=10000 annot=NAP_spin-N23 annot-dir=${adir}' 2>> $ERR


## --------------------------------------------------------------------------------
##
## Respiratory signal analysis
##
## --------------------------------------------------------------------------------

if [[ ${NAP_RESP} -eq 1 ]]; then

  # Check and load matlab module on LSF cluster
  if [ $NAP_JOBN -gt 1 ]; then
    module avail matlab/2019b > tmp_matlab.txt 2>&1
    matlab_module_exists=$(cat tmp_matlab.txt | wc -l)
    rm tmp_matlab.txt
    if [[ ! ${matlab_module_exists} -eq 0 ]]; then
      # load matlab module
      module load matlab/2019b
    else
      echo "Matab 2019b module not found on cluster, bailing.."
      exit 1
    fi
  fi

  ${NAP_LUNA} ${input}/s.lst ${id} ${NAP_LUNA_ARGS} silent=T -s CONTAINS sig=nas_pres || true 
  DO_RESP_ANALYSIS=$?
  if [[ ${DO_RESP_ANALYSIS} -eq 0 ]]; then
    echo "Starting Respiratory Analysis"
    edfname=$(${NAP_LUNA} ${input}/s.lst ${id} silent=T -s DESC | grep -e "EDF filename" | cut -d':' -f2 | awk '{$1=$1;print}')
    echo "EDF is ${edfname}"
    ${NAP_MATLAB} -nodisplay -r "FlowQcNsrr $edfname ${output}/${id}/" -sd ${NAP_DIR}"/Flowsanitycheck" -logfile ${output}/${id}/outputconvert.log
  else
    echo "nas_pres channel missing, skipping respiratory analysis"
  fi
fi


## --------------------------------------------------------------------------------
##
## ECG signal analysis
##
## --------------------------------------------------------------------------------



## --------------------------------------------------------------------------------
##
## Misc
##
## --------------------------------------------------------------------------------



## --------------------------------------------------------------------------------
##
## Compile all results (other than STATS, SIGSTATS and MTM) into R dataframes for viewing (luna/shiny)
##
## --------------------------------------------------------------------------------

echo "Compiling tables into RData files..." >> $LOG

# i.e.     path/to/folder/text.txt
# becomes  path/to/folder/text.txt-tab.RData
#      or  path/to/folder/text.txt-fig.RData
# luna-shiny then automatically loads any *-tab.RData and *-fig.RData files

# add fextract() calls into coda2.R to create particular 
# also see example for PSD plots for how to save / attach images
#  these point to .png files, which can either be created in coda2.R based
#  on summary stats, or indpendently (in which case a *-fig.RData file is created
#  which just points to the existing .png

${NAP_R} ${NAP_DIR}/coda2.R ${NAP_DIR} ${NAP_RESOURCE_DIR} ${output}/${id} >> $ERR 2>&1


## --------------------------------------------------------------------------------
##
## All done
##
## --------------------------------------------------------------------------------

echo >> $LOG
echo "All done." >> $LOG
echo >> $LOG

dt=$(date '+%d/%m/%Y %H:%M:%S');

echo "--------------------------------------------------------------------------------" >> $LOG
echo "NAP ${NAP_VERSION} | ${id} | process completed: ${dt} "                         >> $LOG
echo "--------------------------------------------------------------------------------" >> $LOG

exit 0

