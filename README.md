# Avipoxvirus
<img align="right" src="DSC_0116.JPG" width="100"> 

Michael G. Campana and Madeline W. Eibner-Gebhardt, 2023-2024  
Smithsonian's National Zoo and Conservation Biology Institute  

Pipeline to identify *Avipoxvirus* sequences in DNA libraries  

[![DOI](https://zenodo.org/badge/667565062.svg)](https://doi.org/10.5281/zenodo.14010731)

## Citation  
Eibner-Gehbardt MW, Fleischer RC, Campana MG. In prep. A historical Hawaiian Avipoxvirus genome reconstructed from an 1898 museum specimen.  

## License  
The software is made available under the Smithsonian Institution [terms of use](https://www.si.edu/termsofuse).  

## Input  
The pipeline requires a directory of bidirectionally sequenced DNA libraries in FASTQ format. The pipeline expects the forward and reverse reads in separate files. Second, the pipeline requires a CSV file assigning the read files to libraries with the following format:  

Library,Read1,Read2,Adapter1,Adapter2  
\<library1 name>\,\<path to library1 read1\>,\<path to library1 read2\>,\<library1 adapter1 sequence\>,\<library1 adapter2 sequence\>  
\<library2 name>\,\<path to library2 read1\>,\<path to library2 read2\>,\<library2 adapter1 sequence\>,\<library2 adapter2 sequence\>  

Additionally, the pipeline requires access to a local copy of the NCBI non-redundant nucleotide database ('nt') as well as a custom *Avipoxvirus* genomic blast database. See Eibner-Gehbardt et al. for details on compiling the *Avipoxvirus* genome database.  

## Installation  
The pipeline requires [Nextflow](https://www.nextflow.io/). The pipeline can automatically install the dependencies using [Conda](https://conda.io) or [Mamba](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html). After installing Nextflow and Conda/Mamba, install the pipeline with the command:  
`nextflow pull campanam/Avipoxvirus -r main`  

## Dependencies  
If you cannot install the dependencies automatically using Conda, please install the following software packages:  

AdapterRemoval v. 2.3.3 [(1)](https://github.com/MikkelSchubert/adapterremoval)  
Seqtk v. 1.4 [(2)](https://github.com/lh3/seqtk)  
CD-HIT v. 4.8.1 [(3)](https://sites.google.com/view/cd-hit)  
BLAST+ v. 2.13.0 [(4)](https://blast.ncbi.nlm.nih.gov/doc/blast-help/downloadblastdata.html)  
MEGAN - Community Edition v. 6.24.20 [(5)](https://github.com/husonlab/megan-ce)  

If you wish to run damage profiling, you will also need to install the following packages:  

BWA v. 0.7.17 [(6)](https://bio-bwa.sourceforge.net/)  
SAMtools v. 1.18 [(7)](https://www.htslib.org/)  
Genome Analysis Toolkit v. 4.4.0.0 [(8)](https://gatk.broadinstitute.org/hc/en-us)  
DamageProfiler v. 1.1 [(9)](https://damageprofiler.readthedocs.io/en/latest/)  

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
profiledamage: Whether to run DNA damage profiling (true or false)  
refseq: Path to reference sequence for damage profiling  

## Running the Pipeline  
Enter the command:  
`nextflow run campanam/Avipoxvirus -r main -c <your config file>`  

## Output  
The pipeline will create and populate the following output subdirectories:  

01_BlastResults: Unique, merged sequences in FASTA format and their BLAST results against the custom *Avipoxvirus* database in XML format.  
02_RMA_LCA: MEGAN RMA6 and LCA files derived from BLAST XML results. Files derived from the second BLAST step against the nt database will have '_avi' appended before the file suffix (either .lca.txt or .rma6).  
03_BlastHits: Reads that match *Avipoxvirus* in the first round of BLAST analysis in FASTA format.  
04_Summary: A summary file of the number of *Avipoxvirus* hits per library after the first round of BLAST assignment.  
05_NtBlastResults: BLAST results in XML format after secondary assignment against nt database.  
06_NtSummary: A summary file of the number of *Avipoxvirus* hits per library after the second round of BLAST assignment.  
07_DamageProfiles: Alignments in BAM format and DamageProfiler output for *Avipoxvirus* reads.  

## References  
1. Schubert M, Lindgreen S, Orlando L. 2016. AdapterRemoval v2: rapid adapter trimming, identification, and read merging. *BMC Research Notes*. __9__: 88.  
2. Li H. 2023. Seqtk v. 1.4. Available: https://github.com/lh3/seqtk.  
3. Li W, Godzik A. 2006. Cd-hit: a fast program for clustering and comparing large sets of protein or nucleotide sequences. *Bioinformatics*. __22__: 1658-9.  
4. Camacho C, Coulouris G, Avagyan V, Ma N, Papadopoulos J, Bealer K, Madden TL. 2009. BLAST+: architecture and applications. *BMC Bioinformatics*. __10__: 421.
5. Huson DH, Beier S, Flade I, Górska M, Mitra S, Ruscheweyh H-J, Tappu R. 2016. MEGAN Community Edition - interactive exploration and analysis of large-scale microbiome sequencing data. *PLoS Computational Biology*. __12__: e1004957.  
6. Li H, Durbin R. 2009. Fast and accurate short read alignment with Burrows-Wheeler transform. *Bioinformatics*. __25__: 1754-1760.  
7. Danecek P, Bonfield JK, Liddle J, Marshall J, Ohan V, Pollard MO, Whitwham A, Keane T, McCarthy SA, Davies RM, Li H. 2021. Twelves years of SAMtools and BCFtools. *GigaScience*. __10__: giab008.  
8. McKenna A, Hanna M, Banks E, Sivachenko A, Cibulskis K, Kernytsky A, Garimella K, Altshuler D, Gabriel S, Daly M, DePristo MA. 2010. The Genome Analysis Toolkit: a MapReduce framework for analyzing next-generation DNA sequencing data. *Genome Research*. __20__: 1297-1303. 
9. Neukamm J, Peltzer A, Nieselt K. 2021. DamageProfiler: fast damage pattern calculation for ancient DNA. *Bioinformatics*. __37__: 3652–3653.  

## Image Credits:  
Loren Cassin-Sackett. 2014. Hawaii 'amakihi with *Avipoxvirus* lesion. Used with permission of the photographer.  
