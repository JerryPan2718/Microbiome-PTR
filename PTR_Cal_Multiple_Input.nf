#!/usr/bin/env nextflow
import java.text.SimpleDateFormat

params.genome = "/Users/jerrypan/Desktop/GRIPS/Data/GCF_000027085.1_ASM2708v1_genomic.fna"
genome_file = file(params.genome)
// params.ref1_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
// ref1_file = file(params.ref1_file)
// params.ref2_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_2.fastq"
// ref2_file = file(params.ref2_file

// params.ref_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_T0_r1_1.fastq"
// params.ref_file = "/Users/jerrypan/Desktop/GRIPS/Data/Citrobacter_Rodentium/ERR969371.fastq"
// ref_file = file(params.ref_file)

params.size = 2
params.indir1 = '/Users/jerrypan/Desktop/GRIPS/Data/Ery_Test1/'
params.indir2 = '/Users/jerrypan/Desktop/GRIPS/Data/Ery_Test2/'
params.indir = '/Users/jerrypan/Desktop/GRIPS/Data/CR_Test/'

// params.ref1_file = Channel.fromPath("/Users/jerrypan/Desktop/GRIPS/Data/Ery_Test/ERR930224_1*").buffer(size:params.size)
// params.ref2_file = Channel.fromPath("/Users/jerrypan/Desktop/GRIPS/Data/Ery_Test/ERR930224_2*").buffer(size:params.size)
// params.names = Channel.fromPath("/Users/jerrypan/Desktop/GRIPS/Data/Test_Index/*").buffer(size:params.size)

TEMP1 = Channel.fromPath("${params.indir1}/*.fastq")
TEMP2 = Channel.fromPath("${params.indir2}/*.fastq")

TEMP1.into{ READS1; NAMES1 }
TEMP2.into{ READS2; NAMES2 }

TEMP = Channel.fromPath("${params.indir}/*.fastq")
TEMP.into{ READS; NAMES}

// params.value = Channel.from(1,2)
// params.name_file = "/Users/jerrypan/Desktop/GRIPS/Data/Ery_Test/ERR930224_1_*"
// name_file = file(params.name_file)

// params.cr_genome = Channel.fromPath("/Users/jerrypan/Desktop/GRIPS/Data/CR_Test/*.fastq").buffer(size:3)



params.window_size = 10000
params.step_size = 100
params.single_file = true
params.output = "/Users/jerrypan/Desktop/GRIPS/Analysis/20190807-overall"

window_size = params.window_size
step_size = params.step_size

params.build_icm = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/build-icm"
params.glimmer3 = "/Users/jerrypan/Desktop/GRIPS/Glimmer/bin/glimmer3"
params.sickle = "/Users/jerrypan/Desktop/GRIPS/Sickle_Master/sickle"
params.bowtie2_build = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2-build"
params.bowtie2 = "/Users/jerrypan/Desktop/GRIPS/Bowtie2_Binary/bowtie2"
params.r_algo = "/Users/jerrypan/Desktop/GRIPS/Microbiota_Project/PTR_Calculation_Graph.R"
params.samtools = "/Users/jerrypan/Desktop/GRIPS/Samtools_1.9/samtools"


// process name_extract_ {

//     input:
//     file "name_files" from params.names

//     output:
//     file 'basename*' into basename_file

//     script:
//     """
//     String basename = new File('/Users/jerrypan/Desktop/GRIPS/Data/Test_Index/*').text
//     """
// }

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

process sickle_pe_ {

    input:
    file "ref1" from READS1
    file "ref2" from READS2
    // file "basename" from basename_file
    
    output:
    //file 'trimmed*' into trimmed_file
    file 'trimmed1*' into trimmed_file1
    file 'trimmed2*' into trimmed_file2
    file 'trimmedS*' into trimmed_file3


    when:
    !params.single_file

    // params.temp = call()
    script:
    """
    $params.sickle pe -f ref1 -r ref2 -t sanger -o trimmed1 -p trimmed2 -s trimmedS
    """
}

process bowtie2_pe_ {

    input:
    file "trimmed1" from trimmed_file1
    file "trimmed2" from trimmed_file2
    val "index" from index_file
    // file "basename" from basename_file


    output:
    file 'bam*' into bam_file_pe

    when:
    !params.single_file

    script:
    """

    $params.bowtie2 -x $index -1 $trimmed1 -2 $trimmed2 | $params.samtools view -b > bam

    """
}

process calculation_and_graph_pe_ {
    publishDir '/Users/jerrypan/Desktop/GRIPS/Analysis/20190806-overall', mode: 'copy'

    input:
    file "bam" from bam_file_pe
    file "input1" from NAMES1
    file "output" from params.output

    output:

    when:
    !params.single_file

    script:
    """
    $params.r_algo $bam --window_size $window_size --step_size $step_size --output $output --name $input1 

    """
}

process sickle_se_ {

    input:
    file "ref" from READS

    output:
    //file 'trimmed*' into trimmed_file
    file 'trimmed*' into trimmed_file
    

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
    file 'bam*' into bam_file_se
    
    when:
    params.single_file

    script:
    """
    $params.bowtie2 -x $index -U $trimmed | $params.samtools view -b > bam

    """
}

process calculation_and_graph_se_ {
    publishDir 'params.output/', mode: 'copy'

    input:
    file "bam" from bam_file_se
    file input1 from NAMES
    file "output" from params.output

    output:

    when:
    params.single_file

    script:
    """
    $params.r_algo $bam --window_size $window_size --step_size $step_size --output $output --name $input1 

    """
}