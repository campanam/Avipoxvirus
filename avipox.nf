#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process removeAdapters {

	// This process removes adapters using AdapterRemoval 2.3.3
	
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

	// Convert to FASTA using SeqTK 1.4
	// Remove duplicates using CD-HIT v. 4.8.1
	
	input:
	path(reads)
	
	output:
	path("${reads.simpleName}.collapsed.uniq.fa")
	
	"""
	seqtk seq -A $reads > ${reads.simpleName}.collapsed.fa
	cd-hit-est -c 1 -M 0 -i ${reads.simpleName}.collapsed.fa -o ${reads.simpleName}.collapsed.uniq.fa
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
	tuple path("${blast_xml.simpleName}.rma6"), path("${blast_xml.simpleName}.lca.txt")
	
	"""
	blast2rma -i $blast_xml -f BlastXML -bm BlastN -r $blast_fa -supp 0 -o ${blast_xml.simpleName}.rma6
	blast2lca -i $blast_xml -f BlastXML -m BlastN -o ${blast_xml.simpleName}.lca.txt
	"""

}

process getSequences {

	// Count number of BLAST hits using grep -c (counts lines NOT number of matches per lines)
	// Extract reads that align to target taxon using MEGAN-CE read-extractor utility
	
	publishDir "$params.outdir/03_BlastHits", mode: 'copy', pattern: '*avi.fa'
	
	input:
	tuple path(rma6), path(lca)
	
	output:
	path "${lca.simpleName}.count.txt", emit: samples_count
	path "${rma6.simpleName}.avi.fa", emit: avi_fa, optional: true
	
	"""
	#!/usr/bin/env bash
	readcount=`grep -c ${params.taxon} $lca`
	echo ${lca.simpleName},\$readcount > ${lca.simpleName}.count.txt
	if [ \$readcount -gt 0 ]; then read-extractor -i $rma6 -o ${rma6.simpleName}.avi.fa -c Taxonomy -n ${params.taxon} -b; fi
	"""

}

process summarizeHits {

	// Generate a summary table of BLAST hits
	
	publishDir "$params.outdir/04_Summary", mode: 'copy'
	
	input:
	path(files)
	
	output:
	path "${params.outstem}_summary.csv"
	
	"""
	#!/usr/bin/env bash
	echo Library,Hits > ${params.outstem}_summary.csv
	for lib in *.count.txt; do cat \$lib >> ${params.outstem}_summary.csv; done
	"""
	
}

process ntBlastReads {

	// Blast uniqued reads against nt database
	
	publishDir "$params.outdir/05_NtBlastResults", mode: 'copy'
	
	input:
	path(uniq_reads)
	
	output:
	tuple path("$uniq_reads"), path("${uniq_reads.baseName}.xml")
	
	"""
	blastn -db ${params.ntdb} -query $uniq_reads -out ${uniq_reads.baseName}.xml -outfmt 5
	"""

}

workflow blast1 {
	main:
		channel.fromPath(params.inputCsv).splitCsv(header:true).map { row -> tuple(row.Library, file(params.readsdir + row.Read1), file(params.readsdir + row.Read2), row.Adapter1, row.Adapter2)} | removeAdapters | deduplicateReads | blastReads | blast2rmalca | getSequences
		summarizeHits( getSequences.out.samples_count.collect() )
	emit:
		avi_fa = getSequences.out.avi_fa
}
workflow blast2 {
	main:
		ntBlastReads(avi_fa) | blast2rmalca | getSequences
}
workflow {
	main:
		blast1
		//blast2(blast1.out.avi_fa)
}
