

function opt = get_option_rois()
    %returns a structure that contains the options chosen by the user to...
    %copy input files, segment and skull stripping, create and merge ROIs.
    if nargin < 1
        opt=[];
    end
    

    opt.subjects = {'pilot001', 'pilot004', 'pilot005'};
    
    opt.query.modality = 'anat';
    opt.query.ses = '001';
    opt.query.acq = 'r0p75';
    opt.query.suffix = 'UNIT1';

    this_dir = fileparts(mfilename('fullpath'));
    root_dir = fullfile(this_dir, '..', '..', '..');
    opt.dir.raw = fullfile(root_dir, 'inputs', 'cpp_spm-preproc');
    opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');
    opt.dir.output = fullfile(opt.dir.derivatives, 'cpp_spm-roi0p75');
    opt.dir.preproc = opt.dir.raw;
    
    opt.pipeline.type = 'roi';
    opt.anatOnly = 'true';
    
    opt.bidsFilterFile.t1w.suffix = 'UNIT1';
    opt.roi.space = {'IXI549Space', 'individual'};
    %opt.dir.stats = fullfile(opt.dir.raw, '..', 'derivatives', 'cpp_spm-stats');

    % If you use 'individual', then we stay in native space (that of the anat image)
    % set to 'MNI' to normalize data
    opt.space = {'IXI549Space', 'individual'};

    opt=checkOptions(opt);
    saveOptions(opt);
end