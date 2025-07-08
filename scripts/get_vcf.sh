#!/bin/bash


#Script para llevar a cabo la obtención de variantes obtenidas 
# por la pipeline PipeCoV.
# Es importante tener en este mismo directorio los archivos fasta 
# de la secuencia de referencia, así como de la secuencia consenso. 
# Esta secuencia consenson es la que se encuentra en el directorio 
# '5-rscripts/ref_for_remapping/' con el nombre 
# '"$archivo"_aligned_scaffolds_toRef.sorted_consensus.fasta'
# Es importante que antes de ejecutar el script se establezcan las 
# variables dir_ref (directorio del genoma de referencia en formato fasta)
#  y dir_cons (directorio de secuencia consenso utilizada como
#  referencia) 
#Importante tambien estables el valor de archivo, que se correspondera con el SRR id de la muestra.
#Activar directorios conda que tengan las herramientas necesarias para llevar a cabo las funciones a realizar con los archivos vcf

conda activate biosoftwares

dir_ref='/home/juanlu/tfm/benchmark/'
archivo='SRR33436961'
dir_cons='/home/juanlu/tfm/benchmark/"$archivo"/pipecov_output/"$archivo"_assembly_output/5-rscripts/ref_for_remapping/'

cd ~/tfm/benchmark/"$archivo"/pipecov_output/"$archivo"_assembly_output/

#Creación directorio 

mkdir 12-variantes
cd "12-variantes"

#Copiar referencias

echo -e "\n Genoma de referencia\n"
cp "$dir_ref"SARS_CoV2_GenRef_NC_045512.2.fasta .
echo -e "\n Genoma consenso de referencia\n"
cp /home/juanlu/tfm/benchmark/"$archivo"/pipecov_output/"$archivo"_assembly_output/5-rscripts/ref_for_remapping/"$archivo"_aligned_scaffolds_toRef.sorted_consensus.fasta .

#Indexar fasta files

for file in *.fasta
do
	samtools faidx "$file"
done

#Copiar bams

echo -e "\n Bam de todas las lecturas frente a genoma de referencia"
cp ../3-samtools_out/"$archivo".bam .
mv "$archivo".bam "$archivo"_toref.bam
cp ../7-samtools_out2/"$archivo".bam .
mv "$archivo".bam "$archivo"_tocons.bam

#Ordenación archivos .bam

for file in *bam
do 
	echo -e "\n Ordenando bam \n"
	samtools sort -@ 5 -o "${file/.bam/_sort.bam}" "$file"
done

#Indexado bams

for file in *_sort.bam
do
	samtools index -M *_sort.bam
done

#Generación vcf files

echo -e "\n Generando VCF file \n"

echo -e "\n To Ref\n"
bcftools mpileup -Ou -f SARS_CoV2_GenRef_NC_045512.2.fasta "$archivo"_toref_sort.bam --annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR | bcftools call -vmO v --ploidy 1 -o "$archivo"_toref_pipecov.vcf

echo -e "\n To Cons\n"
bcftools mpileup -Ou -f "$archivo"_aligned_scaffolds_toRef.sorted_consensus.fasta "$archivo"_tocons_sort.bam --annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR | bcftools call -vmO v --ploidy 1 -o "$archivo"_tocons_pipecov.vcf

#Compresión e indexado de vcf files.

bgzip *vcf
for file in *.vcf.gz
do
	tabix -p vcf "$file"
done

#Normalización INDELS

echo -e "\n normalización a referencia\n"
bcftools norm -f SARS_CoV2_GenRef_NC_045512.2.fasta -o "$archivo"_toref_norm_pipecov.vcf.gz "$archivo"_toref_pipecov.vcf.gz

echo -e "\n normalización a consenso\n"
bcftools norm -f "$archivo"_aligned_scaffolds_toRef.sorted_consensus.fasta -o "$archivo"_tocons_norm_pipecov.vcf.gz "$archivo"_tocons_pipecov.vcf.gz

#Extracción variantes comunes

bedtools intersect -a "$archivo"_toref_norm_pipecov.vcf.gz -b "$archivo"_tocons_norm_pipecov.vcf.gz -header > commons_variants_"$archivo"_pipecov.vcf.gz

#Extracción variantes únicas

echo -e "\n Variantes únicas ToRef\n"
bedtools subtract -a "$archivo"_toref_norm_pipecov.vcf.gz -b "$archivo"_tocons_norm_pipecov.vcf.gz -header > "$archivo"_toref_uniqs_norm_pipecov.vcf.gz
echo -e "\n Variantes únicas ToCons\n"
bedtools subtract -a "$archivo"_tocons_norm_pipecov.vcf.gz -b "$archivo"_toref_norm_pipecov.vcf.gz -header > "$archivo"_tocons_uniqs_norm_pipecov.vcf.gz

#Obtención archivo .chain

minimap2 -x asm5 -c "$archivo"_aligned_scaffolds_toRef.sorted_consensus.fasta SARS_CoV2_GenRef_NC_045512.2.fasta > alignment.paf 
paf2chain -i alignment.paf > alignment.chain

