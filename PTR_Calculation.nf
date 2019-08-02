#!/usr/bin/env nextflow

params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)
// params.icm_file = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-glimmer/test1.icm"
// icm_file = file(params.icm_file)
params.ref1_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
ref1_file = file(params.ref1_file)
params.ref2_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_2.fastq"
ref2_file = file(params.ref2_file)
// params.trimmed_file1 = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-sickle/trimmed_output_file1.fastq"
// trimmed_file1 = file(params.trimmed_file1)
// params.trimmed_file2 =  "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-sickle/trimmed_output_file2.fastq"
// trimmed_file2 = file(params.trimmed_file2)
// params.index_file =  "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-bowtie2/test1.index"
// index_file = file(params.index_file)
// params.bam_file = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-bowtie2/test1.bam"
// bam_file = file(params.bam_file)

window_size = 10000
sliding_size = 100
output = "/Users/jerrypan/Desktop/Coverage_Reads_Graph.jpg"

params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"
params.sickle = "/Users/jerrypan/Desktop/GRIPS/Sickle_Master/sickle"
params.bowtie2_build = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2-build"
params.bowtie2 = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2"
params.r_algo = "/Users/jerrypan/Desktop/GRIPS/Microbiota_Project/PTR_Calculation_Graph.R"
params.samtools = "/Users/jerrypan/Desktop/GRIPS/Samtools_1.9/samtools"

process glimmer_build_icm_ {

	input:
	file "genome" from genome_file  


    output:
    file 'icm' into icm_file

    script:
    """
 	$params.build_icm icm < $genome

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
	$params.glimmer3 $genome $icm predict > predict

	"""
}

process sickle_ {

	input:
	file "ref1" from ref1_file
	file "ref2" from ref2_file

    output:
    //file 'trimmed*' into trimmed_file
    file trimmed1 into trimmed_file1
    file trimmed2 into trimmed_file2
    file trimmedS into trimmed_file3

    script:
    """
    $params.sickle pe -f $ref1 -r $ref2 -t sanger -o trimmed1 -p trimmed2 -s trimmedS

    """
}

process bowtie2_build_ {

	input:
	file "genome" from genome_file

    output:
    file 'index' into index_file


    script:
    """
	$params.bowtie2_build $genome index > index
	
    """
}

process bowtie2_ {

	input:
	file "trimmed1" from trimmed_file1
    file "trimmed2" from trimmed_file2
    val "index" from index_file

    output:
    file 'bam' into bam_file
    // file 'sam' into sam_file

    script:
    """
    $params.bowtie2 -x $index -1 $trimmed1 -2 $trimmed2 | $params.samtools view -b > bam

    """
}

process calculation_and_graph_ {

    input:
    file "bam" from bam_file
    // val "window_size" from window_size
    // val "sliding_size" from sliding_size
    // val "output" from output

    output:
    // file 'graph' into output1
    // file 'text' into output2


    script:
    """
    $params.r_algo $bam --window_size $window_size --sliding_size $sliding_size --output $output 

    """
}





