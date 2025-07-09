#!/bin/bash

#Script para ejecutar todo el proceso de obtención del arbol filogenético.

#IMPORTANTE: crear un entorno fasta con los softwares necesarios. Los requerimientos del entorno se encontraran recogidos en el archivos phylogenomic.yml, a partir del cual podrás crear el entorno directamente con los requerimientos necesarios.

#Activar entorno conda antes de lanzar el script: "conda activate phylogenomic"

#1.Crear una lista con los "accesion number" de los genomas a descargar.

echo -e "KF430219\nJQ989270\nAF304460\nAY567487\nMN908947\nAY613950\nEF065513\nJX869059\nFJ376619\nEU111742\nKM454473\nMK611985\n" | tee accesion.txt

#2. Utilizar Batch Entrez (https://www.ncbi.nlm.nih.gov/sites/batchentrez) para descargar las secuencias fasta a partir de la lista de "accesion numbers" creada.

cp ~/Descargas/sequences.fasta .

#3·Concatenación de todos los genomas en formato fasta en un único multifasta (supermatriz)

cat *fasta > multifasta.fasta

#4·Alineamiento multiple de las secuencias con mafft

mafft --auto --thread 5 multifasta_phylogenomic.fasta > phylomatrix.fasta

#5·Limpieza alineamiento

trimal -in phylomatrix.fasta -out phylomatrix_clean.fasta -noallgaps -automated1 -htmlout summary_trimal.html

#6·Elaboración arbol con iqtree y otro con raxml

iqtree -s phylomatrix_clean.fasta --seqtype DNA --mem 8G -T 5 -m MFP -B 1000 --nmax 1000 --nstep 100 --prefix sarscov2


