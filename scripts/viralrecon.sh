#!/bin/bash

#Descargar los bed files que contienen las secuencias de primer de forma previa a la ejecución de la pipeline, siempre y cuando se trate de amplicones, y no de metagenómica y/o whole genome sequencing

#SRR33436961     Artic_V4.1      https://github.com/artic-network/artic-ncov2019/tree/3192c91293fd2ba84018009ff63c71fdbcbf3dcd/primer_schemes/nCoV-2019

#SRR33413782     Varskip    vss2f=Varskip vss2b      https://github.com/nebiolabs/VarSkip/blob/f5ff970bd8d4d2b41ac309f0a02aad159ecbf9f9/neb_vss2b.primer.bed

#SRR33658125     Artic_V5.3.2        https://github.com/artic-network/artic-ncov2019/tree/3192c91293fd2ba84018009ff63c71fdbcbf3dcd/primer_schemes/nCoV-2019

#Mover fastq al directorio viralrecon, donde se encontrará el script fastq_dir_to_samplesheet.py (https://github.com/artic-network/artic-ncov2019/tree/3192c91293fd2ba84018009ff63c71fdbcbf3dcd/primer_schemes/nCoV-2019) para generar la samplesheet.csv necesaria para correr viralrecon

# Para encontrar ubicación del archivo
# find . -name fastq_dir_to_samplesheet.py  
# Ejecutar script
# python3 /home/juanlu/Descargas/fastq_dir_to_samplesheet.py

array_amplicon=( "SRR33436961" ) #Los archivos bed para el SRR33413782 no los hay
array_metagenomic=( "SRR33190466" )


cd ~/tfm/benchmark
for dir in ${array_amplicon[@]}
do
    cd "$dir"/
    echo "$dir"
    echo -e "\n"
    echo -e "\n"
    python3 /home/juanlu/tfm/benchmark/assemblies/viralrecon/fastq_dir_to_samplesheet.py ~/tfm/benchmark/$dir/ ~/tfm/benchmark/$dir/viralrecon_samplesheet_$dir.csv -r1 _1.fastq.gz -r2 _2.fastq.gz -sn -sd _ -si 1
    echo -e "\n"
    echo -e "\n"
#     cd viralrecon_output
#     pwd
#     echo -e "\n"
#     echo -e "\n"
    nextflow run nf-core/viralrecon --input viralrecon_samplesheet_$dir.csv --outdir viralrecon_output --platform illumina --genome 'MN908947.3' --protocol amplicon --primer_bed viralrecon_output/*.bed -profile docker
    echo -e "\n"
    echo -e "\n"
    cd ~/tfm/benchmark
done 



cd ~/tfm/benchmark
for dir in ${array_metagenomic[@]}
do
    cd "$dir"/
    echo "$dir"
    echo -e "\n"
    echo -e "\n"
    python3 /home/juanlu/tfm/benchmark/assemblies/viralrecon/fastq_dir_to_samplesheet.py ~/tfm/benchmark/$dir/ ~/tfm/benchmark/$dir/viralrecon_samplesheet_$dir.csv -r1 _1.fastq.gz -r2 _2.fastq.gz -sn -sd _ -si 1
    echo -e "\n"
    echo -e "\n"
#     cd viralrecon_output
#     pwd
#     echo -e "\n"
#     echo -e "\n"
    nextflow run nf-core/viralrecon --input viralrecon_samplesheet_$dir.csv --outdir viralrecon_output --platform illumina --genome 'MN908947.3' --protocol metagenomic -profile docker
    echo -e "\n"
    echo -e "\n"
    cd ~/tfm/benchmark
done 