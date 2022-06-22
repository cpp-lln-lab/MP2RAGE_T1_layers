clear;
clc;


addpath(fullfile(pwd, '..'));
initEnv();
% addpath(fullfile(pwd, '..', '..'));
% cpp_spm('init');


opt = get_option_preproc();

% check = checkDependencies();

%% Run batches

unzip = true;

%bidsCopyInputFolder(opt, 'unzip', true, 'force', true); it tries to copy
%the entire folder, independently of the options 

%bidsSTC(opt);
opt.subjects = {'pilot001'}; %, 'pilot005'};
opt.skullstrip.threshold = 0.75;


%bidsSegmentSkullStrip(opt);

bidsSpatialPrepro(opt);
