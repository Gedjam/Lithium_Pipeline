#!/bin/bash

echo "Running Recon all, this may take sometime!"
##Then recon all the post-OP data (add a if statement if needs to be ran for Pre-OP data also)
source $FREESURFER_HOME/SetUpFreeSurfer.sh

T1_Directory="$1"
Input_T1="$2"
Output_Folder="$3"

SUBJECTS_DIR=${Output_Folder}

recon-all -subjid $Input_T1 -i $T1_Directory -all 
