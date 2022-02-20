#!/bin/bash -login
#SBATCH --constraint=[intel16|intel18|amd20]
#SBATCH --job-name=myJobName             # specify a job name
#SBATCH --nodes=1 --ntasks=1 --cpus-per-task=1 --time=12:59:00 --mem=8G      # specify the resources needed
#SBATCH --licenses=matlab@27000@lm-01.i:1        # specify the license request
 
cd $SLURM_SUBMIT_DIR                            # go to the directory where this job is submitted

#symbol
# matlab -nodisplay -r "addpath(genpath('./.'));cd 3_deployment/symbol_emulation;eva_16a"

# matlab -nodisplay -r "addpath(genpath('./.'));cd 3_deployment/symbol_emulation;eva_16b"

# matlab -nodisplay -r "addpath(genpath('./.'));cd 3_deployment/symbol_emulation;clear;clc;SF = 7:12;eva_17"

# matlab -nodisplay -r "addpath(genpath('./.'));cd 3_deployment/symbol_emulation;clear;clc; SF = 7:12; eva_18"

matlab -nodisplay -r "addpath(genpath('./.'));cd 3_deployment/outdoor_emulation;main_outdoor"
# matlab -nodisplay -r "addpath(genpath('./.'));cd 3_deployment/outdoor_emulation;outdoor_mixing"

# matlab -nodisplay -r "addpath(genpath('./.'));cd 3_deployment/rfid_noise;eva_rfid"

# matlab -nodisplay -r "addpath(genpath('./.'));cd 3_deployment/rfid_noise;eva_8a"


scontrol show job ${SLURM_JOBID}