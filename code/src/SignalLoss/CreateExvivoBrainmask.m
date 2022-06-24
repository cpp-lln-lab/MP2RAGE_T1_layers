qR1 = '/home/marcianunes/Desktop/Data/3dMapHumanBrain/Ahead_brain_MRI-qR1_Segmentation/2019-10-12-195022_v6bRecon_10pcMask_8kBeta_Echo_01_Magnitude_R1_bmasked-v2_bfwb-nlin3_def-img.nii'

R1 = spm_vol(qR1);
qR1 = spm_read_vols(R1);

R1BrainMask = qR1;

R1BrainMask(R1BrainMask>0) = 1;

HeaderR1BrainMask = R1;
HeaderR1BrainMask.fname = fullfile('/home/marcianunes/Desktop/Data/3dMapHumanBrain/Ahead_brain_MRI-qR1_Segmentation', 'R1_brainmask.nii');  % This is where you fill in the new filename

HeaderR1BrainMask.private.dat.fname = HeaderR1BrainMask.fname;  % This just replaces the old filename in another location within the header.

% Step 2.  Now use spm_write_vol to write out the new data.
%          You need to give spm_write_vol the new header information and corresponding data matrix
ExvivoBrainmask = spm_write_vol(HeaderR1BrainMask, R1BrainMask);