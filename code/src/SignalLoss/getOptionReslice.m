function opt = getOptionReslice()
    % returns a structure that contains the options chosen by the user to...
    % copy input files, segment and skull stripping, create and merge ROIs.
    if nargin < 1
        opt = [];
    end

    this_dir = fileparts(mfilename('fullpath'));
    root_dir = fullfile(this_dir, '..', '..', '..');
    % opt.dir.raw = fullfile(root_dir, 'outputs');
    opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');
    opt.dir.output = fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75');
    opt.dir.preproc = opt.dir.output;
    opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75'), 'cpath');

    opt.pipeline.type = 'anat';

    opt = checkOptions(opt);
    saveOptions(opt);
end
