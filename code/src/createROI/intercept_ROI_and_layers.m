function intercept_ROI_and_layers(opt)
    if nargin < 1
        opt = [];
    end

    BIDSref = bids.layout(opt.dir.output, 'use_schema', false);

    for iSub = 1:numel(opt.subjects)
        subLabel = opt.subjects{iSub};
        printProcessingSubject(iSub, subLabel, opt);

        %% find resliced layers
        filter.sub = subLabel;
        filter.acq = 'r0p375';
        filter.space = 'individual';
        filter.prefix = 'r';
        filter.label = '6layerEquidist';
        filter.suffix = 'mask';

        layers = bids.query(BIDSref, 'data', filter);
        layers = layers {1};

        clear filter;

        %% find ROIs intercepted with T1 map binary mask
        filter.sub = subLabel;
        filter.ses = '001';
        filter.space = 'individual';
        filter.label = {'V1d', 'V1v', 'pFus', 'mFus', 'CoS'};
        filter.suffix = 'mask';
        filter.desc = 'intercT1mapBin';
        filter.prefix = '';

        listofRois = bids.query(BIDSref, 'data', filter);
        clear filter;
        [BIDS, opt] = setUpWorkflow(opt, 'intercept ROI and layers');
        for ROIidx = 1:numel(listofRois)
            Roiname = strcat(char(extractBetween(listofRois{ROIidx}, '\roi\', 'desc-')), 'desc-6layers_mask.nii');
            session = char(extractBetween(listofRois{ROIidx}, '\ses-', '\roi\'));
            Roi = char(extractBetween(listofRois{ROIidx}, ['\roi\sub-' subLabel '_ses-' session '_'], '_mask.nii'));
            %% multiplication ROIs and layers
            exp = 'i1.*i2';
            % set batch image calculator
            input = {layers; listofRois{ROIidx}};
            outDir = fullfile(opt.dir.output, ['sub-' subLabel '\ses-' session '\roi']);
            outputCommonVoxels = fullfile(outDir, Roiname);
            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, input, outputCommonVoxels, outDir, exp, 'float32');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'VoxelCount';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        end
    end

end
