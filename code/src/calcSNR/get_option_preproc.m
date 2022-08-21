function opt = get_option_preproc()
    % returns a structure that contains the options chosen by the user to...
    % copy input files, segment and skull stripping, create and merge ROIs.
    if nargin < 1
        opt = [];
    end

    opt.subjects = {'pilot004'};

    this_dir = fileparts(mfilename('fullpath'));
    root_dir = fullfile(this_dir, '..', '..', '..');
    opt.dir.raw = fullfile(root_dir, 'inputs', 'raw');
    opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');
    opt.dir.output = fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75');
    opt.dir.input = opt.dir.raw;

    opt.pipeline.type = 'preproc';
    opt.dir.preproc = opt.dir.output;
    opt.anatOnly = true;
    opt.skullstrip.threshold = 0.90;

    opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75'), 'cpath');
    opt.roi.name = {'IOG', 'OTS', 'ITG', ...
                    'MTG', 'LOS', 'hMT', 'v1d', 'v2d', 'v3d', ...
                    'v1v', 'v2v', 'v3v', 'mFus', 'pFus', 'CoS'};
    % 'rh_TOS', 'lh_pOTS', 'lh_IOS'
    opt.roi.atlas = 'visfAtlas';

    opt.bidsFilterFile.roi.suffix = '';
    opt.bidsFilterFile.t1w.suffix = 'UNIT1';
    opt.bidsFilterFile.t1w.ses = '001';
    opt.dryRun = false; % don't want to run the analysis

    % If you use 'individual', then we stay in native space (that of the anat image)
    % set to 'MNI' to normalize data
    opt.space = {'IXI549Space', 'individual'};
    opt.roi.space = {'IXI549Space', 'individual'};

    opt.segment.force = true;

    opt = checkOptions(opt);
    saveOptions(opt);
end
