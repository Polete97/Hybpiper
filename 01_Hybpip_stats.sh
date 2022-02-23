#!/bin/bash
#SBATCH -J hibpip_pata
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 4
#SBATCH -p shared
#SBATCH --qos shared
#SBATCH -t 4-02:40:00 


#load modules (cargar antes)
ml biopython/1.77-python-3.7.7
ml openmpi/1.10.7
ml intel


python /home/csic/dve/pfm/bin/HybPiper/get_seq_lengths.py mega353.fasta names.txt dna > nuc_seq_len.txt

python /home/csic/dve/pfm/bin/HybPiper/hybpiper_stats.py nuc_seq_len.txt names.txt > nuc_stats.txt

while read name;
    do echo $name
        python /home/csic/dve/pfm/bin/HybPiper/paralog_investigator.py $name 2>> nuc_para.log
    done < names.txt
done

python /home/csic/dve/pfm/bin/HybPiper/retrieve_sequences.py mega353.fasta . dna supercontig 2>> nuc retrseqs.log 

