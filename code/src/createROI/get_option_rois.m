function opt = get_option_rois()
    % returns a structure that contains the options chosen by the user to...
    % copy input files, segment and skull stripping, create and merge ROIs.
    if nargin < 1
        opt = [];
    end

%     opt.subjects = {'pilot001', 'pilot004', 'pilot005'};
% 
%     opt.query.modality = 'anat';
%     opt.query.ses = '001';
%     opt.query.desc = 'skullstripped';
%     opt.query.acq = 'r0p75';
%     opt.query.suffix = {'UNIT1', 'xfm'};

    this_dir = fileparts(mfilename('fullpath'));
    root_dir = fullfile(this_dir, '..', '..', '..');
    %opt.dir.raw = fullfile(root_dir, 'outputs');
    opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');
    opt.dir.output = fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75');
    opt.dir.preproc = opt.dir.output;
    opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75'), 'cpath');

    opt.pipeline.type = 'roi';
    %opt.anatOnly = 'true';

    opt.bidsFilterFile.t1w.suffix = 'UNIT1';
%     opt.roi.atlas = 'visfAtlas';
%     opt.roi.name = {'mFus', 'pFus', 'IOG', 'OTS', 'ITG',...
%         'MTG', 'LOS', 'CoS', 'hMT', 'v1d', 'v2d', 'v3d', ...
%         'v1v', 'v2v', 'v3v'}; %'rh_TOS', 'lh_pOTS', 'lh_IOS'
    opt.roi.space = {'IXI549Space', 'individual'};
    % opt.dir.stats = fullfile(opt.dir.raw, '..', 'derivatives', 'cpp_spm-stats');

    % If you use 'individual', then we stay in native space (that of the anat image)
    % set to 'MNI' to normalize data
    opt.space = 'individual';
    opt.bidsFilterFile.t1w.ses = '001';
    opt = checkOptions(opt);
    saveOptions(opt);
end
