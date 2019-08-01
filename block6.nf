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
params.bam_file = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190731-bowtie2/test1.bam"
bam_file = file(params.bam_file)

window_size = Channel.from(10000)
sliding_size = Channel.from(100)
output = Channel.from("/Users/jerrypan/Desktop/Coverage_Reads_Graph")

params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"
params.sickle = "/Users/jerrypan/Desktop/GRIPS/Sickle_Master/sickle"
params.bowtie2_build = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2-build"
params.bowtie2 = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2"
params.r_algo = "/Users/jerrypan/Desktop/GRIPS/Microbiota_Project/PTR_Calculation_Graph.R"

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