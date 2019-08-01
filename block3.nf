#!/usr/bin/env nextflow

params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)
params.icm_file = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-glimmer/test1.icm"
icm_file = file(params.icm_file)
params.ref1_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
ref1_file = file(params.ref1_file)
params.ref2_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_2.fastq"
ref2_file = file(params.ref2_file)


params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"
params.sickle = "/Users/jerrypan/Desktop/GRIPS/Sickle_Master/sickle"

process sickle_ {

	input:
	file "ref1" from ref1_file
	file "ref2" from ref2_file

    output:
    file 'trimmed*' into trimmed_file
    // file trimmed1 into trimmed_file
    // file trimmed2 into trimmed_file
    // file trimmedS into trimmed_file

    script:
    """
    $params.sickle pe -f $ref1 -r $ref2 -t sanger -o trimmed1 -p trimmed2 -s trimmedS

    """
}