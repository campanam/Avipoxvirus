# Avipoxvirus

Michael G. Campana and Madeline W. Eibner-Gebhardt, 2023-2024  
Smithsonian's National Zoo and Conservation Biology Institute  

Pipeline to identify *Avipoxvirus* sequences in DNA libraries  

## Citation  
Eibner-Gehbardt MW, Fleischer RC, Campana MG. In prep. A historical Hawaiian Avipoxvirus genome reconstructed from an 1898 museum specimen.  

## License  

## Input  
The pipeline requires a directory of bidirectionally sequenced DNA libraries in FASTQ format. The pipeline expects the forward and reverse reads in separate files. Second, the pipeline requires a CSV file assigning the read files to libraries with the following format:  

Library,Read1,Read2,Adapter1,Adapter2  
\<library1 name>\,\<path to library1 read1\>,\<path to library1 read2\>,\<library1 adapter1 sequence\>,\<library1 adapter2 sequence\>  
\<library2 name>\,\<path to library2 read1\>,\<path to library2 read2\>,\<library2 adapter1 sequence\>,\<library2 adapter2 sequence\>  

Additionally, the pipeline requires access to a local copy of the NCBI non-redundant nucleotide database ('nt') as well as a custom *Avipoxvirus* genomic blast database. See Eibner-Gehbardt et al. for details on compiling the *Avipoxvirus* genome database.  

## Installation  
The pipeline requires [Nextflow](https://www.nextflow.io/). The pipeline can automatically install the dependencies using [Conda](https://conda.io). After installing Nextflow and Conda, install the pipeline with the command:  
`nextflow pull campanam/Avipoxvirus -r main`  

## Dependencies  
If you cannot install the dependencies automatically using the Conda, please install the following software packages:  

AdapterRemoval v. 2.3.3 [(1)](https://github.com/MikkelSchubert/adapterremoval)  
Seqtk v. 1.4 [(2)](https://github.com/lh3/seqtk)  
CD-HIT v. 4.8.1 [(3)](https://sites.google.com/view/cd-hit)  
BLAST+ v. 2.13.0 [(4)](https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html)  
MEGAN - Community Edition v. 6.24.20 [(5)](https://github.com/husonlab/megan-ce)  

## Pipeline Configuration  
We recommend copying and modifying the `nextflow.config` file included in this directory. A profile ('hydra') describing the configuration and Conda recipes used in Eibner-Gebhardt et al. is included in the `nextflow.config` file. Please consult the Nextflow documentation to configure the pipeline for your system.  

Configurable parameters needed for the pipeline are:

inputCsv: Path to the input CSV of Samples
blastdb: Path to custom *Avipoxvirus* BLAST database
ntdb: Path to BLAST nt database
readsdir: Path to directory holding raw read pairs
outdir: Output directory
outstem: Output file stem  
taxon: Taxon to search for in MEGAN LCA files  

## Running the Pipeline  
Enter the command:  
`nextflow run campanam/Avipoxvirus -r main -c <your config file>`  

## References  
1. Schubert M, Lindgreen S, Orlando L. 2016. AdapterRemoval v2: rapid adapter trimming, identification, and read merging. *BMC Research Notes*. __9__: 88.  
2. Li H. 2023. Seqtk v. 1.4. Available: https://github.com/lh3/seqtk.  
3. Li W, Godzik A. 2006. Cd-hit: a fast program for clustering and comparing large sets of protein or nucleotide sequences. *Bioinformatics*. __22__: 1658-9.  
4. Camacho C, Coulouris G, Avagyan V, Ma N, Papadopoulos J, Bealer K, Madden TL. 2009. BLAST+: architecture and applications. *BMC Bioinformatics*. __10__: 421.
5. Huson DH, Beier S, Flade I, Górska M, Mitra S, Ruscheweyh H-J, Tappu R. 2016. MEGAN Community Edition - interactive exploration and analysis of large-scale microbiome sequencing data. *PLoS Computational Biology*. __12__: e1004957.  
