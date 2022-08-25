# MP2RAGE T1 relaxation in the layers

## Analysis steps
0. Install the following subdatasets in `inputs`:

        1. `bidsNighres`: 'git@gin.g-node.org:/cpp_brewery/analysis_V5_high-res_pilot_nighres.git'
        2. `cpp_spm-preproc`: 'git@gin.g-node.org:/marcobarilari/analysis_high-res_MP2RAGE-layers_derivatives_cpp_spm-preproc.git'
        3. `laynii-layers`: 'git@gin.g-node.org:/marcobarilari/analysis_high-res_MP2RAGE-layers_derivatives_laynii.git'
        4. `raw`: 'git@gin.g-node.org:/RemiGau/V5_high-res_pilot-1_raw.git'

** Create sibling for `bidsNighRes` because we could not do 'datalad get' in `inputs/bidsNighRes`. Issue to be fixed in the future. Sibling named 'local-copy'.

Done for pilot001, pilot004 and pilot005:

        1. Edit the subjects in `get_option_rois.m` to run `bidsCreateROI.m`

        2. For each of the scripts or functions in `PipelineMP2RAGET1Layers.m`, the files were copied manually to `outputs/derivatives/cpp_spm-roi/sub-subLabel/ses-001/` (`.../anat/` or `.../roi/`)

        3. Run part 1 of `PipelineMP2RAGET1Layers.m`

        4. Plot relaxation profiles in the layers using `T1relax.R`.

1.  Update `get_option_rois.m`

2. Manually copy files using the terminal: `copy -L path/to/file path/to/folder` (0p375mm UNIT1, Deformation field, Brain mask, Layers, T1 map)

3. Run first part of `PipelineMP2RAGET1Layers.m`

## Log of steps
1. Update `get_option_rois.m`:

        Some defaults that might need to be changed:
        - opt.subjects = {pilot001, pilot004, pilot005};

        The next options were altered in the script `PipelineMP2RAGET1Layers.m` to run `bidsCreateROI.m`

        - opt.subjects = {pilot001, pilot004, pilot005}; (one subject per run)
        - opt.roi.atlas = 'wang';
        - opt.roi.name = {'V1v', 'V1d'};

        Changed to:

        - opt.roi.atlas = 'visfAtlas';
        - opt.roi.name = {'mFus', 'pFus', 'CoS'};

        ** bidsCreateROI.m runs for all ROIs in the `group` folder -> to fix!

2. Manually copied files using the terminal: `copy -L path/to/file path/to/folder` for each subject (if not done before, get the content of interest using the terminal: `datalad get 'path/to/file'`):

        Look for the following patterns in `inputs/cpp_spm-preproc/sub-'subLabel'/ses-001` and copy them to `outputs/derivatives/cpp_spm-roi/sub-'subLabel'/ses-001/roi`

            1. 0p375mm UNIT1:`*acq-r0p375_desc-skullstripped_space-individual_UNIT1.nii`
            2. Deformation field: `*from-IXI549Space_to-UNIT1.nii`
            3. Brain mask: `*brain_mask.nii`

        Look for the following patterns in ``inputs/laynii-layers/sub-'subLabel'/ses-001/layers`` and copy them to `outputs/derivatives/cpp_spm-roi/sub-'subLabel'/ses-001/roi`

            3. Layers: `*6layer_mask_layers_equidist.nii.gz*`

        Look for the following patterns in `temptodelete/MP2RAGE_T1_layers/inputs/bidsNighRes/sub-'subLabel'/ses-001/anat` to `outputs/derivatives/cpp_spm-roi/sub-'subLabel'/ses-001/anat`:

            4. T1 map: `*acq-r0p375_desc-skullstripped_T1map.nii`

