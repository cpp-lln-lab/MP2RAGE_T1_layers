clear;
clc;

run ../initEnv();

opt = get_option_rois();

opt.subjects = {'pilot004'};

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)

  %% get list of layers files

  subLabel = opt.subjects{subIdx};
  fprintf('subject number: %d\n', subIdx);
  filter.sub = subLabel;
  filter.suffix = 'mask';
  
  filter.label = {'V1layer1', 'V1layer2', 'V1layer3', 'V1layer4', 'V1layer5', 'V1layer6'};
  filter.desc = 'wang';
  filter.modality = 'roi';

  listoflayers = bids.query(BIDS, 'data', filter);

  clear filter
  
  %get the T1 map
  filter.sub = subLabel;
  %filter.prefix = 'r';
  filter.suffix = 'T1map';
    
  T1map = bids.query(BIDS, 'data', filter);
  T1map = T1map{1};
  
  T1relax = struct();
  clear filter
  numVoxPerLayer = zeros(1, numel(listoflayers));

  for layerIdx = 1:numel(listoflayers)
      
      fprintf('\nWorking on layer: %s\n', num2str(layerIdx))
    
      T1relax.(sprintf('layer_%d', layerIdx)) = spm_summarise(T1map, listoflayers{layerIdx});
      
      numVoxPerLayer(layerIdx) = size(T1relax.(sprintf('layer_%d', layerIdx)), 2);

  end
  
  maxNbVoxel = max(numVoxPerLayer);
  
  for layerIdx = 1:numel(listoflayers)
          
      T1relax.(sprintf('layer_%d', layerIdx)) = [ T1relax.(sprintf('layer_%d', layerIdx)) ...
                                                    nan(1, maxNbVoxel - numVoxPerLayer(layerIdx)) ];
      
  end
  
  outputName = [ 'sub-' subLabel ...
                 '_ses-001_acq-r0p375_T1relaxation.tsv'];
        
  fileName = fullfile(opt.dir.output, ['sub-' subLabel] , 'ses-001', 'anat', outputName);
  
  bids.util.tsvwrite(fileName, T1relax);
  
end
