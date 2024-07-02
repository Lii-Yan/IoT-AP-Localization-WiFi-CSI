# IoT-AP-Localization-WiFi-CSI
**Efficient IoT Devices/AP Localization Through Wi-Fi CSI Feature Fusion and Anomaly Detection**

This repository contains the reproduction code for the IEEE Internet of Things Journal paper:  
*Efficient IoT Devices Localization Through Wi-Fi CSI Feature Fusion and Anomaly Detection*.

## Introduction

This project provides the reproduction code for the paper. Readers should mainly focus on the `model.py` file and refer to the input data described in the paper. The code can be run directly after installing the dependencies listed in `requirements.txt`.

If you want to create your own dataset based on CSI, you can use your own CSI data for feature extraction using different algorithms. Essentially, the goal is to extract features from multipath channel information, which will yield similar results.

The NOMP algorithm will be open-sourced later after further organization.

## Networks

The two main networks in this code are used for CSI fusion and anomaly detection. You can see how these networks work together in the `main.py` file. We hope this will be helpful to you.

## 🔗 Citation

If you find our work helpful, please cite:
```bibtex
@ARTICLE{10579753,
  author={Li, Yan and Yang, Jie and Shih, Shang-Ling and Shih, Wan-Ting and Wen, Chao-Kai and Jin, Shi},
  journal={IEEE Internet of Things Journal}, 
  title={Efficient IoT Devices Localization Through Wi-Fi CSI Feature Fusion and Anomaly Detection}, 
  year={2024},
  volume={},
  number={},
  pages={1-1},
  keywords={Location awareness;Internet of Things;Wireless fidelity;Smart phones;Estimation;Accuracy;Trajectory;IoT devices localization;channel state information;artificial intelligence;anomaly detection},
  doi={10.1109/JIOT.2024.3421577}}
、、、


## Dataset

We have also constructed a dataset available at:  
[https://github.com/CoLoSNet/Extractor](https://github.com/CoLoSNet/Extractor)  
This dataset contains CSI information collected in an indoor office environment. Our network is fully trained on this dataset and shows excellent performance, demonstrating the simulation quality of the dataset.

## Contact

For any questions or discussions, please feel free to contact me via email: leeyan@seu.edu.cn
