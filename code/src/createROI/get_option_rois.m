function opt = get_option_rois()
    % returns a structure that contains the options chosen by the user ...
    % to run the workflows that extract T1 laminar profile in occipital- ...
    % temporal regions
    if nargin < 1
        opt = [];
    end

    opt.subjects = {'pilot001'};
    opt.ses = '001';
    opt.acq = 'r0p375';
    opt.brainmask = 'label';

    opt.roi.name = {'V1v', 'V1d'};
    opt.roi.atlas = 'wang';

    opt.query.modality = 'anat';
    opt.query.ses = '001';
    opt.query.desc = 'skullstripped';
    opt.query.acq = 'r0p375';
    opt.query.suffix = {'UNIT1', 'xfm'};

    this_dir = fileparts(mfilename('fullpath'));
    root_dir = fullfile(this_dir, '..', '..', '..');
    opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');
    opt.dir.output = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
    opt.dir.preproc = opt.dir.output;
    opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');

    opt.pipeline.type = 'roi';

    opt.bidsFilterFile.t1w.suffix = 'UNIT1';

    opt.roi.space = {'IXI549Space', 'individual'};
    opt.space = 'individual';
    opt.bidsFilterFile.t1w.ses = '001';
    opt = checkOptions(opt);
    saveOptions(opt); % options are saved in a JSON file in a ``cfg`` folder
end
