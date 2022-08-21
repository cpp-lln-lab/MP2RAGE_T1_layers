clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();

addpath(fullfile(pwd, '../calcSNR'));
opt = get_option_preproc();

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, ...
                   'use_schema', false);

for subIdx = 1:numel(opt.subjects)
    subLabel = opt.subjects{subIdx};
    fprintf('subject number: %d\n', subIdx);
    % find UNIT1 sess 001 and 002
    filters.sub = subLabel;
    filters.ses = '001';
    filters.modality = 'anat';
    filters.acq = 'r0p75';
    filters.suffix = 'UNIT1';
    filters.prefix = '';
    filters.desc = 'intercBrainMask';

    sub1stSesUNIT1 = bids.query(BIDS, 'data', filters);
    sub1stSesUNIT1 = sub1stSesUNIT1{1};

    filters.ses = '002';
    filters.prefix = '';

    sub2stSesUNIT1 = bids.query(BIDS, 'data', filters);
    sub2stSesUNIT1 = sub2stSesUNIT1{1};

    % find T1 map 001 and 002 sessions
    filter.sub = subLabel;
    filter.acq = 'r0p75';
    filter.ses = '001';
    filter.suffix = 'T1map';
    filter.desc = 'skullstripped';
    filter.space = '';
    filter.prefix = '';

    T1map_001 = bids.query(BIDS, 'data', filter);
    T1map_001 = T1map_001{1};

    header_sub1stT1map = spm_vol(T1map_001);
    sub1stT1map_vol = spm_read_vols(header_sub1stT1map);

    filter.ses = '002'; % change for other sessions

    T1map_002 = bids.query(BIDS, 'data', filter);
    T1map_002 = T1map_002{1};

    clear filter;

    % find brain masks 001 and 002 sessions
    filter.sub = subLabel;
    filter.ses = '001';
    filter.space = 'individual';
    filter.acq = 'r0p75'; % change depending on the pipeline
    filter.suffix = 'mask';
    brainmask_001 = bids.query(BIDS, 'data', filter);
    brainmask_001 = brainmask_001{:}; % because it complains: 'Struct contents reference from a non-struct array object.'

    filter.ses = '002';

    brainmask_002 = bids.query(BIDS, 'data', filter);
    brainmask_002 = brainmask_002{:}; % because it complains: 'Struct contents reference from a non-struct array object.'

    clear filter;

    %% coregistration UNIT1s
    matlabbatch = {};
    matlabbatch = setBatchCoregistration(matlabbatch, opt, sub1stSesUNIT1, sub2stSesUNIT1);

    batchName = 'coregister_Ses001_ses002_UNIT1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    %% coregistration T1 maps
    matlabbatch = {};
    matlabbatch = setBatchCoregistration(matlabbatch, opt, T1map_001, T1map_002);

    batchName = 'coregister_Ses001_ses002_T1map';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    %% coregistration brain masks
    matlabbatch = {};
    matlabbatch = setBatchCoregistration(matlabbatch, opt, brainmask_001, brainmask_002);

    batchName = 'coregister_Ses001_ses002_brainmasks';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

end
