#!/bin/bash

# cd /home/juanlu/tfm/benchmark/

# for dir in $(ls);  
# do
#     if [[ "$dir" == SRR* ]]
#        then
#        cd "$dir"
#        rm -r SRR*kraken SRR*txt SRR*fasta SRR*fastq processed_* pipecov_output vpipe_output viralrecon_output *html *json *zip 
#        mkdir pipecov_output
#        #mkdir vpipe_output
#        #mkdir viralrecon_output
#        cd ..
#     fi
# done


for dir in $(ls /home/juanlu/tfm/benchmark/);
do
    if [[ "$dir" == SRR* ]]
        then
        cd $dir 
        echo "$(pwd)"
        ls
        cp *.fastq.gz /home/juanlu/tfm/benchmark/assemblies/pipecov/pipes/QualityControl
        cd /home/juanlu/tfm/benchmark/assemblies/pipecov/pipes/QualityControl
        ./qc_docker.sh -i illumina -1 "$dir"_1.fastq.gz -2 "$dir"_2.fastq.gz -q 28 -l 50 -o "$dir"_qc_output -t 4
        rm *fastq.gz
        cd ../Mapping_Assembly 
        ./assembly_docker.sh -i illumina -1 ../QualityControl/"$dir"_qc_output/"$dir"_good.pair1.truncated -2 ../QualityControl/"$dir"_qc_output/"$dir"_good.pair2.truncated -r ~/tfm/benchmark/SARS_CoV2_GenRef_NC_045512.2.fasta -k 30 -m 2 -l 100 -c 10 -o "$dir"_assembly_output -t 5 -s "$dir" -g 4
        mv "$dir"_assembly_output /home/juanlu/tfm/benchmark/"$dir"/pipecov_output
        cd ../QualityControl
        mv "$dir"_qc_output /home/juanlu/tfm/benchmark/"$dir"
        cd /home/juanlu/tfm/benchmark/
    fi
done


