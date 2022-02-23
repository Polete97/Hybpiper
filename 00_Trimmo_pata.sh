#!/bin/bash
#SBATCH -J Trim_pata
#SBATCH -N 1
#SBATCH -c 6
#SBATCH -p shared
#SBATCH --qos shared
#SBATCH -t 08:10:00  

#load modules
ml parallel/20200922
ml openmpi/4.1.1

#run but first
gunzip /mnt/netapp1/Store_CSIC/home/csic/dve/pfm/raw_patagonia/*.gz 
cp /mnt/netapp1/Store_CSIC/home/csic/dve/pfm/raw_patagonia/*.fastq /mnt/lustre/scratch/home/csic/dve/pfm/work/patagonia/trim_qc/.

for raw in *_1.fastq;
do
    qc=${raw%%_1.fastq}".fastq"
    trimmomatic PE -phred33 -trimlog ${raw%%_1.fastq} -basein $raw -baseout $qc ILLUMINACLIP:/home/csic/dve/pfm/miniconda3/share/trimmomatic-0.39-2/adapters/TruSeq3-PE-2.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50
done

