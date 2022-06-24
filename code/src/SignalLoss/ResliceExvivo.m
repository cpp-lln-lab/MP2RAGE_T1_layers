
clear;
clc;

run ../initEnv();

% opt = getOptionPreproc('mp2rage');

opt = getOptionReslice();

BIDSref = bids.layout(opt.dir.output, 'use_schema', false);
BIDSsrc = bids.layout(opt.dir.output, 'use_schema', false);

opt.subjects = {'pilot001', 'pilot004','pilot005'};

src = fullfile(opt.dir.output, 'acq-0p15_desc-brainmaskExvivo.nii');

src = cellstr(src);

for subIdx = 1:numel(opt.subjects)

    subLabel = opt.subjects{subIdx};

    %% get reference image

    filter.sub = subLabel;
    filter.suffix = 'mask';
    filter.desc = 'brain';
    filter.modality = 'anat';
    filter.space = 'individual';

    ref = bids.query(BIDSref, 'data', filter);
    ref = ref{1};
    
    clear filter
  
    %% reslice with nearest neighbour interpolation
    interpolation = 0;
    matlabbatch = {};
    matlabbatch = setBatchReslice(matlabbatch, opt, ref, src, interpolation);

    batchName = 'reslice_ExvivoSubj1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
end