# HybFilter

## Description

HybFilter is a pipeline designed to clean and filter the output of the HybPiper targeted-enrichment data analysis suite. Currently, HybFilter consists of four scripts which (1) reorganize the HybPiper base directory, (2) remove sequences from loci files which contain premature termination codons in frame 1, (3) remove loci files which are represented by less than a given proportion of samples, and (4) remove sequences belonging to taxa which are represented by less than a given proportion of loci.

## Required Software

HybFilter has been tested on CentOS Linux release 7.9.2009 using the output of HybPiper 2.1.6.

## Important Note

This pipeline has only been tested as a whole and in order (i.e., 01_cleanHybPiper.sh -> 02_removePtc.sh -> 03_removeLoci.sh -> 04_removeSamples.sh). While all scripts should work individually and out of their expected order, I cannot guarantee this.

## Pipeline Input

### Step 01: cleanHybPiper

To run `01_cleanHybPiper.sh`, you must supply the PATH to your HybPiper base directory and the namelist file used by HybPiper.

```
01_cleanHybPiper.sh -h /PATH/TO/HYBPIPER/DIRECTORY -n /PATH/TO/namelist.txt
```

This script cleans and reorganizes the HybPiper base directory. Four new directories will be created during this process:

```
FAA/
FNA/
FILES/
PARALOGS/
```

All non-empty files in the base directory with the extensions ".FAA" and ".FNA" will be moved into the `FAA/` and `FNA/` directories respectively. Empty files with those extensions will be deleted.
All remaining files (e.g., hybpiper_stats.tsv, namelist.txt, paralog_heatmap.png, paralog_report.tsv) will be moved into the `FILES/` directory.
The directories `paralogs_all/` and `paralogs_no_chimeras/` will be moved into the `PARALOGS/` directory.
Please note that all gene directories in the base directory will be permanently deleted.

### Step 02: removePtc

To run `02_removePtc.sh`, you must supply the PATH to your HybPiper base directory and the PATH to the output directory you prefer your cleaned data to be written to.

```
02_removePtc.sh -h /PATH/TO/HYBPIPER/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY
```

This script removes all sequences from your "FAA" and "FNA" files which contain at least one premature termination codon (ptc) in frame 1. HybPiper denotes such codons with "*" in the FAA files. Three new directories will be created in your output directory during this process:

```
FAA/
FNA/
IDS/
```

All cleaned "FAA" and "FNA" files will be written to `FAA/` and `FNA/` respectively. To denote they have been processed, the suffix "_pR" (ptcs removed) will be added to each file's basename.
The directory `IDS/` will contain one file per locus, each file containing the fasta header(s) of those sequences which had at least one ptc and were removed. Empty files represent loci in which zero sequences had at least one ptc.

### Step 03: removeLoci

To run `03_removeLoci.sh`, you must supply the PATH to your input data directory (the output directory provided in step 02), the PATH to the output directory you prefer your cleaned data to be written to, and the namelist file used by HybPiper. You must also supply a value between 0.00 and 1.00, which represents the proportion of samples in your namelist file that each locus file must have to be written to your output directory.

```
03_removeLoci.sh -i /PATH/TO/INPUT/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY -n /PATH/TO/namelist.txt -p FLOAT
```

For example, if you have:

- 100 samples in your namelist file
- 60 samples represented in LOCUS_01.FAA
- 50 samples represented in LOCUS_02.FAA
- 40 samples represented in LOCUS_03.FAA

and you set `-p 0.50`, LOCUS_01.FAA (60 >= (0.50 * 100)) and LOCUS_02.FAA (50 >= (0.50 * 100)) will be written to your output directory whereas LOCUS_03.FAA (40 < (0.50 * 100)) will not.

Three new directories will be created in your output directory during this process:

```
FAA/
FNA/
IDS/
```

All cleaned "FAA" and "FNA" files will be written to `FAA/` and `FNA/` respectively. To denote they have been processed, the suffix "_lR" (loci removed) will be added to each file's basename.
The directory `IDS/` will contain one file listing those loci which passed the filter and were written to your output directory.

### Step 04: removeSamples

To run `04_removeSamples.sh`, you must supply the PATH to your input data directory (the output directory provided in step 03), the PATH to the output directory you prefer your cleaned data to be written to, and the namelist file used by HybPiper. You must also supply a value between 0.00 and 1.00, which represents the proportion of loci each sample must have to have in order for its sequences to be retained in your output loci files.

```
04_removeSamples.sh -i /PATH/TO/INPUT/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY -n /PATH/TO/namelist.txt -p FLOAT
```

For example, if you have:

- 100 loci in your Step 03 output directories
- 60 loci assembled from Species_A
- 50 loci assembled from Species_B
- 40 loci assembled from Species_C

and you set `-p 0.50`, all sequences belonging to Species_A (60 >= (0.50 * 100)) and Species_B (50 >= (0.50 * 100)) will be retained in your output loci files whereas all sequences beloning to Species_C (40 < (0.50 * 100)) will be removed from your output loci files.

Three new directories will be created in your output directory during this process:

```
FAA/
FNA/
IDS/
```

All cleaned "FAA" and "FNA" files will be written to `FAA/` and `FNA/` respectively. To denote they have been processed, the suffix "_sR" (samples removed) will be added to each file's basename.
The directory `IDS/` will contain one file listing those samples which passed the filter and whose sequences were retained in your output loci files.

## Rationale

### 01_cleanHybpiper.sh

This script was written primarily to make the data written to the HybPiper base directory easier to navigate. An added benefit, especially for HPC users, is that the removal of the gene directories also frees up substantial disk space and inode allocation.

### 02_removePtc.sh

This script was written primarily to remove sequences containing premature termination codons (ptc). Although many such ptc may be artifacts, the product of sequencing or assembly errors, those which are real could imply that the sequences containing them are pseudogenes. In the context of a standard phylogenetic analysis, such data might not only be low-signal, but high-noise due to relaxed selection. This could, of course, be tested on a sequence-by-sequence basis and clearly pseudogenized sequences filtered out; this approach represents a blunt yet effective one for handling such data.

### 03_removeLoci.sh

This script was written primarily to remove loci which are represented by a small proportion of the total samples analyzed via HybPiper. Imagine a locus represented by only 10 of the 100 samples analyzed by HybPiper. That locus will thus be comprised of at least 90% ambiguous data distributed across 90% of the samples in the final phylogenetic analysis. Especially if we assume the species for which sequences did not assemble do actually possess that locus in their genomes, the inclusion of such a locus has the potential to introduce noise and uncertainty into the analysis. Amplified across multiple sparsely-assembled loci, the potential to introduce substantial noise and uncertainty exists. This is an issue that must be considered when working with hDNA in museomics contexts especially; the lack of sequence assembly could be related to several factors such as specimen storage conditions, specimen age, mistakes made during DNA extraction, library preparation, sequencing, etc.

### 04_removeSamples.sh

This script was written primarily to remove samples which are represented by a small proportion of the total loci assembled via HybPiper. Imagine a sample represented by only 10 of the 100 loci assembled by HybPiper. That sample will thus be comprised of a substantial proportion of ambiguous data in the final phylogenetic analysis. Especially if we assume such a sample does actually possess most of those 100 loci in its genome, the inclusion of such a sample has the potential to introduce noise and uncertainty into the analysis. Amplified across multiple loci-poor samples, the potential to introduce substantial noise and uncertainty exists. This is an issue that must be considered when working with hDNA in museomics contexts especially; the lack of sequence assembly could be related to several factors such as specimen storage conditions, specimen age, mistakes made during DNA extraction, library preparation, sequencing, etc.
