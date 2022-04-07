# MP2RAGE T1 realxation in the layers

## Analyses steps

0. Assuming that `T1map`, `MP2RAGE segmentation` and `Layers` grown on the MP2RAGE are already processed in `inputs/bidsNighres`. We will require upsampling the MP2RAGE resolution from 0.75 mm to eg 0.25 mm [WIP]

1. SPM anatomical segmentation and deformation field for normalisation via `bidsSegmentSkullStrip.m`

2. Define V1 Roi from atlas in MNI space

3. Apply ROIs in MNI space to individual space

4. Put together ROI and layers and create single masks

5. Exctrat T1 relaxation from `T1map` from each mask and save in a `tsv`

6. Repeat in each subject

7. Plot relaxation profiles in the layers
