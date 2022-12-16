clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();

% -------------------------------------------------------------%
% -------------------------T1 profile--------------------------%
% -------------------------------------------------------------%

opt = get_option_rois();

% Segmentation and skull stripping done previouslly, no need to run it:
% bidsSegmentSkullStrip(opt);
% -----------------------------------------------------------------------------------------------------------------------------------
%% Define regions of interest and create them using CPP_ROI atlases in MNI space and move them to native space 
% bidsCreateROI is a workflow in bidspm that uses CPP_ROI and marsbar to create 
% a ROI in MNI space based on a given atlas
% and inverse normalize those ROIs in native space

opt.roi.name = {'V1v', 'V1d'};
opt.roi.atlas = 'wang';
bidsCreateROI(opt); % does not work for multiple subjects

opt.roi.name = {'mFus', 'pFus', 'CoS'};
opt.roi.atlas = 'visfAtlas';
bidsCreateROI(opt);

%% Reslice the computationally defined cortical layers to UNIT1 dimensions and orientation
resliceLayersToRoi(opt);

createBrainMaskT1map(opt);

opt.roi.name = {'V1v', 'V1d', 'pFus', 'mFus', 'CoS'};
intercept_ROI_and_brainmask(opt);

intercept_ROI_and_layers(opt);

createLayerMaskROIs(opt);

addpath(fullfile(pwd, '..', 'extractT1'));
ExtractT1Layers(opt);
% -------------------------------------------------------------%
%% -----------------------Quality control---------------------%
%-----------------run this on the raw data--------------------%
%-------------------------------------------------------------%

%%
% -------------------------------------------------------------%
clear opt;
clear;

addpath(fullfile(pwd, '..', 'calcSNR'));
opt = get_option_preproc();
matlabbatch = bidsGenerateT1map(opt);

bidsSpatialPrepro(opt); % if files are already there it will not overwrite
% change opt.bidsFilterFile.t1w.ses accordingly to the session you want to preprocess

% after running the segmentation in FreeSurfer, run 'mri_convert_mgz.sh' to alter the segmentation file format;

bidsCreateROI(opt); % this will run for the ROIs and atlas in the following option file

% this will run for other ROIs in another atlas, so we define these options
% again an run the script to create them
opt.roi.name = {'V1v', 'V1d'};
opt.roi.atlas = 'wang';
bidsCreateROI(opt); % this function runs for all ROIs in the group folder
% that contains the ROIs in MNI space

interceptUNIT1andBrainMask(opt);

createBrainMaskT1map(opt);

opt.roi.name = {'IOG', 'OTS', 'ITG', ...
                    'MTG', 'LOS', 'hMT', 'v2d', 'v3d', ...
                    'v2v', 'v3v', 'mFus', 'pFus', 'CoS', 'V1v', 'V1d'};
intercept_ROI_and_brainmask(opt);

resliceAsegAutoToUNIT1(opt);

addpath(fullfile(pwd, '../createROI'));
createMaskForegroundWMGMAseg(opt);
intercept_ROI_and_GM(opt);
extract_snr_from_gm(opt);
extract_snr_from_roi(opt);

% -------------------------------------------------------------%
%% Covariance
addpath(fullfile(pwd, '..', 'calcSNR'));
opt = get_option_preproc();
addpath(fullfile(pwd, '..', 'calcCoV'));
CoregResliceses002UNIT1andT1map(opt); %just coregister, no reslice

calcCov(opt);

commonVoxelsROIsandSessions(opt);

statsCoVROIs(opt);
