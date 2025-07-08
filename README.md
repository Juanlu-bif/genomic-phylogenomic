# genomic-phylogenomic
Trabajo de genomica, y comparación de varias pipelines utilizadas en genómica del SARS-CoV-2, y elaboración de un protocolo básico de filogenómica del SARS-CoV-2. Tanto el protocolo de filogenómica, como alguna de las pipelines, se podrían adaptar y utilizar con otro tipo de organismos.

En este repositorio se recoge todos los resultados, código utilizado y archivos generados durante el desarrollo del trabajo "Genómica y Filogenómica del SARS-CoV-2", incluyendo también la memoria desarrollada durante el trabajo. La parte genómica y de comparación de pipelines siguen un procedimiento similar al seguido por [alversco](https://github.com/alvesrco/pipecov/tree/master) para la comparación de su pipeline "PipeCov" frente a otras pipelines. De hecho, la pipeline a comprobar es PipeCov frente a Vpipe y nf-core/Viralrecon, para poder corrobar los resultados que obtuvo su creador, solo que en este caso, el experimento se ha realizado a pequeña escala debido a limitaciones computacionales. 

A continuación, describimos los procesos llevamos a cabo.

Lo primero es llevar a cabo la instalación de los entornos conda necesarios, así como la instalación de las pipelines a utilizar. Como herramienta de instalación de la mayoría de paquetes, utilizaremos el gestor de paquetes y entornos conda, instalado previamente según las instrucciones de su web <https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html> 

### Conda environment
Los archivos de extensión yml para la creación de los entornos se encuentran en la carpeta "environments"

##### Instalación de entorno conda
'conda env create -f file.yml'

##### Listado de entornos:
1. biosoftwares.yml
2. dataplots.yml
3. phylogenomic.yml
4. quast.yml
5. V-pipe.yml
6. nextflow.yml

# **GENOMIC ASSEMBLY & BENCHMARKING**


## Instalación PipeCoV

`git clone https://github.com/alvesrco/pipecov.git`

## Instalación ViralRecon

Instalación desde conda, con el fin de crear un entorno aislado para evitar modificaciones en las dependencias de la maquina virtual utilizada.

conda env create -f nextflow.yml

## Instalación V-pipe

Instalación desde conda, con el fin de crear un entorno aislado para evitar modificaciones en las dependencias de la maquina virtual utilizada.

conda env create -f V-pipe.yml
curl -O 'https://raw.githubusercontent.com/cbg-ethz/V-pipe/master/utils/quick_install.sh'
./quick_install.sh -w work

## Ensamblaje PipeCoV

El ensamblaje con PipeCoV fue llevado a cabo tal como se indica en su repositorio de github <https://github.com/alvesrco/pipecov>, a excepción de una modificación sobre la pipeline, que se realizó con el fin de que adapter removal realizará la autodetección de los adaptadores de las secuencias, puesto que los adaptadores de algunas de las carreras de secuenciación utilizadas en este trabajo no los conociamos. La pipeline original requiere la secuencia de los adaptadores, pero tras la modificación, adapter removal se encargaba de autodetectarlos en caso de que los hubiera. Esta pipeline con esta pequeña modificación se encuentra recogida en el directorio PipeCoV_mod.

Tras la modificación, pasamos a la ejecución de la pipeline:

      ./qc_docker.sh -i illumina -1 file_1.fastq.gz -2 file_2.fastq.gz -q 28 -l 50 -o qc_output -t 4
      
      ./assembly_docker.sh -i illumina -1 qc_output/file_good.pair1.truncated -2 qc_output/file_good.pair2.truncated -r reference_genome.fasta -k 30 -m2 -l 100 -c 10 -o assembly_output -t 5 -s sample_name -g4

Estos comandos recogen la ejecución general que se llevó a cabo para el procesado de las lecturas, y el posterior ensamblaje. Todos los comandos utilizados se recogen en el script "pipecov.sh", encontrado en la carpeta de scripts. 

## Ensamblaje ViralRecon

## Ensamblaje V-pipe

## BENCHMARKING
