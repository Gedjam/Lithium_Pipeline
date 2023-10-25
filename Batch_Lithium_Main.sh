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
  
  Batch version of this requirest a .txt list for each of the -i, -l, -t, -f or -p, -o arguements.
  Lists should be perline the filepaths for each repsective flag.
  Just a folder pathway is required for the flag -s, (i.e. Overall stats folder)

  ***If you have an already FreeSurfered T1 weighted image (Ran on a standard "Reconall protocall")***
  sh Batch_Lithium_Main.sh -i <Pathway/to/Subjects/List.txt> -l <Pathway/to/Lithium_Image.nii.gz> -t <Pathway/to/T1w_Lithium_Image.nii.gz> -f <Pathway/to/FreeSurfer/Directory> -o <Pathway/to/Output> -s <Output

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
while getopts "i:g:l:t:p:f:o:s:" OPT; do
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
        s) #Output of Overall stats folder
    Overall_Stats=$OPTARG
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
            SUBJ_ID=$(sed "${i}q;d" $List)
            #Calling the main
            sh ${Current_Dir}/Lithium_Main.sh \
            -g $(sed "${i}q;d" $g_flag) \
            -l $(sed "${i}q;d" $Lithium_Image) \
            -t $(sed "${i}q;d" $Lithium_T1) \
            -p $(sed "${i}q;d" $Proton_T1) \
            -o $(sed "${i}q;d" $Output_Folder) 
            echo "Subject ${i} is Processed!" 

            #Make Output folder the current folder
            Output_Folder_Subj=$(sed "${i}q;d" $Output_Folder)
            #Attaching a simple label to the folder
            echo ${SUBJ_ID} > ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt
            #Will make this more elegant one day, creating an overall tab
            Mean_Total=$(paste -d',' ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt \
            ${Output_Folder_Subj}/stats/Left_Frontal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Frontal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Temporal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Temporal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Insula_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Insula_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Parietal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Parietal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Occipital_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Occipital_Mean.txt)

            #Will make this more elegant one day, creating an overall tab
            STD_Total=$(paste -d',' ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt \
            ${Output_Folder_Subj}/stats/Left_Frontal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Frontal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Temporal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Temporal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Insula_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Insula_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Parietal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Parietal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Occipital_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Occipital_STD.txt)

            echo $Mean_Total > ${Output_Folder_Subj}/stats/${SUBJ_ID}_Mean_Values.csv
            echo $STD_Total > ${Output_Folder_Subj}/stats/${SUBJ_ID}_STD_Values.csv

    done

elif [[ -z $g_flag ]] && [[ ! -z $Proton_T1 ]];
    then
    echo "FreeSurfer needs to be ran" 

    for i in $(seq 1 $Subject_Number)
        do
            SUBJ_ID=$(sed "${i}q;d" $List)
            #Calling the main
            sh ${Current_Dir}/Lithium_Main.sh \
            -l $(sed "${i}q;d" $Lithium_Image) \
            -t $(sed "${i}q;d" $Lithium_T1) \
            -p $(sed "${i}q;d" $Proton_T1) \
            -o $(sed "${i}q;d" $Output_Folder) 
            echo "Subject ${i} is completed!" 

            #Make Output folder the current folder
            Output_Folder_Subj=$(sed "${i}q;d" $Output_Folder)
            #Attaching a simple label to the folder
            echo ${SUBJ_ID} > ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt
            #Will make this more elegant one day, creating an overall tab
            Mean_Total=$(paste -d',' ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt \
            ${Output_Folder_Subj}/stats/Left_Frontal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Frontal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Temporal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Temporal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Insula_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Insula_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Parietal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Parietal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Occipital_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Occipital_Mean.txt)

            #Will make this more elegant one day, creating an overall tab
            STD_Total=$(paste -d',' ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt \
            ${Output_Folder_Subj}/stats/Left_Frontal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Frontal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Temporal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Temporal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Insula_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Insula_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Parietal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Parietal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Occipital_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Occipital_STD.txt)

            echo $Mean_Total > ${Output_Folder_Subj}/stats/${SUBJ_ID}_Mean_Values.csv
            echo $STD_Total > ${Output_Folder_Subj}/stats/${SUBJ_ID}_STD_Values.csv
    done

