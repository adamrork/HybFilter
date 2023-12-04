# HybFilter

Current version: 1.0 (November 2023)

## Description

HybFilter is a suite of tools designed to clean and filter the output of the HybPiper targeted enrichment data analysis pipeline. HybFilter consists of four scripts:

```
01_cleanHybpiper.sh cleans and reorganizes the HybPiper base directory.  
02_removePtc.sh removes sequences from gene files which contain premature termination codons.  
03_removeGenes.sh removes gene files represented by less than a given proportion of samples.  
04_removeSamples.sh removes all sequences belonging to samples represented by less than a given proportion of genes.
```


## Software Requirements

HybFilter has been tested on the output of the HybPiper 2.1.6 pipeline. For the purposes of HybFilter, the full HybPiper pipeline consists of the following commands:

```
1.  hybpiper assemble  
2.  hybpiper stats  
3.  hybpiper recovery_heatmap  
4a. hybpiper retrieve_sequences ... aa ...  
4b. hybpiper retrieve_sequences ... dna ...  
5.  hybpiper paralog_retriever
```

It is recommended that you run all of the above commands before using the HybFilter scripts.

HybFilter has been tested on CentOS Linux (release 7.9.2009).

## Sample Naming Convention

It is strongly recommended that your sample names contain only alphanumeric characters with underscores or hyphens seperating words. Your sample names should not contain any of the following characters:

```
" " whitespaces / tabs
">" greater-than signs
"*" asterisks
":" colons
```

## Using the HybFilter Pipeline

### Step 01: Reorganize your HybPiper directory

To run `01_cleanHybpiper.sh`, you must supply the PATH to your HybPiper base directory and the namelist file used by HybPiper.

```
01_cleanHybpiper.sh -h /PATH/TO/HYBPIPER/DIRECTORY -n /PATH/TO/namelist.txt
```

This script reorganizes the HybPiper base directory. Four new directories will be created during this process:

```
FAA/
FNA/
FILES/
PARALOGS/
```

All non-empty files in the base directory with the extensions ".FAA" and ".FNA" will be moved into the `FAA/` and `FNA/` directories respectively. Empty files with those extensions will be deleted. All remaining files (e.g., hybpiper_stats.tsv, namelist.txt, paralog_heatmap.png, paralog_report.tsv) will be moved into the `FILES/` directory. The directories `paralogs_all/` and `paralogs_no_chimeras/` will be moved into the `PARALOGS/` directory. Please note that all sample directories in the base directory will be permanently deleted.

### Step 02: Remove sequences containing premature termination codons

To run `02_removePtc.sh`, you must supply the PATH to your HybPiper base directory and the PATH to the output directory you prefer your cleaned data to be written to. You must have "FAA" files for this script to work.

```
02_removePtc.sh -h /PATH/TO/HYBPIPER/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY
```

This script removes all sequences from your "FAA" and "FNA" files which contain at least one premature termination codon in frame 1. Three new directories will be created in your output directory:

```
FAA/
FNA/
IDS/
```

All cleaned "FAA" and "FNA" files will be written to `FAA/` and `FNA/` respectively. Processed files will have the suffix "_pR" (ptcs removed) appended to their basename. The directory `IDS/` will contain one file per gene, each containing the fasta header(s) of those sequences containing premature termination codons. Empty files represent genes in which zero sequences had at least one ptc.

### Step 03: Remove genes containing below a certain proportion of samples

To run `03_removeGenes.sh`, you must supply the PATH to your input data directory (the output directory provided in step 02), the PATH to the output directory you prefer your cleaned data to be written to, and the namelist file used by HybPiper. You must also supply a value between 0.00 and 1.00, which represents the proportion of samples in your namelist file that each gene file must have to be written to your output directory.

```
03_removeGenes.sh -i /PATH/TO/INPUT/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY -n /PATH/TO/namelist.txt -p FLOAT
```

For example, if you have

- 100 samples in your namelist file
- 60 samples represented in GENE_01.FAA
- 50 samples represented in GENE_02.FAA
- 40 samples represented in GENE_03.FAA

and you set `-p 0.50`, GENE_01.FAA and GENE_02.FAA will be written to your output directory whereas GENE_03.FAA will not. Three new directories will be created in your output directory:

```
FAA/
FNA/
IDS/
```

All cleaned "FAA" and "FNA" files will be written to `FAA/` and `FNA/` respectively. Processed files will have the suffix "_gR" (genes removed) appended to their basename. The directory `IDS/` will contain one file listing each gene which passed the filter and were written to your output directory.

### Step 04: Remove samples containing below a certain proportion of genes

To run `04_removeSamples.sh`, you must supply the PATH to your input data directory (the output directory provided in step 03), the PATH to the output directory you prefer your cleaned data be written to, and the namelist file used by HybPiper. You must also supply a value between 0.00 and 1.00, which represents the proportion of genes each sample must have to have in order for its sequences to be retained in your output gene files.

```
04_removeSamples.sh -i /PATH/TO/INPUT/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY -n /PATH/TO/namelist.txt -p FLOAT
```

For example, if you have

- 100 genes in your Step 03 output directories
- 60 genes assembled from Species_A
- 50 genes assembled from Species_B
- 40 genes assembled from Species_C

and you set `-p 0.50`, all sequences belonging to Species_A and Species_B will be retained in your output gene files whereas all sequences beloning to Species_C will be removed from your output gene files. Three new directories will be created in your output directory:

```
FAA/
FNA/
IDS/
```

All cleaned "FAA" and "FNA" files will be written to `FAA/` and `FNA/` respectively. Processed files will have the suffix "_sR" (samples removed) appended to their basename. The directory `IDS/` will contain one file listing those samples which passed the filter and whose sequences were retained in your output gene files.
