clear;
clc;

run ../initEnv();
addpath(fullfile(pwd, '..'));
opt = get_option_rois();

opt.dir.roi = opt.dir.output;

BIDS = bids.layout(opt.dir.roi, 'use_schema', false);
rois = {'pFus', 'CoS', 'mFus', 'V1v', 'V1d'};

for subIdx = 1:numel(opt.subjects)
    
    %% get list of layers files
    
    subLabel = opt.subjects{subIdx};
    fprintf('subject number: %d\n', subIdx);
    
    hemispheres = {'R', 'L'};
    
    clear filter
    
    %get the T1 map
    filter.sub = subLabel;
    filter.suffix = 'T1map';
    filter.acq = 'r0p375';
    filter.desc = 'skullstripped';

    T1map = bids.query(BIDS, 'data', filter);
    T1map = T1map{1};
    
    acq = filter.acq;
    clear filter
    
    for roisIdx = 1:numel(rois)
        
        for hemisIdx = 1:numel(hemispheres)
            
            nlayers = string(1:6);
            filter.label = strcat(rois(roisIdx), 'layer', nlayers);
            filter.desc = '6layers';
            filter.sub = subLabel;
            filter.hemi = hemispheres{hemisIdx};
            filter.modality = 'roi';
            filter.suffix = 'mask';
            filter.prefix = 'r';
            
            listoflayers = bids.query(BIDS, 'data', filter);
            
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
                '_ses-001_acq-' acq '_hemi-' hemispheres{hemisIdx} '_label-' char(rois(roisIdx)) '_desc-T1relaxation.tsv'];
            
            fileName = fullfile(opt.dir.output, ['sub-' subLabel] , 'ses-001', 'anat', outputName);
            
            bids.util.tsvwrite(fileName, T1relax);
        end
    end
end