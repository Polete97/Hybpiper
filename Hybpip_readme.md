# Trimado y control de calidad de secuencias en crudo
## Preprocesado con fastQC y trimmomatic
1. desde carpeta **raw** descomprimir secuencias con `gunzip`
    ```bash
    gunzip -k PAFTOL_0*.fastq.gz
    ```
2. mover (`mv`) secuencias descomprimidas desde **raw** a **trim_qc** 
    ```bash
    mv *.fastq ../../work/trim_qc/.
    ```
3. control de calidad de secuencias descomprimidas en crudo con `fastqc` con el script **00_fastqc_pre_trim.sh**
    ```bash
    bash 00_fastqc_pre_trim.sh
    ```
4. trimado con `trimmomatic` para eliminar adaptadores y seqs de baja calidad con el script **00_trim_qc.sh**
    ```bash
    bash 00_trim_qc.sh
    ```
5. control de calidad de secuencias trimadas PE con `fastqc` con el script **00_fastqc_post_trim.sh**
    ```bash
    bash 00_fastqc_post_trim.sh
    ```
    
# Ensamblado de secuencias trimadas y pareadas
## Postprocesado con Hybpiper

1. Copiar reads pareados de `trim_qc` a `hybpip_nuc`

    ````
    cp trim_qc/*P.fastq ./hybpip_nuc/
    ````
2. Descargar archivo dianas nucleares `mega353`

*   descargar
    ````
    wget https://github.com/chrisjackson-pellicle/NewTargets/raw/master/mega353.fasta.zip
    ````
* descomprimir 
    ````
    unzip mega353.fasta.zip
    ```` 
3. Crear lista de nombres sin duplicados
    ````
    basename -s _1P.fastq *_1P.fastq > names.txt
    ````
4. Ejecutar **`Hybpiper`** para recuperar dianas nucleares con script **01_hybpip_nuc.sh** 

    ````
    bash ../../scripts/01_hybpip_nuc.sh
    
    ````
5. Calcular estadísticas para comprobar que `HybPiper` ha funcionado + paralogos + recuperar sequencias **02_post_hybpip_nuc.sh**


    * Calcular longitudes para las secuencias mapeadas y ensambladas
    ```
    python /home/csic/dve/pfm/bin/HybPiper/get_seq_lengths.py mega353.fasta names.txt dna > nuc_seq_len.txt
    
    ```
    * Calcular estadísticas resumen de `HybPiper`
    ```
    python /home/csic/dve/pfm/bin/HybPiper/hybpiper_stats.py nuc_seq_len.txt names.txt > nuc_stats.txt
    ```
    * Comprobar los parálogos detectados por `HybPiper`

    ```
    while read name;
        do echo $name
            python /home/csic/dve/pfm/bin/HybPiper/paralog_investigator.py $name 2>> nuc_para.log
        done < names.txt
    ```
    * Por último, recuperar las secuencias 
    ```
    python /home/csic/dve/pfm/bin/HybPiper/retrieve_sequences.py mega353.fasta . dna supercontig 2>> nuc retrseqs.log 
    ```
# Generar matrices y refinarlas (alinear, trimar,  encoger y realinear)
## Empleando `MAFFT` (alinear y realinear), `trimAl` (para trimar), `FastTree2` (para inferir filos rápidas), `TreeShrink` (para eliminar taxa fuera de rango) y `AMAS` (para controlar la calidad de los alineamientos)  
1. Mover (`mv`) archivos FNA con seqs supcontig desde carpeta **hybpip_nuc**
    ```
    mv work/hybpip_nuc/*.FNA work/aln_nuc/.
    ```
2. Poner en cuarentena genes con tres o más parálogos
- crear lista y carpeta
    ```
    nano para_3-n-up.txt

    mkdir para_3-n-up
    ```
- `while` loop para trasladar genes con parálogos
    ```
    while read para; 
        do mv $para".FNA" para_3-n-up/.; 
        done < para_3-n-up.txt
    ```
3. Poner en cuarentena genes menos de 2/3 de la mediana de la matriz  
- contar seqs por gene
    ```
    for gene in *.FNA; 
        do grep --with-filename --count ">" $gene; 
        done > seqs_per_gene_no-para_3-n-up.txt
    ```
- crear lista de genes con menos de 2/3 de la mediana de la matriz y crear carpeta
    ```
    nano less_two_thirds_median_seqs.txt

    mkdir less_two_thirds_median_seqs
    ```
- trasladar genes en lista a carpeta usando `while` loop
    ```
    while read gene; 
        do mv $gene".FNA" less_two_thirds_median_seqs/.; 
        done < less_two_thirds_median_seqs.txt
    ```
4. Alinear con MAFFT
  - crear carpeta para outputs
    ```
    mkdir aln_nuc_325
    ```
  - Obtener directorios de archivos FNA
    ```
    find . -maxdepth 1 -name "*.FNA" > paths_to_fna_senecio.txt
    ```
  - Ejecutar script de `bash` *bash 02_mafft_nuc.sh*
   
      ```
      ## paths to FNA files
      unaln_file=$(cat paths_to_fna_senecio.txt | awk -v line=$SLURM_ARRAY_TASK_ID '{if (NR == line) print $0}')
      ## get the subdir (000*/) in which each fasta was saved and file name
      aln_file=$(basename $unaln_file | sed 's/\.FNA/\.aln/g')

      ## align FNA files
      mafft --genafpair --maxiterate 1000 --thread 4 --threadit 0 $unaln_file > aln_nuc_222/$aln_file
      ## THE END
      ```
5. Trimar con TrimAL + Fasttree
    - Crear directorios
     ```
     mkdir trimAL_222
     mkdir fasttree_222
     ```
  - Ejecutar script de `bash` *bash 03_TrimAl+Fasttree_nuc.sh*
     ```
     find . -maxdepth 1 -name "*.aln" paths_to_aln.txt
     ## paths to FNA files
    aln_file=$(cat paths_to_aln.txt | awk -v line=$SLURM_ARRAY_TASK_ID '{if (NR == line) print $0}')
    ## get the subdir (000*/) in which each fasta was saved and file name
    trim_file=$(basename $aln_file | sed 's/\.aln/\.trim.aln/g')
    tree_file=$(basename $aln_file | sed 's/\.aln/\.trim.tree/g')
    ## trim aln files
    trimal -in $aln_file -out ./trimAL_222/$trim_file -automated1

    ## fasttree
    FastTree ./trimAL_222/$trim_file > ./fasttree_222/$tree_file
    ## THE END
     ```

6. Eliminar taxa fuera de rango con Treeshrink

    - Ir a la carpeta con FNA y crear carpeta para resultados shrink
    ```
    cd ../
    mkdir shrnk_222_nuc
    ```
    - Crear lista de FNA, contar genes y crear carpeta para cada gen dentro de la carpeta de outputs
    ```
    basename -s .FNA *.FNA > nuc_genes.txt
    wc -l nuc_genes.txt
    while read gene; do mkdir -p shrnk_222_nuc/$gene; done < nuc_genes.txt
    ```
    - Ir a la carpeta de fastrees y copiarlos a las carpetas que hemos creado en el paso anterior (modificar paths)
    ```
    cd fasttree_222
    for f in *.trim.tree; do
      [[ -f "$f" ]] || continue # skip if not regular file
      dir=./../../shrnk_222_nuc/"${f%.trim.*}"
      cp "$f" "$dir"
    done
     ```
     - Ir a la carpeta de trimal y copiar a las carpetas que hemos creado en el paso anterior (modificar paths)
     ```
    cd ../trimAL_222
    for f in *.trim.aln; do
      [[ -f "$f" ]] || continue # skip if not regular file
      dir=./../../shrnk_69_pl/"${f%.trim.*}"
      cp "$f" "$dir"
	  done
    ```
    - Cambiar nombres de los archivos para que tengan el mismo nombre (modificar paths)
    ```
    for f in ./*/*.tree; do
      directory=$(pwd $f)
      name1=$(dirname $f)
      name=$(basename $name1)
      tre="${directory}/${name}/tre.tree"	
      mv $f $tre
    done
    ```
    ```
    for f in ./*/*.aln; do
      directory=$(pwd $f)
      name1=$(dirname $f)
      name=$(basename $name1)
      tre="${directory}/${name}/alignment.aln"	
      mv $f $tre
    done
    ```
    - Ejecutar script de `bash` *bash 04_Treeshrink_nuc.sh*
    ````
    ## shrink aln files
    /home/csic/dve/pfm/miniconda3/bin/run_treeshrink.py -i ./shrnk_222_nuc -t tree.tre -a alignment.aln -m per-species -q "0.05 0.5"
    ## THE END
    ````
    - Cambiar nombres de los outputs segun su carpeta
    ````
    for f in ./*/output*; do 
      result=$(dirname $f)
      result1=$(basename $result)
      mv $f "${f%.*}-$result1.${f##*.}"
     done
     ````
     - Crear carpeta de realiniamento (para uno o todos los tresholds) copiar todos los archilvos *.aln* 
     ```
     mkdir aln_shrink_0.5 #para treahold 0.5
     cp ./*/*.aln ./aln_shrink_0.5
     ```
     -Realinear con MAFFT con script de `bash` *bash 05_MAFFT_realign_nuc.sh*
    ```
      find . -maxdepth 1 -name "*.FNA" > paths_to_aln_senecio.txt
      mkdir realn_nuc_222
       
      ## paths to FNA files
      unaln_file=$(cat paths_to_aln_senecio.txt | awk -v line=$SLURM_ARRAY_TASK_ID '{if (NR == line) print $0}')
      ## get the subdir (000*/) in which each fasta was saved and file name
      aln_file=$(basename $unaln_file | sed 's/\.FNA/\.aln/g')

      ## align FNA files
      mafft --genafpair --maxiterate 1000 --thread 4 --threadit 0 $unaln_file > realn_nuc_222/$aln_file
      ## THE END
      ```
5. Trimar con TrimAL 
    - Crear directorios
     ```
     mkdir trimAL_222
     ```
     - Ejecutar script de `bash` *bash 06_TrimAl_nuc.sh*
     ```
    find . -maxdepth 1 -name "*.aln" paths_to_aln.txt
     ## paths to FNA files
    aln_file=$(cat paths_to_aln.txt | awk -v line=$SLURM_ARRAY_TASK_ID '{if (NR == line) print $0}')
    ## get the subdir (000*/) in which each fasta was saved and file name
    trim_file=$(basename $aln_file | sed 's/\.aln/\.trim.aln/g')
    ## trim aln files
    trimal -in $aln_file -out ./trimAL_222/$trim_file -automated1
    ```
    
    8. Hacer arboles de genes con IQTree

- Ejecutar script de `bash` *bash 07_IQtree_nuc.sh*

        ```
        ## iqtree files
        for i in *.aln;
          do
          iqtree -s $i -m MFP
        done

        ```
   9. Juntar arboles con ASTRAL

- create working folder and concatenate shrunk, trimmed gene tree files inside it
    ```
    mkdir sptre_nuc 
    
    cd sptre_nuc
    
    cat ../gtre_nuc/gtre_316_nuc/*.shrnk.trm.treefile > poppy.nuc.316.shrnk.trm.gene.trees
    ```
- create thresholds file and collapse bipartitions under said thresholds
    ```
    nano bs_thresholds.txt

    while read bs;
        do
            /PATH_TO_TOOL/bin/nw_ed poppy.nuc.316.shrnk.trm.gene.trees 'i & b<'$bs'' o > poppy.nuc.316.bs$bs.shrnk.trm.gene.trees
        done < bs_thresholds.txt
    ```
- Submit batch script to SLURM
    ```
    sbatch 10-0_ASTRAL_sptr_bs_nuc_poppy.sh
    ```
    - this script runs ASTRAL inside a `while` loop to iterate over all BS collapse thresholds (w or w/o *t -2* flag)
        ```
        while read bs;
	        do
		        java -jar /PATH_TO_TOOL/bin/ASTRAL/astral.5.6.3.jar -i poppy.nuc.316.bs$bs.shrnk.trm.gene.trees -t 2 -o poppy.nuc.316.bs$bs.t2.shrnk.trm.sp.tre 2> poppy.nuc.316.bs$bs.t2.shrnk.trm.sp.log
		        
                #java -jar /PATH_TO_TOOL/bin/ASTRAL/astral.5.6.3.jar -i poppy.nuc.316.bs$bs.shrnk.trm.gene.trees -o poppy.nuc.316.bs$bs.shrnk.trm.sp.tre 2> poppy.nuc.316.bs$bs.shrnk.trm.sp.log
	        done < bs_thresholds.txt
        ```
- Estimate branch lengths on given (BS ≥ 11%) species tree (`sbatch 10-1_RAxML-NG_sptr_brlen_nuc_poppy.sh)
    ```
    /PATH_TO_TOOL/bin/raxml-ng --evaluate --msa poppy.nuc.316.shrnk.trm.concat.phy --prefix "poppy.nuc.316.shrnk.trm.concat.brlen" --model poppy.nuc.316.shrnk.trm.concat.parts --tree poppy.nuc.316.bs11.shrnk.trm.sp.tre --brlen scaled --seed 42 --threads 16 --force perf_threads
    ```
### **THE END**

   ```
    
    


    
