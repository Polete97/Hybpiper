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
- ejecutar script de `bash` (dentro de `screen`)
    ```
    bash 02_mafft_nuc.sh
    ```
    - Dentro va un `for` loop para alinear con `MAFFT`
        ```
        for gene in *.FNA;
            do mafft --genafpair --maxiterate 1000 $gene > aln_nuc_325/${gene%%.FNA}".aln" 2>> aln_nuc_325.log
            done
        ```
5. Trimar con TrimAL
       
     ```
    trimal -in <inputfile> -out <outputfile> -automated1
     ```

6. Fasttree
     ```
    FastTree alignment.file > tree_file 
     ```

6. AMAS
     ```
    python3 AMAS.py summary -f fasta -d dna -i *phy 
     ```
