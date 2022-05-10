clear;
clc;

run ../initEnv();

opt = get_option_rois();

opt.subjects = {'pilot005'};

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);

for subIdx = 1:numel(opt.subjects)
    
  %% get layer

  subLabel = opt.subjects{subIdx};
  
  
  %% get T1 map
