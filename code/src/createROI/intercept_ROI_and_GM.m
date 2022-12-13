function intercept_ROI_and_GM(opt)

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);
opt.roi.name = {'IOG', 'OTS', 'ITG', 'V1v', 'V1d', ...
    'MTG', 'LOS', 'hMT', 'v2d', 'v3d',...
    'v2v', 'v3v', 'mFus', 'pFus', 'CoS'};
for subIdx = 1:numel(opt.subjects)
    
    subLabel = opt.subjects{subIdx};
    fprintf('subject number: %d\n', subIdx);
    %% find ROIs UNIT1
    fprintf('subject number: %d\n', subIdx);
    filter.sub = subLabel;
    filter.suffix = {'mask'};
    filter.desc = 'intercUNIT1Bin';
    filter.label = opt.roi.name;
    filter.prefix = '';
    filter.ses = '001'; % change for other sessions
    
    listofROIsUNIT1 = bids.query(BIDS, 'data', filter);
        
    clear filter;
    %% find ROIs T1 map
    fprintf('subject number: %d\n', subIdx);
    filter.sub = subLabel;
    filter.suffix = {'mask'};
    filter.desc = 'intercT1mapBin';
    %filter.atlas = {'visfAtlas', 'wang'};
    filter.label = opt.roi.name;
    filter.prefix = '';
    filter.ses = '001'; % change for other sessions
    
    listofROIsT1map = bids.query(BIDS, 'data', filter);
    
    clear filter;
    gm = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001', 'roi'), '^[^w].*ses-001_space-individual_label-GM_raseg.nii$');

    for ROIidx = 1:numel(listofROIsUNIT1)
        %% common voxels T1 maps - binary mask
        RoinameT1map = strcat(char(extractBetween(listofROIsT1map{ROIidx}, '\roi\', '_desc')), '_desc-intercT1mapGM_mask.nii');
        RoinameUNIT1 = strcat(char(extractBetween(listofROIsUNIT1{ROIidx}, '\roi\', '_desc')), '_desc-intercUNIT1GM_mask.nii');
        session = char(extractBetween(listofROIsUNIT1{ROIidx}, '\ses-', '\roi\'));
        Roi = char(extractBetween(listofROIsUNIT1{ROIidx}, ['\roi\sub-' subLabel '_ses-' session '_'], '_mask.nii'));
        
        exp = 'i1.*i2';
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' session], 'roi');
        %% set batch T1 map
        inputsT1map = {listofROIsT1map{ROIidx}; gm};
        outputT1map = fullfile(outDir, RoinameT1map);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsT1map, outputT1map, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
        batchName = 'Common Voxels ROIs T1 and GM';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
        %% set batch UNIT1
        inputsUNIT1 = {listofROIsUNIT1{ROIidx}; gm};
        outputUNIT1 = fullfile(outDir, RoinameUNIT1);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsUNIT1, outputUNIT1, outDir, exp, 'float32');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
        batchName = 'Common Voxels ROIs UNIT1 and GM';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
        
    end
end
end