function intercept_ROI_and_GM(opt)

    BIDS = bids.layout(opt.dir.output, 'use_schema', false);
    
    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        fprintf('subject number: %d\n', subIdx);
        %% find ROIs UNIT1
        filter.sub = subLabel;
        filter.suffix = 'mask';
        filter.desc = 'intercUNIT1Bin';
        filter.label = opt.roi.name;
        filter.prefix = '';
        filter.ses = opt.ses;

        listofROIsUNIT1 = bids.query(BIDS, 'data', filter);
        hdrUNIT1 = spm_vol(listofROIsUNIT1);

        clear filter;
        
        %% find ROIs T1 map
        filter.sub = subLabel;
        filter.suffix = 'mask';
        filter.desc = 'intercT1mapBin';
        filter.label = opt.roi.name;
        filter.prefix = '';
        filter.ses = opt.ses;

        listofROIsT1map = bids.query(BIDS, 'data', filter);
        hdrT1map = spm_vol(listofROIsT1map);
        
        clear filter;
        gm = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], ['ses-' opt.ses], 'roi'), strcat('^[^w].*ses-', opt.ses, '_space-individual_label-GM_raseg.nii$'));

        for ROIidx = 1:numel(listofROIsUNIT1)

            %% common voxels T1 maps - binary mask
            session = opt.ses;

            bf = bids.File(char(listofROIsUNIT1(ROIidx)));
            ROIName = bf.entities.label;

            bf.entities.desc = 'intercUNIT1GM';
            RoiUNIT1CommonGM = fullfile(spm_fileparts(hdrUNIT1{ROIidx, 1}.fname), bf.filename);
            
            bf.entities.desc = 'intercT1mapGM';
            RoiT1mapCommonGM = fullfile(spm_fileparts(hdrT1map{ROIidx, 1}.fname), bf.filename);
            
            exp = 'i1.*i2';
            outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' session], 'roi');
            %% set batch UNIT1
            inputsUNIT1 = {listofROIsUNIT1{ROIidx}; gm};
            outputUNIT1 = RoiUNIT1CommonGM;

            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsUNIT1, outputUNIT1, outDir, exp, 'float32');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'Common Voxels ROIs UNIT1 and GM';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
            %% set batch T1 map
            inputsT1map = {listofROIsT1map{ROIidx}; gm};
            outputT1map = RoiT1mapCommonGM;

            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsT1map, outputT1map, outDir, exp, 'float32');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'Common Voxels ROIs T1 and GM';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

        end
    end
end