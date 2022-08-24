function interceptUNIT1andBrainMask(opt)

    BIDS = bids.layout(opt.dir.preproc, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)
        subLabel = opt.subjects{subIdx};

        %% get brain mask
        filter.modality = 'anat';
        filter.sub = subLabel;
        filter.ses = '002';    % change accordingly to the session
        filter.space = 'individual';
        % filter.acq = 'r0p75';
        filter.suffix = 'mask';
        brainmask = bids.query(BIDS, 'data', filter);
        brainmask = brainmask{:}; % because it complains: 'Struct contents reference from a non-struct array object.'

        session = filter.ses;

        clear filter;

        Headerbrainmask = spm_vol(brainmask);
        Brainmask = spm_read_vols(Headerbrainmask);

        %% get UNIT1
        filter.sub = subLabel;
        filter.suffix = 'UNIT1';
        filter.ses = '002';    % change accordingly to the session
        UNIT1 = bids.query(BIDS, 'data', filter);
        UNIT1 = UNIT1{:}; % because it complains: 'Struct contents reference from a non-struct array object.'

        clear filter;

        HeaderUNIT1 = spm_vol(UNIT1);
        Unit1 = spm_read_vols(HeaderUNIT1);

        UNIT1Skullstripped = Brainmask .* Unit1;

        HeaderUNIT1Skullstripped = HeaderUNIT1;
        HeaderUNIT1Skullstripped.fname = fullfile([HeaderUNIT1.fname(1:end - 9) 'desc-intercBrainMask_UNIT1.nii']);  % This is where you fill in the new filename

        HeaderUNIT1Skullstripped.private.dat.fname = HeaderUNIT1Skullstripped.fname;  % This just replaces the old filename in another location within the header.

        % Step 2.  Now use spm_write_vol to write out the new data.
        %          You need to give spm_write_vol the new header information and corresponding data matrix
        spm_write_vol(HeaderUNIT1Skullstripped, UNIT1Skullstripped);  % where HeaderInfo is your header information for the new file, and Data is the image matrix corresponding to the image you'll be writing out.
    end

end
