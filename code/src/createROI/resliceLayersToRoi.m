% (C) Copyright 2021 Remi Gau

clear;
clc;

run ../initEnv();

% opt = getOptionPreproc('mp2rage');

opt = get_option_rois();

% opt.dir.roi = fullfile(opt.dir.preproc, '..', 'cpp_spm-roi');
% opt.dir.jobs = fullfile(opt.dir.output, 'jobs', 'gratingBimodalMotion');

opt.dryRun =  false;

BIDSref = bids.layout(opt.dir.output, 'use_schema', false);
BIDSsrc = bids.layout(opt.dir.output, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)

    subLabel = opt.subjects{subIdx};

    %% get reference image

    filter.sub = subLabel;
    filter.suffix = 'UNIT1';
    filter.modality = 'anat';
    filter.space = 'individual';
    filter.desc = 'skullstripped';
    filter.acq = 'r0p375';

    ref = bids.query(BIDSref, 'data', filter);
    ref = ref{1};

    %% get source image to reslice
    clear filter;

    filter.sub = subLabel;
    filter.extension = '.nii';
    filter.label = '6layerEquidist';
    filter.prefix = '';
    
    
    layers = bids.query(BIDSsrc, 'data', filter);
    % should have one image only
    assert(numel(layers) == 1);

    clear filter;

    %     filter.sub = subLabel;
    %     filter.suffix = 'mask';
    %     filter.prefix = '';
    %     filter.extension = '.nii';
    %
    %     masks = bids.query(BIDSsrc, 'data', filter);

    %     src = cat(1, layers, masks);

    %% reslice with nearest neighbour interpolation
    interpolation = 0;
    matlabbatch = {};
    matlabbatch = setBatchReslice(matlabbatch, opt, ref, layers, interpolation);

    batchName = 'reslice_layers_to_UNIT1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

end
