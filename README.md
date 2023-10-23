# Lithium_Pipeline

## About
These are a bunch of simple scripts designed for Dr David Cousins. These 

## Requirements
To run these scripts you first need the following MRI tools installed and setup. Please remember to cite all of these tools when using this pipeline
 - FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL)
 - ANTs (https://stnava.github.io/ANTs)
 - FreeSurfer (https://surfer.nmr.mgh.harvard.edu)

## How to use
### If you have an already FreeSurfered T1 weighted image (Ran on a standard "Reconall protocall")
  Lithium_Main.sh -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -f <Pathway/to/FreeSurfer/Directory> -o <Pathway/to/Output>

### If you have a T1w image that hasn't been FreeSurfered, Use this method (Caution, this method will take time!!! (~6 hours a patient))
  Lithium_Main.sh -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -p <Pathway/to/Proton_T1w_image.nii.gz> -o <Pathway/to/Output>
