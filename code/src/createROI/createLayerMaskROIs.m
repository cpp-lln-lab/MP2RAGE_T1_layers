% 1 - restricts the layer segmentation image to only include voxels from the ROI
% 2 - creates one binary mask per layer / ROI

clear;
clc;

run ../initEnv();

opt = get_option_rois();

opt.subjects = {'pilot005'};

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)
    
    %% get images
    fprintf('subject number: %d\n', subIdx);
    subLabel = opt.subjects{subIdx};
    
    filter.sub = subLabel;
    filter.suffix = 'mask';
    filter.label = {'mFus', 'pFus', 'CoS', 'V1d', 'V1v'};
    filter.atlas = {'visfAtlas', 'wang'};
    filter.modality = 'roi';
    
    ListofROIs = bids.query(BIDS, 'data', filter);
    
    clear filter
    
    filter.sub = subLabel;
    filter.prefix = 'r';
    filter.label = '6layerEquidist';
    
    File6Layers = bids.query(BIDS, 'data', filter);
    File6Layers = File6Layers{1};
    clear filter
    %% restricts the layer segmentation image to only include voxels from the ROI
    
    hdr = spm_vol(ListofROIs);
    
    layer_seg = spm_read_vols(spm_vol(File6Layers));
    
    % Intersaction ROIs and layers
    Info_ROIs = [];
    for roi_idx = 1:numel(ListofROIs)
        %read ROI
        header_roi = spm_vol(ListofROIs{roi_idx});
        roi_vol= spm_read_vols(header_roi);
        
        info_roi=char(extractBetween(ListofROIs{roi_idx}, '/roi/sub', '_mask.nii'));
        info_roi_struct=strrep(info_roi, '-', ''); % '-' was giving problems when naming the fields in structure
        fprintf('ROI: %s', info_roi);
        
        Info_ROIs{end + 1} = info_roi_struct;
        
    end
    
    
    ListofROIs = cell2struct(ListofROIs', Info_ROIs, 2);
    ROIsFieldnames = fieldnames(ListofROIs);
    
    for roi_idx = 1:length(ROIsFieldnames)
        
        Read_ROIs = spm_read_vols(spm_vol(getfield(ListofROIs,char(ROIsFieldnames(roi_idx))))); 
        Layers = zeros(size(Read_ROIs));
        Layers(find(Read_ROIs)) = layer_seg(find(Read_ROIs)); %#ok<*FNDSB>
        
        bf = bids.File(getfield(ListofROIs,char(ROIsFieldnames(roi_idx))));
        ROIName = bf.entities.label;
        bf.entities.label = strcat(ROIName, '6layers'); %%, 'pFus', 'CoS', 'mFus'};
        ROI_layers_file = fullfile(spm_fileparts(hdr{roi_idx,1}.fname), bf.filename);
        hdr{roi_idx,1}.fname = ROI_layers_file;
        spm_write_vol(hdr{roi_idx,1}, Layers); % where hdr{roi_idx,1} is the header information for the new file, and Layers is the image matrix corresponding to the image that will be writing out.
        
        %% creates one binary mask per layer / ROI
        
        labelStruct(1).ROI = 'layer1';
        labelStruct(1).label = 1;
        labelStruct(2).ROI = 'layer2';
        labelStruct(2).label = 2;
        labelStruct(3).ROI = 'layer3';
        labelStruct(3).label = 3;
        labelStruct(4).ROI = 'layer4';
        labelStruct(4).label = 4;
        labelStruct(5).ROI = 'layer5';
        labelStruct(5).label = 5;
        labelStruct(6).ROI = 'layer6';
        labelStruct(6).label = 6;
        
        for i = 1:numel(labelStruct)
            thissLabelStruct = labelStruct(i);
            
            thissLabelStruct.ROI = [ROIName, labelStruct(i).ROI];
            output = extractRoiByLabel(ROI_layers_file, thissLabelStruct);
            
        end
        
        
    end
end
