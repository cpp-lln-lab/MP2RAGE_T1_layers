clear;
clc;

run ../initEnv();
addpath(fullfile(pwd, '../createROI'));
opt = get_option_preproc();
opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)

    subLabel = opt.subjects{subIdx};
    %% find ROIs UNIT1
    fprintf('subject number: %d\n', subIdx);
    filter.sub = subLabel;
    filter.suffix = {'mask'};
    filter.desc = 'intercUNIT1Bin';
    filter.atlas = {'visfAtlas', 'wang'};
    filter.prefix = '';
    filter.ses = '001'; % change for other sessions

    listofROIsUNIT1 = bids.query(BIDS, 'data', filter);

    clear filter;
    %% find ROIs T1 map
    fprintf('subject number: %d\n', subIdx);
    filter.sub = subLabel;
    filter.suffix = {'mask'};
    filter.desc = 'intercT1mapBin';
    filter.atlas = {'visfAtlas', 'wang'};
    filter.prefix = '';
    filter.ses = '001'; % change for other sessions

    listofROIsT1map = bids.query(BIDS, 'data', filter);

    clear filter;
    %% find UNIT1 without bias correction

    filter.sub = subLabel;
    filter.suffix = 'UNIT1';
    filter.acq = 'r0p75';
    filter.ses = '001'; % change for other sessions
    filter.desc = 'intercBrainMask';
    UNIT1 = bids.query(BIDS, 'data', filter);
    UNIT1 = UNIT1{1};

    %% change filters to find T1 map

    filter.suffix = 'T1map';
    filter.desc = 'skullstripped';
    filter.space = '';
    T1map = bids.query(BIDS, 'data', filter);
    T1map = T1map{1};

    clear filter;

    % select and add white matter masks

    wm = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001', 'roi'), '^[^w].*ses-001_space-individual_label-WM_desc-raseg.nii$');
    listofROIsUNIT1{numel(listofROIsUNIT1) + 1, 1} = wm;
    listofROIsT1map{numel(listofROIsT1map) + 1, 1} = wm;

    wm_L = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001', 'roi'), '^[^w].*hemi-L_space-individual_label-WM_desc-raseg.nii$');
    listofROIsUNIT1{numel(listofROIsUNIT1) + 1, 1} = wm_L;
    listofROIsT1map{numel(listofROIsT1map) + 1, 1} = wm_L;

    wm_R = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001', 'roi'), '^[^w].*hemi-R_space-individual_label-WM_desc-raseg.nii$');
    listofROIsUNIT1{numel(listofROIsUNIT1) + 1, 1} = wm_R;
    listofROIsT1map{numel(listofROIsT1map) + 1, 1} = wm_R;

    % select and add grey matter masks

    gm = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001', 'roi'), '^[^w].*ses-001_space-individual_label-GM_desc-raseg.nii$');
    listofROIsUNIT1{numel(listofROIsUNIT1) + 1, 1} = gm;
    listofROIsT1map{numel(listofROIsT1map) + 1, 1} = gm;

    gm_L = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001', 'roi'), '^[^w].*hemi-L_space-individual_label-GM_desc-raseg.nii$');
    listofROIsUNIT1{numel(listofROIsUNIT1) + 1, 1} = gm_L;
    listofROIsT1map{numel(listofROIsT1map) + 1, 1} = gm_L;

    gm_R = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001', 'roi'), '^[^w].*hemi-R_space-individual_label-GM_desc-raseg.nii$');
    listofROIsUNIT1{numel(listofROIsUNIT1) + 1, 1} = gm_R;
    listofROIsT1map{numel(listofROIsT1map) + 1, 1} = gm_R;

    % select and add foreground mask
    foreground = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], 'ses-001', 'roi'), '^[^w].*ses-001_space-individual_label-foreground_desc-raseg.nii$');
    listofROIsUNIT1{numel(listofROIsUNIT1) + 1, 1} = foreground;
    listofROIsT1map{numel(listofROIsT1map) + 1, 1} = foreground;

    signal_UNIT1 = struct();
    signal_T1map = struct();

    numVoxPerRoi = zeros(1, numel(listofROIsUNIT1));

    for roi_idx = 1:numel(listofROIsUNIT1)

        info_roi = [char(extractBetween(listofROIsUNIT1(roi_idx), 'individual_', '_desc')) '-' char(extractBetween(listofROIsUNIT1(roi_idx), 'hemi-', '_'))];
        info_roi_struct = strrep(info_roi, '-', ''); % '-' was giving problems when naming the fields in structure
        fprintf('ROI: %s', info_roi);

        % voxel intensities per ROI
        signal_UNIT1.(info_roi_struct) = spm_summarise(UNIT1, listofROIsUNIT1{roi_idx});
    end
    
    for roi_idx = 1:numel(listofROIsT1map)

        info_roi = [char(extractBetween(listofROIsT1map(roi_idx), 'individual_', '_desc')) '-' char(extractBetween(listofROIsT1map(roi_idx), 'hemi-', '_'))];
        info_roi_struct = strrep(info_roi, '-', ''); % '-' was giving problems when naming the fields in structure
        fprintf('ROI: %s', info_roi);

        % voxel intensities per ROI
        signal_T1map.(info_roi_struct) = spm_summarise(T1map, listofROIsT1map{roi_idx});

    end
    
    field = fieldnames(signal_UNIT1);
    means_UNIT1 = structfun(@mean, signal_UNIT1, 'uniform', 0);
    stds_UNIT1 = structfun(@std, signal_UNIT1, 'uniform', 0);
    nVoxels_UNIT1 = structfun(@numel, signal_UNIT1);
    minROI_UNIT1 = structfun(@min, signal_UNIT1, 'uniform', 0);
    maxROI_UNIT1 = structfun(@max, signal_UNIT1, 'uniform', 0);

    means_T1map = structfun(@mean, signal_T1map, 'uniform', 0);
    stds_T1map = structfun(@std, signal_T1map, 'uniform', 0);
    nVoxels_T1map = structfun(@numel, signal_T1map);
    minROI_T1map = structfun(@min, signal_T1map, 'uniform', 0);
    maxROI_T1map = structfun(@max, signal_T1map, 'uniform', 0);

    SNR_UNIT1 = struct();
    SNR_T1map = struct();

    for k = 1:numel(field)
        SNR_UNIT1.(field{k}) = (means_UNIT1.(field{k}) / stds_UNIT1.(field{k})) * (numel(signal_UNIT1.(field{k})) / (numel(signal_UNIT1.(field{k})) - 1))^(1 / 2); % Oliveira et al. NeuroImage (2021)
        SNR_T1map.(field{k}) = (means_T1map.(field{k}) / stds_T1map.(field{k})) * (numel(signal_T1map.(field{k})) / (numel(signal_T1map.(field{k})) - 1))^(1 / 2); % Oliveira et al. NeuroImage (2021)
    end
    MeanSignal_UNIT1 = struct2cell(means_UNIT1);
    StdSignal_UNIT1 = struct2cell(stds_UNIT1);
    SNR_UNIT1 = cell2mat(struct2cell(SNR_UNIT1));
    Min_UNIT1 = cell2mat(struct2cell(minROI_UNIT1));
    Max_UNIT1 = cell2mat(struct2cell(maxROI_UNIT1));

    MeanSignal_T1map = struct2cell(means_T1map);
    StdSignal_T1map = struct2cell(stds_T1map);
    SNR_T1map = cell2mat(struct2cell(SNR_T1map));
    Min_T1map = cell2mat(struct2cell(minROI_T1map));
    Max_T1map = cell2mat(struct2cell(maxROI_T1map));

    SNRStats_UNIT1 = table(field, SNR_UNIT1, MeanSignal_UNIT1, StdSignal_UNIT1, nVoxels_UNIT1, Min_UNIT1, Max_UNIT1);
    SNRStats_T1map = table(field, SNR_T1map, MeanSignal_T1map, StdSignal_T1map, nVoxels_T1map, Min_T1map, Max_T1map);

    outputNameSNRstatsUNIT1 = ['sub-' subLabel ...
                               '_ses-001_acq-r0p75_desc-SNRStatsROIs_UNIT1.tsv'];
    outputNameSNRstatsT1map = ['sub-' subLabel ...
                               '_ses-001_acq-r0p75_desc-SNRStatsROIs_T1map.tsv'];
    fileNameSNRstatsUNIT1 = fullfile(opt.dir.output, ['sub-' subLabel], 'ses-001', 'anat', outputNameSNRstatsUNIT1);
    fileNameSNRstatsT1map = fullfile(opt.dir.output, ['sub-' subLabel], 'ses-001', 'anat', outputNameSNRstatsT1map);

    bids.util.tsvwrite(fileNameSNRstatsUNIT1, SNRStats_UNIT1);
    bids.util.tsvwrite(fileNameSNRstatsT1map, SNRStats_T1map);

end
