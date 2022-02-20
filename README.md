# CurvingLoRa

This repository contains scripts and instructions for reproducing the experiments in our NSDI'22 paper "
CurvingLoRa to Boost LoRa Network Capacity via Concurrent Transmission". 
<!-- [CurvingLoRa to Boost LoRa Network Capacity via Concurrent Transmission](https://www.usenix.org/conference/osdi21/presentation/lai)".  -->

# Overview

* [Environment Setting](#environment-setting)
* [Repo Structure](#repo-structure)
* [Reproduce Results with Provided Logs](#reproduce-results-with-provided-logs)
* [Reproduce Results from Scratch](#reproduce-results-from-scratch)
* [Notes](#notes)
* [Contact](#contact)

# Environment Setting

Required Software:

* MatLab - Processing & Algorithm
* GNU Radio - Data Collection

Run the following commands to download CurvingLoRa from GitHub. 

```
git clone https://github.com/liecn/CurvingLoRa_NSDI22.git
cd CurvingLoRa_NSDI22
cp config_example.m config.m
# update the HOME_DIR in the config.m
```

# Repo Structure

```
Repo Root
+-- 0_demo                  # A toy example for non-linear chirp generation.
+-- 1_observation           # Fig 5(a)-(d), Fig 7(a)-(d).
+-- 2_simulation            # Fig 6(a)-(b), Fig 8(a)-(b).
+-- 3_deployment            # Evalution Part
    +-- symbol_emulation    # Fig 16(a)-(b), Fig 17(a)-(d), Fig 18(a)-(d).
    +-- outdoor_emulation   # Fig 20(a)
    +-- result              # Results
    +-- transmitter         # Matlab scripts for packet generation
+-- data                    # Dataset
    +-- symbol              # Indoor symbol dataset
    +-- outdoor             # Outdoor dataset
    +-- groundtruth         # Groundtruth for the outdoor dataset
+-- utils                   # Utility functions
+-- figs                    # Some figures in the paper
+-- config_example.m        # Configuration template
```

# Reproduce Results with Provided Logs

We provide the performance results under the coresponding directory `result/`. To reproduce the figures in the paper, you can run following commands for python scripts.

``` bash
cd CurvingLoRa_NSDI22
matlab -nodisplay
```

``` matlab
%% Matlab
addpath(genpath('./.'));

%% Observation Results
1_observation/fig_5       #Fig 5
1_observation/fig_7       #Fig 7

%% Simulation Results
2_simulation/fig_6a      #Fig 5
2_simulation/fig_6b      #Fig 7
2_simulation/fig_8a      #Fig 8a  
2_simulation/fig_8b      #Fig 8b
2_simulation/fig_sir2map #SIR map

%% Evaluation Results
3_deployment/symbol_emulation/fig_16a      #Fig 16a
3_deployment/symbol_emulation/fig_16b      #Fig 16b
3_deployment/symbol_emulation/fig_17abcd   #Fig 17abcd
3_deployment/symbol_emulation/fig_18abcd   #Fig 18abcd
3_deployment/symbol_emulation/fig_17abcd   #Fig 20a
3_deployment/outdoor_emulation/figs_outdoor_emulation   #Fig 20a
```

# Reproduce Results from Scratch
***Please assure that all paths in the configurations are consistent for datasets, scripts, and logs.***

1. [Download datasets](https://drive.google.com/file/d/1T0wN_7gGkI93cCd-tOleUcJ6AWrklwTO/view?usp=sharing). Please download symbol and outdoor datasets and put them under the `data/`, as shown in the directory tree above.

2. Please run the eva_{***} scripts under each directory to reproduce the results from Scratch.

# Notes
please consider to cite our paper if you use the code or data in your research project.
``` bibtex
@inproceedings{CurvingLoRa_NSDI22,
    author = {Li, Chenning and Guo, Xiuzhen and Shuangguan, Longfei and Cao, Zhichao and Jamieson, Kyle},
    title = {CurvingLoRa to Boost LoRa Network Throughput via Concurrent Transmission},
    year = {2022},
    booktitle = {Proceedings of USENIX NSDI},
}
```

<!-- # Acknowledgements

Thanks to Fan Lai and Xiangfeng Zhu for their OSDI'21 paper [Oort: Efficient Federated Learning via Guided Participant Selection](https://www.usenix.org/conference/osdi21/presentation/lai). The source codes can be found in repo [Oort](https://github.com/SymbioticLab/Oort). -->

# Contact
Chenning Li by lichenni@msu.edu


