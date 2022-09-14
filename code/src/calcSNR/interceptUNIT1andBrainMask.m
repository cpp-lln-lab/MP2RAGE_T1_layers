function interceptUNIT1andBrainMask(opt)

    BIDS = bids.layout(opt.dir.preproc, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)
        subLabel = opt.subjects{subIdx};

        %% get brain mask
        filter.modality = 'anat';
        filter.sub = subLabel;
        filter.ses = '001';    % change accordingly to the session
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
        filter.ses = '001';    % change accordingly to the session
        filter.desc = '';
        filter.space = '';
        UNIT1 = bids.query(BIDS, 'data', filter);
        UNIT1 = UNIT1{:};

        clear filter;
        
        %% set batch
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
    end

end
