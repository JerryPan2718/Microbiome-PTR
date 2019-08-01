#!/usr/bin/env nextflow

params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)
params.icm_file = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-glimmer/test1.icm"
icm_file = file(params.icm_file)
params.ref1_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
ref1_file = file(params.ref1_file)
params.ref2_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_2.fastq"
ref2_file = file(params.ref2_file)
params.trimmed_file1 = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-sickle/trimmed_output_file1.fastq"
trimmed_file1 = file(params.trimmed_file1)
params.trimmed_file2 =  "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-sickle/trimmed_output_file2.fastq"
trimmed_file2 = file(params.trimmed_file2)
params.index_file =  "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-bowtie2/test1.index"
// index_file = file(params.index_file)

params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"
params.sickle = "/Users/jerrypan/Desktop/GRIPS/Sickle_Master/sickle"
params.bowtie2_build = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2-build"
params.bowtie2 = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2"

process bowtie2 {

	input:
	file "trimmed1" from trimmed_file1
    file "trimmed2" from trimmed_file2
    val params.index_file

    output:
    file 'bam' into bam_file

    script:
    """
    $params.bowtie2 -x $params.index_file -1 $trimmed1 -2 $trimmed2 > bam

    """
}

