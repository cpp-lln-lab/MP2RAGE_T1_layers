function resliceRoiToBrainmask(opt)

    opt.dir.roi = opt.dir.output;

    BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)
        % List of ROIs
        subLabel = opt.subjects{subIdx};
        fprintf('subject number: %d\n', subIdx);
        filter.sub = subLabel;
        filter.ses = '002';
        filter.space = 'individual';

        % filter.label = {'V1d', 'V1v', 'v1v', 'v1d', 'pFus', 'mFus', 'CoS'};
        %% uncoment the previous line to run the pipeline, comment to run the quality control metrics
        filter.suffix = 'mask';
        filter.hemi = {'L', 'R'};
        filter.prefix = '';
        filter.desc = ''; % to remove the interception of masks files already in the folder
        listofROIs = bids.query(BIDS, 'data', filter);

        clear filter;
        %% get brain mask
        filter.sub = subLabel;
        filter.ses = '002';
        filter.space = 'individual';
        filter.acq = 'r0p75'; % change depending on the pipeline
        filter.suffix = 'mask';
        % filter.desc = 'skullstripped';
        brainmask = bids.query(BIDS, 'data', filter);
        brainmask = brainmask{:};

        clear filter;

        Headerbrainmask = spm_vol(brainmask);
        Brainmask = spm_read_vols(Headerbrainmask);

        for ROIidx = 1:numel(listofROIs)

            HeaderRoi = spm_vol(listofROIs{ROIidx});
            Roi = spm_read_vols(HeaderRoi);

            %% reslice with nearest neighbour interpolation
            interpolation = 0;
            matlabbatch = {};
            matlabbatch = setBatchReslice(matlabbatch, opt, brainmask, HeaderRoi.fname, interpolation);

            batchName = 'reslice_ROI_to_brain_mask';
            saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);
        end

    end
end
