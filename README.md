# 📡 IoT-AP-Localization-WiFi-CSI
**Efficient IoT Devices/AP Localization Through Wi-Fi CSI Feature Fusion and Anomaly Detection**

This repository contains the reproduction code for the IEEE Internet of Things Journal paper:  
*Efficient IoT Devices Localization Through Wi-Fi CSI Feature Fusion and Anomaly Detection*.

## 📝 Introduction

This project provides the code to reproduce the results presented in the paper. The main code resides in the `model.py` file. Ensure you have the required dependencies listed in `requirements.txt` installed before running the code.

The code uses MATLAB to generate a trajectory's CSI and applies the NOMP algorithm for parameter extraction. It then segments the trajectory into multiple segments using a sliding window of length 5 and step size 1, processing them with the network. If you wish to create your own dataset using different CSI parameter extraction methods, you can use your own CSI data for feature extraction. Ensure the data is formatted correctly for network input.

## 🔍 NOMP Algorithm Parameter Extraction

CSI data requires preprocessing, specifically using the NOMP algorithm to extract multipath channel parameters. Detailed extraction methods can be found here:  
[CSI Extraction](https://github.com/CoLoSNet/Extractor/blob/main/functions/CSI_Extraction.m)

## 🤖 Networks

The two main networks in this code are used for CSI fusion and anomaly detection. The `main.py` file demonstrates how these networks work together.

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
```

## 📁 Dataset

We have also constructed a dataset available at:  
[https://github.com/CoLoSNet/Extractor](https://github.com/CoLoSNet/Extractor)  
This dataset contains CSI information collected in an indoor office environment. Our network is fully trained on this dataset and shows excellent performance, demonstrating the simulation quality of the dataset.
You can adjust the receiving antenna configuration as needed, and detailed steps for the NOMP algorithm are provided.
## Contact

For any questions or discussions, please feel free to contact me via email: leeyan@seu.edu.cn
