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

## Citation

Please cite the paper as follows:

Efficient IoT Devices Localization Through Wi-Fi  CSI Feature Fusion and Anomaly Detection  
Yan Li, Jie Yang, Shang-Ling Shih, Wan-Ting Shih, Chao-Kai Wen, Fellow, IEEE, and Shi Jin, Fellow, IEEE  

## Dataset

We have also constructed a dataset available at:  
[https://github.com/CoLoSNet/Extractor](https://github.com/CoLoSNet/Extractor)  
This dataset contains CSI information collected in an indoor office environment. Our network is fully trained on this dataset and shows excellent performance, demonstrating the simulation quality of the dataset.

## Contact

For any questions or discussions, please feel free to contact me via email: leeyan@seu.edu.cn
