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

## **Genomic Assembly & benchmarking**
