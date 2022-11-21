function interceptUNIT1andBrainMask(opt)

    BIDS = bids.layout(opt.dir.preproc, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)
        subLabel = opt.subjects{subIdx};

        %% get brain mask
        filter.modality = 'anat';
        filter.sub = subLabel;
        filter.ses = '005';    % change accordingly to the session
        filter.space = 'individual';
        % filter.acq = 'r0p75';
        filter.suffix = 'mask';
        brainmask = bids.query(BIDS, 'data', filter);
        brainmask = brainmask{:}; 

        session = filter.ses;

        clear filter;

        %% get UNIT1
        filter.sub = subLabel;
        filter.suffix = 'UNIT1';
        filter.ses = '005';    % change accordingly to the session
        filter.desc = '';
        filter.space = '';
        UNIT1 = bids.query(BIDS, 'data', filter);
        UNIT1 = UNIT1{:};

        clear filter;
        
        %% get t1 map
        filter.sub = subLabel;
        filter.suffix = 'T1map';
        filter.ses = '005';    % change accordingly to the session
        filter.desc = '';
        filter.space = '';
        T1map = bids.query(BIDS, 'data', filter);
        T1map = T1map{:};

        
        clear filter;
        
        %% set batch
        %UNIT1 no bias
        NoBias = fullfile(['sub-' subLabel '_ses-' session '_acq-r0p75_desc-intercBrainMask_UNIT1.nii']);  % This is where you fill in the new filename
        exp = 'i1.*i2';
        % set batch image calculator
        
        inputs = {char(brainmask); char(UNIT1)};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' session], 'anat');
        output = fullfile(outDir, NoBias);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputs, output, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
        batchName = 'Common Voxels brainmask and UNIT1';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
        
        %% T1map - skullstripped
        T1mapSkullstripped = fullfile(['sub-' subLabel '_ses-005_acq-r0p75_desc-skullstripped_T1map.nii']);  % This is where you fill in the new filename
        exp = 'i1.*i2';
        % set batch image calculator
        
        inputs = {char(brainmask); char(T1map)};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], 'ses-005', 'anat');
        output = fullfile(outDir, T1mapSkullstripped);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputs, output, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
        batchName = 'Common Voxels brainmask and T1map';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
        
        %% save brain mask as T1 map binary mask
        T1binmask = fullfile(['sub-pilot001_ses-005_acq-r0p75_desc-brainmask_T1map.nii']);  % This is where you fill in the new filename
        exp = 'i1>0';
        % set batch image calculator
        
        inputs = {output};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], 'ses-005', 'anat');
        output = fullfile(outDir, T1binmask);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputs, output, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
        batchName = 'T1 map bin mask';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    end

end
