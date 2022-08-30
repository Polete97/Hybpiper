# Trimado y control de calidad de secuencias en crudo
## Preprocesado con fastQC y trimmomatic
1. desde carpeta **raw** descomprimir secuencias con `gunzip`
    ```
    gunzip -k PAFTOL_0*.fastq.gz
    ```
2. mover (`mv`) secuencias descomprimidas desde **raw** a **trim_qc** 
    ```
    mv *.fastq ../../work/trim_qc/.
    ```
3. control de calidad de secuencias descomprimidas en crudo con `fastqc` con el script **00_fastqc_pre_trim.sh**
    ```
    bash 00_fastqc_pre_trim.sh
    ```
4. trimado con `trimmomatic` para eliminar adaptadores y seqs de baja calidad con el script **00_trim_qc.sh**
    ```
    bash 00_trim_qc.sh
    ```
5. control de calidad de secuencias trimadas PE con `fastqc` con el script **00_fastqc_post_trim.sh**
    ```
    bash 00_fastqc_post_trim.sh
    ```
