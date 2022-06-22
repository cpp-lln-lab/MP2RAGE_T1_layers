function intercept_ROI_and_brainmask(opt)

opt.subjects = {'pilot004'};

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)
    %List of ROIs
    subLabel = opt.subjects{subIdx};
    fprintf('subject number: %d\n', subIdx);
    filter.sub = subLabel;
    filter.suffix = 'mask';
    filter.atlas = {'wang', 'visfAtlas'};
    filter.space = 'individual';
    filter.hemi={'L', 'R'};
    filter.desc = ''; %to remove the interception of masks files already in the folder
    listofROIs = bids.query(BIDS, 'data', filter);
    
    clear filter
    %% get brain mask
    filter.sub = subLabel;
    filter.ses = '001';
    filter.space = 'individual';
    filter.acq = 'r0p75';
    filter.suffix = 'mask';
    brainmask = bids.query(BIDS, 'data', filter);
    brainmask = brainmask{:}; %because it complains: 'Struct contents reference from a non-struct array object.'
    
    clear filter;
end

	Headerbrainmask = spm_vol(brainmask);
    Brainmask = spm_read_vols(Headerbrainmask);

    for ROIidx = 1:numel(listofROIs)
        
        HeaderRoi = spm_vol(listofROIs{ROIidx});
        Roi = spm_read_vols(HeaderRoi);

        Intercept = Roi .* Brainmask;
        % Step 1.  Take the header information from a previous file with similar dimensions
        %          and voxel sizes and change the filename in the header.
        HeaderInfo = HeaderRoi;
        Roiname = strcat(char(extractBetween(listofROIs{ROIidx}, '/roi/', '_mask.nii')), '_desc-intercMasks_mask.nii');
        session = char(extractBetween(listofROIs{ROIidx}, '/ses-', '/roi/'));
        HeaderInfo.fname = fullfile(opt.dir.roi, ['sub-' subLabel], ['ses-' session], 'roi', Roiname);  % This is where you fill in the new filename

        HeaderInfo.private.dat.fname = HeaderInfo.fname;  % This just replaces the old filename in another location within the header.

        % Step 2.  Now use spm_write_vol to write out the new data.
        %          You need to give spm_write_vol the new header information and corresponding data matrix
        spm_write_vol(HeaderInfo, Intercept);  % where HeaderInfo is your header information for the new file, and Data is the image matrix corresponding to the image you'll be writing out.
    end
end
