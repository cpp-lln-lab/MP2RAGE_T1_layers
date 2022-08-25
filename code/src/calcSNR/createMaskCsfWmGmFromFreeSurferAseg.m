clear;
clc;

run ../initEnv();
addpath(fullfile(pwd, '../createROI'));
opt = get_option_preproc();
opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)

    subLabel = opt.subjects{subIdx};
    aseg = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/anat'), 'raseg.auto_noCCseg_interceptBrainmask.nii');

    header_aseg = spm_vol(aseg);
    aseg_vol = spm_read_vols(header_aseg);

    %% csf matrix
    label = 'CSF';
    csf = zeros(size(aseg_vol));
    csf(aseg_vol == 24) = 1;
    % save csf
    CSFFilename = ['sub-' subLabel '_ses-001' '_space-individual_label-CSF_desc-raseg.auto_noCCseg.nii'];
    header_csf = header_aseg;
    header_csf.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/roi', CSFFilename);
    header_csf.private.dat.fname = header_csf.fname;
    header_csf.dt = header_aseg.dt;
    csf_nii = spm_write_vol(header_csf, csf);

    %% white matter matrix
    label = 'WM';
    wm = zeros(size(aseg_vol));
    wm_L = zeros(size(aseg_vol));
    wm_R = zeros(size(aseg_vol));

    % Left WM
    wm_L(aseg_vol == 2) = 1;
    WM_hemiLFilename = ['sub-' subLabel '_ses-001' '_hemi-L_space-individual_label-WM_desc-raseg.auto_noCCseg.nii'];

    header_wm_L = header_aseg;
    header_wm_L.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/roi', WM_hemiLFilename);

    header_wm_L.private.dat.fname = header_wm_L.fname;
    header_wm_L.dt = header_aseg.dt;
    wm_L_nii = spm_write_vol(header_wm_L, wm_L);

    % Right WM
    wm_R(aseg_vol == 41) = 1;

    WM_hemiRFilename = ['sub-' subLabel '_ses-001' '_hemi-R_space-individual_label-WM_desc-raseg.auto_noCCseg.nii'];
    header_wm_R = header_aseg;
    header_wm_R.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/roi', WM_hemiRFilename);
    header_wm_R.private.dat.fname = header_wm_R.fname;
    header_wm_R.dt = header_aseg.dt;
    wm_R_nii = spm_write_vol(header_wm_R, wm_R);

    % save white matter
    wm(aseg_vol == 2 | aseg_vol == 41) = 1;
    WMFilename = ['sub-' subLabel '_ses-001' '_space-individual_label-WM_desc-raseg.auto_noCCseg.nii'];

    header_wm = header_aseg;
    header_wm.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/roi', WMFilename);
    header_wm.private.dat.fname = header_wm.fname;
    header_wm.dt = header_aseg.dt;
    wm_nii = spm_write_vol(header_wm, wm);

    %% grey matter matrix
    label = 'GM';
    gm = zeros(size(aseg_vol));
    gm_L = zeros(size(aseg_vol));
    gm_R = zeros(size(aseg_vol));

    % Left GM
    gm_L(aseg_vol == 3) = 1;
    GM_hemiLFilename = ['sub-' subLabel '_ses-001' '_hemi-L_space-individual_label-GM_desc-raseg.auto_noCCseg.nii'];

    header_gm_L = header_aseg;
    header_gm_L.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/roi', GM_hemiLFilename);

    header_gm_L.private.dat.fname = header_gm_L.fname;
    header_gm_L.dt = header_aseg.dt;
    gm_L_nii = spm_write_vol(header_gm_L, gm_L);

    % Right WM
    gm_R(aseg_vol == 42) = 1;

    GM_hemiRFilename = ['sub-' subLabel '_ses-001' '_hemi-R_space-individual_label-GM_desc-raseg.auto_noCCseg.nii'];
    header_gm_R = header_aseg;
    header_gm_R.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/roi', GM_hemiRFilename);
    header_gm_R.private.dat.fname = header_gm_R.fname;
    header_gm_R.dt = header_aseg.dt;
    gm_R_nii = spm_write_vol(header_gm_R, gm_R);

    % save grey matter
    gm(aseg_vol == 3 | aseg_vol == 42) = 1;
    GMFilename = ['sub-' subLabel '_ses-001' '_space-individual_label-GM_desc-raseg.auto_noCCseg.nii'];

    header_gm = header_aseg;
    header_gm.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/roi', GMFilename);
    header_gm.private.dat.fname = header_gm.fname;
    header_gm.dt = header_aseg.dt;
    gm_nii = spm_write_vol(header_gm, gm);

    % create foreground - WM + GM

    foreground = wm + gm;
    ForegrdFilename = ['sub-' subLabel '_ses-001' '_space-individual_label-Foreground_desc-raseg.auto_noCCseg.nii'];
    header_Foregrd = header_aseg;
    header_Foregrd.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001/roi', ForegrdFilename);
    header_Foregrd.private.dat.fname = header_Foregrd.fname;
    header_Foregrd.dt = header_aseg.dt;
    Foreground_nii = spm_write_vol(header_Foregrd, foreground);

end
