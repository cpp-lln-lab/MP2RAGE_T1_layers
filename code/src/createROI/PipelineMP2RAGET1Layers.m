clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();
%% -------------------------T1 profile--------------------------%

opt = get_option_rois();

% Segmentation and skull stripping done previouslly, no need to run it:
% bidsSegmentSkullStrip(opt);
% -----------------------------------------------------------------------------------------------------------------------------------
%% Define regions of interest and create them using CPP_ROI atlases in MNI space and move them to native space
%{
% bidsCreateROI is a workflow in bidspm that uses CPP_ROI and marsbar to create
a ROI in MNI space based on a given atlas and inverse normalize those ROIs in native space

bidsCreateROI will run for the ROIs and atlas defined in opt = get_option_preproc();
bidsCreateROI runs for all ROIs in the group folder that contains the ROIs in MNI space

bidsCreateROI will run again for other ROIs and atlas
(opt.roi.name and opt.roi.atlas are redefined before running bidsCreateROI the second time):
%}
bidsCreateROI(opt); % does not work for multiple subjects

opt.roi.name = {'mFus', 'pFus', 'CoS'};
opt.roi.atlas = 'visfAtlas';
bidsCreateROI(opt);

%% Reslice the computationally defined cortical layers to UNIT1 dimensions and orientation
% ensure that layers output and UNIT1/T1 map have the same dimensions and
% orientation
resliceLayersToRoi(opt);

% the T1 map was skullstripped with bidsNighres. createBrainMaskT1map
% creates a binary mask of the brain
createBrainMaskT1map(opt);

opt.roi.name = {'V1v', 'V1d', 'pFus', 'mFus', 'CoS'}; % redefine opt.roi.name to include all ROIs

% to ensure that we work with ROIs in which all voxels are part of the brain
% (problems in segmentation may lead to ROIs not matching 100% the voxels
% in the brain
intercept_ROI_and_brainmask(opt);

% define layers for each ROI
intercept_ROI_and_layers(opt);

% define each layer for each ROI
createLayerMaskROIs(opt);

% find T1 relaxation times distribution in T1 maps
addpath(fullfile(pwd, '..', 'extractT1'));
ExtractT1Layers(opt);
%% -----------------------Quality controls---------------------%
%{
The next lines were implemented to assess the presence of noise and
variability introduced with MP2RAGE sequence (Marques et al. NeuroImage
(2010)). The Signal to noise ratio (SNR) and the voxel-wise relative
percentage difference (Covariance) are estimated in UNIT1 images and T1
maps (0.75 mm isotropic resolution).
%}

clear opt;
clear;

addpath(fullfile(pwd, '..', 'calcSNR'));
opt = get_option_preproc();

%{
bidsGenerateT1map relies on the MP2RAGE toolbox for SPM.
https://github.com/benoitberanger/mp2rage
%}
matlabbatch = bidsGenerateT1map(opt);

bidsSpatialPrepro(opt); % if files are already there it will not overwrite
% change opt.bidsFilterFile.t1w.ses accordingly to the session you want to preprocess

% after running the segmentation in FreeSurfer, run 'mri_convert_mgz.sh' to alter the segmentation file format;

%{
bidsCreateROI will run for the ROIs and atlas defined in opt = get_option_preproc();
bidsCreateROI runs for all ROIs in the group folder that contains the ROIs in MNI space

bidsCreateROI will run again for other ROIs and atlas
(opt.roi.name and opt.roi.atlas are redefined before running bidsCreateROI the second time):
%}

% create ROIs defined in options function
bidsCreateROI(opt);

% rerun bidsCreateROI for Wang atlas
opt.roi.name = {'V1v', 'V1d'};
opt.roi.atlas = 'wang';
bidsCreateROI(opt);

% create UNIT1 without background and skull
interceptUNIT1andBrainMask(opt);

% create binary brain mask for T1 map skullstripped with bidsNighres
createBrainMaskT1map(opt);

opt.roi.name = {'IOG', 'OTS', 'ITG', ...
                'MTG', 'LOS', 'hMT', 'v2d', 'v3d', ...
                'v2v', 'v3v', 'mFus', 'pFus', 'CoS', 'V1v', 'V1d'};

% to ensure that we work with ROIs in which all voxels are part of the brain
% (problems in segmentation may lead to ROIs not matching 100% the voxels
% in the brain
intercept_ROI_and_brainmask(opt);

% ensure UNIT1 and segmentation performed with freesurfer have the same
% dimensions/orientation
resliceAsegAutoToUNIT1(opt);

addpath(fullfile(pwd, '../createROI'));

% create WM, GM and WM+GM masks for each subject for SNR estimations
createMaskForegroundWMGMAseg(opt);

% define GM within ROIs
intercept_ROI_and_GM(opt);

% estimate SNR for GM within ROIs
extract_snr_from_gm(opt);

% estimate SNR for entire ROI
extract_snr_from_roi(opt);

% -------------------------------------------------------------%
%% Covariance
addpath(fullfile(pwd, '..', 'calcSNR'));
opt = get_option_preproc();
addpath(fullfile(pwd, '..', 'calcCoV'));

% coregister acquisitions
CoregResliceses002UNIT1andT1map(opt);

% estimate voxel-wise relative percentage difference (RPD)
calcCov(opt);

% keep voxels in common between sessions in ROI masks
commonVoxelsROIsandSessions(opt);

% estimate statistics such as median RPD within ROIs
statsCoVROIs(opt);
