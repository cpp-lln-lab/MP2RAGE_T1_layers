function createLayerMaskROIs(opt)
    % 1 - restricts the layer segmentation image to only include voxels from the ROI
    % 2 - creates one binary mask per layer / ROI

    BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

    for subIdx = 1:numel(opt.subjects)

        %% get images
        fprintf('subject number: %d\n', subIdx);
        subLabel = opt.subjects{subIdx};

        filter.sub = subLabel;
        filter.suffix = 'mask';
        filter.label = opt.roi.name;
        filter.modality = 'roi';
        filter.desc = '6layers';
        filter.prefix = '';

        ListofROIs = bids.query(BIDS, 'data', filter);

        clear filter;

        filter.sub = subLabel;
        filter.prefix = 'r';
        filter.label = '6layerEquidist';

        File6Layers = bids.query(BIDS, 'data', filter);
        File6Layers = File6Layers{1};
        clear filter;
        %% restricts the layer segmentation image to only include voxels from the ROI

        hdr = spm_vol(ListofROIs);

        layer_seg = spm_read_vols(spm_vol(File6Layers));

        for roi_idx = 1:length(ListofROIs)

            Read_ROIs = spm_read_vols(spm_vol(char(ListofROIs(roi_idx))));
            Layers = zeros(size(Read_ROIs));
            Layers(find(Read_ROIs)) = layer_seg(find(Read_ROIs)); %#ok<*FNDSB>
            bf = bids.File(char(ListofROIs(roi_idx)));

            ROIName = bf.entities.label;
            bf.entities.label = strcat(ROIName, '6layers'); %% , 'pFus', 'CoS', 'mFus'};
            ROI_layers_file = fullfile(spm_fileparts(hdr{roi_idx, 1}.fname), bf.filename);
            hdr{roi_idx, 1}.fname = ROI_layers_file;
            spm_write_vol(hdr{roi_idx, 1}, Layers); % where hdr{roi_idx,1} is the header information for the new file, and Layers is the image matrix corresponding to the image that will be writing out.

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
end
