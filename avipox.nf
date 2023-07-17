#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process removeAdapters {

	// This process removes adapters using AdapterRemoval 2.3.2
	
	input:
	tuple val(library), path(reads1), path(reads2), val(adapter1), val(adapter2)
	
	output:
	path("${library}.fastq.gz")
	
	"""
	AdapterRemoval --file1 $reads1 --file2 $reads2 --basename $library --adapter1 $adapter1 --adapter2 $adapter2 --collapse --gzip --minlength 30
	cat ${library}.collapsed.gz ${library}.collapsed.truncated.gz > ${library}.fastq.gz
	"""
	
}

process deduplicateReads {

	// Convert to FASTA using SeqtKk 1.2-r94
	// Remove duplicates using CD-HIT v. 4.6
	
	input:
	path(reads)
	
	output:
	path("${reads.simpleName}.collapsed.uniq.fa")
	
	"""
	seqtk seq -A $reads > ${reads.simpleName}.collapsed.fa
	cd-hit-est -c 1 -i ${reads.simpleName}.collapsed.fa -o ${reads.simpleName}.collapsed.uniq.fa
	"""

}

process blastReads {

	// Blast uniqued reads against custom viral database
	
	publishDir "$params.outdir/01_BlastResults", mode: 'copy'
	
	input:
	path(uniq_reads)
	
	output:
	tuple path("$uniq_reads"), path("${uniq_reads.baseName}.xml")
	
	"""
	blastn -db ${params.blastdb} -query $uniq_reads -out ${uniq_reads.baseName}.xml -outfmt 5
	"""

}

process blast2rmalca {

	// Convert BLAST results to RMA6 using MEGAN6-CE blast2rma utility
	// Convert BLAST results to LCA using MEGAN6-CE blast2lca utility
	// Modified from GRW4 analysis pipeline
	
	publishDir "$params.outdir/02_RMA_LCA", mode: 'copy', pattern: '*.rma6'
	publishDir "$params.outdir/02_RMA_LCA", mode: 'copy', pattern: '*.lca.txt'

	input:
	tuple path(blast_fa), path(blast_xml)
	
	output:
	path "${blast_xml.simpleName}.rma6"
	path "${blast_xml.simpleName}.lca.txt"
	
	"""
	blast2rma -i $blast_xml -f BlastXML -bm BlastN -r $blast_fa -o ${blast_xml.simpleName}.rma6
	blast2lca -i $blast_xml -f BlastXML -m BlastN -o ${blast_xml.simpleName}.lca.txt
	"""

}

workflow {
	channel.fromPath(params.inputCsv).splitCsv(header:true).map { row -> tuple(row.Library, file(params.readsdir + row.Read1), file(params.readsdir + row.Read2), row.Adapter1, row.Adapter2)} | removeAdapters | deduplicateReads | blastReads | blast2rmalca
}