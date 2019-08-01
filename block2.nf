#!/usr/bin/env nextflow

params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)
params.icm_file = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-glimmer/test1.icm"
icm_file = file(params.icm_file)

params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"



process glimmer3_ {

	input:
	file "genome" from genome_file
	file "icm" from icm_file

	output:
	file 'predict' into predict_file

	script:
	"""
	$params.glimmer3 $genome $icm predict > predict

	"""
}