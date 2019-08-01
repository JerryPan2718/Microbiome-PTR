#!/usr/bin/env nextflow

params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)

params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"

process glimmer_build_icm {

	input:
	file "genome" from genome_file  


    output:
    //file icm //into icm_file
    file 'icm' into icm_file
    script:
    """
 	$params.build_icm icm < $params.genome

    """
}

process glimmer3_ {

	input:
	file "genome" from genome_file
	file "icm" from icm_file

	output:
	file 'predict' into predict_file

	script:
	"""
	$params.glimmer3 $params.genome $params.icm predict > predict

	"""
}