#!/bin/bash

#--------------------------------------------------------------------------------------------#
# Batch version of the main script that gets mean and standard deviation from a lithium image
# Requirements: FSL, ANTs, FreeSurfer
# T1w image needs to be FreeSurfered prior to running this script if possible
# Script by Gerard Hall (email: gerard.hall@newcastle.ac.uk)
#--------------------------------------------------------------------------------------------#


#First find the folder where the Scripts are located
Current_Dir=$(pwd)
echo $Current_Dir


print_usage() {
  printf "
  Usage: 
  
  ***If you have an already FreeSurfered T1 weighted image (Ran on a standard "Reconall protocall")***
  sh Batch_Lithium_Main.sh -i <Pathway/to/Subjects/List.txt> -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -f <Pathway/to/FreeSurfer/Directory> -o <Pathway/to/Output>

  ***If you have a T1w image that hasn't been FreeSurfered, Use this method (Caution, this method will take time!!! (~6 hours a patient))
  sh Batch_Lithium_Main.sh -i <Pathway/to/Subjects/List.txt> -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -p <Pathway/to/Proton_T1w_image.nii.gz> -o <Pathway/to/Output>
   "
}



##################
# Default Values #
##################
List=''
g_flag=''
Lithium_Image=''
Lithium_T1=''
Proton_T1=''
Free_Surf_Dir=''
Output_Folder='Output'


#Flag switch board for batch version
while getopts "i:g:l:t:p:f:o:" OPT; do
  case $OPT in
        i) #Input text file
    List=$OPTARG
    ;;
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

#Find out how many lines there are in the Text file
Subject_Number=$(wc -l < $List)
echo "Number of Subjects to batch process is ${Subject_Number}"

#Based on the four main types of operations

if [[ ! -z $g_flag ]] && [[ ! -z $Proton_T1 ]]; 
    then 
    echo "Both Header info and FreeSurfer need to be run"
    for i in $(seq 1 $Subject_Number)
        do 
            sh ${Current_Dir}/Lithium_Main.sh -l $(sed "${i}q;d" $List -g $g_flag/${i}/ -l $Lithium_Image -t $Lithium_T1 -p $Proton_T1 -o $Output_Folder
            echo "Subject ${i} is completed!" 
    done

elif [[ -z $g_flag ]] && [[ ! -z $Proton_T1 ]];
    then
    echo "FreeSurfer needs to be ran" 

    for i in $(seq 1 $Subject_Number)
        do
            sh ${Current_Dir}/Lithium_Main.sh -l $List -l $Lithium_Image -t $Lithium_T1 -p $Proton_T1 -o $Output_Folder
            echo "Subject ${i} is completed!" 
    done

elif [[ ! -z $g_flag ]] && [[ -z $Proton_T1 ]];
    then 
    echo "Header information needs adding to all images"

    for i in $(seq 1 $Subject_Number)
        do
            sh ${Current_Dir}/Lithium_Main.sh -l $List -g $g_flag -l $Lithium_Image -t $Lithium_T1 -f $Free_Surf_Dir -o $Output_Folder
            echo "Subject ${i} is completed!" 
    done

elif [[ -z $g_flag ]] && [[ -z $Proton_T1 ]];
    then
    #Neither needs running
    
        for i in $(seq 1 $Subject_Number)
            do
            sh ${Current_Dir}/Lithium_Main.sh -l $List -l $Lithium_Image -t $Lithium_T1 -f $Free_Surf_Dir -o $Output_Folder
            echo "Subject ${i} is completed!" 
    done
fi 


#Create a CSV table of all the concentrations
for i in $(cat $List)
    do 
###-----------Wrap below into a script to form a spreadsheet---------------###

#I know this is dumb (i'll use arrays soon)
echo ${SUBJ_ID} > ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}.txt

# Now add the .txt outputs into one large .csv for all the subjects

Mean_Total=$(paste -d',' ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Frontal_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Frontal_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Temporal_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Temporal_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Insula_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Insula_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Parietal_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Parietal_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Occipital_Mean.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Occipital_Mean.txt)
STD_Total=$(paste -d',' ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Frontal_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Frontal_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Temporal_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Temporal_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Insula_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Insula_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Parietal_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Parietal_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Left_Occipital_STD.txt ${Output_Folder}/${SUBJ_ID}/stats/${SUBJ_ID}_Right_Occipital_STD.txt)

echo $Mean_Total > ${Output_Folder}/stats/${SUBJ_ID}_Mean_Values.csv
echo $STD_Total > ${Output_Folder}/stats/${SUBJ_ID}_STD_Values.csv

#Add these into a simple .csv file for now

echo "Subject_ID,Frontal_Left,Frontal_Right,Temporal_Left,Temporal_Right,Insula_Left,Insula_Right,Parietal_Left,Parietal_Right,Occipital_Left,Occipital_Right" > ${Output_Folder}/stats/Complete_Array_Mean.csv
echo "Subject_ID,Frontal_Left,Frontal_Right,Temporal_Left,Temporal_Right,Insula_Left,Insula_Right,Parietal_Left,Parietal_Right,Occipital_Left,Occipital_Right" > ${Output_Folder}/stats/Complete_Array_STD.csv

for SUBJ_ID in $(cat $Subj_List)
do 

    cat ${Output_Folder}/stats/${SUBJ_ID}_Mean_Values.csv >> ${Output_Folder}/stats/Complete_Array_Mean.csv
    cat ${Output_Folder}/stats/${SUBJ_ID}_STD_Values.csv >> ${Output_Folder}/stats/Complete_Array_STD.csv
done 


done