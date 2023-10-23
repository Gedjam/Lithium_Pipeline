#!/bin/bash 

#-------------------------------------------------------------------------#
# Main script that gets mean and standard deviation from a lithium image
# Requirements: FSL, ANTs, FreeSurfer
# T1w image needs to be FreeSurfered prior to running this script
# Script by Gerard Hall (email: gerard.hall@newcastle.ac.uk)
#-------------------------------------------------------------------------#

##################
# Default Values #
##################

g_flag=''
Lithium_Image=''
Lithium_T1=''
Proton_T1=''
Free_Surf_Dir=''
Output_Folder='Output'

print_usage() {
  printf "
  Usage: 
  
  ***If you have an already FreeSurfered T1 weighted image (Ran on a standard "Reconall protocall")***
  Lithium_Main.sh -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -f <Pathway/to/FreeSurfer/Directory> -o <Pathway/to/Output>

  ***If you have a T1w image that hasn't been FreeSurfered, Use this method (Caution, this method will take time!!! (~6 hours a patient))
  Lithium_Main.sh -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -p <Pathway/to/Proton_T1w_image.nii.gz> -o <Pathway/to/Output>
   "
}

#Flag switch board
while getopts "g:l:t:p:f:o:" OPT; do
  case $OPT in
        
        g) #No header in Lithium Image
    g_flag=$OPTARG 
    ;;
        l) #Lithium Image Input 
    Lithium_Image=$OPTARG
    ;; 
        t) #Lithium T1 input
    Lithium_T1=$OPTARG 
    ;;    
        p) #Proton T1 input
    Proton_T1=$OPTARG 
    ;;
        f) #FreeSurfer Directory Input
    Free_Surf_Dir=$OPTARG
    ;;
        o) #Output_Folder
    Output_Folder=$OPTARG
    ;;
    *) #No Inputs output Usage
        print_usage
       exit 1 
    ;;
  esac
done


# Make Sure the filepaths required exist, add a sectionary version of this 

if [[ ! -f "${Lithium_Image}" ]];
    then
    echo "The Lithium image '${Lithium_Image}' does not exist. Can you double check the filepath"
    exit 1
fi

#First find the folder where the Scripts are located
Current_Dir=$(pwd)
echo $Current_Dir

#Output folder for the endgame stats 
mkdir -p ${Output_Folder}/stats

if [ -z "$g_flag" ]
    then
    echo "User has checked the Lithium NIFTI image and has confirmed header information is correct!"
    
    else 
    echo "-g has been called, will apply the header information from -g to the lithium image called in -l"
    #Since the header info is cleaned from the "_complex_avg_mag.nii"
    #Get the basic geomtery header setup from one of the complex_averages
    #Lets begin by copying over the geometry, as all avg_mag files have been wiped of header information
    fslcpgeom $g_flag $Lithium_Image
    #Extract the header information
    fslhd -x $g_flag > ${Output_Folder}/complex_average_header.txt
    #Now add it to the image 
    fslcreatehd ${Output_Folder}/complex_average_header.txt $Lithium_Image
fi 

if [ -z "$Proton_T1" ]
then
echo "User has ALREADY RAN FREESURFER on the T1w image, will run continue the pipeline on the FreeSurfer folder"
else 
echo "Running FreeSurfer"
#Get the name of the T1 image and make it a folder
T1_File=$(echo "$Proton_T1" | sed 's:.*/::')
#Run the recon-all script 
sh ${Curren_Dir}/Run_Reconall.sh $Proton_T1 $T1_File $Output_Folder
#Now make the output of the freesurfer directory 
Free_Surf_Dir=${Output_Folder}/${T1_File}
fi 

#Direct for the main MRI directory
Free_Surf_Dir_MRI=${Free_Surf_Dir}/mri
#Now create a lobe atlas and dilate slightly for now
sh ${Current_Dir}/Atlas_Dilator_Script_Lithuim.sh $Free_Surf_Dir_MRI ${Output_Folder}/Atlas_Dilation

# register the T1w normal coil to the T1 lithuim coil 
mkdir -p ${Output_Folder}/registration #Make a folder if it already doesn't exist
antsRegistrationSyN.sh -d 3 -f $Lithium_T1 -m ${Free_Surf_Dir_MRI}/orig.nii.gz -o ${Output_Folder}/registration/T1Proton_2_T1Lithium_ -t r -n 8

#Run the trim first
sh ${Current_Dir}/Lithium_Image_Trim.sh $Free_Surf_Dir_MRI ${Output_Folder}/registration/T1Proton_2_T1Lithium_ $Lithium_Image 

# resample each lobe dilation to the mag image
for i in Left Right #For each hemipshere
    do 
    #Create Mask for each Hemisphere 
    #Make the dilation images into a mask and then trim based on hemisphere
    fslmaths ${Output_Folder}/Atlas_Dilation/Hemisphere/${i}/${i}_Hemi_dilall -bin ${Output_Folder}/Atlas_Dilation/Hemisphere/${i}/${i}_Hemi_dilall_Mask

    for j in Frontal Temporal Parietal Insula Occipital #Each Lobe
        do 

        fslmaths ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/${j}.nii.gz -dilM ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/${j}_dilM.nii.gz

        #Get the first letter of side
        #Move the projection atlas into the Lithuim space AND resample to the complex_mag
        antsApplyTransforms -d 3 -i ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/${j}_dilM.nii.gz -r ${Output_Folder}/registration/T1Proton_2_T1Lithium_Warped.nii.gz -o ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/${i}_${j}_T1Lith_Space.nii.gz -n MultiLabel -t [${Output_Folder}/registration/T1Proton_2_T1Lithium_0GenericAffine.mat, 0]
        antsApplyTransforms -d 3 -i ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/${i}_${j}_T1Lith_Space.nii.gz -r $Lithium_Image -o ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/${i}_${j}_T1Lith_Space_Resampled.nii.gz -n MultiLabel
        #fslmaths ${Output_Folder}/Lobular_Regions/${i}/${j}/${i}_${j}_T1Lith_Space_Resampled.nii.gz -bin ${Output_Folder}/Lobular_Regions/${i}/${j}/${i}_${j}_T1Lith_Space_Resampled_Mask.nii.gz

 
        #Now get the assoicated Lithuim Voxels for that given region
        fslmaths $Lithium_Image -mul ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/${i}_${j}_T1Lith_Space_Resampled.nii.gz ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/Complex_avg_mag_${i}_${j}

        #Make the directory for the output
        mkdir -p ${Output_Folder}/stats/

        fslstats ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/Complex_avg_mag_${i}_${j} -M > ${Output_Folder}/stats/${i}_${j}_Mean.txt
        fslstats ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/Complex_avg_mag_${i}_${j} -S > ${Output_Folder}/stats/${i}_${j}_STD.txt
        fslstats ${Output_Folder}/Atlas_Dilation/Lobular_Regions/${i}/${j}/Complex_avg_mag_${i}_${j} -V > ${Output_Folder}/stats/${i}_${j}_Vol.txt
        
    done
done

