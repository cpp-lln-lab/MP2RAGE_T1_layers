function resliceAsegAutoToUNIT1(opt)

    BIDS = bids.layout(opt.dir.output, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)
        subLabel = opt.subjects{subIdx};

        %% find aseg
        filter.modality = 'anat';
        filter.sub = subLabel;
        filter.ses = opt.bidsFilterFile.t1w.ses;
        filter.acq = opt.acq;
        filter.suffix = 'aseg';
        filter.prefix = '';
        aseg = bids.query(BIDS, 'data', filter);
        assert(numel(aseg) == 1);
        aseg = aseg{:}; 

        %% select UNIT1
        filter.sub = subLabel;
        filter.suffix = 'UNIT1';
        filter.acq = opt.acq;
        filter.ses = opt.bidsFilterFile.t1w.ses;
        filter.desc = 'intercBrainMask';
        UNIT1 = bids.query(BIDS, 'data', filter);
        assert(numel(UNIT1) == 1);
        UNIT1 = UNIT1{:}; 

        clear filter;

        %% reslice with nearest neighbour interpolation
        interpolation = 0;
        matlabbatch = {};
        matlabbatch = setBatchReslice(matlabbatch, opt, UNIT1, aseg, interpolation);

        batchName = 'reslice_aseg_to_UNIT1';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
    end
end