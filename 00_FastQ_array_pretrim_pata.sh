#!/bin/bash
#SBATCH --array=1-184
#SBATCH -J fastqc_pre_trim_pata
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -o /mnt/lustre/scratch/home/csic/dve/pfm/work/patagonia/trim_qc/pre_trim_qc/%x_%A_%a.out
#SBATCH -e /mnt/lustre/scratch/home/csic/dve/pfm/work/patagonia/trim_qc/pre_trim_qc/%x_%A_%a.err
#SBATCH -p shared
#SBATCH --qos shared
#SBATCH -t 01:10:00
#SBATCH -c 4 

#load modules
ml parallel/20200922
ml openmpi/4.1.1

## basename -a *_1.fastq > directories.txt

raw1=$(cat directories.txt | awk -v line=$SLURM_ARRAY_TASK_ID '{if (NR == line) print $0}')
raw2=${raw1%%_1.fastq}"_2.fastq"
fastqc $raw1 $raw2 -o pre_trim_qc
