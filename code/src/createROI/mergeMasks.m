function mergeMasks(opt)
     if nargin < 1
         opt = [];
     end
    
    for iSub = 1:numel(opt.subjects)
        subLabel = opt.subjects{iSub};
        printProcessingSubject(iSub, subLabel, opt);

        opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi'), 'cpath');
        roiList = spm_select('FPlist', ...
            fullfile(opt.dir.roi, ['sub-', subLabel], 'roi'), ...
            '^[^w].*_mask.nii$'); %data2read

        [BIDS, opt] = setUpWorkflow(opt, 'merge ROIs');
                
        Headerm1 = spm_vol(roiList(1,:));
        Headerm2 = spm_vol(roiList(2,:));
        Headerm3 = spm_vol(roiList(3,:));   
        Headerm4 = spm_vol(roiList(4,:));

        m1= spm_read_vols(Headerm1);
        m2= spm_read_vols(Headerm2);
        m3= spm_read_vols(Headerm3);
        m4= spm_read_vols(Headerm4);
        
        expression = m1 | m2 | m3 | m4;
        % Step 1.  Take the header information from a previous file with similar dimensions 
        %          and voxel sizes and change the filename in the header.
        HeaderInfo=Headerm1;
        HeaderInfo.fname = fullfile(opt.dir.roi,['sub-' subLabel],'roi',['sub-' subLabel '_space-individual_V1_wang-mask.nii']);  % This is where you fill in the new filename

        HeaderInfo.private.dat.fname = HeaderInfo.fname;  % This just replaces the old filename in another location within the header.
        
        % Step 2.  Now use spm_write_vol to write out the new data.  
        %          You need to give spm_write_vol the new header information and corresponding data matrix
        spm_write_vol(HeaderInfo,expression);  % where HeaderInfo is your header information for the new file, and Data is the image matrix corresponding to the image you'll be writing out.
        
    end
    
end