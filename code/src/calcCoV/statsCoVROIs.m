clear;
clc;

addpath(fullfile(pwd, '..'));
initEnv();

addpath(fullfile(pwd, '../calcSNR'));
opt = get_option_preproc();

BIDS = bids.layout(opt.dir.output, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)
    subLabel = opt.subjects{subIdx};
    %% statistics ROIs

    % find CoV images
    %unit1
    UNIT1CoV = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel]),...
        '^[^w].*CoV-CommonVoxSes001Ses002_UNIT1.nii$');
    %T1map
    T1mapCoV = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel]),...
        '^[^w].*CoV-CommonVoxSes001Ses002_T1map.nii$');
    %% find ROIs UNIT1
    fprintf('subject number: %d\n', subIdx);
    filter.sub = subLabel;
    filter.suffix = {'mask'};
    filter.desc = 'intercUNIT1SessionsBin';
    filter.atlas = {'visfAtlas', 'wang'};
    filter.prefix = '';
    filter.ses = '001'; 
    
    listofROIsUNIT1 = bids.query(BIDS, 'data', filter);
    clear filter
    CovRoiUNIT1 = struct();
    
    for roi_idx = 1:numel(listofROIsUNIT1)

        info_roi = char(extractBetween(listofROIsUNIT1(roi_idx), 'hemi-', '_desc-intercUNIT1SessionsBin_mask.nii'));
        info_roi_struct = strrep(info_roi, '-', ''); 
        fprintf('ROI: %s', info_roi);

        CovRoiUNIT1.(info_roi_struct) = spm_summarise(UNIT1CoV, listofROIsUNIT1{roi_idx});
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
    %% find ROIs T1 map
    fprintf('subject number: %d\n', subIdx);
    filter.sub = subLabel;
    filter.suffix = {'mask'};
    filter.desc = 'intercT1mapSessionsBin';
    filter.atlas = {'visfAtlas', 'wang'};
    filter.prefix = '';
    filter.ses = '001'; 

    listofROIsT1map = bids.query(BIDS, 'data', filter);

    clear filter;
    CovRoiUNIT1 = struct();

    for roi_idx = 1:numel(listofROIsT1map)

        info_roi = char(extractBetween(listofROIsT1map(roi_idx), 'hemi-', '_desc-intercT1mapSessionsBin_mask.nii'));
        info_roi_struct = strrep(info_roi, '-', ''); 
        fprintf('ROI: %s', info_roi);

        CovRoiT1map.(info_roi_struct) = spm_summarise(T1mapCoV, listofROIsT1map{roi_idx});
    end
    
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