#!/bin/bash
#SBATCH --array=1-178
#SBATCH -J MAFFT_array_pata
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -o /lustre/scratch/cpokorny/marga/logs/aln_178/%x_%A_%a.out
#SBATCH -e /lustre/scratch/cpokorny/marga/logs/aln_178/%x_%A_%a.err
#SBATCH -p quanah
#SBATCH -A default

## prior to running shell:
## create directory in logs for array outputs
#  mkdir -p /lustre/scratch/cpokorny/marga/logs/aln_178
## create txt file with paths to FNA files
#  find . -maxdepth 1 -name "*.FNA" > paths_to_fna_senecio.txt
## count lines to determine total array number
#  wc -l paths_to_fna_senecio.txt
## 178 genes

## load modules
ml gnu/5.4.0
ml openmpi/1.10.6
ml mafft/7.402

## go to working folder
cd /lustre/scratch/cpokorny/marga/aln/

## create aln folder(s)
mkdir -p aln_178/

## paths to FNA files
unaln_file=$(cat paths_to_fna_senecio.txt | awk -v line=$SLURM_ARRAY_TASK_ID '{if (NR == line) print $0}')
## get the subdir (000*/) in which each fasta was saved and file name
aln_file=$(basename $unaln_file | sed 's/\.FNA/\.aln/g')

## align FNA files
mafft --genafpair --maxiterate 1000 --thread 4 --threadit 0 $unaln_file > aln_178/$aln_file
## THE END

