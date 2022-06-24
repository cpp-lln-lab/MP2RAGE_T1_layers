
clear;
clc;

run ../initEnv();
opt = get_option_coregister();

opt.subjects = {'pilot005'};

ref = '/home/marcianunes/Desktop/Data/MP2RAGE_T1_layers/outputs/derivatives/cpp_spm-roi_acq-0p75/sub-pilot005/ses-001/anat/sub-pilot005_ses-001_acq-r0p75_space-individual_desc-skullstripped_UNIT1.nii';
src = '/home/marcianunes/Desktop/Data/MP2RAGE_T1_layers/outputs/derivatives/cpp_spm-roi_acq-0p75/sub-pilot005/ses-002/anat/sub-pilot005_ses-002_acq-r0p75_space-individual_desc-skullstripped_UNIT1.nii';
matlabbatch = {};

matlabbatch = setBatchCoregistration(matlabbatch, opt, ref, src);

saveAndRunWorkflow(matlabbatch, "coregistration", opt, ['pilot005'])