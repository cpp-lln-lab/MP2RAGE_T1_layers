function opt = get_option_roisinterceptionbrainmask()
    % returns a structure that contains the options chosen by the user to...
    % copy input files, segment and skull stripping, create and merge ROIs.
    if nargin < 1
        opt = [];
    end

    opt.subjects = {'pilot001', 'pilot004', 'pilot005'};

    this_dir = fileparts(mfilename('fullpath'));
    root_dir = fullfile(this_dir, '..', '..', '..');
    opt.dir.raw = fullfile(root_dir, 'inputs', 'cpp_spm-preproc');
    opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');
    opt.dir.output = fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75');
    opt.dir.preproc = opt.dir.raw;
    opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75'), 'cpath');
    
    opt.bidsFilterFile.roi.suffix = '';

    opt = checkOptions(opt);
    saveOptions(opt);
end
