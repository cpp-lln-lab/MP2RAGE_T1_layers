clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();
% addpath(fullfile(pwd, '..', '..'));
% cpp_spm('init');

opt = get_option_preproc();

%% Run batches

unzip = true;

% bidsCopyInputFolder(opt, 'unzip', true, 'force', true); it tries to copy
% the entire folder, independently of the options

BIDS = bids.layout(opt.dir.preproc, ...
                   'use_schema', false);

% subIdx = 1:numel(opt.subjects)
%     subLabel = opt.subjects{subIdx};
%
%
filter.sub = opt.subjects;
filter.modality = 'anat';
filter.ses = '001';
filter.acq = 'r0p75';
filter.suffix = 'UNIT1';
filter.desc = '';
filter.space = '';

files = bids.query(BIDS, 'data', filter);

bidsSpatialPrepro(opt);
