# MP2RAGE T1 relaxation in the layers

## Analysis steps
0. Install the following subdatasets in `inputs`:

        1. `bidsNighres`: 'git@gin.g-node.org:/cpp_brewery/analysis_V5_high-res_pilot_nighres.git'
        2. `cpp_spm-preproc`: 'git@gin.g-node.org:/marcobarilari/analysis_high-res_MP2RAGE-layers_derivatives_cpp_spm-preproc.git'
        3. `laynii-layers`: 'git@gin.g-node.org:/marcobarilari/analysis_high-res_MP2RAGE-layers_derivatives_laynii.git'
        4. `raw`: 'git@gin.g-node.org:/RemiGau/V5_high-res_pilot-1_raw.git'

** Create sibling for `bidsNighRes` because we could not get any dataset content with 'datalad get' in `inputs/bidsNighRes`. Issue to be fixed in the future. Sibling named 'local-copy'.

1.  Edit the subjects in `get_option_rois.m` before running `bidsCreateROI.m`

2. Manually copy files using the terminal: `copy -L path/to/file path/to/folder` (0p375mm UNIT1, Deformation field, Brain mask, Layers, T1 map)

3. Run first part of `PipelineMP2RAGET1Layers.m`

4. Plot relaxation profiles in the layers using `T1relax.R`.

## Log of steps
1. Update `get_option_rois.m`:

        Change subject label in opt.subjects before running `bidsCreateROI.m` since this function does not run correctly for multiple subjects (to fix).

2. Manually copy files using the terminal: `copy -L path/to/file path/to/folder` for each subject (if not done before, get the content of interest using the terminal: `datalad get 'path/to/file'`):

        Look for the following patterns in `inputs/cpp_spm-preproc/sub-'subLabel'/ses-001` and copy them to `outputs/derivatives/cpp_spm-roi/sub-'subLabel'/ses-001/roi`

            1. 0p375mm UNIT1:`*acq-r0p375_desc-skullstripped_space-individual_UNIT1.nii`
            2. Deformation field: `*from-IXI549Space_to-UNIT1.nii`
            3. Brain mask: `*brain_mask.nii`

        Look for the following patterns in ``inputs/laynii-layers/sub-'subLabel'/ses-001/layers`` and copy them to `outputs/derivatives/cpp_spm-roi/sub-'subLabel'/ses-001/roi`

            3. Layers: `*6layer_mask_layers_equidist.nii.gz*`

        Look for the following patterns in `temptodelete/MP2RAGE_T1_layers/inputs/bidsNighRes/sub-'subLabel'/ses-001/anat` to `outputs/derivatives/cpp_spm-roi/sub-'subLabel'/ses-001/anat`:

            4. T1 map: `*acq-r0p375_desc-skullstripped_T1map.nii`

3. Run first part of `PipelineMP2RAGET1Layers.m` (Run until the script `extractT1Layers.m`)
        Ensure that the following variables were changed:
                `createBrainMaskT1map.m`:
                    filter.acq = 'r0p375';
                    filter.ses = '001';

                `intercept_ROI_and_brainmask.m`:
                    filter.ses = '001';
                    filter.acq = 'r0p375';



# QUALITY CONTROL METRICS
The quantitative assessment of MP2RAGE was performed for T1-weighted images (UNIT1) and T1 maps at raw resolution (0p75 mm). 

## Analysis steps

0. Ensure that the following subdatasets are installed in inputs:
        1. `bidsNighres`: 'git@gin.g-node.org:/cpp_brewery/analysis_V5_high-res_pilot_nighres.git'
        2. `raw`: 'git@gin.g-node.org:/RemiGau/V5_high-res_pilot-1_raw.git'

1. Update `get_option_preproc.m`.

2. Manually copy files using the terminal

3. Run Freesurfer segmentation for raw resolution

4. Run second part of `PipelineMP2RAGET1Layers.m` (quality control metrics)

## Log of steps

1. Update `get_option_preproc.m`

        Some defaults that might need to be changed:

            opt.bidsFilterFile.t1w.ses = '001'; (change for different sessions)
            opt.subjects = {'pilot001', 'pilot004', 'pilot005'};

2. Manually copied files using the terminal: `copy -L path/to/file path/to/folder` for each subject from `inputs/raw/sub-'subLabel'/ses-''/anat/`

        - UNIT1: `sub-'subLabel'_ses-001_acq-r0p75_UNIT1.nii`

    and copy from `inputs/bisNighres/sub-'subLabel'/ses-''/anat/` for each subject:

        - T1 map: `sub-'subLabel'_ses-''_acq-r0p75_desc-skullstripped_T1map.nii`

3.  Run Freesurfer segmentation for raw resolution
    1. Convert `aseg.mgz` to `aseg.nii` using `mri_convert_mgz.sh`.
             Change the paths in `mri_convert_mgz.sh` and run it.
    2. Rename `aseg.nii` according to BIDS format to `sub-pilot001_ses-001_acq-r0p75_aseg.nii`
    3. Reslice `sub-pilot001_ses-001_acq-r0p75_aseg.nii` to UNIT1 dimensions and orientations

4. Run second part of `PipelineMP2RAGET1Layers.m` (quality control metrics)

        Ensure that the following variables were changed:

            `SpatialPreproc.m`
                filter.ses = '001'; (change for different sessions)
                This script runs for the first anat file if finds, which is the file of interest for us (function `getAnatFilename`). to fix!
            `interceptUNIT1andBrainMask.m`:
                filter.ses = '001';
            `createBrainMaskT1map.m`:
                filter.acq = 'r0p75';
                filter.ses = '001' %change this filter according to the % session of interest
            `intercept_ROI_and_brainmask.m`:
                filter.acq = 'r0p75';
            `resliceAsegAutoToUNIT1.m`
                filter.acq = 'r0p75'
                filter.ses = '001'
            `intercept_aseg_brainmask.m`
                filter.ses = '001'
            `createMaskForegroundWMGMAseg.m`
                Freesurfer WM and GM labels:
                    WM: 2(Left), 41 (Right)
                    GM: 3(Left), 42 (Right)

    ### Log first steps done to estimate Signal loss

            - Find 3d ex vivo brain in MNI space (0.5 mm resolution). Database: Alkemade et al. 2022, DOI: 10.1126/sciadv.abj7892)
            - Normalise both ex vivo MNI brains to pilot001 space and coregister, using the inverse normalisation parameters
