# Lithium_Pipeline

## About
These are a bunch of simple scripts designed for Dr David Cousins & the R-LINK project.
The aim of these scripts is to collect average measures of Lithium concentrations without applying any resampling or interpolation techniques

## Requirements
To run these scripts you first need the following MRI tools installed and setup. Please remember to cite all of these tools when using this pipeline
 - FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL)
 - ANTs (https://stnava.github.io/ANTs)
 - FreeSurfer (https://surfer.nmr.mgh.harvard.edu)

## How to use

These scripts are designed to be ran in terminal on mac or linux OS. After downloading, from terminal, please change directory (cd) to the folder location (.e.g. "cd ~/Downloads/Lithium_Pipeline-main"). 

You MUST run these scripts within the "Lithium_Pipeline-main" folder. 
After chaning directory to the folder, in terminal call sh Lithium_Main.sh for usage. 

### If you have an already FreeSurfered T1 weighted image (Ran on a standard "Reconall protocall")
  Lithium_Main.sh -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -f <Pathway/to/FreeSurfer/Directory> -o <Pathway/to/Output>

### If you have a T1w image that hasn't been FreeSurfered, Use this method (Caution, this method will take time!!! (~6 hours a patient))
  Lithium_Main.sh -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -p <Pathway/to/Proton_T1w_image.nii.gz> -o <Pathway/to/Output>

## Contacts
Any questions or queries please contact
 - Gerard Hall (gerard.hall@newcastle.ac.uk)
