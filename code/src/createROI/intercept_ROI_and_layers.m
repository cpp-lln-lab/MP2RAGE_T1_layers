function intercept_ROI_and_layers(opt)
    if nargin < 1
        opt = [];
    end

    BIDSref = bids.layout(opt.dir.output, 'use_schema', false);

    for iSub = 1:numel(opt.subjects)
        subLabel = opt.subjects{iSub};
        printProcessingSubject(iSub, subLabel, opt);

        % find resliced layers

        filter.sub = subLabel;
        filter.acq = 'r0p375';
        filter.space = 'individual';
        filter.prefix = 'r';
        filter.label = '6layerEquidist';
        filter.suffix = 'mask';

        layers = bids.query(BIDSref, 'data', filter);
        layers = layers {1};

        clear filter;

        % find ROIs
        filter.sub = subLabel;
        filter.ses = '001';
        filter.space = 'individual';
        filter.label = {'V1d', 'V1v', 'v1v', 'v1d', 'pFus', 'mFus', 'CoS'};
        filter.suffix = 'mask';
        filter.desc = 'intercMasks';
        filter.prefix = 'r';

        listofRois = bids.query(BIDSref, 'data', filter);
        clear filter;
        [BIDS, opt] = setUpWorkflow(opt, 'intercept ROI and layers');

        HeaderLayers = spm_vol(layers);
        Layers = spm_read_vols(HeaderLayers);

        for ROIidx = 1:numel(listofRois)

            HeaderRoi = spm_vol(listofRois{ROIidx});
            Roi = spm_read_vols(HeaderRoi);

            Intercept = Roi .* Layers;
            % Step 1.  Take the header information from a previous file with similar dimensions
            %          and voxel sizes and change the filename in the header.
            HeaderInfo = HeaderRoi;

            Roiname = strcat(char(extractBetween(listofRois{ROIidx}, '/roi/', 'desc-')), 'desc-6layers_mask.nii');
            session = char(extractBetween(listofRois{ROIidx}, '/ses-', '/roi/'));
            HeaderInfo.fname = fullfile(opt.dir.roi, ['sub-' subLabel], ['ses-' session], 'roi', Roiname);  % This is where you fill in the new filename
            HeaderInfo.dt = HeaderLayers.dt;
            HeaderInfo.private.dat.fname = HeaderInfo.fname;  % This just replaces the old filename in another location within the header.

            % Step 2.  Now use spm_write_vol to write out the new data.
            %          You need to give spm_write_vol the new header information and corresponding data matrix
            spm_write_vol(HeaderInfo, Intercept);  % where HeaderInfo is your header information for the new file, and Data is the image matrix corresponding to the image you'll be writing out.

        end
    end

end
