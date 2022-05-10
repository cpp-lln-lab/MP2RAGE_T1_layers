function intercept_ROI_and_layers(opt)
     if nargin < 1
         opt = [];
     end
    
    for iSub = 1:numel(opt.subjects)
        subLabel = opt.subjects{iSub};
        printProcessingSubject(iSub, subLabel, opt);

        opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi', ['sub-', subLabel], 'roi'), 'cpath');
        opt.dir.layer = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi', ['sub-', subLabel], 'ses-001/ROI'), 'cpath');

        roi = spm_select('FPlist', opt.dir.roi, '^[^w].*-mask.nii$' ); %data2read
        Layers = spm_select('FPlist', opt.dir.layer, '^[^w].*equidist.nii'); %data2read

        [BIDS, opt] = setUpWorkflow(opt, 'intercept ROI and layers');
                
        HeaderRoi = spm_vol(roi(1,:));
        HeaderLayers = spm_vol(Layers(1,:));


        Roi= spm_read_vols(HeaderRoi);
        Layers= spm_read_vols(HeaderLayers);

        
        Intercept = Roi .* Layers;
        % Step 1.  Take the header information from a previous file with similar dimensions 
        %          and voxel sizes and change the filename in the header.
        HeaderInfo=HeaderLayers;
        HeaderInfo.fname = fullfile(opt.dir.roi,['sub-' subLabel],'roi',['sub-' subLabel '_interception-ROI-and-layers.nii']);  % This is where you fill in the new filename

        HeaderInfo.private.dat.fname = HeaderInfo.fname;  % This just replaces the old filename in another location within the header.
        
        % Step 2.  Now use spm_write_vol to write out the new data.  
        %          You need to give spm_write_vol the new header information and corresponding data matrix
        spm_write_vol(HeaderInfo,Intercept);  % where HeaderInfo is your header information for the new file, and Data is the image matrix corresponding to the image you'll be writing out.
        
    end
    
end