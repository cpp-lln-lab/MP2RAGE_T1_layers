function statsCoVROIs(opt)

    BIDS = bids.layout(opt.dir.output, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)
        subLabel = opt.subjects{subIdx};
        %% statistics ROIs

        %find CoV images
        %unit1
        UNIT1CoV = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel]),...
            strcat('^[^w].*cov-commonVoxSes', opt.ses, '_ses', opt.ses2, '_UNIT1.nii$'));
        %T1map
        T1mapCoV = spm_select('FPList', fullfile(opt.dir.roi, ['sub-' subLabel]),...
            strcat('^[^w].*cov-commonVoxSes', opt.ses, '_ses', opt.ses2, '_T1map.nii$'));
        %% find ROIs UNIT1
        fprintf('subject number: %d\n', subIdx);
        filter.sub = subLabel;
        filter.suffix = 'mask';
        filter.desc = 'intercUNIT1SessionsBin';
        filter.label = opt.roi.name;
        filter.prefix = '';
        filter.ses = opt.ses; 
        filter.hemi = 'L';

        listofROIsUNIT1_L = bids.query(BIDS, 'data', filter);

        filter.hemi = 'R';
        listofROIsUNIT1_R = bids.query(BIDS, 'data', filter);
        clear filter

        CovRoiUNIT1_L = struct();
        CovRoiUNIT1_R = struct();

        for roi_idx = 1:numel(listofROIsUNIT1_L)
            bf = bids.File(char(listofROIsUNIT1_L(roi_idx)));
            info_roi = bf.entities.label;
            fprintf('ROI: %s', info_roi);

            CovRoiUNIT1_L.(info_roi) = spm_summarise(UNIT1CoV, listofROIsUNIT1_L{roi_idx});
            CovRoiUNIT1_R.(info_roi) = spm_summarise(UNIT1CoV, listofROIsUNIT1_R{roi_idx});        
        end

        %% UNIT1 stats
        %Left
        field_L = fieldnames(CovRoiUNIT1_L);
        meanCovRoiUNIT1_L = structfun(@mean, CovRoiUNIT1_L, 'uniform', 0);
        stdsUNIT1_L = structfun(@std, CovRoiUNIT1_L, 'uniform', 0);
        nVoxelsUNIT1_L = structfun(@numel, CovRoiUNIT1_L);
        minROIUNIT1_L = structfun(@min, CovRoiUNIT1_L, 'uniform', 0);
        maxROIUNIT1_L = structfun(@max, CovRoiUNIT1_L, 'uniform', 0);
        medianROIUNIT1_L = structfun(@median, CovRoiUNIT1_L, 'uniform', 0);
        iqrROIUNIT1_L = structfun(@iqr, CovRoiUNIT1_L, 'uniform', 0);

        MeanCovUNIT1_L = struct2cell(meanCovRoiUNIT1_L);
        StdCovUNIT1_L = struct2cell(stdsUNIT1_L);
        MinUNIT1_L = cell2mat(struct2cell(minROIUNIT1_L));
        MaxUNIT1_L = cell2mat(struct2cell(maxROIUNIT1_L));
        medianCovUNIT1_L = cell2mat(struct2cell(medianROIUNIT1_L));
        IqrROIUNIT1_L = struct2cell(iqrROIUNIT1_L);

        %right
        field_R = fieldnames(CovRoiUNIT1_R);
        meanCovRoiUNIT1_R = structfun(@mean, CovRoiUNIT1_R, 'uniform', 0);
        stdsUNIT1_R = structfun(@std, CovRoiUNIT1_R, 'uniform', 0);
        nVoxelsUNIT1_R = structfun(@numel, CovRoiUNIT1_R);
        minROIUNIT1_R = structfun(@min, CovRoiUNIT1_R, 'uniform', 0);
        maxROIUNIT1_R = structfun(@max, CovRoiUNIT1_R, 'uniform', 0);
        medianROIUNIT1_R = structfun(@median, CovRoiUNIT1_R, 'uniform', 0);
        iqrROIUNIT1_R = structfun(@iqr, CovRoiUNIT1_R, 'uniform', 0);
        IqrROIUNIT1_R = struct2cell(iqrROIUNIT1_R);

        MeanCovUNIT1_R = struct2cell(meanCovRoiUNIT1_R);
        StdCovUNIT1_R = struct2cell(stdsUNIT1_R);
        MinUNIT1_R = cell2mat(struct2cell(minROIUNIT1_R));
        MaxUNIT1_R = cell2mat(struct2cell(maxROIUNIT1_R));
        medianCovUNIT1_R = cell2mat(struct2cell(medianROIUNIT1_R));

        % Create table
        CovStatsUNIT1_L = table(field_L, MeanCovUNIT1_L, medianCovUNIT1_L, IqrROIUNIT1_L, StdCovUNIT1_L, nVoxelsUNIT1_L, MinUNIT1_L, MaxUNIT1_L);
        CovStatsUNIT1_R = table(field_R, MeanCovUNIT1_R, medianCovUNIT1_R, IqrROIUNIT1_R, StdCovUNIT1_R, nVoxelsUNIT1_R, MinUNIT1_R, MaxUNIT1_R);

        outputNameCovStatsUNIT1 = ['sub-' subLabel ...
                                   '_ses' opt.ses 'ses' opt.ses2 '_acq-' opt.acq '_hemi-L_desc-covStatsROIs_UNIT1.tsv';...
                                   'sub-' subLabel ...
                                   '_ses' opt.ses 'ses' opt.ses2 '_acq-' opt.acq '_hemi-R_desc-covStatsROIs_UNIT1.tsv'];        fileNameCovStatsUNIT1_L = fullfile(opt.dir.output, ['sub-' subLabel], outputNameCovStatsUNIT1(1,:));

        fileNameCovStatsUNIT1_R = fullfile(opt.dir.output, ['sub-' subLabel], outputNameCovStatsUNIT1(2,:));
        bids.util.tsvwrite(fileNameCovStatsUNIT1_L, CovStatsUNIT1_L);
        bids.util.tsvwrite(fileNameCovStatsUNIT1_R, CovStatsUNIT1_R);

        % T1 map
        %% find ROIs T1 map
        fprintf('subject number: %d\n', subIdx);
        filter.sub = subLabel;
        filter.suffix = 'mask';
        filter.desc = 'intercT1mapSessionsBin';
        filter.label = opt.roi.name;
        filter.prefix = '';
        filter.hemi = 'L';
        filter.ses = opt.ses; 

        listofROIsT1map_L = bids.query(BIDS, 'data', filter);

        filter.hemi = 'R';
        listofROIsT1map_R = bids.query(BIDS, 'data', filter);

        clear filter;
        CovRoiT1map_L = struct();
        CovRoiT1map_R = struct();

        for roi_idx = 1:numel(listofROIsT1map_L)
            bf = bids.File(char(listofROIsT1map_L(roi_idx)));
            info_roi = bf.entities.label;
            fprintf('ROI: %s', info_roi);
            
            CovRoiT1map_L.(info_roi) = spm_summarise(T1mapCoV, listofROIsT1map_L{roi_idx});
            CovRoiT1map_R.(info_roi) = spm_summarise(T1mapCoV, listofROIsT1map_R{roi_idx});
        end

        %LEFT
        meanCovRoiT1map_L = structfun(@mean, CovRoiT1map_L, 'uniform', 0);
        stdsT1map_L = structfun(@std, CovRoiT1map_L, 'uniform', 0);
        nVoxelsT1map_L = structfun(@numel, CovRoiT1map_L);
        minROIT1map_L = structfun(@min, CovRoiT1map_L, 'uniform', 0);
        maxROIT1map_L = structfun(@max, CovRoiT1map_L, 'uniform', 0);
        medianROIT1map_L = structfun(@median, CovRoiT1map_L, 'uniform', 0);

        iqrROIT1map_L = structfun(@iqr, CovRoiUNIT1_L, 'uniform', 0);
        IqrROIT1map_L = struct2cell(iqrROIT1map_L);

        MeanCovT1map_L = struct2cell(meanCovRoiT1map_L);
        StdCovT1map_L = struct2cell(stdsT1map_L);
        MinT1map_L = cell2mat(struct2cell(minROIT1map_L));
        MaxT1map_L = cell2mat(struct2cell(maxROIT1map_L));
        medianCovT1map_L = cell2mat(struct2cell(medianROIT1map_L));


        %right
        meanCovRoiT1map_R = structfun(@mean, CovRoiT1map_R, 'uniform', 0);
        stdsT1map_R = structfun(@std, CovRoiT1map_R, 'uniform', 0);
        nVoxelsT1map_R = structfun(@numel, CovRoiT1map_R);
        minROIT1map_R = structfun(@min, CovRoiT1map_R, 'uniform', 0);
        maxROIT1map_R = structfun(@max, CovRoiT1map_R, 'uniform', 0);
        medianROIT1map_R = structfun(@median, CovRoiT1map_R, 'uniform', 0);

        iqrROIT1map_R = structfun(@iqr, CovRoiT1map_R, 'uniform', 0);
        IqrROIT1map_R = struct2cell(iqrROIT1map_R);

        MeanCovT1map_R = struct2cell(meanCovRoiT1map_R);
        StdCovT1map_R = struct2cell(stdsT1map_R);
        MinT1map_R = cell2mat(struct2cell(minROIT1map_R));
        MaxT1map_R = cell2mat(struct2cell(maxROIT1map_R));
        medianCovT1map_R = cell2mat(struct2cell(medianROIT1map_R));

        CovStatsT1map_L = table(field_L, MeanCovT1map_L, medianCovT1map_L, IqrROIT1map_L, StdCovT1map_L, nVoxelsT1map_L, MinT1map_L, MaxT1map_L);
        CovStatsT1map_R = table(field_R, MeanCovT1map_R, medianCovT1map_R, IqrROIT1map_R, StdCovT1map_R, nVoxelsT1map_R, MinT1map_R, MaxT1map_R);

        outputNameCovStatsT1map = ['sub-' subLabel ...
                                   '_ses' opt.ses 'ses' opt.ses2 '_acq-' opt.acq '_hemi-L_desc-covStatsROIs_T1map.tsv';...
                                   'sub-' subLabel ...
                                   '_ses' opt.ses 'ses' opt.ses2 '_acq-' opt.acq '_hemi-R_desc-covStatsROIs_T1map.tsv'];

        fileNameCovStatsT1map_L = fullfile(opt.dir.output, ['sub-' subLabel], outputNameCovStatsT1map(1,:));
        fileNameCovStatsT1map_R = fullfile(opt.dir.output, ['sub-' subLabel], outputNameCovStatsT1map(2,:));    
        bids.util.tsvwrite(fileNameCovStatsT1map_L, CovStatsT1map_L);
        bids.util.tsvwrite(fileNameCovStatsT1map_R, CovStatsT1map_R);
    end
end