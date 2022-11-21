clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();
opt = get_option_preproc();

%% Get UNIT1 0.75 mm
BIDS = bids.layout(opt.dir.preproc, ...
                   'use_schema', false);

filter.sub = opt.subjects;
filter.modality = 'anat';
filter.ses = '005';
filter.acq = 'r0p75';
filter.suffix = 'UNIT1';
filter.desc = '';
filter.space = '';

files = bids.query(BIDS, 'data', filter);
%% spatial preprocessing 
bidsSpatialPrepro(opt);
