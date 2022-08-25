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
    %% find UNIT1 sess 001 and 002
    filters.sub = subLabel;
    filters.ses = '001';
    filters.modality = 'anat';
    filters.acq = 'r0p75';
    filters.suffix = 'UNIT1';
    filters.prefix = '';
    filters.desc = 'intercBrainMask';

    sub1stSesUNIT1 = bids.query(BIDS, 'data', filters);
    sub1stSesUNIT1 = sub1stSesUNIT1{1};

    filters.ses = '002';
    filters.prefix = '';

    sub2ndSesUNIT1 = bids.query(BIDS, 'data', filters);
    sub2ndSesUNIT1 = sub2ndSesUNIT1{1};

    %% find T1 map 001 and 002 sessions
    filter.sub = subLabel;
    filter.acq = 'r0p75';
    filter.ses = '001';
    filter.suffix = 'T1map';
    filter.desc = 'skullstripped';
    filter.space = '';
    filter.prefix = '';

    T1map_001 = bids.query(BIDS, 'data', filter);
    T1map_001 = T1map_001{1};

    filter.ses = '002'; % change for other sessions

    T1map_002 = bids.query(BIDS, 'data', filter);
    T1map_002 = T1map_002{1};

    clear filter;

    %% common voxels T1 maps - binary mask

    exp = '(i1.*i2)>0.0';
    % set batch image calculator
    inputMaskT1maps = {T1map_001; T1map_002};
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    outputMask = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_desc-BinaryMask_T1maps.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputMaskT1maps, outputMask, outDir, exp, 'uint8');

    batchName = 'binaryMaskT1maps';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    %% find brain UNIT1 masks 001 and 002 sessions
    filter.sub = subLabel;
    filter.ses = '001';
    filter.space = 'individual';
    filter.acq = 'r0p75'; % change depending on the pipeline
    filter.suffix = 'mask';
    brainmask_001 = bids.query(BIDS, 'data', filter);
    brainmask_001 = brainmask_001{:}; % because it complains: 'Struct contents reference from a non-struct array object.'

    filter.ses = '002';

    brainmask_002 = bids.query(BIDS, 'data', filter);
    brainmask_002 = brainmask_002{:}; % because it complains: 'Struct contents reference from a non-struct array object.'

    clear filter;
    %% find T1 binary mask

    T1mapsmask = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_desc-BinaryMask_T1maps.nii']);
    T1mapsmask = T1mapsmask;
    %% CoV operations

    exp = '((abs(i1 - i2))./((i1 + i2)/2)).*i3.*i4.*i5';
    % set batch image calculator - UNIT1
    inputCovUNIT1 = {sub1stSesUNIT1; sub2ndSesUNIT1; brainmask_001; brainmask_002; T1mapsmask};
    outDir = fullfile(opt.dir.output, ['sub-' subLabel]);
    outputUNIT1 = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_CovarianceSes001Ses002_UNIT1.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputCovUNIT1, outputUNIT1, outDir, exp, 'uint8');

    batchName = 'Cov_UNIT1';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    % set batch image calculator - T1 map
    inputCovT1map = {T1map_001; T1map_002; brainmask_001; brainmask_002; T1mapsmask};
    outputT1map = fullfile(opt.dir.output, ['sub-' subLabel], ['sub-' subLabel '_acq-r0p75_CovarianceSes001Ses002_T1map.nii']);
    matlabbatch = {};
    matlabbatch = setBatchImageCalculation(matlabbatch, opt, inputCovT1map, outputT1map, outDir, exp, 'uint8');

    batchName = 'Cov_T1map';
    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    clear filters;

    filters.sub = subLabel;
    filters.suffix = {'mask'};
    filters.desc = 'intercMasks';
    filters.atlas = {'visfAtlas', 'wang'};
    filters.prefix = 'r';
    list_of_rois = bids.query(BIDS, 'data', filters);

    CovRoiUNIT1 = struct();
    CovRoiT1map = struct();

    clear filters;
    clear filter;
    for roi_idx = 1:numel(list_of_rois)

        info_roi = char(extractBetween(list_of_rois(roi_idx), 'hemi-', '_desc-intercMasks_mask.nii'));
        info_roi_struct = strrep(info_roi, '-', ''); % '-' was giving problems when naming the fields in structure
        fprintf('ROI: %s', info_roi);

        CovRoiUNIT1.(info_roi_struct) = spm_summarise(outputUNIT1, list_of_rois{roi_idx});
        CovRoiT1map.(info_roi_struct) = spm_summarise(outputT1map, list_of_rois{roi_idx});
    end

    % UNIT1 stats
    field = fieldnames(CovRoiUNIT1);
    meanCovRoiUNIT1 = structfun(@mean, CovRoiUNIT1, 'uniform', 0);
    stdsUNIT1 = structfun(@std, CovRoiUNIT1, 'uniform', 0);
    nVoxelsUNIT1 = structfun(@numel, CovRoiUNIT1);
    minROIUNIT1 = structfun(@min, CovRoiUNIT1, 'uniform', 0);
    maxROIUNIT1 = structfun(@max, CovRoiUNIT1, 'uniform', 0);
    medianROIUNIT1 = structfun(@median, CovRoiUNIT1, 'uniform', 0);

    MeanCovUNIT1 = struct2cell(meanCovRoiUNIT1);
    StdCovUNIT1 = struct2cell(stdsUNIT1);
    MinUNIT1 = cell2mat(struct2cell(minROIUNIT1));
    MaxUNIT1 = cell2mat(struct2cell(maxROIUNIT1));
    medianCovUNIT1 = cell2mat(struct2cell(medianROIUNIT1));

    CovStatsUNIT1 = table(field, MeanCovUNIT1, medianCovUNIT1, StdCovUNIT1, nVoxelsUNIT1, MinUNIT1, MaxUNIT1);

    outputNameCovStatsUNIT1 = ['sub-' subLabel ...
                               '_acq-r0p75_desc-CovStatsROIs_UNIT1.tsv'];

    fileNameCovStatsUNIT1 = fullfile(opt.dir.output, ['sub-' subLabel], outputNameCovStatsUNIT1);
    bids.util.tsvwrite(fileNameCovStatsUNIT1, CovStatsUNIT1);

    % T1 map
    meanCovRoiT1map = structfun(@mean, CovRoiT1map, 'uniform', 0);
    stdsT1map = structfun(@std, CovRoiT1map, 'uniform', 0);
    nVoxelsT1map = structfun(@numel, CovRoiT1map);
    minROIT1map = structfun(@min, CovRoiT1map, 'uniform', 0);
    maxROIT1map = structfun(@max, CovRoiT1map, 'uniform', 0);
    medianROIT1map = structfun(@median, CovRoiT1map, 'uniform', 0);

    MeanCovT1map = struct2cell(meanCovRoiT1map);
    StdCovT1map = struct2cell(stdsT1map);
    MinT1map = cell2mat(struct2cell(minROIT1map));
    MaxT1map = cell2mat(struct2cell(maxROIT1map));
    medianCovT1map = cell2mat(struct2cell(medianROIT1map));

    CovStatsT1map = table(field, MeanCovT1map, medianCovT1map, StdCovT1map, nVoxelsT1map, MinT1map, MaxT1map);

    outputNameCovStatsT1map = ['sub-' subLabel ...
                               '_acq-r0p75_desc-CovStatsROIs_T1map.tsv'];

    fileNameCovStatsT1map = fullfile(opt.dir.output, ['sub-' subLabel], outputNameCovStatsT1map);
    bids.util.tsvwrite(fileNameCovStatsT1map, CovStatsT1map);

end
