function CoregResliceses002UNIT1andT1map(opt)

    BIDS = bids.layout(opt.dir.output, ...
                       'use_schema', false);

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

        %% find brain masks UNIT1 2 sessions
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.space = 'individual';
        filter.acq = opt.acq;
        filter.suffix = 'mask';
        brainmaskUNIT1_001 = bids.query(BIDS, 'data', filter);
        assert(numel(brainmaskUNIT1_001) == 1);
        brainmaskUNIT1_001 = brainmaskUNIT1_001{:};

        filter.ses = opt.ses2;

        brainmaskUNIT1_002 = bids.query(BIDS, 'data', filter);
        assert(numel(brainmaskUNIT1_002) == 1);
        brainmaskUNIT1_002 = brainmaskUNIT1_002{:};

        clear filter;

        %% find T1 map binary masks 2 sessions

        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.acq = opt.acq;
        filter.suffix = 'T1map';
        filter.desc = 'brainmask';

        brainmaskT1map_001 = bids.query(BIDS, 'data', filter);
        assert(numel(brainmaskT1map_001) == 1);
        brainmaskT1map_001 = brainmaskT1map_001{:};

        filter.ses = opt.ses2;

        brainmaskT1map_002 = bids.query(BIDS, 'data', filter);
        assert(numel(brainmaskT1map_002) == 1);
        brainmaskT1map_002 = brainmaskT1map_002{:};

        clear filter;
        %% coregistration UNIT1s
        matlabbatch = {};
        matlabbatch = setBatchCoregistration(matlabbatch, opt, UNIT1_001, UNIT1_002);

        batchName = ['coregister_Ses' opt.ses '_ses' opt.ses2 '_UNIT1'];
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %% coregistration T1 maps
        matlabbatch = {};
        matlabbatch = setBatchCoregistration(matlabbatch, opt, T1map_001, T1map_002);

        batchName = ['coregister_Ses' opt.ses '_ses' opt.ses2 '_T1map'];
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %% coregistration brain masks UNIT1
        matlabbatch = {};
        matlabbatch = setBatchCoregistration(matlabbatch, opt, brainmaskUNIT1_001, brainmaskUNIT1_002);

        batchName = ['coregister_Ses' opt.ses '_ses' opt.ses2 '_brainmasksUNIT1'];
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        %% coregistration brain masks T1 map
        matlabbatch = {};
        matlabbatch = setBatchCoregistration(matlabbatch, opt, brainmaskT1map_001, brainmaskT1map_002);

        batchName = ['coregister_Ses' opt.ses '_ses' opt.ses2 '_brainmasksT1map'];
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    end
end
