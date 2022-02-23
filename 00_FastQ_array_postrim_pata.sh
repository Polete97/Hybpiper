#!/bin/bash
#SBATCH --array=1-184
#SBATCH -J fastqc_post_trim_pata
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -o /mnt/lustre/scratch/home/csic/dve/pfm/work/patagonia/trim_qc/post_trim_qc/%x_%A_%a.out
#SBATCH -e /mnt/lustre/scratch/home/csic/dve/pfm/work/patagonia/trim_qc/post_trim_qc/%x_%A_%a.err
#SBATCH -p shared
#SBATCH --qos shared
#SBATCH -t 01:20:00
#SBATCH -c 4   

#load modules
ml parallel/20200922
ml openmpi/4.1.1

#run
raw1=$(cat directories.txt | awk -v line=$SLURM_ARRAY_TASK_ID '{if (NR == line) print $0}')
qc1=${raw1%%_1.fastq}"_1P.fastq"
qc2=${raw1%%_1.fastq}"_2P.fastq"
fastqc $qc1 $qc2 -o post_trim_qc