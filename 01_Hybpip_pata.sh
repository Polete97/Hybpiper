#!/bin/bash
#SBATCH -J hibpip_pata
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 20
#SBATCH --mail-type=begin #Envía un correo cuando el trabajo inicia
#SBATCH --mail-type=end #Envía un correo cuando el trabajo finaliza
#SBATCH --mail-user=pol.fernandez@csic.es #Dirección a la que se envía
#SBATCH -p shared
#SBATCH --qos shared
#SBATCH -t 4-02:40:00 

#load modules
ml biopython/1.77-python-3.7.7


while read name;
	do /home/csic/dve/pfm/bin/HybPiper/reads_first.py -b mega353.fasta -r $name*.fastq --prefix $name --bwa
        python /home/csic/dve/pfm/bin/HybPiper/cleanup.py $name
        python /home/csic/dve/pfm/bin/HybPiper/intronerate.py --prefix $name
	done < names.txt
