function commonVoxelsROIsandSessions(opt)
    BIDS = bids.layout(opt.dir.output, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        fprintf('subject number: %d\n', subIdx);

        %% get  T1 map binary mask common voxels sessions 1 and 2
        T1mapMask = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel]), ...
                               '^[^w].*desc-intercBinmasks_T1maps.nii$');

        %% get UNIT1 binary mask  common voxels sessions 1 and 2
        UNIT1Mask = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel]), ...
                               '^[^w].*desc-intercBinmasks_UNIT1s.nii$');
        %% find ROIs
        clear filter;
        filter.sub = subLabel;
        filter.ses = opt.ses;
        filter.space = 'individual';
        filter.suffix = 'mask';
        filter.prefix = '';
        filter.hemi = {'L', 'R'};
        filter.label = opt.roi.name;
        filter.desc = '';
        listofROIs = bids.query(BIDS, 'data', filter);

        clear filter;

        hdr = spm_vol(listofROIs);

        for roi_idx = 1:numel(listofROIs)
            bfUNIT1 = bids.File(char(listofROIs(roi_idx)));
            bfT1map = bids.File(char(listofROIs(roi_idx)));

            info_roi = bfUNIT1.entities.label;

            bfUNIT1.entities.desc = 'intercUNIT1SessionsBin';
            bfT1map.entities.desc = 'intercT1mapSessionsBin';

            RoinameUNIT1 = fullfile(spm_fileparts(hdr{roi_idx, 1}.fname), bfUNIT1.filename);
            RoinameT1map = fullfile(spm_fileparts(hdr{roi_idx, 1}.fname), bfT1map.filename);

            fprintf('ROI: %s', info_roi);
            %% common voxels T1 maps - binary mask
            exp = 'i1.*i2';
            outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'roi');
            %% set batch T1 map
            inputsT1map = {T1mapMask; listofROIs{roi_idx}}; % i1 and i2
            outputT1map = RoinameUNIT1;

            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsT1map, outputT1map, outDir, exp, 'float32');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'Common Voxels ROIs and T1 binary maskS';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

            %% set batch UNIT1
            inputsUNIT1 = {UNIT1Mask; listofROIs{roi_idx}}; % i1 and i2
            outputUNIT1 = RoinameT1map;

            matlabbatch = {};
            matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsUNIT1, outputUNIT1, outDir, exp, 'float32');
            matlabbatch{1}.spm.util.imcalc.options.interp = 0;

            batchName = 'Common Voxels ROIs and UNIT1 binary maskS';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
        end
    end
end
