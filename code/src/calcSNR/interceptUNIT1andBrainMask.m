function interceptUNIT1andBrainMask(opt)

    BIDS = bids.layout(opt.dir.preproc, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)
        subLabel = opt.subjects{subIdx};

        %% get brain mask
        filter.modality = 'anat';
        filter.sub = subLabel;
        filter.ses = opt.bidsFilterFile.t1w.ses;    % change accordingly to the session
        filter.space = 'individual';
        filter.acq = opt.acq;
        filter.suffix = 'mask';
        brainmask = bids.query(BIDS, 'data', filter);
        assert(numel(brainmask) == 1);
        brainmask = brainmask{:};

        clear filter;

        %% get UNIT1
        filter.sub = subLabel;
        filter.suffix = 'UNIT1';
        filter.ses = opt.bidsFilterFile.t1w.ses;    % change accordingly to the session
        filter.desc = '';
        filter.space = '';
        UNIT1 = bids.query(BIDS, 'data', filter);
        assert(numel(UNIT1) == 1);
        UNIT1 = UNIT1{:};

        clear filter;

        %% get t1 map
        filter.sub = subLabel;
        filter.suffix = 'T1map';
        filter.ses = opt.bidsFilterFile.t1w.ses;    % change accordingly to the session
        filter.desc = '';
        filter.space = '';
        T1map = bids.query(BIDS, 'data', filter);
        assert(numel(T1map) == 1);
        T1map = T1map{:};

        clear filter;

        %% set batch
        % UNIT1 no bias
        NoBias = fullfile(['sub-' subLabel '_ses-' char(opt.bidsFilterFile.t1w.ses) '_acq-' char(opt.acq) '_desc-intercBrainMask_UNIT1.nii']);
        exp = 'i1.*i2';

        % set batch image calculator
        inputs = {char(brainmask); char(UNIT1)};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' char(opt.bidsFilterFile.t1w.ses)], 'anat');
        output = fullfile(outDir, NoBias);

        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputs, output, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'Common Voxels brainmask and UNIT1';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %% T1map - skullstripped
        T1mapSkullstripped = fullfile(['sub-' subLabel '_ses-' char(opt.bidsFilterFile.t1w.ses) '_acq-' opt.acq '_desc-skullstripped_T1map.nii']);
        exp = 'i1.*i2';

        % set batch image calculator
        inputs = {char(brainmask); char(T1map)};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' char(opt.bidsFilterFile.t1w.ses)], 'anat');
        output = fullfile(outDir, T1mapSkullstripped);

        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputs, output, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'Common Voxels brainmask and T1map';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %% save brain mask as T1 map binary mask
        T1binmask = fullfile(['sub-' subLabel '_ses-' char(opt.bidsFilterFile.t1w.ses) '_acq-' opt.acq '_desc-brainmask_T1map.nii']);
        exp = 'i1>0';
        % set batch image calculator

        inputs = {output};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' char(opt.bidsFilterFile.t1w.ses)], 'anat');
        output = fullfile(outDir, T1binmask);

        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputs, output, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'T1 map bin mask';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    end

end
