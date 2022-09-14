clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();

addpath(fullfile(pwd, '../calcSNR'));
opt = get_option_preproc();

BIDS = bids.layout(opt.dir.output, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)
    
    subLabel = opt.subjects{subIdx};
    fprintf('subject number: %d\n', subIdx);
    
    %% get  T1 map binary mask common voxels sessions 1 and 2
    T1mapMask = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel]),...
        '^[^w].*desc-intercBinmasks_T1maps.nii$');
    
    %% get UNIT1 binary mask  common voxels sessions 1 and 2
    UNIT1Mask = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel]),...
        '^[^w].*desc-intercBinmasks_UNIT1s.nii$');
    %% find ROIs
    clear filter;
    filter.sub = subLabel;
    filter.ses = '001';
    filter.space = 'individual';
    filter.suffix = 'mask';
    filter.prefix= '';
    filter.hemi = {'L', 'R'};
    filter.desc = ''; 
    listofROIs = bids.query(BIDS, 'data', filter);
    clear filter;
    
    for ROIidx = 1:numel(listofROIs)
        %% common voxels T1 maps - binary mask
        RoinameT1map = strcat(char(extractBetween(listofROIs{ROIidx}, '\roi\', '_mask.nii')), '_desc-intercT1mapSessionsBin_mask.nii');
        RoinameUNIT1 = strcat(char(extractBetween(listofROIs{ROIidx}, '\roi\', '_mask.nii')), '_desc-intercUNIT1SessionsBin_mask.nii');
        session = char(extractBetween(listofROIs{ROIidx}, '\ses-', '\roi\'));
        Roi = char(extractBetween(listofROIs{ROIidx}, ['\roi\sub-' subLabel '_ses-' session '_'], '_mask.nii'));
        Roi = strrep(Roi, '-', ''); % '-' was giving problems when naming the fields in structure

        exp = 'i1.*i2';
        outDir = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' session], 'roi');
        %% set batch T1 map
        inputsT1map = {T1mapMask; listofROIs{ROIidx}}; %i1 and i2
        outputT1map = fullfile(outDir, RoinameUNIT1);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsT1map, outputT1map, outDir, exp, 'int16');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
        batchName = 'Common Voxels ROIs and T1 binary maskS';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
        
        %% set batch UNIT1
        inputsT1map = {UNIT1Mask; listofROIs{ROIidx}}; %i1 and i2
        outputT1map = fullfile(outDir, RoinameT1map);
        
        matlabbatch = {};
        matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputsT1map, outputT1map, outDir, exp, 'int16');
        matlabbatch{1}.spm.util.imcalc.options.interp = 0;
        
        batchName = 'Common Voxels ROIs and UNIT1 binary maskS';
        saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
        
    end
end