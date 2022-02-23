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
4. Ejecutar **`Hybpiper`** para recuperar dianas nucleares con script **01_hybpip_nuc.sh** dentro de una screen

    ````
    screen -S test
    ````
    

* Ejecutar **`Hybpiper`**

    ````
    bash ../../scripts/01_hybpip_nuc.sh
    
    ````
    * Para salir de la screen : **ctr + a + d**  
    * Para volver a entrar
    
        ````
        ### una shell concreta
        screen -r test  

        ### la shell activa
        screen -x
        ````

    * Para quital la session 
        ````
        screen -X -S test quit
        ````
5. Calcular estadísticas para comprobar que `HybPiper` ha funcionado (desde `screen`)
    ```
    screen -r test
    ```
    * Calcular longitudes para las secuencias mapeadas y ensambladas
    ```
    python /home/csic/dve/pfm/bin/HybPiper/get_seq_lengths.py mega353.fasta names.txt dna > nuc_seq_len.txt
    ```
    * Calcular estadísticas resumen de `HybPiper`
    ```
    python /home/csic/dve/pfm/bin/HybPiper/hybpiper_stats.py nuc_seq_len.txt names.txt > nuc_stats.txt
    ```
6. Comprobar los parálogos detectados por `HybPiper` (desde `screen`)
    ```
    screen -X
    ```
    * Ejecutar `while` loop
    ```
    while read name;
        do echo $name
            python /home/csic/dve/pfm/bin/HybPiper/paralog_investigator.py $name 2>> nuc_para.log
        done < names.txt
    ```
7. Por último, recuperar las secuencias (desde `screen`)
    ```
    python /home/csic/dve/pfm/bin/HybPiper/retrieve_sequences.py mega353.fasta . dna supercontig 2>> nuc retrseqs.log 
    ```