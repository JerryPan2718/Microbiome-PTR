#!/usr/bin/env nextflow

params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)
// params.icm_file = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-glimmer/test1.icm"
// icm_file = file(params.icm_file)
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
params.bam_file = "/Users/jerrypan/Desktop/GRIPS/Analysis/test1.bam"
bam_file = file(params.bam_file)

window_size = Channel.from(10000)
sliding_size = Channel.from(100)
output = "/Users/jerrypan/Desktop/Coverage_Reads_Graph"

params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"
params.sickle = "/Users/jerrypan/Desktop/GRIPS/Sickle_Master/sickle"
params.bowtie2_build = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2-build"
params.bowtie2 = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2"
params.r_algo = "/Users/jerrypan/Desktop/GRIPS/Microbiota_Project/PTR_Calculation_Graph.R"

process glimmer_build_icm {

	input:
	file "genome" from genome_file  


    output:
    file 'icm' into icm_file

    script:
    """
 	$params.build_icm icm < $params.genome

    """
}

process glimmer3 {

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

process sickle {

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

process bowtie2_build {

	input:
	file "genome" from genome_file

    output:
    file 'index' into index_file


    script:
    """
	$params.bowtie2_build $genome index > index
	
    """
}

process bowtie2 {

	input:
	file "trimmed*" from trimmed_file
    // file "trimmed2" from trimmed_file
    val params.index_file

    output:
    file 'bam' into bam_file

    script:
    """
    $params.bowtie2 -x $params.index_file -1 $trimmed1 -2 $trimmed2 > bam

    """
}

process calculation_and_graph {

    input:
    file "bam" from bam_file
    val "window_size" from window_size
    val "sliding_size" from sliding_size
    val "output" from output

    output:
    file 'graph' into output1
    file 'text' into output2


    script:
    """
    $params.r_algo $bam --window_size $window_size --sliding_size $sliding_size --output $output 

    """
}

















































// #!/usr/bin/env nextflow

// params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
// genome_file = file(params.genome)
// params.ref1 = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
// ref1_file = file(params.ref1)
// params.ref2 = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_2.fastq"
// ref2_file = file(params.ref2)
// params.window_size = 10000
// params.sliding_size = 100
// params.output = "Users/jerrypan/Desktop/Coverage_Graph"

// long_orfs = Channel.fromPath(/Users/Desktop/GRIPS/Glimmer/bin/long_orfs)
// sickle = Channel.fromPath(/Users/Desktop/GRIPS/Sickle_Master/sickle)
// bowtie2-build = Channel.fromPath(/Users/Desktop/GRIPS/Bowtie2_Binary/bowtie2-build)
// bowtie2 = Channel.fromPath(/Users/Desktop/GRIPS/Bowtie2_Binary/bowtie2)
// build-icm = Channel.fromPath(/Users/Desktop/GRIPS/Glimmer/bin/build-icm)
// glimmer3 = Channel.fromPath(/Users/Desktop/GRIPS/Glimmer/bin/glimmer3)
// executable_file = Channel.fromPath(/Users/Desktop/GRIPS/Microbiota_project/Executable_File.R)


// process glimmer_build_icm {

// 	input:
// 	file genome from genome_file  


//     output:
//     file icm //into icm_file

//     script:
//     """
//     build-icm icm < genome

//     """
// }

// process glimmer3_ {

// 	input:
// 	file genome from genome_file
// 	file icm //from icm_file

// 	output:
// 	file predict //into predict_file

// 	script:
// 	"""
// 	glimmer3 genome icm > predict
// 	"""

// }



// process sickle {

// 	input:
// 	file ref1 //from ref1_file
// 	file ref2 //from ref2_file

//     output:
//     file trimmed1 //into trimmed_file
//     file trimmed2 //into trimmed_file
//     file trimmedS //into trimmed_file

//     script:
//     """
//     sickle pe -f ref1 -r ref2 -t sanger -o trimmed1 -p trimmed2 -s trimmedS

//     """
// }

// process bowtie2_build_{

// 	input:
// 	file genome from genome_file

//     output:
//     file index //into index_file


//     script:
//     """
//     bowtie2-build genome > index

//     """
// }

// process bowtie2 {

// 	input:
// 	file trimmed1 //from trimmed_file
//     file trimmed2 //from trimmed_file
//     file index //from index_file

//     output:
//     file bam //into bam_file

//     script:
//     """
//     bowtie2_method -x index -1 trimmed1 -2 trimmed > bam

//     """
// }

// process calculation_and_graph {

// 	input:
// 	file bam from bam_file
// 	val x 


//     output:
//     file graph into graph_file
//     file text into text_file


//     script:
//     """
//     executionable_file bam params.window_size params.sliding_size > graph | text

//     """
// }