3. Run script until `extractT1Layers.m`
        Ensure that the following variables were changed:

                `resliceLayersToROi.m`:
                    filter.acq = 'r0p375';
                `resliceRoiToBrainmask.m`:
                    filter.label = {'V1d', 'V1v', 'v1v', 'v1d', 'pFus', 'mFus', 'CoS'};
                    filter.ses = '001';
                    filter.acq = 'r0p375';
                `intercept_ROI_and_brainmask.m`:
                    filter.ses = '001';
                    filter.acq = 'r0p375';


# QUALITY CONTROL METRICS

## Analysis steps

0. Install the following subdataset in inputs:

        Freesurfer outputs: https://github.com/marcobarilari/analysis_high-res_pilot_freesurfer-laynii.git

1. Create new folder inside `outputs/derivatives` called `cpp_spm-roi_acq-0p75`.

        SNR was estimated for pilot001, pilot004 and pilot005. Coefficient of variation was estimated for pilot004 and pilot005.

2. Update `get_option_preproc.m`.

3. Manually copy files using the terminal

4. Convert `aseg.auto_noCCseg.mgz` to `aseg.auto_noCCseg.nii.gz` using `mri_convert_mgz.sh`

5. Reslice `aseg.auto_noCCseg.nii.gz` to UNIT1 0.75 mm resolution and dimensions

6. Run second part of `PipelineMP2RAGET1Layers.m` (quality control metrics)

## Log of steps

2. Update `get_option_preproc.m`

        Some defaults that might need to be changed:

            opt.bidsFilterFile.t1w.ses = '001'; (change for different sessions)
            opt.subjects = {'pilot001', 'pilot004', 'pilot005'}; (delete pilot001 to run CoV)


3. Manually copied files using the terminal: `copy -L path/to/file path/to/folder` for each subject from `inputs/raw/sub-'subLabel'/ses-''/anat/`

        - UNIT1: `sub-'subLabel'_ses-001_acq-r0p75_UNIT1.nii`

    and copy from `inputs/bisNighres/sub-'subLabel'/ses-''/anat/` for each subject:

        - T1 map: `sub-'subLabel'_ses-''_acq-r0p75_desc-skullstripped_T1map.nii`

    and copy from `freesurfer/sub-'subLabel'/ses-001/anat/mri` for each subject:

        - Segmentation map: `aseg.auto_noCCseg.mgz`

    to `outputs/derivatives/cpp_spm-roi_acq-0p75/sub-'subLabel'/ses-''/anat` (if not done before, get the content of interest using the terminal: `datalad get 'path/to/file'`, for T1 map do `datalad unlock` since the coregistration will change the header of the file)

4. Convert `aseg.auto_noCCseg.mgz` to `aseg.auto_noCCseg.nii.gz`using `mri_convert_mgz.sh`. Change the paths in this file and run it.

6. Run second part of `PipelineMP2RAGET1Layers.m` (quality control metrics)

        Ensure that the following variables were changed:

            `SpatialPreproc.m`
                filter.ses = '001'; (change for different sessions)
            `interceptUNIT1andBrainMask.m`:
                filter.ses = '001';
            `resliceRoiToBrainmask.m`:
                filter.ses = '001';
                filter.acq = 'r0p75'
                comment filter.label
            `resliceAsegAutoToUNIT1.m`
                filter.ses = '001'
            `intercept_aseg_brainmask.m`
                filter.ses = '001'
            `createMaskCsfWmGmFromFreeSurferAseg.m`
                - check that FreeSurfer map numbers are the following:
                    CSF:24
                    WM: 2(Left), 41 (Right)
                    GM: 3(Left), 42 (Right)
            `extract_snr_from_roi.m`
                filter.ses = '001'

        SpatialPreproc: it runs for the first anat file if finds, which is the file of interest for us (function `getAnatFilename`). to fix!

    ### Log first steps done to estimate Signal loss

            - download both 3d ex vivo brains in MNI space (0.5 mm resolution) from the database (Alkemade et al. 2022, DOI: 10.1126/sciadv.abj7892))
            - Normalise both ex vivo MNI brains to pilot001 space and coregister, using the inverse normalisation parameters
