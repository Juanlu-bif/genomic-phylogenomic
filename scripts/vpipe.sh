#!/bin/bash

#Es importante activar el entorno vpipe de conda de manera previa a ejecutar este script. Las dependencias y softwares que componen este entorno se encontran guardadas en el archivo vpipe.yml
#conda activate V-pipe

cd ~/tfm/benchmark/
mkdir vpipe_output
cd vpipe_output
cp /home/juanlu/tfm/benchmark/assemblies/vpipe/quick_install.sh .
bash quick_install -p vp_analysis -w work
cd vp_analysis/work
array=( "SRR33436961" "SRR33190466" )
mkdir samples
cd samples
for i in ${array[@]}
do
    mkdir "$i"
    cd "$i"
    directorio=$(date | awk '{print$3$4}')
    mkdir $directorio
    cd $directorio
    mkdir raw_data
    cd raw_data 
    cp ~/tfm/benchmark/$i/*fastq.gz .
    mv "$dir"_1.fastq.gz "$dir"_R1.fastq.gz 
    mv "$dir"_1.fastq.gz "$dir"_R2.fastq.gz
    cd ../../../
done
cd ..
.vpipe --dryrun --cores 2
#Se generará la samples.tsv, un archivo tabular, en el cual, la primera columna recoge el nombre de la muestra, la segunda la identificación que le hayamos puesto (en este caso la hora de generación), y la tercera no vendrá, habrá que añadirla manualmente en el caso de pocas muestras (como este caso), o bien mediante la elaboración y ejecución de un script para dicha función. Esta tercera columna debe contener la longitud de las lecturas, para que aquellos softwares como shora, que así no utilicen las longitud de lectura establecidas por defecto en dichos softawares, puesto que puede darse fallos en la ejecución, o generación de archivos incorrectos.

./vpipe -p --cores 5 --conda-frontend conda