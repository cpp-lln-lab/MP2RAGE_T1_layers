clear;
clc;

run ../initEnv();
addpath('/home/marcianunes/Desktop/Data/MP2RAGE_T1_layers/code/src/createROI');
opt = get_option_rois();

opt.subjects = {'pilot001'};

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)

  subLabel = opt.subjects{subIdx};
  fprintf('subject number: %d\n', subIdx);
  filter.sub = subLabel;
  filter.suffix = {'mask'};
  filter.desc = {'visfAtlas','wang'};
  filter.modality = 'roi';
  filter.label={'V1v','V1d','pFus','mFus','CoS'};
  %filter.hemi='R';
  list_of_rois= bids.query(BIDS, 'data', filter);
  
  
  clear filter
  
  %get the 0.75 mm iso UNIT1 
  filter.sub = subLabel;
  filter.suffix = 'UNIT1';
  filter.acq = 'r0p75';
  UNIT1 = bids.query(BIDS, 'data', filter);
  UNIT1 = UNIT1{1};
  clear filter
  
  header_UNIT1 = spm_vol(UNIT1);
  UNIT1_vol= spm_read_vols(header_UNIT1);
  
  signal = struct();
 
  clear filter
  
  numVoxPerRoi = zeros(1, numel(list_of_rois));

  for roi_idx = 1:numel(list_of_rois)
      %read ROI
      header_roi = spm_vol(list_of_rois{1});
      roi_vol= spm_read_vols(header_roi);
      
      info_roi=char(extractBetween(list_of_rois(roi_idx), 'space-individual_', '_mask.nii'));
      info_roi_struct=strrep(info_roi, '-', ''); % '-' was giving problems when naming the fields in structure
      fprintf('ROI: %s', info_roi)    
      
      %voxel intensities per ROI
      signal.(info_roi_struct) = spm_summarise(UNIT1, list_of_rois{roi_idx});
      %means = structfun(@mean, signal, 'uniform', 0);
      numVoxPerRoi(roi_idx) = size(signal.(sprintf('layer_%d', layerIdx)), 2);

  end
  field = fieldnames(signal);
  means=structfun(@mean, signal, 'uniform', 0);
  stds=structfun(@std, signal, 'uniform', 0);
  nVoxels=structfun(@numel,signal);
  SNR=struct();
  for k = 1:numel(field)
      SNR.(field{k}) = (means.(field{k}) / stds.(field{k}))*(numel(signal.(field{k}))/(numel(signal.(field{k}))-1))^(1/2); %Oliveira et al. NeuroImage (2021)
  end
  
  maxNbVoxel = max(nVoxels);
  
  for roi_idx = 1:numel(list_of_rois)
          
      T1relax.(sprintf('layer_%d', layerIdx)) = [ T1relax.(sprintf('layer_%d', layerIdx)) ...
                                                    nan(1, maxNbVoxel - numVoxPerLayer(layerIdx)) ];
      
  end
end