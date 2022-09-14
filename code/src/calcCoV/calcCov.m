clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();

addpath(fullfile(pwd, '../calcSNR'));
opt = get_option_preproc();

BIDS = bids.layout(opt.dir.output, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)

    subLabel = opt.subjects{subIdx};
    fprintf('subject number: %d\n', subIdx);
    %% find UNIT1 sess 001 and 002
    filters.sub = subLabel;
    filters.ses = '001';
    filters.modality = 'anat';
    filters.acq = 'r0p75';
    filters.suffix = 'UNIT1';
    filters.prefix = '';
    filters.desc = 'intercBrainMask';

    sub1stSesUNIT1 = bids.query(BIDS, 'data', filters);
    sub1stSesUNIT1 = sub1stSesUNIT1{1};

    filters.ses = '002';
    filters.prefix = '';

    sub2ndSesUNIT1 = bids.query(BIDS, 'data', filters);
    sub2ndSesUNIT1 = sub2ndSesUNIT1{1};

    %% find T1 map 001 and 002 sessions
    filter.sub = subLabel;
    filter.acq = 'r0p75';
    filter.ses = '001';
    filter.suffix = 'T1map';
    filter.desc = 'skullstripped';
    filter.space = '';
    filter.prefix = '';

    T1map_001 = bids.query(BIDS, 'data', filter);
    T1map_001 = T1map_001{1};

    filter.ses = '002'; 
    
    T1map_002 = bids.query(BIDS, 'data', filter);
    T1map_002 = T1map_002{1};

    clear filter;
    %% find brain UNIT1 masks 001 and 002 sessions
    filter.sub = subLabel;
    filter.ses = '001';
    filter.space = 'individual';
    filter.acq = 'r0p75'; 
    filter.suffix = 'mask';
    filter.prefix = '';
    brainmask_001 = bids.query(BIDS, 'data', filter);
    brainmask_001 = brainmask_001{:}; 
    filter.ses = '002';

    brainmask_002 = bids.query(BIDS, 'data', filter);
    brainmask_002 = brainmask_002{:};

    clear filter;
    %% find T1 binary masks 

    filter.sub = subLabel;
    filter.ses = '001';
    filter.acq = 'r0p75';
    filter.suffix = 'T1map';
    filter.prefix = '';
    filter.desc = 'brainmask';
    brainmaskT1map_001 = bids.query(BIDS, 'data', filter);
    brainmaskT1map_001 = brainmaskT1map_001{:}; 

    filter.ses = '002';

    brainmaskT1map_002 = bids.query(BIDS, 'data', filter);
    brainmaskT1map_002 = brainmaskT1map_002{:}; 

    clear filter;
 %% common voxels UNIT1s - multiplication binary masks
    
    exp = 'i1.*i2';
    % set batch image calculator
    inputMaskT1maps = {brainmask_001; brainmask_002};
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    outputMaskUNIT1 = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_desc-intercBinmasks_UNIT1s.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputMaskT1maps, outputMaskUNIT1, outDir, exp, 'int16');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'binaryMaskT1maps';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
    %% common voxels T1 maps - multiplication binary masks
    
    exp = 'i1.*i2';
    % set batch image calculator
    inputMaskT1maps = {brainmaskT1map_001; brainmaskT1map_002};
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    outputMaskT1map = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_desc-intercBinmasks_T1maps.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputMaskT1maps, outputMaskT1map, outDir, exp, 'int16');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
    batchName = 'binaryMaskT1maps';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
    %% CoV expressions

    expAbsdiff = 'abs(i1 - i2)';
    expMean = '(i1 + i2)./2';
    Cov = '(i1 ./ i2).*100'; %i1 is expAbsdiff and i2 is expMean
    
    %% set batch image calculator - UNIT1
    %expAbsdiff
    
    input = {sub1stSesUNIT1; sub2ndSesUNIT1}; %i1, i2
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    
    outputDiff = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_AbsDiffSes001Ses002_UNIT1.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputDiff, outDir, expAbsdiff, 'float32');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'AbsDiffUNIT1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
    %expMean
    input = {sub1stSesUNIT1; sub2ndSesUNIT1}; %i1, i2
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    
    outputMean = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_MeanSes001Ses002_UNIT1.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputMean, outDir, expMean, 'float32');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'AbsDiffUNIT1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
    %CoV
    input = {outputDiff; outputMean}; %i1, i2
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    
    outputCoV = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_CoVSes001Ses002_UNIT1.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCoV, outDir, Cov, 'float32');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'CoVUNIT1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
    %CoV common voxels
    exp = 'i1.*i2';
    input = {outputCoV; outputMaskUNIT1}; %i1, i2
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    
    outputCommon = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_CoV-CommonVoxSes001Ses002_UNIT1.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCommon, outDir, exp, 'float32');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'CoV-CommonVoxelsUNI1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    %% set batch image calculator - T1 map
    
    %expAbsdiff
    
    input = {T1map_001; T1map_002}; %i1, i2
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    
    outputDiff = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_AbsDiffSes001Ses002_T1map.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputDiff, outDir, expAbsdiff, 'float32');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'AbsDiffT1map';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
    %expMean
    input = {T1map_001; T1map_002}; %i1, i2
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    
    outputMean = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_MeanSes001Ses002_T1map.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputMean, outDir, expMean, 'float32');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'AbsDiffT1map';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
    %CoV
    input = {outputDiff; outputMean}; %i1, i2
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    
    outputCoV = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_CoVSes001Ses002_T1map.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCoV, outDir, Cov, 'float32');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'CoVT1map';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
    %CoV common voxels
    exp = 'i1.*i2';
    input = {outputCoV; outputMaskT1map}; %i1, i2
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    
    outputCommon = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_CoV-CommonVoxSes001Ses002_T1map.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCommon, outDir, exp, 'float32');
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;

    batchName = 'CoV-CommonVoxelsT1map';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    
end
