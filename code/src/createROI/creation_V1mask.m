clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();

opt = get_option_rois();

% reportBIDS(opt);

unzip = true;
% files copied manually, no need to run the next step:
% bidsCopyInputFolder(opt, unzip);

% Segmentation and skull stripping done previouslly, no need to run it:
% bidsSegmentSkullStrip(opt);

% -----------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------
%  Uses CPP_ROI and marsbar to:
% create a ROI in MNI space based on a given atlas
% inverse normalize those ROIs in native space if requested.
% -----------------------------------------------------------------------------------------------------------------------------------

bidsCreateROI(opt);

mergeMasks(opt);
intercept_ROI_and_layers(opt);
