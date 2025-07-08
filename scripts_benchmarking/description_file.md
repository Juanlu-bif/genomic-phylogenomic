En este directorio encontramos los script elaborados en python y bash para llevar a cabo las comparaciones entre las diferentes pipepines.


### 1. **genome_comparison_long.py**

  Para ejecutar este archivo es necesario tener en un mismo directorio el genoma de referencia de la especie (en este caso el SARS-CoV-2) y la secuencia consenso obtenida con cada pipeline (en este caso PipeCoV, V-pipe y Viralrecon).
  
  Previo a su ejecución, hay que modificar la función "plot_length_comparison" del script, concretamente las líneas 21 y 22 del script, donde a las variables "samples" y "pipelines" hay que darles el valor del identificador de las muestras y el nombre de las pipelines a comparar, respectivamente. 
  
  Es importante también que el nombre de los archivos fasta con la secuencia consenso de cada pipeline tengan el siguiente formato en funcion de la muestra y la pipeline que lo haya generado: "{sample}_{pipeline}_consensus.fasta".
  
  Ejecución: Con el entorno conda "dataplots" activado:
      
      `python3 genome_comparison_long.py`

### 2. **count_n_bases.py**

  Para ejecutar este archivo es necesario tener en un mismo directorio el genoma de referencia de la especie (en este caso el SARS-CoV-2) y la secuencia consenso obtenida con cada pipeline (en este caso PipeCoV, V-pipe y Viralrecon).
  
  Previo a su ejecución, hay que modificar la función "plot_n_comparison" del script, concretamente las líneas 25 y 26 del script, donde a las variables "samples" y "pipelines" hay que darles el valor del identificador de las muestras y el nombre de las pipelines a comparar, respectivamente. 
  
  Es importante también que el nombre de los archivos fasta con la secuencia consenso de cada pipeline tengan el siguiente formato en funcion de la muestra y la pipeline que lo haya generado: "{sample}_{pipeline}_consensus.fasta".
  
  Ejecución: Con el entorno conda "dataplots" activado:
      
      `python3 count_n_bases.py`

### 3. **vcf_analysis.py**

  Para ejecutar este archivo es necesario tener en un mismo directorio el genoma de referencia de la especie (en este caso el SARS-CoV-2) y el archivo de variantes obtenido con cada pipeline (en este caso PipeCoV, V-pipe y Viralrecon).
  
  Previo a su ejecución, hay que modificar la función "plot_variants" del script, concretamente las líneas 17 y 18 del script, donde a las variables "samples" y "pipelines" hay que darles el valor del identificador de las muestras y el nombre de las pipelines a comparar, respectivamente. 
  
  Es importante también que el nombre de los archivos ".vcf" de las variantes obtenidas con cada pipeline tengan el siguiente formato en funcion de la muestra y la pipeline que lo haya generado: "{sample}_{pipeline}.vcf".
  
  Ejecución: Con el entorno conda "dataplots" activado:
      
      `python3 vcf_analysis.py`
  
  En el caso de este script, se utilizó no solo para comparar las variantes, si no para comparar las variantes tras el filtrado de las mismas. Para ello, se filtraron las variantes con el scritp "filter_vcf.sh", concretamente utilizando bcftools filter, y los archivos vcf filtrados se renombraron para que coincidieran con el formato de nombre necesario para la ejecución de este script.

### 4. **filter_vcf.sh**

   Script utilizado para llevar a cabo el filtrado de variantes de los archivos vcf obtenidos de las diferentes pipelines. Es importante tener en cuenta a la hora de utilizarlo los directorios y hacer los cambios correspondientes. En el se recogen las condiciones de filtrado utilizadas para los vcf generados por las distintas pipelines.

   Ejecución: Para ejecutarlo es necesario dar a este script permisos de ejecución, activar el entorno conda donde se haya instalado bcftools (en este caso, <biosoftwares>) y posteriormente lanzarlo para que se ejecute.

   `sudo chmod u+x filter_vcf.sh; ./filter_vcf.sh`
