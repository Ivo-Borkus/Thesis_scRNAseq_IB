#!/usr/bin/env bash

#SBATCH --job-name="105086-009-003"
#SBATCH --chdir=/scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/105086-009-003_BrM23-25
#SBATCH --time=23:00:00
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH --qos=long
                        						
         		
#SBATCH --error ./logs/slurm-.%N.%j.err 
#SBATCH --output ./logs/slurm-%N.%j.out                      							      						



/scratch_isilon/groups/singlecell/shared/software/cellranger/cellranger-9.0.0/cellranger multi --id 105086-009-003 \
    --csv /scratch_isilon/groups/singlecell/iborkus/Projects/brain_met/105086-009-003_BrM23-25/105086-009-003.csv \
    --localcores 2 \
    --jobmode /scratch_isilon/groups/singlecell/shared/software/cellranger/cellranger-9.0.0/external/martian/jobmanagers/slurm.template





