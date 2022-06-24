function opt = get_option_rois()
    %returns a structure that contains the options chosen by the user to...
    %copy input files, segment and skull stripping, create and merge ROIs.
    if nargin < 1
        opt=[];
    end
    

    opt.subjects = {'pilot001', 'pilot004', 'pilot005'};
    
    this_dir = fileparts(mfilename('fullpath'));
    root_dir = fullfile(this_dir, '..', '..', '..');
    opt.dir.raw = fullfile(root_dir, 'inputs', 'raw');
    opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');
    opt.dir.output = fullfile(opt.dir.derivatives, 'cpp_spm-roi_acq-0p75');
    opt.dir.input = opt.dir.raw;
    
    opt.pipeline.type = 'preproc';
    opt.dir.preproc = opt.dir.output;
    opt.anatOnly = true;
    
    BIDS = bids.layout(opt.dir.raw, ...
                   'use_schema', false);
               
    filters.sub = {'pilot001', 'pilot004', 'pilot005'};
    filters.modality = 'anat';
    filters.acq = 'r0p75';
    filters.suffix = 'UNIT1';
    filters.space = 'individual';
    filters.desc = 'skullstripped';
    
    files = bids.query(BIDS, 'data', filters);

    disp(files);

    opt=checkOptions(opt);
    saveOptions(opt);
end