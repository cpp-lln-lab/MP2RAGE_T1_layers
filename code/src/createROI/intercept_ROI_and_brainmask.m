function intercept_ROI_and_brainmask(opt)

    BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        fprintf('subject number: %d\n', subIdx);

        %% get  T1 map binary mask
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.acq = opt.acq;
        filter.suffix = 'T1map';
        filter.desc = 'brainmask';
        binaryT1map = bids.query(BIDS, 'data', filter);
        assert(numel(binaryT1map) == 1);
        binaryT1map = binaryT1map{:};

        clear filter;
        %% get UNIT1 binary mask
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.acq = opt.acq;
        filter.suffix = 'mask';
        filter.(opt.brainmask) = 'brain';
        filter.space = 'individual';
        binaryUNIT1 = bids.query(BIDS, 'data', filter);
        assert(numel(binaryUNIT1) == 1);
        binaryUNIT1 = binaryUNIT1{:};

        clear filter;

        %% find ROIs
        clear filter;
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.space = 'individual';
        filter.suffix = 'mask';
        filter.prefix = '';
        filter.hemi = {'L', 'R'};
        filter.desc = '';
        filter.label = opt.roi.name;
        listofROIs = bids.query(BIDS, 'data', filter);
        clear filter;

        hdr = spm_vol(listofROIs);

        for roi_idx = 1:numel(listofROIs)
            %% common voxels T1 maps - binary mask
            bfUNIT1 = bids.File(char(listofROIs(roi_idx)));
            bfT1map = bids.File(char(listofROIs(roi_idx)));

            ROIName = bfUNIT1.entities.label;

            bfUNIT1.entities.desc = 'intercUNIT1Bin';
            bfT1map.entities.desc = 'intercT1mapBin';

            ROIUNIT1output = fullfile(spm_fileparts(hdr{roi_idx, 1}.fname), bfUNIT1.filename);
            ROIT1mapoutput = fullfile(spm_fileparts(hdr{roi_idx, 1}.fname), bfT1map.filename);

            exp = 'i1.*i2';
            outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'roi');
            %% set batch T1 map
            inputsT1map = {binaryT1map; listofROIs{roi_idx}};

            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsT1map, ROIT1mapoutput, outDir, exp, 'float32');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'Common Voxels ROIs and T1 binary mask';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
            %% set batch UNIT1
            inputsUNIT1 = {binaryUNIT1; listofROIs{roi_idx}};

            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsUNIT1, ROIUNIT1output, outDir, exp, 'float32');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'Common Voxels ROIs and UNIT1 binary mask';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        end
    end
end
