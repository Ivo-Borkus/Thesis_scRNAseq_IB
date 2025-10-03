Cell Ranger / Cell Ranger-ARC Setup & Execution Guideline
================
Gerard Deuner-Cos
October 1st, 2025

- [Steps Summary](#steps-summary)
  - [Step 1: Environment Setup and FASTQ Preparation (Setup Part
    I)](#step-1-environment-setup-and-fastq-preparation-setup-part-i)
  - [Step 2: Organize FASTQs and Prepare Configurations (Setup Part
    II)](#step-2-organize-fastqs-and-prepare-configurations-setup-part-ii)
  - [Step 3: Metadata, Config and Reference Files
    Generation](#step-3-metadata-config-and-reference-files-generation)
  - [Step 4A: Initialize and Run Cell
    Ranger](#step-4a-initialize-and-run-cell-ranger)
  - [Step 4B: Special Instructions for Cell
    Ranger-ARC](#step-4b-special-instructions-for-cell-ranger-arc)
- [Guideline](#guideline)
  - [Directories Structure](#directories-structure)
  - [Setup Phase](#setup-phase)
    - [Step 1: Environment Setup and FASTQ Preparation (Setup Part
      I)](#step-1-environment-setup-and-fastq-preparation-setup-part-i-1)
    - [Step 2: Organize FASTQs and Prepare Configurations (Setup Part
      II)](#step-2-organize-fastqs-and-prepare-configurations-setup-part-ii-1)
    - [Step 3: Metadata, Config and Reference Files
      Generation](#step-3-metadata-config-and-reference-files-generation-1)
  - [Execution Phase](#execution-phase)
    - [Step 4A: Initialize and Run Cell
      Ranger](#step-4a-initialize-and-run-cell-ranger-1)
    - [Step 4B: Special Instructions for Cell
      Ranger-ARC](#step-4b-special-instructions-for-cell-ranger-arc-1)
    - [Step 5: Clean Up](#step-5-clean-up)

This repository provides a straightforward, two-part pipeline to set up
and run Cell Ranger or Cell Ranger-ARC.

It reduces manual work by:

- Querying LIMS, retrieving FASTQ paths and creating the copy scripts
- Organizing FASTQs into the expected folder structure
- Generating the metadata file
- Generating the config file
- Guiding through the generation of the feature / multiplexing reference
  files
- Running Cell Ranger/Cell Ranger-ARC jobs

------------------------------------------------------------------------

# Steps Summary

### Step 1: Environment Setup and FASTQ Preparation (Setup Part I)

Activate the Cell Ranger conda environment:

``` bash
conda activate /scratch_isilon/groups/singlecell/shared/conda_env/cellranger-env
```

Move to the scripts directory:

``` bash
cd /scratch_isilon/groups/singlecell/shared/software/Guideline/Script_Utils/raw_data_processing/SingleCell/cellranger_auto/
```

Define the variables:

``` bash
PROJECT="PROJ"
SUBPROJECT="PROJ_01_02"
CELLRANGER="cellranger|cellranger-arc"
MULTIPLEXING="none|hto|ocm|cmo|flex"
REFERENCE="human|mouse"
EXPECT_CELLS=5000
```

Run:

``` bash
bash setup_cellranger_part-I.sh $PROJECT $SUBPROJECT $CELLRANGER
```

### Step 2: Organize FASTQs and Prepare Configurations (Setup Part II)

Run:

``` bash
bash setup_cellranger_part-II.sh $PROJECT $SUBPROJECT $CELLRANGER
```

### Step 3: Metadata, Config and Reference Files Generation

**Step 3.1: Create Metadata File**

``` bash
python info2metadata.py --project $PROJECT --subproject $SUBPROJECT --cellranger $CELLRANGER --chemistry auto --expect_cells $EXPECT_CELLS --multiplexing $MULTIPLEXING
```

**Step 3.2: Create Config File Paths Reference File**

``` bash
python generate_config.py --project $PROJECT --subproject $SUBPROJECT --cellranger $CELLRANGER --reference $REFERENCE --multiplexing $MULTIPLEXING
```

**Step 3.3: Create the Multiplexing / Feature References**

``` bash
cd /scratch_isilon/groups/singlecell/data/cellranger_runs/$PROJECT/$SUBPROJECT/$CELLRANGER/data/

vim ${SUBPROJECT}_multi_reference.csv
vim ${SUBPROJECT}_feature_reference.csv
```

### Step 4A: Initialize and Run Cell Ranger

**Step 4A.1: Cell Ranger initialization:**

``` bash
cd /scratch_isilon/groups/singlecell/data/cellranger_runs/$PROJECT/$SUBPROJECT/$CELLRANGER/scripts/

./1_init.py
```

**Step 4A.2: Cell Ranger execution:**

``` bash
./2_run_cellranger.sh
```

### Step 4B: Special Instructions for Cell Ranger-ARC

**Step 4B.1: Cell Ranger ARC requires one additional step before
initialization: create the UMI2 index fastq files.**

``` bash
cd /scratch_isilon/groups/singlecell/data/cellranger_runs/$PROJECT/$SUBPROJECT/cellranger-arc/scripts

# Create ATAC UMI2 Index
bash submit_create_UMI2.sh $PROJECT $SUBPROJECT
```

**Step 4B.2: Then initialize and run cellranger-arc:**

``` bash
bash cellranger_arc_template_adj.sh $PROJECT $SUBPROJECT $REFERENCE
```

------------------------------------------------------------------------

# Guideline

## Directories Structure

The workflow assumes the following directories:

- **Scripts Directory**

      /scratch_isilon/groups/singlecell/shared/software/Guideline/Script_Utils/raw_data_processing/SingleCell/cellranger_auto/

  Contains the setup scripts and Cell Ranger (ARC) pipelines.

- **FASTQ Storage Directory**

      /scratch_isilon/groups/singlecell/data/data_transfer/cellranger_fastqs/<PROJECT>/<SUBPROJECT>/

  Temporary location where raw FASTQs are organized.

- **Cell Ranger Project Output Directory**

      /scratch_isilon/groups/singlecell/data/cellranger_runs/<PROJECT>/<SUBPROJECT>/<cellranger|cellranger-arc>/

  Main analysis folder where the metadata, scripts and outputs are
  stored.

- **Cell Ranger Conda Environment Directory**

      /scratch_isilon/groups/singlecell/shared/conda_env/cellranger-env

  Conda environment with all required packages to run Cell Ranger (ARC).

------------------------------------------------------------------------

#### Scripts Organization

    # Base dir
    /scratch_isilon/groups/singlecell/shared/software/Guideline/Script_Utils/raw_data_processing/SingleCell/cellranger_auto                

    # Structure
    ├── setup/               
    │   ├── setup_cellranger_part-I.sh
    │   ├── setup_cellranger_part-II.sh
    │   └── info2metadata.py 
    │   └── generate_config.py
    │   └── fastq_path.py
    │
    ├── cellranger/          
    │   ├── data
    │   ├── scripts
    │   |   ├── 1_init.sh    
    │   |   ├── 2_run_cellranger.sh
    │   |   ├── 3_merge_metrics_cellranger.py
    │   |   ├── 4_copy_cellranger_websummary.sh
    │   |   ├── 5_copy_cellranger_results.sh
    │   |   ├── 6_QC_CellrangerMapping.Rmd
    │   |   ├── utils.R
    │   └── subprojects
    │
    └── cellranger-arc/      
    │   ├── data
    │   ├── scripts
    │   |   ├── cellranger_arc_template_adj.sh
    │   |   ├── init_arc.py
    │   |   ├── update_symlinks_cellranger-arc.py
    │   |   ├── slurm.template
    │   |   ├── create_UMI2.sh
    │   |   ├── submit_create_UMI2.sh
    │   └── jobs

#### **Folder Descriptions**

- **`setup/`** – Contains scripts to set up the environment to run Cell
  Ranger (ARC).  
- **`cellranger/`** – Template structure transferred to the subproject’s
  directory, including input data (`data/`) and scripts (`scripts/`).  
- **`cellranger-arc/`** – Same as above, but for Cell Ranger ARC
  (multiome).

------------------------------------------------------------------------

## Setup Phase

### Step 1: Environment Setup and FASTQ Preparation (Setup Part I)

Activate the Cell Ranger conda environment

``` bash
conda activate /scratch_isilon/groups/singlecell/shared/conda_env/cellranger-env
```

Move to the scripts directory:

``` bash
cd /scratch_isilon/groups/singlecell/shared/software/Guideline/Script_Utils/raw_data_processing/SingleCell/cellranger_auto/
```

Define the variables:

``` bash
PROJECT="PROJ"
SUBPROJECT="PROJ_01_02"
CELLRANGER="cellranger|cellranger-arc"
MULTIPLEXING="none|hto|ocm|cmo|flex"
REFERENCE="human|mouse"
EXPECT_CELLS=5000
```

- `<project>` → Main project name (e.g., `PROJ`)  
- `<subproject>` → Subproject, supports multiple suffixes (e.g.,
  `PROJ_01_02`)  
- `<cellranger>` → Cellranger modality, either `cellranger` or
  `cellranger-arc`  
- `<multiplexing>` → Multiplexing modality:
  - `none` → No multiplexing
  - `hto` → Hashtag oligos (hashing)
  - `cmo` → 3’ CellPlex
  - `ocm` → On-Chip Multiplexing (OCM)
  - `flex` → Probe-based Flex
- `<reference>` → Species genome reference (e.g., human or mouse)
- `<expect_cells>` → Expected number of recovered cells

Run:

``` bash
bash setup_cellranger_part-I.sh $PROJECT $SUBPROJECT $CELLRANGER
```

**What this script does step by step:**

1.  **Set paths** – Defines base directories for `cellranger_runs`,
    `data_transfer`, and script references.  
2.  **Create project folder** – Under
    `/scratch_isilon/groups/singlecell/data/cellranger_runs/`.  
3.  **Create `copy_fastqs` folder** – Stores generated FASTQ copy
    scripts and info files.  
4.  **Create subproject folder** – Inside the project directory.  
5.  **Copy template pipeline folder** – Copies either `cellranger` or
    `cellranger-arc` template into the subproject.  
6.  **Set up data transfer directory** – Creates
    `<PROJECT>/<SUBPROJECT>` under `data_transfer/cellranger_fastqs`.  
7.  **Query LIMS** – Uses `limsq_p3.py` to generate a sequencing info
    file (`<SUBPROJECT_NAME>_info.txt`).  
8.  **Generate FASTQ path file** – Runs `fastq_path.py` to retrieve the
    FASTQs paths in `<SUBPROJECT_NAME>_fastq_path.txt`.  
9.  **Generate copy script** – Creates
    `<SUBPROJECT_NAME>_copy_script.sh` for transferring FASTQs into the
    data transfer directory.  
10. **Move generated files** – movesmoves all generated files (info,
    paths, copy script) to the `copy_fastqs` directory.

<!-- -->

    ├── /scratch_isilon/groups/singlecell/data/cellranger_runs/<PROJECT>/

    │   ├── copy_fastqs/
    │   |   ├── <SUBPROJECT>_info.txt
    │   |   ├── <SUBPROJECT>_fastq_path.txt
    │   |   ├── <SUBPROJECT>_copy_script.sh
           
    │   ├── <SUBPROJECT>/<CELLRANGER>
    │   |   |   ├── data/
    │   |   |   ├── scripts/
    │   |   |   ├── subprojects|jobs/

**!!At the end, a copy script is ready to fetch FASTQs. Share it in the
data-transfer Slack channel for execution!!**

------------------------------------------------------------------------

### Step 2: Organize FASTQs and Prepare Configurations (Setup Part II)

Run:

``` bash
bash setup_cellranger_part-II.sh $PROJECT $SUBPROJECT $CELLRANGER
```

**What this script does step by step:**

1.  **Create subproject directory within data transfer** – Ensures the
    subproject-specific FASTQ transfer folder exists in
    `data_transfer/cellranger_fastqs`.  

2.  **Identify unique FASTQ prefixes (flowcells)** – Scans for
    `.fastq.gz` files, extracts prefixes, and lists them.  

3.  **Organize FASTQs by flowcell id and lane** – For each prefix,
    creates directories:

        ├── /scratch_isilon/groups/singlecell/data/data_transfer/cellranger_fastqs
        │   ├── PREFIX/1/fastq/
        │   ├── PREFIX/2/fastq/

    Moves `prefix_1*.fastq.gz` into `1/fastq/` and `prefix_2*.fastq.gz`
    into `2/fastq/`.  
    Skips files with unexpected patterns.  

4.  **Print manual next steps** – Instructs the user to:

    - Run `info2metadata.py` to create the metadata CSV.
    - Run `generate_config.py` to customize the Cell Ranger config
      file.  
    - Create `multi_reference.csv` and/or `feature_reference.csv` files
      if needed.

    <!-- -->

        ├── /scratch_isilon/groups/singlecell/data/cellranger_runs/<PROJECT>/<CELLRANGER>

        |   ├── data/
        │   |   ├── <SUBPROJECT>_info.txt
        │   |   ├── <SUBPROJECT>_metadata.csv
        │   |   ├── <SUBPROJECT>_multi_reference.csv
        │   |   ├── <SUBPROJECT>_feature_reference.csv

        |   ├── scripts/
        │   |   ├── config.py
        │   |   ├── ...

5.  **Display execution instructions** – Shows how to run Cell Ranger or
    Cell Ranger ARC depending on the pipeline chosen.

At the end, your FASTQs are organized and ready for Cell Ranger input.

------------------------------------------------------------------------

### Step 3: Metadata, Config and Reference Files Generation

**Step 3.1: Create Metadata File**

``` bash
python info2metadata.py --project $PROJECT --subproject $SUBPROJECT --cellranger $CELLRANGER --chemistry auto --expect_cells $EXPECT_CELLS --multiplexing $MULTIPLEXING
```

#### Parameters

- `--project` → Project name, must match the directory
- `--subproject` → Subproject name
- `--cellranger` → Either `cellranger` or `cellranger-arc`
- `--chemistry` → Library chemistry (often `auto`)
- `--expect_cells` → Expected number of recovered cells
- `--multiplexing` → Multiplexing modality

Generates a metadata CSV inside the project’s `data/` directory.

The generated **metadata CSV** contains the following columns:

| Column | Description |
|----|----|
| **`project`** | The main project name (e.g., `PROJ`) — matches the top-level directory. |
| **`subproject`** | The library-specific subproject suffix (e.g., `PROJ_01`) |
| **`subproject_folder`** | The subproject name — matches the subdirectory name (e.g., `PROJ_01_02`) |
| **`gem_id`** | GEM ID (10x sample identifier, often corresponds to a single sample run). |
| **`library_id`** | Unique identifier for each library (GEX, VDJ, ATAC, etc.). |
| **`library_name`** | Human-readable name of the library (as given in LIMS or project notes). |
| **`library_barcode`** | Barcode or index used for demultiplexing this library. |
| **`type`** | Library type (e.g., `GEX`, `VDJ`, `ATAC`). |
| **`chemistry`** | 10x chemistry used (e.g., `auto`, `SC3Pv3`, `Flex`). |
| **`multiplexing`** | Multiplexing strategy (`none`, `hto`, `cmo`, `ocm`, `flex`). |
| **`expect_cells`** | Approximate expected number of cells for this library. |
| **`batches`** | Batch or lane information (useful if combining multiple runs). |

**Step 3.2: Create Config File Paths Reference File**

``` bash
python generate_config.py --project $PROJECT --subproject $SUBPROJECT --cellranger $CELLRANGER --reference $REFERENCE --multiplexing $MULTIPLEXING
```

#### Parameters

- `--project` / `--subproject` → Same as metadata
- `--cellranger` → Choose pipeline (`cellranger` or `cellranger-arc`)
- `--reference` → Species genome reference (e.g., human or mouse)
- `--multiplexing` → Multiplexing modality

Creates a config.py file used by 1_init.sh to create the actual gem_id
specific config files.

The generated file contains the following variables:

#### Cell Ranger Config Path Reference Variables

##### SUBPROJECT INFO

- `project`: Name of the main project.
- `subproject`: Name of the subproject within the main project.
- `cellranger`: Type of Cell Ranger pipeline (`cellranger` or
  `cellranger-arc`).
- `reference`: Species reference genome (`human` or `mouse`).
- `multiplexing`: Type of multiplexing applied (`hto`, `cmo`, `ocm`,
  `flex`, or `none`).

##### PATHS

- `project_path`: Base path for all files related to the project.
- `subproject_path`: Path specific to the Cell Ranger run for this
  subproject.
- `infofile_path`: Path to the subproject info text file.
- `metadata_path`: Path to the subproject metadata CSV.
- `feature_ref_path`: Path to feature reference CSV (used if
  `multiplexing` is `hto` or `cmo`).
- `multi_ref_path`: Path to multiplexing reference CSV (used if
  `multiplexing` is not `None`).
- `fastq_path`: Location of raw FASTQ files for the project/subproject.
- `probe_set_path`: Path to the probe set reference file for Flex
  experiments.

##### CELLRANGER PATHS

- `cellranger_path`: Path to the Cell Ranger or Cell Ranger-ARC
  executable.
- `slurmtemplate_path`: Path to the SLURM template used for job
  submission.

##### GENOME REFERENCES

- `Mmus_path`: Mouse GEX reference genome path.
- `Mmus_vdj_path`: Mouse VDJ reference genome path (for `cellranger`
  only).
- `Hsapiens_path`: Human GEX reference genome path.
- `Hsapiens_vdj_path`: Human VDJ reference genome path (for `cellranger`
  only).

**Step 3.3: Multiplexing / Feature References**

Depending on the experiment type, you may need:

- **Feature Reference (`<SUBPROJECT>_feature_reference.csv`)**  
  For **HTO** and **CellPlex (CMO)**.

- **Multi Reference (`<SUBPROJECT>_multi_reference.csv`)**  
  For **HTO**, **OCM**, and **Flex**.

**You will find this information in the designated subproject’s tab on
Jira.**

Place these inside (including the header):

``` bash
cd /scratch_isilon/groups/singlecell/data/cellranger_runs/$PROJECT/$SUBPROJECT/$CELLRANGER/data/

vim ${SUBPROJECT}_multi_reference.csv
vim ${SUBPROJECT}_feature_reference.csv
```

#### Example Templates

**HTO Feature Reference (`<SUBPROJECT>_feature_reference.csv`)**

``` csv
id,name,read,pattern,sequence
HTO1,Sample1,Read2,5P,ACGTACGT
HTO2,Sample2,Read2,5P,TGCACTGA
```

**CellPlex CMO Feature Reference
(`<SUBPROJECT>_feature_reference.csv`)**

``` csv
id,name,read,pattern,sequence
CMO301,Sample1,Read2,5P,AGCTTAGC
CMO302,Sample2,Read2,5P,TCGAGTCA
```

**Flex Multi Reference (`<SUBPROJECT>_multi_reference.csv`)**

``` csv
sample_id,probe_barcode_ids,description
Sample1,BC001,Control
Sample2,BC002,Treated
```

**3’ Cellplex CMO Multi Reference (`<SUBPROJECT>_multi_reference.csv`)**

``` csv
sample_id,cmo_ids
Sample1,CMO301
Sample2,CMO302
```

**On-Chip Multiplexing (OCM) Multi Reference
(`<SUBPROJECT>_multi_reference.csv`)**

``` csv
sample_id,ocm_barcode_ids
Sample1,OB1
Sample2,OB2
```

------------------------------------------------------------------------

## Execution Phase

### Step 4A: Initialize and Run Cell Ranger

**Step 4A.1: Cell Ranger initialization:**

``` bash
cd /scratch_isilon/groups/singlecell/data/cellranger_runs/$PROJECT/$SUBPROJECT/$CELLRANGER/scripts/

./1_init.py
```

#### `init.py` Functions

``` python
def file_config_multi_GEX_VDJ(...):
  """
  Creates the Cell Ranger Multi configuration file for GEM IDs with combined Gene Expression (GEX) and V(D)J libraries.
  """

def file_config_multi_GEX_VDJ_hashing(...):
  """
  Creates the Cell Ranger Multi configuration file for GEM IDs with Gene Expression (GEX), V(D)J libraries, and hashing/multiplexing data (e.g., Hashtag Oligos or CellPlex).
  """

def file_config_multi_GEX_cellplex(...):
  """
  Creates the Cell Ranger Multi configuration file for GEM IDs with Gene Expression (GEX) libraries using CellPlex multiplexing barcodes (CMOs).
  """

def file_config_multi_GEX_OCM(...):
  """
  Creates the Cell Ranger Multi configuration file for GEM IDs with Gene Expression (GEX) libraries using OCM (antibody-based) barcodes for multiplexing.
  """

def file_config_multi_Flex(...):
  """
  Creates the Cell Ranger Multi configuration file for GEM IDs with Gene Expression (GEX) libraries using Flex probe sets.
  """
```

**Step 4A.2: Cell Ranger execution:**

``` bash
./2_run_cellranger.sh
```

**Step 4A.3: Get Cell Ranger output:**

Then, you can extract the desired output:

``` bash
# Merge performance metrics of cellranger multi for all libraries -> /results folder
./3_merge_metrics_cellranger.py 

# Copy all the web_summary.html files -> /results/web_summary folder
./4_copy_cellranger_websummary.sh 

# Copy all the output files:
#   web summaries -> /results/web_summary folder
#   filtered matrices -> /results/data_transfer
./5_copy_cellranger_results.sh

# Perform QC of the cell ranger mapping results
6_QC_CellrangerMapping.Rmd
```

------------------------------------------------------------------------

### Step 4B: Special Instructions for Cell Ranger-ARC

**Step 4B.1: Cell Ranger ARC requires one additional step before
initialization: create the UMI2 index fastq files.**

``` bash
cd /scratch_isilon/groups/singlecell/data/cellranger_runs/$PROJECT/$SUBPROJECT/cellranger-arc/scripts

# Create ATAC UMI2 Index
bash submit_create_UMI2.sh $PROJECT $SUBPROJECT
```

Generates the UMI2 index fastq files required by Cell Ranger-ARC. Run
this **before** initializing or launching Cell Ranger ARC.

**Step 4B.2: Then initialize and run cellranger-arc:**

``` bash
bash cellranger_arc_template_adj.sh $PROJECT $SUBPROJECT $REFERENCE
```

------------------------------------------------------------------------

### Step 5: Clean Up

- If necessary, remember that after sharing the web summaries to Jira or
  saving the desired output, please remove the jobs/ directories since
  they take up a lot of space.

- For personal / internal projects, exporting the cellranger_runs
  subproject folder to your directory of interest is recommended.
