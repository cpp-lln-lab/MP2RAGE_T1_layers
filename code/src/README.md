# MP2RAGE T1 relaxation in the layers

## Analyses steps
0. Create sibling for `MP2RAGE_T1_layers` because we could not do 'datalad get' in `inputs/bidsNighRes`. Issue to be fixed in the future.

Done for sub-pilot001, sub-pilot004 and sub-pilot005:

1. UNIT1, deformation field and layers copied manually (running in the terminal `copy -L path/to/file path/to/folder`) to the derivatives folder, for each subject:
    - UNIT1 (`*desc-skullstripped_space-individual_UNIT1.nii`) and deformation field (`*from-IXI549Space_to-UNIT1*`) copied from `inputs/cpp_spm-preproc/sub-'subLabel'/ses-001` to `outputs/derivatives/cpp_spm-roi/sub-subLabel/ses-001/ROI`

Done for sub-pilot004 and sub-pilot005 (no layers for sub-pilot001 yet):

    - Layers file (`*6layer_mask_layers_equidist.nii.gz*`) copied from `inputs/laynii-layers/sub-'subLabel'/ses-001/layers` to `outputs/derivatives/cpp_spm-roi/sub-'subLabel'/ses-001/ROI`
    - T1 map copied manually from `temptodelete/MP2RAGE_T1_layers/inputs/bidsNighRes/sub-'subLabel'/ses-001/anat` to `outputs/derivatives/cpp_spm-roi/sub-'subLabel'/ses-001/anat`

2. Run `creation_V1mask.m`.

Done for SubLabel= {pilot001, pilot004, pilot005}.
Changes made to `outputs/derivatives/cpp_spm-roi/sub-'SubLabel'`
- `sub-'SubLabel'/ses-001/ROI` changed to `sub-'SubLabel'/ses-001/roi`
- `sub-'SubLabel'/ses-001/roi` renamed to `sub-'SubLabel'/ses-001/anat`
- `sub-'SubLabel'/roi` moved to `sub-'SubLabel'/ses-001/anat`
- outputs of `bidsCreateRoi.m` renamed manually accordingly to BIDS format (Informaion about the session was missing, `ses-001` added to the filename).
- outputs of `mergeMasks.m` renamed manually 
- Layers file moved to `sub-'SubLabel'/ses-001/roi`

Done for SubLabel= {pilot005}
2. Reslice layers file to UNIT1 dimensions (has the same dimension as the individual mask) using `resliceLayersToRoi.m`

3. Put together ROI and layers and create single masks using `createLayerMaskROIs.m`. Single masks saved in `sub-'SubLabel'/ses-001/roi`

3. `sub-'SubLabel'_ses-001_acq-r0p375_T1map.nii.gz` copied manually from `bidsNighres/sub-'SubLabel'/anat/` to `outputs/derivatives/cpp_spm-roi/sub-'SubLabel'/ses-001/anat`

4. Extract T1 relaxation from `T1map` from each layer mask and save in a `tsv` using `src/extractT1/ExtractT1Layers.m`

6. Plot relaxation profiles in the layers.

5. Repeat for SubLabel= {pilot001, pilot004}.

6. Repeat everything from step 2. for visfAtlas ROIs: pFus, mFus and CoS.


## Log of steps
2. Run `creation_V1mask.m`. The next steps are completed within this script:

    1. Define V1 ROI from atlas in MNI space using `bidsCreateRois.m` and converted to individual space
        - Default atlas is `Wang`. Four partial masks (left and right, dorsal and ventral) are created in MNI space; 
        - Partial masks are converted to individual space.

    2. Partial ROIs are merged using `mergeMasks.m`.

- Issue submitted on Github to fix bidsCreateROIs.m output format.

3. Put together ROI and layers and create single masks.

working on sub-pilot005:

    1. create interception of v1 mask and layers



    2. Create 1 mask per layer



