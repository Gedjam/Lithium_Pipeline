#!/bin/bash
## If user hasn't ran reconall prior to running Lithium Main
## Simple script to use a simple recon-all command
echo "Running Recon all, this may take sometime!"

source $FREESURFER_HOME/SetUpFreeSurfer.sh

T1_Directory="$1"
Input_T1="$2"
Output_Folder="$3"

SUBJECTS_DIR=${Output_Folder}

recon-all -subjid $Input_T1 -i $T1_Directory -all 
