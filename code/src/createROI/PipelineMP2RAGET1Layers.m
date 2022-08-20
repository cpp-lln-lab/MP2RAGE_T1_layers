clear;
clc;

% -------------------------------------------------------------%
% -------------------------T1 profile--------------------------%
% -------------------------------------------------------------%

addpath(fullfile(pwd, '..'));
initEnv();

opt = get_option_rois();

% files copied manually, no need to run the next step:
% bidsCopyInputFolder(opt, unzip);

% Segmentation and skull stripping done previouslly, no need to run it:
% bidsSegmentSkullStrip(opt);
% -----------------------------------------------------------------------------------------------------------------------------------
opt.roi.name = {'V1v', 'V1d'};
opt.roi.atlas = 'wang';
bidsCreateROI(opt); % does not work for multiple subjects

opt.roi.name = {'mFus', 'pFus', 'CoS'};
opt.roi.atlas = 'visfAtlas';
bidsCreateROI(opt);

run 'resliceLayersToRoi.m';

resliceRoiToBrainmask(opt);

intercept_ROI_and_brainmask(opt); % filter.acq = 'r0p375';

intercept_ROI_and_layers(opt);
run 'createLayerMaskROIs.m';
addpath(fullfile(pwd, '..', 'extractT1'));

run 'ExtractT1Layers.m';

% -------------------------------------------------------------%
%% -----------------------Quality control---------------------%
% -----------------run this on the raw data--------------------%
% -------------------------------------------------------------%


%%
% -------------------------------------------------------------%
%% SNR
% to do:
% copy files automatically script

% -------------------------------------------------------------%
clear opt;
clear;
opt = get_option_preproc();
% if files are already there it will not overwrite
run 'SpatialPreproc.m'; % change opt.bidsFilterFile.t1w.ses accordingly to the session you want to preprocess

% this will run for the ROIs and atlas in the following option file
addpath(fullfile(pwd, '..', 'calcSNR'));
opt = get_option_preproc();

bidsCreateROI(opt);

% this will run for other ROIs in another atlas, so we define these options
% again an run the script to create them
opt.roi.name = {'V1v', 'V1d'};
opt.roi.atlas = 'wang';
bidsCreateROI(opt); % this function runs for all ROIs in the group folder
% that contains the ROIs in MNI space

% for session 2 changes options and run again the next 2 lines for CoV
opt = get_option_preproc();
interceptUNIT1andBrainMask(opt);

resliceRoiToBrainmask(opt);
intercept_ROI_and_brainmask(opt);
% copy aseg.auto from freesurfer outputs to derivatives/cpp_spm-roi-r0p75

run 'resliceAsegAutoToUNIT1.m';
run 'intercept_aseg_brainmask.m';
run 'createMaskForegroundWMGMAseg.m';

run 'extract_snr_from_roi.m';

% -------------------------------------------------------------%
%% Covariance

addpath(fullfile(pwd, '..', 'calcCoV'));
run 'CoregResliceses002UNIT1andT1map.m';
<<<<<<< HEAD

run 'calcCov.m';

=======
run 'calcCov.m';
>>>>>>> [pre-commit.ci] auto fixes from pre-commit.com hooks
