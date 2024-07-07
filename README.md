# 📡 IoT-AP-Localization-WiFi-CSI
**Efficient IoT Devices/AP Localization Through Wi-Fi CSI Feature Fusion and Anomaly Detection**

This repository contains the reproduction code for the IEEE Internet of Things Journal paper:  
*Efficient IoT Devices Localization Through Wi-Fi CSI Feature Fusion and Anomaly Detection*.

## 📝 Introduction

This repository contains the code to reproduce the results presented in our paper. The main code is in the `model.py` file. Before running the code, please ensure you have installed all the dependencies listed in `requirements.txt`.

Our code utilizes MATLAB to generate a trajectory's Channel State Information (CSI) and applies the NOMP algorithm for parameter extraction. The trajectory is then segmented using a sliding window of length 5 and step size 1, and processed by the by the network using PyTorch.. You can also create your own dataset using different CSI parameter extraction methods, as long as the data is formatted correctly for network input.

## 🔍 NOMP Algorithm Parameter Extraction

Preprocessing CSI data involves using the NOMP algorithm to extract multipath channel parameters. Detailed extraction methods can be found here [CSI Extraction](https://github.com/CoLoSNet/Extractor/blob/main/functions/CSI_Extraction.m).
## 🤖 Networks

The repository includes two main networks for CSI fusion and anomaly detection. The `main.py` file demonstrates how these networks function together.
## 🛠 How to Use

1. **Environment Setup**: Extract the files to a directory and set up the Python environment as required. Open `run_main.bat` with a text editor and modify the line `call activate torch` to match your environment name (e.g., `torch`).

2. **Run MATLAB Script**: Execute `matlab_main/main.m`. This script demonstrates the Line-of-Sight (LoS) Angle of Arrival (AoA) estimation results across different trajectories, as shown in [our paper](https://ieeexplore.ieee.org/document/10579753), Fig. 6.

3. **Feature File**: The file `feature_all.mat` contains the processed results of the indoor office space grid points, derived using the NOMP algorithm. It has dimensions 6890×20×10, representing 6890 grid points, 20 extraction results, and 10 Access Points (APs). Our code utilizes only AP9.

4. **Custom Feature Generation**: If you prefer generating features instead of using `feature_all.mat`, set `rand_flag = 1` in `guiyihua_1.m`. Ensure you understand the [Indoor office](https://github.com/CoLoSNet/Extractor).

5. **Antenna Configuration**: To modify the antenna setup, edit `SetAntenna.m`.

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
	  doi={10.1109/JIOT.2024.3421577}}
	```
## 📁 Dataset
A relevant dataset is available [Indoor office](https://github.com/CoLoSNet/Extractor)  
This dataset contains CSI information collected in an indoor office environment. Our network is fully trained on this dataset and shows excellent performance, demonstrating the simulation quality of the dataset.
You can adjust the receiving antenna configuration as needed, and detailed steps for the NOMP algorithm are provided.
## Contact

For any questions or discussions, please feel free to contact me via email: leeyan@seu.edu.cn