elif [[ ! -z $g_flag ]] && [[ -z $Proton_T1 ]];
    then 
    echo "Header information needs adding to all images"

    for i in $(seq 1 $Subject_Number)
        do
            SUBJ_ID=$(sed "${i}q;d" $List)
            #Calling the main
            #sh ${Current_Dir}/Lithium_Main.sh \
            #-g $(sed "${i}q;d" $g_flag) \
            #-l $(sed "${i}q;d" $Lithium_Image) \
            #-t $(sed "${i}q;d" $Lithium_T1) \
            #-f $(sed "${i}q;d" $Free_Surf_Dir) \
            #-o $(sed "${i}q;d" $Output_Folder) 
            echo "Subject ${i} is completed!"

            #Make Output folder the current folder
            Output_Folder_Subj=$(sed "${i}q;d" $Output_Folder)
            #Attaching a simple label to the folder, will make these variables one day
            #easier to pass .txt values between scripts
            echo ${SUBJ_ID} > ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt
            #Will make this more elegant one day, creating an overall tab
            Mean_Total=$(paste -d',' ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt \
            ${Output_Folder_Subj}/stats/Left_Frontal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Frontal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Temporal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Temporal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Insula_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Insula_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Parietal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Parietal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Occipital_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Occipital_Mean.txt)

            #Will make this more elegant one day, creating an overall tab
            STD_Total=$(paste -d',' ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt \
            ${Output_Folder_Subj}/stats/Left_Frontal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Frontal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Temporal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Temporal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Insula_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Insula_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Parietal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Parietal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Occipital_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Occipital_STD.txt)
    
            echo $Mean_Total > ${Output_Folder_Subj}/stats/${SUBJ_ID}_Mean_Values.csv
            echo $STD_Total > ${Output_Folder_Subj}/stats/${SUBJ_ID}_STD_Values.csv
    done

elif [[ -z $g_flag ]] && [[ -z $Proton_T1 ]];
    then
    #Neither needs running
    
        for i in $(seq 1 $Subject_Number)
            do
            SUBJ_ID=$(sed "${i}q;d" $List)
            #Calling the main
            sh ${Current_Dir}/Lithium_Main.sh \
            -l $(sed "${i}q;d" $Lithium_Image) \
            -t $(sed "${i}q;d" $Lithium_T1) \
            -f $(sed "${i}q;d" $Free_Surf_Dir) \
            -o $(sed "${i}q;d" $Output_Folder)
            echo "Subject ${i} is completed!"

            #Make Output folder the current folder
            Output_Folder_Subj=$(sed "${i}q;d" $Output_Folder)
            #Attaching a simple label to the folder
            echo ${SUBJ_ID} > ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt
            #Will make this more elegant one day, creating an overall tab
            Mean_Total=$(paste -d',' ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt \
            ${Output_Folder_Subj}/stats/Left_Frontal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Frontal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Temporal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Temporal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Insula_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Insula_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Parietal_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Parietal_Mean.txt \
            ${Output_Folder_Subj}/stats/Left_Occipital_Mean.txt \
            ${Output_Folder_Subj}/stats/Right_Occipital_Mean.txt)

            #Will make this more elegant one day, creating an overall tab
            STD_Total=$(paste -d',' ${Output_Folder_Subj}/stats/${SUBJ_ID}.txt \
            ${Output_Folder_Subj}/stats/Left_Frontal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Frontal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Temporal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Temporal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Insula_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Insula_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Parietal_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Parietal_STD.txt \
            ${Output_Folder_Subj}/stats/Left_Occipital_STD.txt \
            ${Output_Folder_Subj}/stats/Right_Occipital_STD.txt)
    
            echo $Mean_Total > ${Output_Folder_Subj}/stats/${SUBJ_ID}_Mean_Values.csv
            echo $STD_Total > ${Output_Folder_Subj}/stats/${SUBJ_ID}_STD_Values.csv 
    done
fi 


#After Lithium main has been ran, create a CSV table of all the concentrations
echo "Now collecting all the information into one single spreadsheet"

mkdir -p $Overall_Stats/stats

echo "Subject_ID,Frontal_Left,Frontal_Right,Temporal_Left,Temporal_Right,Insula_Left,Insula_Right,Parietal_Left,Parietal_Right,Occipital_Left,Occipital_Right" > ${Overall_Stats}/stats/Complete_Array_Mean.csv
echo "Subject_ID,Frontal_Left,Frontal_Right,Temporal_Left,Temporal_Right,Insula_Left,Insula_Right,Parietal_Left,Parietal_Right,Occipital_Left,Occipital_Right" > ${Overall_Stats}/stats/Complete_Array_STD.csv

#Add the outputs from individual subjects into one overall subject
for i in $(seq 1 $Subject_Number)
    do 
    SUBJ_ID=$(sed "${i}q;d" $List)
    Output_Folder_Subj=$(sed "${i}q;d" $Output_Folder)

    cat ${Output_Folder_Subj}/stats/${SUBJ_ID}_Mean_Values.csv >> ${Overall_Stats}/stats/Complete_Array_Mean.csv
    cat ${Output_Folder_Subj}/stats/${SUBJ_ID}_STD_Values.csv >> ${Overall_Stats}/stats/Complete_Array_STD.csv
done

#Completed
echo "JOB COMPLETED! Please check ${Overall_Stats}/stats/Complete_Array_Mean.csv and ${Overall_Stats}/stats/Complete_Array_STD.csv"