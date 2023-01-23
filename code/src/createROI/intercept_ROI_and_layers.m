function intercept_ROI_and_layers(opt)
    if nargin < 1
        opt = [];
    end

    BIDS = bids.layout(opt.dir.output, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        printProcessingSubject(subIdx, subLabel, opt);

        %% find resliced layers
        filter.sub = subLabel;
        filter.acq = opt.acq;
        filter.space = 'individual';
        filter.prefix = 'r';
        filter.label = '6layerEquidist';
        filter.suffix = 'mask';

        layers = bids.query(BIDS, 'data', filter);
        assert(numel(layers) == 1);
        layers = layers {1};

        clear filter;

        %% find ROIs intercepted with T1 map binary mask
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.space = 'individual';
        filter.label = opt.roi.name;
        filter.suffix = 'mask';
        filter.desc = 'intercT1mapBin';
        filter.prefix = '';

        listofRois = bids.query(BIDS, 'data', filter);
        hdr = spm_vol(listofRois);

        clear filter;

        [BIDS, opt] = setUpWorkflow(opt, 'intercept ROI and layers');

        for ROIidx = 1:numel(listofRois)
            bf = bids.File(char(listofRois(ROIidx)));
            ROIName = bf.entities.label;
            bf.entities.desc = '6layers';

            outputCommonVoxelsName = fullfile(spm_fileparts(hdr{ROIidx, 1}.fname), bf.filename);
            %% multiplication ROIs and layers
            exp = 'i1.*i2';
            % set batch image calculator
            input = {layers; listofRois{ROIidx}};
            outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'roi');
            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCommonVoxelsName, outDir, exp, 'float32');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'VoxelCount';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        end
    end

end
