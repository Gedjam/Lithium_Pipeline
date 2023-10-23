#!/bin/bash
#Collect the inputs from the Main Lithium Script
FreeSurfer_MRI_Dir="$1"
Ants_Reg_Dir="$2"
Complex_Avg="$3"

#With the input get the filepaths I want (will clean this once I get it working)
Brain="${FreeSurfer_MRI_Dir}/brain.mgz"
Brain_Mask="${FreeSurfer_MRI_Dir}/brain_Mask.nii.gz"
Brain_Mask_Reg="${FreeSurfer_MRI_Dir}/brain_Mask_Reg.nii.gz"
Brain_Mask_Reg_Inv="${FreeSurfer_MRI_Dir}/brain_Mask_Reg_Inv.nii.gz"
Brain_Mask_Reg_Inv_S10="${FreeSurfer_MRI_Dir}/brain_Mask_Reg_Inv_S10.nii.gz"
Brain_Mask_Reg_Inv_S10_Resample="${FreeSurfer_MRI_Dir}/brain_Mask_Reg_Inv_S10_Resamp.nii.gz"
Brain_Mask_Trimmed="${FreeSurfer_MRI_Dir}/brain_Mask_Trimmed.nii.gz"
Reg_T1="${Ants_Reg_Dir}Warped.nii.gz"
Transform="${Ants_Reg_Dir}0GenericAffine.mat"

#Convert and binarise
mri_convert $Brain $Brain_Mask
fslmaths $Brain_Mask -bin $Brain_Mask

#Move the mask (Currently in Proton space) into the Lithium space
antsApplyTransforms -d 3 -i $Brain_Mask -r $Reg_T1 -o $Brain_Mask_Reg -n MultiLabel -t [${Transform}, 0]

#Now Inverse the registered mask
fslmaths $Brain_Mask_Reg -binv $Brain_Mask_Reg_Inv

#Smooth
fslmaths $Brain_Mask_Reg_Inv -s 10 $Brain_Mask_Reg_Inv_S10

#Resmaple
antsApplyTransforms -d 3 -i $Brain_Mask_Reg_Inv_S10 -r $Complex_Avg -o $Brain_Mask_Reg_Inv_S10_Resample

#Threshold
fslmaths $Brain_Mask_Reg_Inv_S10_Resample -uthr 0.2 -bin $Brain_Mask_Trimmed

#Now trim the Complex average 
fslmaths $Complex_Avg -mul $Brain_Mask_Trimmed $Complex_Avg