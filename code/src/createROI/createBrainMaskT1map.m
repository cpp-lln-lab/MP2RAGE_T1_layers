function createBrainMaskT1map(opt)

    BIDS = bids.layout(opt.dir.output, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        fprintf('subject number: %d\n', subIdx);

        %% get T1 map skullstripped
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.acq = opt.acq;
        filter.desc = 'skullstripped';
        filter.suffix = 'T1map';
        filter.prefix = '';
        T1map = bids.query(BIDS, 'data', filter);
        assert(numel(T1map) == 1);
        T1map = T1map{1};

        clear filter;

        exp = 'i1>0';
        % set batch image calculator
        input = {T1map};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'anat');
        nameMask = ['sub-' subLabel '_ses-' opt.ses '_acq-' opt.acq '_desc-brainmask_T1map.nii'];
        output = fullfile(outDir, nameMask);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, output, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;

        batchName = 'Binary Mask T1 map';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    end
end
