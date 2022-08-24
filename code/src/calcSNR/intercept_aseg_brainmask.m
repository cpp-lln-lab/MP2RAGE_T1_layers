clear;
clc;

run ../initEnv();
addpath(fullfile(pwd, '../createROI'));
opt = get_option_preproc();
opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)

    subLabel = opt.subjects{subIdx};
    aseg = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/anat'), 'raseg.auto_noCCseg.nii');

    header_aseg = spm_vol(aseg);
    aseg_vol = spm_read_vols(header_aseg);

    %% select UNIT1
    filter.sub = subLabel;
    filter.suffix = 'UNIT1';
    filter.acq = 'r0p75';
    filter.ses = '001';
    filter.desc = 'intercBrainMask';
    UNIT1 = bids.query(BIDS, 'data', filter);
    UNIT1 = UNIT1{1};

    header_UNIT1 = spm_vol(UNIT1);
    UNIT1_vol = spm_read_vols(header_UNIT1);

    clear filter;

    %% select brain mask
    filter.sub = subLabel;
    filter.suffix = 'mask';
    filter.acq = 'r0p75';
    filter.space = 'individual';
    filter.ses = '001'; % change for other sessions
    filter.desc = 'brain';
    BrainMask = bids.query(BIDS, 'data', filter);
    BrainMask = BrainMask{1};

    clear filter;

    header_BrainMask = spm_vol(BrainMask);
    BrainMask_vol = spm_read_vols(header_BrainMask);

    %% intercept aseg with brain mask
    aseg_intercept = aseg_vol .* BrainMask_vol;

    %% save aseg
    header_aseg_intercept = header_aseg;
    header_aseg_intercept.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/anat', 'raseg.auto_noCCseg_interceptBrainmask.nii');
    header_aseg_intercept.private.dat.fname = header_aseg_intercept.fname;
    header_aseg_intercept.dt = header_aseg.dt;
    aseg_intercept_nii = spm_write_vol(header_aseg_intercept, aseg_intercept);

end
