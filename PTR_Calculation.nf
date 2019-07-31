#!/usr/bin/env nextflow

params.genome = "/Users/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)
params.ref1 = "/Users/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
ref1_file = file(params.ref1)
params.ref2 = "/Users/Desktop/GRIPS/Data/Ery_T0_r1_2.fastq"
ref2_file = file(params.ref2)


long_orfs_method = Channel.fromPath(/Users/Desktop/GRIPS/Glimmer/bin/long_orfs)
sickle_method = Channel.fromPath(/Users/Desktop/GRIPS/Sickle_Master/sickle)
bowtie2_build_method = Channel.fromPath(/Users/Desktop/GRIPS/Bowtie2_Binary/bowtie2-build)
bowtie2_method = Channel.fromPath(/Users/Desktop/GRIPS/Bowtie2_Binary/bowtie2)
glimmer_build_icm_method = Channel.fromPath(/Users/Desktop/GRIPS/Glimmer/bin/build-icm)
glimmer3_method = Channel.fromPath(/Users/Desktop/GRIPS/Glimmer/bin/glimmer3)


process glimmer_build_icm {

	input:
	file genome from genome_file  


    output:
    file icm into icm_file

    script:
    """
    glimmer_build_icm_method icm < genome

    """
}

process glimmer3 {

	input:
	file genome from genome_file
	file icm from icm_file

	output:
	file predict into predict_file

	script:
	"""
	glimmer3_method genome icm predict
	"""

}



process sickle {

	input:
	file ref1 from ref1_file
	file ref2 from ref2_file

    output:
    file trimmed1 into trimmed_file
    file trimmed2 into trimmed_file
    file trimmedS into trimmed_file

    script:
    """
    sickle_method pe -f ref1 -r ref2 -t sanger -o trimmed1 -p trimmed2 -s trimmedS

    """
}

process bowtie2_build {

	input:
	file genome from genome_file

    output:
    file index into index_file


    script:
    """
    bowtie2_build_method genome index

    """
}

process bowtie2 {

	input:
	file trimmed1 from trimmed_file
    file trimmed2 from trimmed_file
    file index from index_file

    output:
    file bam into bam_file

    script:
    """
    bowtie2_method -x index -1 trimmed1 -2 trimmed > bam

    """
}

process calculation_and_graph {

	input:
	file bam from bam_file

    output:
    


    script:
    """
    

    """
}
