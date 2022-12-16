function calcCov(opt)

    BIDS = bids.layout(opt.dir.output, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        fprintf('subject number: %d\n', subIdx);
        %% find UNIT1 2 sessions
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.modality = 'anat';
        filter.acq = opt.acq;
        filter.suffix = 'UNIT1';
        filter.prefix = '';
        filter.desc = 'intercBrainMask';

        UNIT1_001 = bids.query(BIDS, 'data', filter);        
        assert(numel(UNIT1_001) == 1);
        UNIT1_001 = UNIT1_001{:};

        filter.ses = opt.ses2;
        filter.prefix = '';

        UNIT1_002 = bids.query(BIDS, 'data', filter);
        assert(numel(UNIT1_002) == 1);
        UNIT1_002 = UNIT1_002{:};

        %% find T1 map 2 sessions
        filter.sub = subLabel;
        filter.acq = opt.acq;
        filter.ses = opt.ses;
        filter.suffix = 'T1map';
        filter.desc = 'skullstripped';
        filter.space = '';
        filter.prefix = '';

        T1map_001 = bids.query(BIDS, 'data', filter);        
        assert(numel(T1map_001) == 1);
        T1map_001 = T1map_001{:};

        filter.ses = opt.ses2; 

        T1map_002 = bids.query(BIDS, 'data', filter);
        assert(numel(T1map_002) == 1);
        T1map_002 = T1map_002{:};

        clear filter;
        %% find brain UNIT1 masks 2 sessions
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.space = 'individual';
        filter.acq = opt.acq; 
        filter.suffix = 'mask';
        filter.prefix = '';
        brainmask_001 = bids.query(BIDS, 'data', filter);
        brainmask_001 = brainmask_001{:};
        
        filter.ses = opt.ses2;

        brainmask_002 = bids.query(BIDS, 'data', filter);
        brainmask_002 = brainmask_002{:};

        clear filter;
        %% find T1 binary masks 2 sessions

        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.acq = opt.acq;
        filter.suffix = 'T1map';
        filter.prefix = '';
        filter.desc = 'brainmask';
        brainmaskT1map_001 = bids.query(BIDS, 'data', filter);
        brainmaskT1map_001 = brainmaskT1map_001{:};

        filter.ses = opt.ses2;

        brainmaskT1map_002 = bids.query(BIDS, 'data', filter);
        brainmaskT1map_002 = brainmaskT1map_002{:};

        clear filter;
     %% common voxels UNIT1s - multiplication binary masks

        exp = 'i1.*i2';
        % set batch image calculator
        inputMaskT1maps = {brainmask_001; brainmask_002};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
        outputMaskUNIT1 = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_desc-intercBinmasks_UNIT1s.nii']);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputMaskT1maps, outputMaskUNIT1, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'binaryMaskT1maps';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %% common voxels T1 maps - multiplication binary masks

        exp = 'i1.*i2';
        % set batch image calculator
        inputMaskT1maps = {brainmaskT1map_001; brainmaskT1map_002};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
        outputMaskT1map = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_desc-intercBinmasks_T1maps.nii']);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputMaskT1maps, outputMaskT1map, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'binaryMaskT1maps';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %% CoV expressions

        expAbsdiff = 'abs(i1 - i2)';
        expMean = '(i1 + i2)./2';
        Cov = '(i1 ./ i2).*100'; %i1 is expAbsdiff and i2 is expMean

        %% set batch image calculator - UNIT1
        %expAbsdiff

        input = {UNIT1_001; UNIT1_002}; %i1, i2
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);

        outputDiff = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_absDiffSes' opt.ses '_ses' opt.ses2 '_UNIT1.nii']);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputDiff, outDir, expAbsdiff, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'AbsDiffUNIT1';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %expMean
        input = {UNIT1_001; UNIT1_002}; %i1, i2
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);

        outputMean = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_meanSes' opt.ses '_ses' opt.ses2 '_UNIT1.nii']);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputMean, outDir, expMean, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'AbsDiffUNIT1';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %CoV
        input = {outputDiff; outputMean}; %i1, i2
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);

        outputCoV = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_covSes' opt.ses '_ses' opt.ses2 '_UNIT1.nii']);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCoV, outDir, Cov, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'CoVUNIT1';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %CoV common voxels
        exp = 'i1.*i2';
        input = {outputCoV; outputMaskUNIT1}; %i1, i2
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);

        outputCommon = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_cov-commonVoxSes' opt.ses '_ses' opt.ses2 '_UNIT1.nii']);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCommon, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'CoV-CommonVoxelsUNI1';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %% set batch image calculator - T1 map

        %expAbsdiff

        input = {T1map_001; T1map_002}; %i1, i2
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);

        outputDiff = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_absDiffSes' opt.ses 'Ses' opt.ses2 '_T1map.nii']);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputDiff, outDir, expAbsdiff, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'AbsDiffT1map';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %expMean
        input = {T1map_001; T1map_002}; %i1, i2
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);

        outputMean = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_meanSes' opt.ses 'Ses' opt.ses2 '_T1map.nii']);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputMean, outDir, expMean, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'AbsDiffT1map';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %CoV
        input = {outputDiff; outputMean}; %i1, i2
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);

        outputCoV = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_covSes' opt.ses 'Ses' opt.ses2 '_T1map.nii']);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCoV, outDir, Cov, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'CoVT1map';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %CoV common voxels
        exp = 'i1.*i2';
        input = {outputCoV; outputMaskT1map}; %i1, i2
        outDir = fullfile(opt.dir.output, ['sub-' subLabel]);

        outputCommon = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-' opt.acq '_covCommonVoxSes' opt.ses 'Ses' opt.ses2 '_T1map.nii']);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCommon, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'CoV-CommonVoxelsT1map';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    end
end