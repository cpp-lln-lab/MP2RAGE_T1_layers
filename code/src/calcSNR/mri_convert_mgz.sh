#convert Freesurfer outputs from .mgz format to .nii.gz
#run in the terminal

export FREESURFER_HOME=/usr/local/freesurfer/7.2.0-1

source $FREESURFER_HOME/SetUpFreeSurfer.sh

#format command
# mri_convert 'path/to/file/mgz' 'new/path/file/newformat'

mri_convert '/home/marcianunes/Desktop/Data/MP2RAGE_T1_layers/outputs/derivatives/cpp_spm-roi_acq-0p75/sub-pilot004/ses-001/anat/aseg.auto_noCCseg.mgz' '/home/marcianunes/Desktop/Data/MP2RAGE_T1_layers/outputs/derivatives/cpp_spm-roi_acq-0p75/sub-pilot004/ses-001/anat/aseg.auto_noCCseg.nii.gz'
