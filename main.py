L = 5

# Importing necessary libraries
import torch
from torch import nn
import torch.nn.functional as F
from torch.utils.data.dataset import Dataset
from torch.utils.data.dataloader import DataLoader
from scipy.io import loadmat
import numpy as np
import json

# Importing custom modules
from model import CB_Bilstm, feature_extract, EncDecAD
from tool import plot_cdf, data_divide

## Network setup
import datetime

starttime = datetime.datetime.now()
loss_func = torch.nn.MSELoss()


# Baseline neural network definition
class nnNet(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(nnNet, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        out = self.fc1(x)
        out = self.relu(out)
        out = self.fc2(out)
        out = out * 2 - 1  # Scaling output to [-1, 1]
        return out


# Load pre-trained models for AP selection and estimation
save_path = 'result_baseline_AP_selected/'
AP_model_baseline = nnNet(input_size=20, hidden_size=128, output_size=2)
state_dict = torch.load(save_path + 'CB_selected.pth', map_location=torch.device('cpu'))
AP_model_baseline.load_state_dict(state_dict)

save_path = 'APselected_result_estimate_L5/'
AP_model_pre = CB_Bilstm(3, 128, 2, 1)
state_dict = torch.load(save_path + 'CB_selected.pth', map_location=torch.device('cpu'))
AP_model_pre.load_state_dict(state_dict)

ext_place = 'APselected_result_estimate_L5/'
AP_f_ext = feature_extract(input_size=3)
pretrained_dict = torch.load(ext_place + 'CB_selected.pth', map_location=torch.device('cpu'))
AP_f_ext.load_state_dict(pretrained_dict, strict=False)

save_path = 'APselected_encdec_result_L5/'
AP_model = EncDecAD(3, 3, 1)
state_dict = torch.load(save_path + 'AD_selected.pth', map_location=torch.device('cpu'))
AP_model.load_state_dict(state_dict)

##########################################################################################
# Robustness testing
save_path = 'result_baseline/'
model_baseline = nnNet(input_size=20, hidden_size=128, output_size=2)
state_dict = torch.load(save_path + 'CB_selected.pth', map_location=torch.device('cpu'))
model_baseline.load_state_dict(state_dict)

save_path = 'result_estimate_L' + str(L) + '/'
model_pre = CB_Bilstm(3, 128, 2, 1)
state_dict = torch.load(save_path + 'CB_selected_(0,1,5,6,7,9).pth', map_location=torch.device('cpu'))
model_pre.load_state_dict(state_dict)

ext_place = 'result_estimate_L' + str(L) + '/'
f_ext = feature_extract(input_size=3)
pretrained_dict = torch.load(ext_place + 'CB_selected_(0,1,5,6,7,9).pth', map_location=torch.device('cpu'))
f_ext.load_state_dict(pretrained_dict, strict=False)

save_path = 'encdec_result_L' + str(L) + '/'
model = EncDecAD(3, 3, 1)
state_dict = torch.load(save_path + 'AD_selected_(0,1,5,6,7,9).pth', map_location=torch.device('cpu'))
model.load_state_dict(state_dict)


def getxy(name_dir):
    """
    Function to load data from .mat files and preprocess for neural network input.

    Args:
    - name_dir (str): Directory path containing the .mat file.

    Returns:
    - x (numpy array): Processed input features.
    - y (numpy array): Processed output labels.
    - traj_idx (numpy array): Trajectory indices.
    """
    name = name_dir + '/traj_temp.mat'
    spam = loadmat(name)
    X = spam['feature']
    Y = spam['AOA'].reshape(-1)
    tx = spam['tx'].reshape(-1) - 1
    Y1 = Y / 180 * np.pi
    y1 = np.sin(Y1)
    y2 = np.cos(Y1)

    if X.ndim == 3:
        X = np.expand_dims(X, axis=-1)
        x = np.zeros([X.shape[0], 20, X.shape[-1]]).squeeze()
        x[:, :10] = X[:, :10, tx, :].squeeze()
        x[:, -10:-5] = (np.sin(X[:, -5:, tx, :].squeeze()) + 1) / 2
        x[:, -5:] = (np.cos(X[:, -5:, tx, :].squeeze()) + 1) / 2
        x = np.expand_dims(x, axis=-1)
    else:
        x = np.zeros([X.shape[0], 20, X.shape[-1]])
        x[:, :10, :] = X[:, :10, tx, :].squeeze()
        x[:, -10:-5, :] = (np.sin(X[:, -5:, tx, :].squeeze()) + 1) / 2
        x[:, -5:, :] = (np.cos(X[:, -5:, tx, :].squeeze()) + 1) / 2

    y = np.array([y1, y2]).transpose()
    traj_idx = spam['traj_idx'].reshape(-1)

    return x, y, traj_idx


# Data loading and processing
location = 'traj/'
data = []
mat_dir = location + '/'
x0, y0, traj_idx0 = getxy(mat_dir)
x, y, traj_idx = x0, y0, traj_idx0

# Convert to torch tensors
traj_idx = np.array(traj_idx, dtype=np.float32)
traj_idx = torch.from_numpy(traj_idx).float().cpu()

x = (torch.from_numpy(x.reshape(1, -1, 20, x.shape[-1]))).float().cpu()
y0 = (torch.from_numpy(y0.reshape(1, -1, 2))).float().cpu()
y = (torch.from_numpy(y.reshape(1, -1, 2))).float().cpu()
y = y.float().cpu()
x = x.reshape(-1, 4, 5, x.shape[-1]).float().cpu()
y = y.reshape(-1, 2).float().cpu()
y0 = y0.reshape(-1, 2).float().cpu()

x = x.unsqueeze(0)
data = [x, y, y0, traj_idx]

import math


def get_angle(val):
    """
    Utility function to calculate angle from sine and cosine values.

    Args:
    - val (numpy array): Array containing sine and cosine values.

    Returns:
    - angle (float): Calculated angle in degrees.
    """
    val = val.flatten().tolist()
    sin_val, cos_val = val[0], val[1]
    angle = math.atan2(sin_val, cos_val) * 180 / math.pi
    angle = angle if angle >= 0 else 360 + angle
    return angle


data = data_divide(data)  # Assuming this function splits data into manageable parts

pre_list = []
for data_i in range(len(data)):
    [x, y, y0, traj_idx] = data[data_i]
    pre_angle = [0]
    pre_angle_name = ['ad']
    threshold = 0.002

    y = y.reshape(-1, 2)
    pre_angle.append(get_angle(y))
    pre_angle_name.append('true')

    # Predictions based on different criteria
    sorted_data, sorted_indices = torch.sort(x[0, x.size(1) // 2, 0, :], descending=True)
    prediction = x[0, x.size(1) // 2, [-2, -1], sorted_indices[0]].reshape(-1, 2)
    prediction = prediction * 2 - 1
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('RSS')

    sorted_data, sorted_indices = torch.sort(x[0, x.size(1) // 2, 1, :], descending=True)
    prediction = x[0, x.size(1) // 2, [-2, -1], sorted_indices[-1]].reshape(-1, 2)
    prediction = prediction * 2 - 1
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('time')

    prediction = model_baseline(x[:, L // 2, :].reshape(-1, 20))
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('baseline')

    prediction = model_pre(x)
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('network')

    z = f_ext(x).float().cpu()
    prediction = model(z).cpu()
    loss = loss_func(prediction, z).tolist()

    if loss < threshold:
        pre_angle[0] = 1

    y_temp = get_angle(y)

    ku_temp = []
    ku = np.array(x[0, x.size(1) // 2, 2:4, :].data.cpu()).transpose()
    ku = torch.tensor(ku * 2 - 1)
    for ku_i in range(5):
        ku_temp.append(get_angle(ku[ku_i]))
    ku_temp = np.array(ku_temp)

    near = np.minimum(abs(ku_temp - y_temp), 360 - abs(ku_temp - y_temp))
    min_index = np.argmin(near)
    prediction = x[0, x.size(1) // 2, [-2, -1], min_index].reshape(-1, 2)
    prediction = prediction * 2 - 1
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('near')

    pre_angle_dict = dict(zip(pre_angle_name, pre_angle))
    pre_list.append(pre_angle_dict)

# Save results to JSON files
with open("traj/traj.json", "w") as f:
    json.dump(pre_list, f)

with open("traj/traj_flag.json", "w") as f:
    json.dump(pre_list, f)
