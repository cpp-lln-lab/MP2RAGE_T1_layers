clear;
clc;


addpath(fullfile(pwd, '..'));
initEnv();

addpath(fullfile(pwd, '../calcSNR'));
opt = get_option_preproc();

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, ...
    'use_schema', false);
               
%to fix: for cycle for not worun 'calcCov.m';
for subIdx = 1 : numel(opt.subjects)
    subLabel = opt.subjects{subIdx};
    fprintf('subject number: %d\n', subIdx);
    % find UNIT1 sess 001 and 002
    filters.sub = subLabel;
    filters.ses = '001';
    filters.modality = 'anat';
    filters.acq = 'r0p75';
    filters.suffix = 'UNIT1';
    filters.prefix = '';
    filters.desc = 'intercBrainMask';
    
    sub1stSesUNIT1 = bids.query(BIDS, 'data', filters);
    sub1stSesUNIT1 = sub1stSesUNIT1{1};

    header_sub1stUNIT1 = spm_vol(sub1stSesUNIT1);
    sub1stUNIT1_vol = spm_read_vols(header_sub1stUNIT1);
    
    filters.ses = '002';
    filters.prefix = '';
    
    sub2stSesUNIT1 = bids.query(BIDS, 'data', filters);
    sub2stSesUNIT1 = sub2stSesUNIT1{1};

    header_sub2ndUNIT1 = spm_vol(sub2stSesUNIT1);
    sub2ndUNIT1_vol = spm_read_vols(header_sub2ndUNIT1);
        
    % find T1 map 001 and 002 sessions
    filter.sub = subLabel;
    filter.acq = 'r0p75';
    filter.ses = '001';  
    filter.suffix = 'T1map';
    filter.desc = 'skullstripped';
    filter.space = '';
    filter.prefix = '';
    
    T1map_001 = bids.query(BIDS, 'data', filter);
    T1map_001 = T1map_001{1};
    
    header_sub1stT1map = spm_vol(T1map_001);
    sub1stT1map_vol = spm_read_vols(header_sub1stT1map);
    
    filter.ses = '002'; %change for other sessions    

    T1map_002 = bids.query(BIDS, 'data', filter);
    T1map_002 = T1map_002{1};
    
    header_sub2ndT1map = spm_vol(T1map_002);
    sub2ndT1map_vol = spm_read_vols(header_sub2ndT1map);

    %% find resliced session 2 
    %start again the filters
    
    filters.prefix = 'r';
    filter.prefix = 'r';

    sub2stSesUNIT1_resliced = bids.query(BIDS, 'data', filters);
    sub2stSesUNIT1_resliced = sub2stSesUNIT1_resliced{1};
    
    T1map_002_resliced = bids.query(BIDS, 'data', filter);
    T1map_002_resliced = T1map_002_resliced{1};
    
    %% CoV operations
    %unit1
    sub2stSesUNIT1_r = spm_vol(sub2stSesUNIT1_resliced);
    sub2stSesUNIT1_r_vol = spm_read_vols(sub2stSesUNIT1_r);
    
    sub2stSesUNIT1_r_vol(sub2stSesUNIT1_r_vol == 0) = NaN;

    meanmatrixUNIT1 = (sub1stUNIT1_vol + sub2stSesUNIT1_r_vol)/2;
    difUNIT1 = abs(sub1stUNIT1_vol - sub2stSesUNIT1_r_vol);
    CovarianceSesUNIT1 = difUNIT1 ./ meanmatrixUNIT1;

    %T1MAP
    
    T1map_002_r = spm_vol(T1map_002_resliced);
    T1map_002_r_vol = spm_read_vols(T1map_002_r);
    
    T1map_002_r_vol(T1map_002_r_vol == 0) = NaN;

    meanmatrixT1map = (sub1stT1map_vol + T1map_002_r_vol)/2;
    difT1map = abs(sub1stT1map_vol - T1map_002_r_vol);
    CovarianceSesT1map = difT1map ./ meanmatrixT1map;
    %% save CoV picture
    
    %UNIT1
    HeaderInfoUNIT1 = header_sub1stUNIT1;
    HeaderInfoUNIT1.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'CovarianceSes001Ses002_UNIT1.nii');  % This is where you fill in the new filename
    HeaderInfoUNIT1.private.dat.fname = HeaderInfoUNIT1.fname;  % This just replaces the old filename in another location within the header.
    HeaderInfoUNIT1.dt = [16 0];
    Covariance_pictureUNIT1 = spm_write_vol(HeaderInfoUNIT1, CovarianceSesUNIT1); 
    
    %T1map
    HeaderInfoT1map = header_sub1stT1map;
    HeaderInfoT1map.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'CovarianceSes001Ses002_T1map.nii');  % This is where you fill in the new filename
    HeaderInfoT1map.private.dat.fname = HeaderInfoT1map.fname;  % This just replaces the old filename in another location within the header.
    HeaderInfoT1map.dt = [16 0];
    Covariance_pictureT1map = spm_write_vol(HeaderInfoT1map, CovarianceSesT1map); 
    %% save CoV statistics
    
    clear filters
    
    filters.sub = subLabel;
    filters.suffix = {'mask'};
    filters.desc = 'intercMasks';
    filters.atlas = {'visfAtlas', 'wang'};
    filters.prefix = 'r';
    list_of_rois = bids.query(BIDS, 'data', filters);
    
    CovRoiUNIT1 = struct();
    CovRoiT1map = struct();

    clear filters
    clear filter
    for roi_idx = 1:numel(list_of_rois)
        
        header_roi = spm_vol(list_of_rois{roi_idx});
        roi_vol = spm_read_vols(header_roi);

        info_roi = char(extractBetween(list_of_rois(roi_idx), 'hemi-', '_desc-intercMasks_mask.nii'));
        info_roi_struct = strrep(info_roi, '-', ''); % '-' was giving problems when naming the fields in structure
        fprintf('ROI: %s', info_roi);
        
        CovRoiUNIT1.(info_roi_struct) = spm_summarise(Covariance_pictureUNIT1.fname, list_of_rois{roi_idx});
        CovRoiT1map.(info_roi_struct) = spm_summarise(Covariance_pictureT1map.fname, list_of_rois{roi_idx});
    end
    
    CovRoiUNIT1_noNaNs = structfun( @rmmissing , CovRoiUNIT1 , 'UniformOutput' , false);
    CovRoiT1map_noNaNs = structfun( @rmmissing , CovRoiT1map , 'UniformOutput' , false);
    % unit1
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
    outputNameCovStatsUNIT1 = [ 'sub-' subLabel ...
                 '_ses-001_acq-r0p75_desc-CovStatsROIs_UNIT1.tsv'];
             
    fileNameCovStatsUNIT1 = fullfile(opt.dir.output, ['sub-' subLabel] , outputNameCovStatsUNIT1);
    bids.util.tsvwrite(fileNameCovStatsUNIT1, CovStatsUNIT1);
    
    %t1 map
    
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
    outputNameCovStatsT1map = [ 'sub-' subLabel ...
                 '_ses-001_acq-r0p75_desc-CovStatsROIs_T1map.tsv'];
             
    fileNameCovStatsT1map = fullfile(opt.dir.output, ['sub-' subLabel] , outputNameCovStatsT1map);
    bids.util.tsvwrite(fileNameCovStatsT1map, CovStatsT1map);
    
end

 