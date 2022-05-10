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

  subLabel = opt.subjects{subIdx};

  filter.sub = subLabel;
  filter.suffix = 'mask';
  filter.label = 'V1';
  filter.desc = 'wang';
  filter.modality = 'roi';

  V1_file = bids.query(BIDS, 'data', filter);
  V1_file = V1_file{1};

  clear filter

  filter.sub = subLabel;
  filter.prefix = 'r';
  filter.label = '6layerEquidist';
    
  layer_file = bids.query(BIDS, 'data', filter);
  layer_file = layer_file{1};

  %% restricts the layer segmentation image to only include voxels from the ROI

  hdr = spm_vol(V1_file);

  layer_seg = spm_read_vols(spm_vol(layer_file));

  % Intersaction V1 and layers
  V1_mask = spm_read_vols(spm_vol(V1_file));
  V1_layers = zeros(size(V1_mask));
  V1_layers(find(V1_mask)) = layer_seg(find(V1_mask)); %#ok<*FNDSB>

  bf = bids.File(V1_file);
  bf.entities.label = 'V16layers';
  Vone_layers_file = fullfile(spm_fileparts(hdr.fname), bf.filename);
  hdr.fname = Vone_layers_file;
  spm_write_vol(hdr, V1_layers);

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

    thissLabelStruct.ROI = ['V1', labelStruct(i).ROI];
    output = extractRoiByLabel(Vone_layers_file, thissLabelStruct);

  end


end
