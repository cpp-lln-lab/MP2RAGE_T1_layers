function resliceLayersToRoi(opt)

    BIDS = bids.layout(opt.dir.output, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};

        %% get reference image

        filter.sub = subLabel;
        filter.suffix = 'UNIT1';
        filter.modality = 'anat';
        filter.space = 'individual';
        filter.desc = 'skullstripped';
        filter.acq = opt.acq;

        ref = bids.query(BIDS, 'data', filter);
        assert(numel(ref) == 1);
        ref = ref{1};

        clear filter;

        %% get source image to reslice

        filter.sub = subLabel;
        filter.extension = '.nii';
        filter.label = '6layerEquidist';
        filter.prefix = '';

        layers = bids.query(BIDS, 'data', filter);
        % should have one image only
        assert(numel(layers) == 1);
        layers = layers{1};

        clear filter;

        %% reslice with nearest neighbour interpolation
        interpolation = 0;
        matlabbatch = {};
        matlabbatch = setBatchReslice(matlabbatch, opt, ref, layers, interpolation);

        batchName = 'reslice_layers_to_UNIT1';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    end
end