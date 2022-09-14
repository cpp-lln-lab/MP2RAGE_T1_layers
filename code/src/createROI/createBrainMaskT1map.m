function createBrainMaskT1map(opt)

    opt.dir.roi = opt.dir.output;

    BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        fprintf('subject number: %d\n', subIdx);

        %% get T1 map
        filter.sub = subLabel;
        filter.ses = '002';
        filter.acq = 'r0p75'; % change depending on the pipeline
        filter.desc = 'skullstripped';
        filter.suffix = 'T1map';
        filter.prefix = '';
        T1map = bids.query(BIDS, 'data', filter);
        T1map = T1map{:}; 
        
        acq = filter.acq;
        session = filter.ses;
        
        clear filter;
        
        exp = 'i1>0';
        % set batch image calculator
        input = {T1map};
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' session], 'anat');
        nameMask = ['sub-' subLabel '_ses-' session '_acq-' acq '_desc-brainmask_T1map.nii'];
        output = fullfile(outDir, nameMask);
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, output, outDir, exp, 'int16');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
        batchName = 'Binary Mask T1 map';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    end
end
