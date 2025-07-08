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

La ejecución de ViralRecon fue llevada a cabo tal y como se indica en su documentación (<https://github.com/nf-core/viralrecon>), teniendo en cuenta que una de las carreras de secuenciación utilizadas fue secuenciada mediante amplicones, y la otra mediante WGS o Whole Genome Sequencing. Esto es importante para la ejecución de esta pipeline, puesto que hay que elegir entre dos protocolos a la hora de ejecutarla, "amplicon" o "metagenomic". En el caso de que la estrategia de secuenciación haya sido WGS, entonces utilizaremos el protocolo "metagenomic".

Para el uso de ambos protocolos, viralrecon facilita la descarga de un script de python que permite la preparación de la "samplesheet" necesaria para la ejecución de esta pipeline:

      wget -L https://raw.githubusercontent.com/nf-core/viralrecon/master/bin/fastq_dir_to_samplesheet.py


### Protocolo **"amplicon"**:

En este caso es importante descargar previamente el archivo bed que contiene los adaptadores de los amplicones, tal como se recoge en la memoria del trabajo.

      python3 fastq_dir_to_samplesheet.py /directorio/fastqs viralrecon_samplesheet.csv -r1 _1.fastq.gz -r2 _2.fastq.gz -sn -sd _ -si 1

      nextflow run nf-core/viralrecon --input viralrecon_samplesheet.csv --outdir viralrecon_output --platform illumina --genome 'MN908947.3' --protocol amplicon --primer_bed file_adapters_amplicon.bed -profile docker

### **Protocolo "metagenomic"**:

      python3 fastq_dir_to_samplesheet.py /directorio/fastqs viralrecon_samplesheet.csv -r1 _1.fastq.gz -r2 _2.fastq.gz -sn -sd _ -si 1

      nextflow run nf-core/viralrecon --input viralrecon_samplesheet.csv --outdir viralrecon_output --platform illumina --genome 'MN908947.3' --protocol metagenomic -profile docker

Estos comandos recogen la ejecución general que se llevó a cabo para la limpieza de lecturas y el ensamblaje. Todos los comandos utilizados se recogen en el script "viralrecon.sh", encontrado en la carpeta de scripts.

## Ensamblaje V-pipe

Para la ejecución de Vpipe se llevaron a cabo los pasos descritos en su repositorio de github y documentación: <https://cbg-ethz.github.io/V-pipe/>. Para ejecución de esta pipeline, lo más importante es su jerarquía de directorios, para que su ejecución no lance errores, o genere errores en los archivos. A continuación, se describen los comandos para la ejecución de Vpipe, pero al igual que en las otros 2 pipelines anteriores, serán los comandos principales y representativos de la ejecución de la pipeline. Todo el proceso de ejecución se encuentra recogido en el script "vpipe.sh", en la carpeta scripts.
Recuerda que es necesario activar el entorno vpipe de forma previa a su ejecución.

      #Configuración del archivo "config.yml"
      
      ./vpipe --dryrun --cores 2
      
      #Modificación manual de la samples.tsv generada 

      ./vpipe -p --cores 5 --conda-frontend conda

## BENCHMARKING

