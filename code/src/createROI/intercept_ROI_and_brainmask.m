function intercept_ROI_and_brainmask(opt)

    opt.dir.roi = opt.dir.output;

    BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        fprintf('subject number: %d\n', subIdx);

        %% get  T1 map binary mask
        filter.sub = subLabel;
        filter.ses = '001';
        filter.acq = 'r0p75'; % change depending on the pipeline
        filter.suffix = 'T1map';
        filter.desc = 'brainmask';
        binaryT1map = bids.query(BIDS, 'data', filter);
        binaryT1map = binaryT1map{:}; 

        %% get UNIT1 binary mask
        filter.sub = subLabel;
        filter.ses = '001';
        filter.acq = 'r0p75'; % change depending on the pipeline
        filter.suffix = 'mask';
        filter.desc = 'brain';
        binaryUNIT1 = bids.query(BIDS, 'data', filter);
        binaryUNIT1 = binaryUNIT1{:}; 

        clear filter;

        %% find ROIs
        clear filter;
        filter.sub = subLabel;
        filter.ses = '001';
        filter.space = 'individual';
        filter.suffix = 'mask';
        filter.prefix= '';
        filter.hemi = {'L', 'R'};
        filter.desc = ''; % to remove the interception of masks files already in the folder
        listofROIs = bids.query(BIDS, 'data', filter);
        %filter.label = {'V1v', 'V1d', 'pFus', 'mFus', 'CoS'};
        clear filter;

        for ROIidx = 1:numel(listofROIs)
            %% common voxels T1 maps - binary mask
            RoinameT1map = strcat(char(extractBetween(listofROIs{ROIidx}, '\roi\', '_mask.nii')), '_desc-intercT1mapBin_mask.nii');
            RoinameUNIT1 = strcat(char(extractBetween(listofROIs{ROIidx}, '\roi\', '_mask.nii')), '_desc-intercUNIT1Bin_mask.nii');
            session = char(extractBetween(listofROIs{ROIidx}, '\ses-', '\roi\'));
            Roi = char(extractBetween(listofROIs{ROIidx}, ['\roi\sub-' subLabel '_ses-' session '_'], '_mask.nii'));
            
            exp = 'i1.*i2';            
            outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' session], 'roi');
            %% set batch T1 map
            inputsT1map = {binaryT1map; listofROIs{ROIidx}};
            outputT1map = fullfile(outDir, RoinameT1map);
            
            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsT1map, outputT1map, outDir, exp, 'int16');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'Common Voxels ROIs and T1 binary mask';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
            %% set batch UNIT1
            inputsUNIT1 = {binaryUNIT1; listofROIs{ROIidx}};
            outputUNIT1 = fullfile(outDir, RoinameUNIT1);
            
            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsUNIT1, outputUNIT1, outDir, exp, 'int16');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;
            
            batchName = 'Common Voxels ROIs and UNIT1 binary mask';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
            
            end
    end
end
