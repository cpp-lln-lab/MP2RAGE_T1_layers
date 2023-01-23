function extract_snr_from_roi(opt)

    BIDS = bids.layout(opt.dir.output, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        subLabel = opt.subjects{subIdx};
        %% find ROIs UNIT1
        fprintf('subject number: %d\n', subIdx);
        filter.sub = subLabel;
        filter.suffix = 'mask';
        filter.desc = 'intercUNIT1Bin';
        filter.label = opt.roi.name;
        filter.hemi = 'L';
        filter.prefix = '';
        filter.ses = opt.ses;

        listofROIsUNIT1_L = bids.query(BIDS, 'data', filter);

        filter.hemi = 'R';
        listofROIsUNIT1_R = bids.query(BIDS, 'data', filter);

        clear filter;
        %% find ROIs T1 map
        fprintf('subject number: %d\n', subIdx);
        filter.sub = subLabel;
        filter.suffix = 'mask';
        filter.desc = 'intercT1mapBin';
        filter.label = opt.roi.name;
        filter.hemi = 'L';
        filter.prefix = '';
        filter.ses = opt.ses;

        listofROIsT1map_L = bids.query(BIDS, 'data', filter);

        filter.hemi = 'R';
        listofROIsT1map_R = bids.query(BIDS, 'data', filter);

        clear filter;
        %% find UNIT1 without bias correction

        filter.sub = subLabel;
        filter.suffix = 'UNIT1';
        filter.acq = opt.acq;
        filter.ses = opt.ses;
        filter.desc = 'intercBrainMask';
        UNIT1 = bids.query(BIDS, 'data', filter);
        assert(numel(UNIT1) == 1);
        UNIT1 = UNIT1{:};

        %% change filters to find T1 map

        filter.suffix = 'T1map';
        filter.desc = 'skullstripped';
        filter.space = '';
        T1map = bids.query(BIDS, 'data', filter);
        assert(numel(T1map) == 1);
        T1map = T1map{:};

        clear filter;
        %% find WM, GM and WMandGM
        % select and add white matter mask
        GMWMtissues = {};

        wm = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], ['ses-' opt.ses], 'roi'), strcat('^[^w].*ses-', opt.ses, '_space-individual_label-WM_raseg.nii$'));
        GMWMtissues{1, 1} = wm;

        gm = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], ['ses-' opt.ses], 'roi'), strcat('^[^w].*ses-', opt.ses, '_space-individual_label-GM_raseg.nii$'));
        GMWMtissues{2, 1} = gm;

        GMandWM = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel], ['ses-' opt.ses], 'roi'), strcat('^[^w].*ses-', opt.ses, '_space-individual_label-GMandWM_raseg.nii$'));
        GMWMtissues{3, 1} = GMandWM;

        signal_UNIT1_L = struct();
        signal_UNIT1_R = struct();
        signal_UNIT1_GMWM = struct();

        signal_T1map_L = struct();
        signal_T1map_R = struct();
        signal_T1map_GMWM = struct();

        numVoxPerRoi = zeros(1, numel(listofROIsUNIT1_L));
        nROIs = numel(listofROIsUNIT1_L);

        for roi_idx = 1:nROIs
            bf = bids.File(char(listofROIsUNIT1_L(roi_idx)));
            info_roi = bf.entities.label;

            fprintf('ROI: %s', info_roi);
            % voxel intensities per ROI
            signal_UNIT1_L.(info_roi) = spm_summarise(UNIT1, listofROIsUNIT1_L{roi_idx});
            signal_UNIT1_R.(info_roi) = spm_summarise(UNIT1, listofROIsUNIT1_R{roi_idx});
            signal_T1map_L.(info_roi) = spm_summarise(T1map, listofROIsT1map_L{roi_idx});
            signal_T1map_R.(info_roi) = spm_summarise(T1map, listofROIsT1map_R{roi_idx});
        end

        nROIsGMWM = numel(GMWMtissues);

        for roi_idx = 1:nROIsGMWM
            bf = bids.File(char(GMWMtissues(roi_idx)));
            info_roi = bf.entities.label;

            fprintf('ROI: %s', info_roi);
            % voxel intensities per ROI
            signal_UNIT1_GMWM.(info_roi) = spm_summarise(UNIT1, GMWMtissues{roi_idx});
            signal_T1map_GMWM.(info_roi) = spm_summarise(T1map, GMWMtissues{roi_idx});
        end

        field = fieldnames(signal_UNIT1_L);
        % unit1
        means_UNIT1_L = structfun(@mean, signal_UNIT1_L, 'uniform', 0);
        stds_UNIT1_L = structfun(@std, signal_UNIT1_L, 'uniform', 0);
        nVoxels_UNIT1_L = structfun(@numel, signal_UNIT1_L);
        minROI_UNIT1_L = structfun(@min, signal_UNIT1_L, 'uniform', 0);
        maxROI_UNIT1_L = structfun(@max, signal_UNIT1_L, 'uniform', 0);

        means_UNIT1_R = structfun(@mean, signal_UNIT1_R, 'uniform', 0);
        stds_UNIT1_R = structfun(@std, signal_UNIT1_R, 'uniform', 0);
        nVoxels_UNIT1_R = structfun(@numel, signal_UNIT1_R);
        minROI_UNIT1_R = structfun(@min, signal_UNIT1_R, 'uniform', 0);
        maxROI_UNIT1_R = structfun(@max, signal_UNIT1_R, 'uniform', 0);

        % T1 MAP

        means_T1map_L = structfun(@mean, signal_T1map_L, 'uniform', 0);
        stds_T1map_L = structfun(@std, signal_T1map_L, 'uniform', 0);
        nVoxels_T1map_L = structfun(@numel, signal_T1map_L);
        minROI_T1map_L = structfun(@min, signal_T1map_L, 'uniform', 0);
        maxROI_T1map_L = structfun(@max, signal_T1map_L, 'uniform', 0);

        means_T1map_R = structfun(@mean, signal_T1map_R, 'uniform', 0);
        stds_T1map_R = structfun(@std, signal_T1map_R, 'uniform', 0);
        nVoxels_T1map_R = structfun(@numel, signal_T1map_R);
        minROI_T1map_R = structfun(@min, signal_T1map_R, 'uniform', 0);
        maxROI_T1map_R = structfun(@max, signal_T1map_R, 'uniform', 0);

        % GMWM
        field_GMWM = fieldnames(signal_UNIT1_GMWM);
        means_UNIT1_GMWM = structfun(@mean, signal_UNIT1_GMWM, 'uniform', 0);
        stds_UNIT1_GMWM = structfun(@std, signal_UNIT1_GMWM, 'uniform', 0);
        nVoxels_UNIT1_GMWM = structfun(@numel, signal_UNIT1_GMWM);
        minROI_UNIT1_GMWM = structfun(@min, signal_UNIT1_GMWM, 'uniform', 0);
        maxROI_UNIT1_GMWM = structfun(@max, signal_UNIT1_GMWM, 'uniform', 0);

        means_T1map_GMWM = structfun(@mean, signal_T1map_GMWM, 'uniform', 0);
        stds_T1map_GMWM = structfun(@std, signal_T1map_GMWM, 'uniform', 0);
        nVoxels_T1map_GMWM = structfun(@numel, signal_T1map_GMWM);
        minROI_T1map_GMWM = structfun(@min, signal_T1map_GMWM, 'uniform', 0);
        maxROI_T1map_GMWM = structfun(@max, signal_T1map_GMWM, 'uniform', 0);

        SNR_UNIT1_L = struct();
        SNR_UNIT1_R = struct();
        SNR_UNIT1_GMWM = struct();
        SNR_T1map_L = struct();
        SNR_T1map_R = struct();
        SNR_T1map_GMWM = struct();

        for k = 1:numel(field)
            SNR_UNIT1_L.(field{k}) = (means_UNIT1_L.(field{k}) / stds_UNIT1_L.(field{k})) * (numel(signal_UNIT1_L.(field{k})) / (numel(signal_UNIT1_L.(field{k})) - 1))^(1 / 2); % Oliveira et al. NeuroImage (2021)
            SNR_UNIT1_R.(field{k}) = (means_UNIT1_R.(field{k}) / stds_UNIT1_R.(field{k})) * (numel(signal_UNIT1_R.(field{k})) / (numel(signal_UNIT1_R.(field{k})) - 1))^(1 / 2); % Oliveira et al. NeuroImage (2021)
            SNR_T1map_L.(field{k}) = (means_T1map_L.(field{k}) / stds_T1map_L.(field{k})) * (numel(signal_T1map_L.(field{k})) / (numel(signal_T1map_L.(field{k})) - 1))^(1 / 2); % Oliveira et al. NeuroImage (2021)
            SNR_T1map_R.(field{k}) = (means_T1map_R.(field{k}) / stds_T1map_R.(field{k})) * (numel(signal_T1map_R.(field{k})) / (numel(signal_T1map_R.(field{k})) - 1))^(1 / 2); % Oliveira et al. NeuroImage (2021)
        end

        for k = 1:numel(field_GMWM)
            SNR_UNIT1_GMWM.(field_GMWM{k}) = (means_UNIT1_GMWM.(field_GMWM{k}) / stds_UNIT1_GMWM.(field_GMWM{k})) * (numel(signal_UNIT1_GMWM.(field_GMWM{k})) / (numel(signal_UNIT1_GMWM.(field_GMWM{k})) - 1))^(1 / 2); % Oliveira et al. NeuroImage (2021)
            SNR_T1map_GMWM.(field_GMWM{k}) = (means_T1map_GMWM.(field_GMWM{k}) / stds_T1map_GMWM.(field_GMWM{k})) * (numel(signal_T1map_GMWM.(field_GMWM{k})) / (numel(signal_T1map_GMWM.(field_GMWM{k})) - 1))^(1 / 2); % Oliveira et al. NeuroImage (2021)
        end

        %% UNIT1
        MeanSignal_UNIT1_L = struct2cell(means_UNIT1_L);
        StdSignal_UNIT1_L = struct2cell(stds_UNIT1_L);
        SNR_UNIT1_L = cell2mat(struct2cell(SNR_UNIT1_L));
        Min_UNIT1_L = cell2mat(struct2cell(minROI_UNIT1_L));
        Max_UNIT1_L = cell2mat(struct2cell(maxROI_UNIT1_L));

        MeanSignal_UNIT1_R = struct2cell(means_UNIT1_R);
        StdSignal_UNIT1_R = struct2cell(stds_UNIT1_R);
        SNR_UNIT1_R = cell2mat(struct2cell(SNR_UNIT1_R));
        Min_UNIT1_R = cell2mat(struct2cell(minROI_UNIT1_R));
        Max_UNIT1_R = cell2mat(struct2cell(maxROI_UNIT1_R));

        %% T1 MAP
        MeanSignal_T1map_L = struct2cell(means_T1map_L);
        StdSignal_T1map_L = struct2cell(stds_T1map_L);
        SNR_T1map_L = cell2mat(struct2cell(SNR_T1map_L));
        Min_T1map_L = cell2mat(struct2cell(minROI_T1map_L));
        Max_T1map_L = cell2mat(struct2cell(maxROI_T1map_L));

        MeanSignal_T1map_R = struct2cell(means_T1map_R);
        StdSignal_T1map_R = struct2cell(stds_T1map_R);
        SNR_T1map_R = cell2mat(struct2cell(SNR_T1map_R));
        Min_T1map_R = cell2mat(struct2cell(minROI_T1map_R));
        Max_T1map_R = cell2mat(struct2cell(maxROI_T1map_R));

        %% GMWM
        MeanSignal_UNIT1_GMWM = struct2cell(means_UNIT1_GMWM);
        StdSignal_UNIT1_GMWM = struct2cell(stds_UNIT1_GMWM);
        SNR_UNIT1_GMWM = cell2mat(struct2cell(SNR_UNIT1_GMWM));
        Min_UNIT1_GMWM = cell2mat(struct2cell(minROI_UNIT1_GMWM));
        Max_UNIT1_GMWM = cell2mat(struct2cell(maxROI_UNIT1_GMWM));

        MeanSignal_T1map_GMWM = struct2cell(means_T1map_GMWM);
        StdSignal_T1map_GMWM = struct2cell(stds_T1map_GMWM);
        SNR_T1map_GMWM = cell2mat(struct2cell(SNR_T1map_GMWM));
        Min_T1map_GMWM = cell2mat(struct2cell(minROI_T1map_GMWM));
        Max_T1map_GMWM = cell2mat(struct2cell(maxROI_T1map_GMWM));

        SNRStats_UNIT1_L = table(field, SNR_UNIT1_L, MeanSignal_UNIT1_L, StdSignal_UNIT1_L, nVoxels_UNIT1_L, Min_UNIT1_L, Max_UNIT1_L);
        SNRStats_UNIT1_R = table(field, SNR_UNIT1_R, MeanSignal_UNIT1_R, StdSignal_UNIT1_R, nVoxels_UNIT1_R, Min_UNIT1_R, Max_UNIT1_R);
        SNRStats_T1map_L = table(field, SNR_T1map_L, MeanSignal_T1map_L, StdSignal_T1map_L, nVoxels_T1map_L, Min_T1map_L, Max_T1map_L);
        SNRStats_T1map_R = table(field, SNR_T1map_R, MeanSignal_T1map_R, StdSignal_T1map_R, nVoxels_T1map_R, Min_T1map_R, Max_T1map_R);

        SNRStats_UNIT1_GMWM = table(field_GMWM, SNR_UNIT1_GMWM, MeanSignal_UNIT1_GMWM, StdSignal_UNIT1_GMWM, nVoxels_UNIT1_GMWM, Min_UNIT1_GMWM, Max_UNIT1_GMWM);
        SNRStats_T1map_GMWM = table(field_GMWM, SNR_T1map_GMWM, MeanSignal_T1map_GMWM, StdSignal_T1map_GMWM, nVoxels_T1map_GMWM, Min_T1map_GMWM, Max_T1map_GMWM);

        outputNameSNRstatsUNIT1 = ['sub-' subLabel ...
                                   '_ses-' opt.ses '_acq-' opt.acq '_hemi-L_desc-SNRStatsROIs_UNIT1.tsv'; ...
                                   'sub-' subLabel ...
                                   '_ses-' opt.ses '_acq-' opt.acq '_hemi-R_desc-SNRStatsROIs_UNIT1.tsv'];
        outputNameSNRstatsT1map = ['sub-' subLabel ...
                                   '_ses-' opt.ses '_acq-' opt.acq '_hemi-L_desc-SNRStatsROIs_T1map.tsv'; ...
                                   'sub-' subLabel ...
                                   '_ses-' opt.ses '_acq-' opt.acq '_hemi-R_desc-SNRStatsROIs_T1map.tsv'];
        outputNameSNRstatsGMWM = ['sub-' subLabel ...
                                  '_ses-' opt.ses '_acq-' opt.acq '_desc-SNRStatsGMWM_UNIT1.tsv'; ...
                                  'sub-' subLabel ...
                                  '_ses-' opt.ses '_acq-' opt.acq '_desc-SNRStatsGMWM_T1map.tsv'];

        fileNameSNRstatsUNIT1_L = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'anat', outputNameSNRstatsUNIT1(1, :));
        fileNameSNRstatsUNIT1_R = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'anat', outputNameSNRstatsUNIT1(2, :));

        fileNameSNRstatsT1map_L = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'anat', outputNameSNRstatsT1map(1, :));
        fileNameSNRstatsT1map_R = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'anat', outputNameSNRstatsT1map(2, :));

        fileNameSNRstatsUNIT1_GMWM = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'anat', outputNameSNRstatsGMWM(1, :));
        fileNameSNRstatsT1map_GMWM = fullfile(opt.dir.output, ['sub-' subLabel], ['ses-' opt.ses], 'anat', outputNameSNRstatsGMWM(2, :));

        bids.util.tsvwrite(fileNameSNRstatsUNIT1_L, SNRStats_UNIT1_L);
        bids.util.tsvwrite(fileNameSNRstatsUNIT1_R, SNRStats_UNIT1_R);

        bids.util.tsvwrite(fileNameSNRstatsT1map_L, SNRStats_T1map_L);
        bids.util.tsvwrite(fileNameSNRstatsT1map_R, SNRStats_T1map_R);

        bids.util.tsvwrite(fileNameSNRstatsUNIT1_GMWM, SNRStats_UNIT1_GMWM);
        bids.util.tsvwrite(fileNameSNRstatsT1map_GMWM, SNRStats_T1map_GMWM);

    end
end