#Activar entorno gatk o crossmap, en función de la aplicación 
#a utilizar. 
conda activate gatk
conda activate crossmap

#Generación de variantes mapeadas. Es importante descomprimir los 
# archivo vcf.gz antes de ser utilizados por gatk LiftoverVcf o CrossMap

# gatk LiftoverVcf -I commons_variants_"$archivo"_pipecov.vcf.gz -O "$archivo"_nofilter_pipecov.vcf -C alignment.chain -R SARS_CoV2_GenRef_NC_045512.2.fasta --REJECT reject_variants.vcf

# gatk LiftoverVcf -I "$archivo"_toref_uniqs_norm_pipecov.vcf.gz -O "$archivo"_toref_nofilter_pipecov.vcf -C alignment.chain -R SARS_CoV2_GenRef_NC_045512.2.fasta --REJECT reject_variants_toref.vcf

# gatk LiftoverVcf -I "$archivo"_tocons_uniqs_norm_pipecov.vcf.gz -O "$archivo"_tocons_nofilter_pipecov.vcf -C alignment.chain -R SARS_CoV2_GenRef_NC_045512.2.fasta --REJECT reject_variants_tocons.vcf

mv commons_variants_"$archivo"_pipecov.vcf.gz commons_variants_"$archivo"_pipecov.vcf
mv "$archivo"_toref_uniqs_norm_pipecov.vcf.gz "$archivo"_toref_uniqs_norm_pipecov.vcf
mv "$archivo"_tocons_uniqs_norm_pipecov.vcf.gz "$archivo"_tocons_uniqs_norm_pipecov.vcf

CrossMap vcf alignment.chain commons_variants_"$archivo"_pipecov.vcf SARS_CoV2_GenRef_NC_045512.2.fasta "$archivo"_nofilter_pipecov.vcf

CrossMap vcf alignment.chain "$archivo"_toref_uniqs_norm_pipecov.vcf SARS_CoV2_GenRef_NC_045512.2.fasta "$archivo"_nofilter_toref_uniqs_pipecov.vcf

CrossMap vcf alignment.chain "$archivo"_tocons_uniqs_norm_pipecov.vcf SARS_CoV2_GenRef_NC_045512.2.fasta "$archivo"_nofilter_tocons_uniqs_pipecov.vcf

#Filtrado de variantes.
#Ante la falta de variantes comunes, asumiremos como buenas las variantes de cada archivo que pasen el filtro que les impongamos. Para ello utilizaremos bcftools merge, sort, filter, para fusionar los vcf que contengan las variantes, ordenarlos y por último filtrarlos por profundidad y calidad. Primero, comprimiremos con bgzip los archivos vcf que vayamos a fusionar y filtrar, y también los indexaremos con tabix, para agilizar y mejorar el proceso de filtrado y fusión.

#Como en este caso vamos a coger todas, vamos a coger las no mapeadas frente a la referencia creada por minimap2 al alinear el genoma de referencia y la secuencia consenso generada, si no las que se mapean de manera individual a la referencia y al consenso. En caso de que hubiera variantes comunes frente a la referencia que creamos previamente con minimap2, nos quedaríamos con estas variantes comunes exclusivamente, puesto que indicarían que son variables que se hayan sobre el genoma de referencia, y es mucho más probable que sean variables confiables, mientras que las que en este caso vamos a utilizar, no son las más recomendadas puesto que pueden deberse a artefactos por desplazamientos entre el genoma de referencia y las secuencias consenso.

#Desactivar crossmap environment y activar biosoftwares environment
conda deactivate

for file in *.unmap
do
	mv "$file" "${file/_pipecov.vcf.unmap/_pipecov_unmap.vcf}"
done

for file in *_unmap.vcf
do
	bgzip -k "$file"
	tabix "$file".gz
done 

bcftools merge *_toref_*_unmap.vcf.gz *_tocons_*_unmap.vcf.gz | bcftools sort -o "$archivo"_nofilter_unmap_sort.vcf.gz -O z 
tabix "$archivo"_nofilter_unmap_sort.vcf.gz

bcftools filter -e 'QUAL<20 && INFO/DP<10' -o "$archivo"_filtered_unmap.vcf.gz "$archivo"_nofilter_unmap_sort.vcf.gz

#Copiar archivo a carpeta SNV
cp "$archivo"_filtered_unmap.vcf.gz /home/juanlu/tfm/benchmark/assemblers_comparation/pipecov
cp "$archivo"_filtered_unmap.vcf.gz /home/juanlu/tfm/benchmark/assemblers_comparation/SNV
cd /home/juanlu/tfm/benchmark/assemblers_comparation/SNV
mv "$archivo"_filtered_unmap.vcf.gz "$archivo"_pipecov.vcf.gz
tabix "$archivo"_pipecov.vcf.gz
gunzip "$archivo"_pipecov.vcf.gz


#Posteriormente, un paso adecuado sería observar si alguna de las variantes detectadas coinciden sobre el genoma de referencia con igv. 


