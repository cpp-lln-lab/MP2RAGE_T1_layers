# MP2RAGE T1 realxation in the layers

## Analyses steps

1. UNIT1, deformation field and layers (`*6layer_mask_layers_equidist.nii.gz*`) copied manually (`copy -L path/to/file path/to/folder`) to the derivatives folder, for each subject.

2. Run `creation_V1mask.m`. The next steps are completed within this script:

    1. Define V1 ROI from atlas in MNI space using `bidsCreateRois.m` and converted to individual space
        - Default atlas is `Wang`. Four partial masks (left and right, dorsal and ventral) are created in MNI space; 
        - Partial masks are converted to individual space.

    2. Partial ROIs are merged using `mergeMasks.m`.

3. Put together ROI and layers and create single masks.

4. Extract T1 relaxation from `T1map` from each mask and save in a `tsv` using `spm_summarize.m`

5. Repeat in each subject.

6. Plot relaxation profiles in the layers.