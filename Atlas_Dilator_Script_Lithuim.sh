#!/bin/bash

## Takes Aparc+Aseg and turns it into a lobe based atlas in the T1 space, passing it back into the orginal script
FreeSurfer_Dir="$1"
Atlas_Output="$2"
## Values assoicated for each (Will make this better in the future)
Left_Frontal_Numbers="1002 1003 1014 1017 1018 1019 1020 1024 1026 1027 1028 1032 1012"
Left_Temporal_Numbers="1001 1006 1007 1009 1015 1016 1030 1033 1034"
Left_Occipital_Numbers="1005 1011 1013 1021"
Left_Insula_Numbers="1035"
Left_Parietal_Numbers="1008 1010 1023 1029 1031 1022 1025" 

Right_Frontal_Numbers="2002 2003 2014 2017 2018 2019 2020 2024 2026 2027 2028 2032 2012"
Right_Temporal_Numbers="2001 2006 2007 2009 2015 2016 2030 2033 2034"
Right_Occipital_Numbers="2005 2011 2013 2021"
Right_Insula_Numbers="2035"
Right_Parietal_Numbers="2008 2010 2023 2029 2031 2022 2025"

## Lets get the aparc+aseg atlas ready (assuming it has already been converted) 
mri_convert ${FreeSurfer_Dir}/aparc+aseg.mgz ${FreeSurfer_Dir}/aparc+aseg.nii.gz
mri_convert ${FreeSurfer_Dir}/ribbon.mgz ${FreeSurfer_Dir}/ribbon.nii.gz
mri_convert ${FreeSurfer_Dir}/brain.mgz ${FreeSurfer_Dir}/brain.nii.gz
mri_convert ${FreeSurfer_Dir}/orig.mgz ${FreeSurfer_Dir}/orig.nii.gz

Atlas="${FreeSurfer_Dir}/aparc+aseg.nii.gz"
Ribbon="${FreeSurfer_Dir}/ribbon.nii.gz"
Brain="${FreeSurfer_Dir}/brain.nii.gz"
Orig="${FreeSurfe_Dir}/orig.nii.gz"
#Change into a brain mask
fslmaths $Brain -bin $Brain

#Make Hemisphere Mask first from the ribbon (will for loop this in future too)

mkdir -p ${Atlas_Output}/Hemisphere/Left
mkdir -p ${Atlas_Output}/Hemisphere/Right

#Create basic masks
#Left 
fslmaths $Ribbon -thr 2 -uthr 2 -bin ${Atlas_Output}/Hemisphere/Left/Left_2
fslmaths $Ribbon -thr 3 -uthr 3 -bin ${Atlas_Output}/Hemisphere/Left/Left_3
fslmaths ${Atlas_Output}/Hemisphere/Left/Left_2 -add ${Atlas_Output}/Hemisphere/Left/Left_3 ${Atlas_Output}/Hemisphere/Left/Left_All
#Right 
fslmaths $Ribbon -thr 41 -uthr 41 -bin ${Atlas_Output}/Hemisphere/Right/Right_41
fslmaths $Ribbon -thr 42 -uthr 42 -bin ${Atlas_Output}/Hemisphere/Right/Right_42
fslmaths ${Atlas_Output}/Hemisphere/Right/Right_41 -add ${Atlas_Output}/Hemisphere/Right/Right_42 ${Atlas_Output}/Hemisphere/Right/Right_All
#Now get post neg sides, and then dilall
fslmaths ${Atlas_Output}/Hemisphere/Left/Left_All -mul -1 ${Atlas_Output}/Hemisphere/Left/Left_All_Neg
fslmaths ${Atlas_Output}/Hemisphere/Right/Right_All -mul -1 ${Atlas_Output}/Hemisphere/Right/Right_All_Neg
fslmaths ${Atlas_Output}/Hemisphere/Right/Right_All -add ${Atlas_Output}/Hemisphere/Left/Left_All_Neg ${Atlas_Output}/Hemisphere/Right/Right_All_Both
fslmaths ${Atlas_Output}/Hemisphere/Left/Left_All -add ${Atlas_Output}/Hemisphere/Right/Right_All_Neg ${Atlas_Output}/Hemisphere/Left/Left_All_Both
fslmaths ${Atlas_Output}/Hemisphere/Right/Right_All_Both -dilall ${Atlas_Output}/Hemisphere/Right/Right_Hemi_dilall
fslmaths ${Atlas_Output}/Hemisphere/Left/Left_All_Both -dilall ${Atlas_Output}/Hemisphere/Left/Left_Hemi_dilall

##Now for lobes (got around to for looping this)
for i in Left Right
do
for j in Frontal Temporal Parietal Insula Occipital
do 
#Now create a blank image for each lobe and side with the same FOV and matrix size and resolution
mkdir -p ${Atlas_Output}/Lobular_Regions/${i}/${j} 
fslmaths $Atlas -mul 0 ${Atlas_Output}/Lobular_Regions/${i}/${j}/${j}.nii.gz 
Current_Lobe=${i}_${j}_Numbers 
for k in ${!Current_Lobe}
do
#Now get the individual regions
echo $k &
fslmaths $Atlas -thr ${k} -uthr ${k} -bin ${Atlas_Output}/Lobular_Regions/${i}/${j}/${i}_${j}_${k}.nii.gz 
#Then add them into the blank lobe image
fslmaths ${Atlas_Output}/Lobular_Regions/${i}/${j}/${j}.nii.gz -add ${Atlas_Output}/Lobular_Regions/${i}/${j}/${i}_${j}_${k}.nii.gz ${Atlas_Output}/Lobular_Regions/${i}/${j}/${j}.nii.gz 
done
done
done

##I know this could be for looped, I just wanted to make it work first, will get onto for looping this one day
for i in Left Right
do 

##Get all the lobe images 
Temporal="${Atlas_Output}/Lobular_Regions/${i}/Temporal/Temporal.nii.gz"
Occipital="${Atlas_Output}/Lobular_Regions/${i}/Occipital/Occipital.nii.gz"
Frontal="${Atlas_Output}/Lobular_Regions/${i}/Frontal/Frontal.nii.gz"
Parietal="${Atlas_Output}/Lobular_Regions/${i}/Parietal/Parietal.nii.gz"
Insula="${Atlas_Output}/Lobular_Regions/${i}/Insula/Insula.nii.gz"

##For visual purposes at the moment, simple overall view of the lobe atlas
fslmaths $Occipital -mul 2 ${Atlas_Output}/Lobular_Regions/${i}/Occipital/Occipital_2.nii.gz
fslmaths $Frontal -mul 3 ${Atlas_Output}/Lobular_Regions/${i}/Frontal/Frontal_3.nii.gz
fslmaths $Parietal -mul 4 ${Atlas_Output}/Lobular_Regions/${i}/Parietal/Parietal_4.nii.gz
fslmaths $Insula -mul 5 ${Atlas_Output}/Lobular_Regions/${i}/Insula/Insula_5.nii.gz

fslmaths $Temporal -add ${Atlas_Output}/Lobular_Regions/${i}/Occipital/Occipital_2.nii.gz -add ${Atlas_Output}/Lobular_Regions/${i}/Frontal/Frontal_3.nii.gz -add ${Atlas_Output}/Lobular_Regions/${i}/Parietal/Parietal_4.nii.gz -add ${Atlas_Output}/Lobular_Regions/${i}/Insula/Insula_5.nii.gz ${Atlas_Output}/Lobular_Regions/${i}/${i}_Lobe_Atlas 

done

#End of simple atlas dilator script, now to pass back into the main script for Lithium analysis