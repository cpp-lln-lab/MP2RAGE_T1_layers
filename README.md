[![made-with-datalad](https://www.datalad.org/badges/made_with.svg)](https://datalad.org)

# Project MP2RAGE_T1_layers

This is the YODA dataset for estimating T1 laminar profiles from MP2RAGE images. WIP

## Data Source after removing Datalad subdatasets

`.gitmodules` content omitting code submodules:

```bash
[submodule "outputs/derivatives"]
	path = outputs/derivatives
	url = git@gin.g-node.org:/cpp_brewery/MP2RAGE_T1_layers_derivatives.git
	datalad-id = 2ca260f5-1d2b-4273-9d2f-6072d4d1945a
[submodule "inputs/bidsNighres"]
	path = inputs/bidsNighres
	url = git@gin.g-node.org:/cpp_brewery/analysis_V5_high-res_pilot_nighres.git
	datalad-id = 0168c8a1-949c-4f06-885f-0fa72925cedc
[submodule "inputs/cpp_spm-preproc"]
	path = inputs/cpp_spm-preproc
	url = git@gin.g-node.org:/marcobarilari/analysis_high-res_MP2RAGE-layers_derivatives_cpp_spm-preproc.git
	datalad-id = d39b0b30-153b-4595-936a-6771f67310f0
	datalad-url = git@gin.g-node.org:/marcobarilari/analysis_high-res_MP2RAGE-layers_derivatives_cpp_spm-preproc.git
[submodule "inputs/laynii-layers"]
	path = inputs/laynii-layers
	url = git@gin.g-node.org:/marcobarilari/analysis_high-res_MP2RAGE-layers_derivatives_laynii.git
	datalad-id = 53cd3d3e-d2fa-4054-bb69-07869f683d6a
	datalad-url = git@gin.g-node.org:/marcobarilari/analysis_high-res_MP2RAGE-layers_derivatives_laynii.git
[submodule "inputs/raw"]
	path = inputs/raw
	url = git@gin.g-node.org:/RemiGau/V5_high-res_pilot-1_raw.git
	datalad-id = 9f77e14c-ff39-4a80-9121-916e5892e2b4
	datalad-url = git@gin.g-node.org:/RemiGau/V5_high-res_pilot-1_raw.git
```

## DataLad datasets and how to use them

<!-- BELOW IS THE TEMPLATE README FOR DATALAD DATASET

MODIFY AT WILL

 -->

This repository is a [DataLad](https://www.datalad.org/) dataset. It provides
fine-grained data access down to the level of individual files, and allows for
tracking future updates. In order to use this repository for data retrieval,
[DataLad](https://www.datalad.org/) is required. It is a free and open source
command line tool, available for all major operating systems, and builds up on
Git and [git-annex](https://git-annex.branchable.com/) to allow sharing,
synchronizing, and version controlling collections of large files. You can find
information on how to install DataLad at
[handbook.datalad.org/en/latest/intro/installation.html](http://handbook.datalad.org/en/latest/intro/installation.html).

### Get the dataset

A DataLad dataset can be `cloned` by running

```
datalad install <url>
```

Once a dataset is cloned, it is a light-weight directory on your local machine.
At this point, it contains only small metadata and information on the identity
of the files in the dataset, but not actual _content_ of the (sometimes large)
data files.

### Retrieve dataset content

After cloning a dataset, you can retrieve file contents by running

```
datalad get <path/to/directory/or/file>`
```

This command will trigger a download of the files, directories, or subdatasets
you have specified.

DataLad datasets can contain other datasets, so called _subdatasets_. If you
clone the top-level dataset, subdatasets do not yet contain metadata and
information on the identity of files, but appear to be empty directories. In
order to retrieve file availability metadata in subdatasets, run

```
datalad get -n <path/to/subdataset>
```

Afterwards, you can browse the retrieved metadata to find out about subdataset
contents, and retrieve individual files with `datalad get`. If you use
`datalad get <path/to/subdataset>`, all contents of the subdataset will be
downloaded at once.

### Stay up-to-date

DataLad datasets can be updated. The command `datalad update` will _fetch_
updates and store them on a different branch (by default
`remotes/origin/master`). Running

```
datalad update --merge
```

will _pull_ available updates and integrate them in one go.

### Find out what has been done

DataLad datasets contain their history in the `git log`. By running `git log`
(or a tool that displays Git history) in the dataset or on specific files, you
can find out what has been done to the dataset or to individual files by whom,
and when.

### More information

More information on DataLad and how to use it can be found in the DataLad
Handbook at
[handbook.datalad.org](http://handbook.datalad.org/en/latest/index.html). The
chapter "DataLad datasets" can help you to familiarize yourself with the concept
of a dataset.
