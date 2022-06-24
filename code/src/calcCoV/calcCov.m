clear;
clc;


addpath(fullfile(pwd, '..'));
initEnv();

opt = getOptionsCov();

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, ...
    'use_schema', false);
               
%to fix: for cycle for not work for subIdx > 1
for subIdx = 1 : numel(opt.subjects)
    subLabel = opt.subjects{subIdx};
    fprintf('subject number: %d\n', subIdx);
    filters.sub = subLabel;
    filters.ses = '001';
    filters.modality = 'anat';
    filters.acq = 'r0p75';
    filters.suffix = 'UNIT1';
    filters.space = 'individual';
    filters.desc = 'skullstripped';
    
    sub1stSes = bids.query(BIDS, 'data', filters);
    sub1stSes = sub1stSes{1};

    header_sub1stSes = spm_vol(sub1stSes);
    sub1stSes_vol = spm_read_vols(header_sub1stSes);
    
    filters.ses = '002';

    sub2stSes = bids.query(BIDS, 'data', filters);
    sub2stSes = sub2stSes{1};

    header_sub2stSes = spm_vol(sub2stSes);
    sub2stSes_vol = spm_read_vols(header_sub2stSes);
    
    sub1stSes_vol(sub1stSes_vol==0) = NaN;
    sub2stSes_vol(sub2stSes_vol==0) = NaN;

    
    meanmatrix = (sub1stSes_vol + sub2stSes_vol)./2;
    difference = abs(sub1stSes_vol - sub2stSes_vol);
    CovarianceSes = difference ./ meanmatrix;
    
    HeaderInfo = header_sub1stSes;
    HeaderInfo.fname = fullfile(opt.dir.roi, ['sub-' subLabel], 'CovarianceSes001Ses002.nii');  % This is where you fill in the new filename
    HeaderInfo.private.dat.fname = HeaderInfo.fname;  % This just replaces the old filename in another location within the header.
    Covariance_picture = spm_write_vol(HeaderInfo, CovarianceSes); 
    
    
    %average covariance in each ROI
    
    clear filters
    
    filters.sub = subLabel;
    filters.suffix = {'mask'};
    filters.desc = 'intercMasks';
    filters.atlas = {'visfAtlas', 'wang'};

    list_of_rois = bids.query(BIDS, 'data', filters);
    
    CovRoi = struct();

    for roi_idx = 1:numel(list_of_rois)
        
        header_roi = spm_vol(list_of_rois{roi_idx});
        roi_vol = spm_read_vols(header_roi);

        info_roi = char(extractBetween(list_of_rois(roi_idx), 'hemi-', '_desc-intercMasks_mask.nii'));
        info_roi_struct = strrep(info_roi, '-', ''); % '-' was giving problems when naming the fields in structure
        fprintf('ROI: %s', info_roi);
        
        CovRoi.(info_roi_struct) = spm_summarise(Covariance_picture.fname, list_of_rois{roi_idx});
    end
    
    field = fieldnames(CovRoi);
    meanCovRoi = structfun(@mean, CovRoi, 'uniform', 0);
    stds = structfun(@std, CovRoi, 'uniform', 0);
    nVoxels = structfun(@numel, CovRoi);
    minROI = structfun(@min, CovRoi, 'uniform', 0);
    maxROI = structfun(@max, CovRoi, 'uniform', 0);
        
    MeanCov = struct2cell(meanCovRoi);
    StdCov = struct2cell(stds);
    Min = cell2mat(struct2cell(minROI));
    Max = cell2mat(struct2cell(maxROI));
    
    CovStats = table(field, MeanCov, StdCov, nVoxels, Min, Max);
    outputNameCovStatsUNIT1 = [ 'sub-' subLabel ...
                 '_ses-001_acq-r0p75_desc-CovStatsROIs_UNIT1.tsv'];
             
    fileNameCovStatsUNIT1 = fullfile(opt.dir.output, ['sub-' subLabel] , outputNameCovStatsUNIT1);
    bids.util.tsvwrite(fileNameCovStatsUNIT1, CovStats);

end

 