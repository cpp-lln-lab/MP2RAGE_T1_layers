clear;
clc;

run ../initEnv();
addpath(fullfile(pwd, '../createROI'));
opt = get_option_preproc();
opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)
    subLabel = opt.subjects{subIdx};
    
    %% find aseg
        filter.modality = 'anat';
        filter.sub = subLabel;
        filter.ses = '001';    % change accordingly to the session
        filter.acq = 'r0p75';
        filter.suffix = 'aseg';
        aseg = bids.query(BIDS, 'data', filter);
        
    %% select UNIT1
    filter.sub = subLabel;
    filter.suffix = 'UNIT1';
    filter.acq = 'r0p75';
    filter.ses = '001'; % change for other sessions
    filter.desc = 'intercBrainMask';
    UNIT1 = bids.query(BIDS, 'data', filter);
    UNIT1 = UNIT1{1};

    clear filter;

    %% reslice with nearest neighbour interpolation
    interpolation = 0;
    matlabbatch = {};
    matlabbatch = setBatchReslice(matlabbatch, opt, UNIT1, aseg, interpolation);

    batchName = 'reslice_aseg_to_UNIT1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
end
