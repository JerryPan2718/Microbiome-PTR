#!/usr/bin/env nextflow
import java.text.SimpleDateFormat

params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)
// params.ref1_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
// ref1_file = file(params.ref1_file)
// params.ref2_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_2.fastq"
// ref2_file = file(params.ref2_file

// params.ref_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
params.ref_file = "/Users/jerrypan/Desktop/GRIPS/Data/Citrobacter_Rodentium/Vcit_A4_3.fastq"
ref_file = file(params.ref_file)
params.ref1_file = Channel.fromPath("/Users/jerrypan/Desktop/GRIPS/Data/Ery_Test/Ery_T0_r1_1*").buffer(size:2)
params.ref2_file = Channel.fromPath("/Users/jerrypan/Desktop/GRIPS/Data/Ery_Test/Ery_T0_r1_2*").buffer(size:2)


// params.cr_genome = Channel.fromPath("/Users/jerrypan/Desktop/GRIPS/Data/CR_Test/*.fastq").buffer(size:3)



params.window_size = 10000
params.step_size = 100
params.single_file = false
// true: error
// false: works fine


output = "/Users/jerrypan/Desktop/Coverage_Reads_Graph.jpg"

window_size = params.window_size
step_size = params.step_size

params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"
params.sickle = "/Users/jerrypan/Desktop/GRIPS/Sickle_Master/sickle"
params.bowtie2_build = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2-build"
params.bowtie2 = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2"
params.r_algo = "/Users/jerrypan/Desktop/GRIPS/Microbiota_Project/PTR_Calculation_Graph.R"
params.samtools = "/Users/jerrypan/Desktop/GRIPS/Samtools_1.9/samtools"

def call(){
    def date = new Date()
    sdf = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss")
    return sdf.format(date)
}

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

process sickle_pe_ {

    input:
    file "ref1" from params.ref1_file
    file "ref2" from params.ref2_file

    output:
    //file 'trimmed*' into trimmed_file
    file 'trimmed1*' into trimmed_file1
    file 'trimmed2*' into trimmed_file2
    file 'trimmedS*' into trimmed_file3

    when:
    !params.single_file

    script:
    """
    params.temp = call()
    $params.sickle pe -f ${ref1} -r ${ref2} -t sanger -o "trimmed1"+params.temp -p "trimmed2"+params.temp -s "trimmedS"+params.temp

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

process bowtie2_pe_ {

    input:
    file "trimmed1" from trimmed_file1
    file "trimmed2" from trimmed_file2
    val "index" from index_file

    output:
    file 'bam*' into bam_file_pe

    when:
    !params.single_file

    script:
    """
    params.temp = call()
    $params.bowtie2 -x $index -1 ${trimmed1} -2 ${trimmed2} | $params.samtools view -b > {bam}+params.temp

    """
}

process calculation_and_graph_pe_ {
    publishDir '/Users/jerrypan/Desktop/GRIPS/Analysis/20190805-nextflow', mode: 'copy'
    input:
    file "bam" from bam_file_pe
    // file "name1" from params.ref1_file
    // file "name2" from params.ref2_file
    // val "window_size" from window_size
    // val "step_size" from step_size
    // val "output" from output

    output:
    // file 'graph' into output1
    // file 'text' into output2

    when:
    !params.single_file

    script:
    """
    params.temp = call()
    $params.r_algo ${bam} --window_size $window_size --step_size $step_size --output ${bam}+params.temp

    """
}

process sickle_se_ {

    input:
    file "ref" from ref_file

    output:
    //file 'trimmed*' into trimmed_file
    file 'trimmed' into trimmed_file
    

    when:
    params.single_file

    script:
    """
    $params.sickle se -f $ref -t sanger -o trimmed

    """
}

process bowtie2_se_ {

    input:
    file "trimmed" from trimmed_file
    val "index" from index_file

    output:
    file 'bam' into bam_file_se
    
    when:
    params.single_file

    script:
    """
    $params.bowtie2 -x $index -1 $trimmed | $params.samtools view -b > bam

    """
}

process calculation_and_graph_se_ {
    publishDir '/Users/jerrypan/Desktop/GRIPS/Analysis/20190805-nextflow', mode: 'copy'
    input:
    file "bam" from bam_file_se


    output:
    // file 'graph' into output1
    // file 'text' into output2

    when:
    params.single_file

    script:
    """
    $params.r_algo $bam --window_size $window_size --step_size $step_size --output $output 

    """
}