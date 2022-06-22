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
%-----------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------
%  Uses CPP_ROI and marsbar to:
% create a ROI in MNI space based on a given atlas
% inverse normalize those ROIs in native space if requested.
% -----------------------------------------------------------------------------------------------------------------------------------
opt.roi.atlas = 'visfAtlas';
opt.roi.name = {'mFus', 'pFus', 'IOG', 'OTS', 'ITG',...
        'MTG', 'LOS', 'CoS', 'hMT', 'v1d', 'v2d', 'v3d', ...
        'v1v', 'v2v', 'v3v'};
bidsCreateROI(opt);
opt.roi.atlas = 'wang';
opt.roi.name = {'V1d','V1v'};
opt.subjects = {'pilot005'};

bidsCreateROI(opt);

clear opt;
opt = get_option_roisinterceptionbrainmask();

intercept_ROI_and_brainmask(opt);
intercept_ROI_and_layers(opt);
