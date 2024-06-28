L=5
#torch库：
import torch
from torch import nn
from torch.autograd import Variable
import torch.nn.functional as F
from torch.utils.data.dataset import Dataset
from torch.utils.data.dataloader import DataLoader
import fnmatch
from scipy.io import loadmat
import numpy as np
import random
import os
#个人库
from model import CB_Bilstm,feature_extract,EncDecAD
from tool import plot_cdf,data_divide
import math

def get_angle(val):
    val=val.flatten().tolist()
    sin_val, cos_val= val[0],val[1]
    angle = math.atan2(sin_val, cos_val) * 180 / math.pi
    angle = angle if angle >= 0 else 360 + angle
    return angle

##网络设置
import datetime
starttime = datetime.datetime.now()
loss_func = torch.nn.MSELoss()
# baseline网络
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
        out = out*2-1
        return out


save_path='result_baseline/'
model_baseline = nnNet(input_size=20, hidden_size =128, output_size=2)
state_dict = torch.load(save_path+'CB_selected.pth',map_location=torch.device('cpu'))
model_baseline.load_state_dict(state_dict)

#估计网络
save_path='result_estimate_L'+str(L)+'/'
model_pre = CB_Bilstm(3,128,2,1)
state_dict = torch.load(save_path+'CB_selected_(0,1,5,6,7,9).pth',map_location=torch.device('cpu'))
model_pre.load_state_dict(state_dict)

#特征提取网络
ext_place='result_estimate_L'+str(L)+'/'
f_ext=feature_extract(input_size=3)
pretrained_dict = torch.load(ext_place+'CB_selected_(0,1,5,6,7,9).pth',map_location=torch.device('cpu'))
f_ext.load_state_dict(pretrained_dict, strict=False)

#特征重构网络
save_path='encdec_result_L'+str(L)+ '/'
model = EncDecAD(3, 3, 1)
state_dict = torch.load(save_path+'AD_selected_(0,1,5,6,7,9).pth',map_location=torch.device('cpu'))
model.load_state_dict(state_dict)

def getxy(name_dir):
    # function:
    name = name_dir + '/traj_temp.mat'
    spam = loadmat(name)
    X = spam['feature']
    Y = spam['AOA'].reshape(-1)
    tx=spam['tx'].reshape(-1)-1
    Y1 = Y / 180 * np.pi
    # X[:, -5:,:] = (np.sin(X[:, -5:,:])+1)/2
    y1 = np.sin(Y1)
    y2 = np.cos(Y1)
    if X.ndim == 3:
        X = np.expand_dims(X, axis=-1)  # 在最后一维添加一个维度
        x = np.zeros([X.shape[0], 20, X.shape[-1]]).squeeze()

        x[:, :10] = X[:, :10, tx,:].squeeze()
        x[:, -10:-5] = (np.sin(X[:, -5:, tx,:].squeeze()) + 1) / 2
        x[:, -5:] = (np.cos(X[:, -5:, tx,:].squeeze()) + 1) / 2
        x = np.expand_dims(x, axis=-1)  # 在最后一维添加一个维度
    else:
        x = np.zeros([X.shape[0], 20, X.shape[-1]])
        x[:, :10, :] = X[:, :10, tx, :].squeeze()
        x[:, -10:-5:, :] = (np.sin(X[:, -5:, tx, :].squeeze()) + 1) / 2
        x[:, -5:, :] = (np.cos(X[:, -5:, tx, :].squeeze()) + 1) / 2
    y = np.array([y1,y2]).transpose()
    traj_idx=spam['traj_idx'].reshape(-1)
    return x,y,traj_idx

def getdata(name_dir):
    name = name_dir + '/feature.mat'
    spam = loadmat(name)
    X = spam['feature_python']
    if X.ndim == 2:
        X = np.expand_dims(X, axis=-1)  # 在最后一维添加一个维度, 这个维度是mat文件维度为1会自动省略.
    x = np.zeros([X.shape[0], 20, X.shape[-1]])
    x[:, :10, :] = X[:, :10, :]
    x[:, -10:-5:, :] = (np.sin(X[:, -5:, :]) + 1) / 2
    x[:, -5:, :] = (np.cos(X[:, -5:, :]) + 1) / 2
    return x#[5,20,分组数]
# 数据载入：
location='datamat/'
data=[]
mat_dir=location+''
x = getdata(mat_dir)
x = (torch.from_numpy(x.reshape(1, -1, 20,x.shape[-1]))).float().cpu()
x = x.reshape(-1, 4, 5,x.shape[-1]).float().cpu()
x = x.unsqueeze(0)

a=1
data_x = x

# 进入循环
pre_angle_name = ['ad']
threshold = 0.002
pre_list = []
for x_i in range(data_x.shape[-1]):
    pre_angle = [0]
    x = data_x[...,x_i]

    # 按照能量进行区分
    sorted_data, sorted_indices = torch.sort(x[0, x.size(1) // 2, 0, :], descending=True)
    prediction = x[0, x.size(1) // 2, [-2, -1], sorted_indices[0]].reshape(-1, 2)
    prediction = prediction * 2 - 1
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('RSS')
    # 按照时间进行区分
    sorted_data, sorted_indices = torch.sort(x[0, x.size(1) // 2, 1, :], descending=True)
    prediction = x[0, x.size(1) // 2, [-2, -1], sorted_indices[-1]].reshape(-1, 2)
    prediction = prediction * 2 - 1
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('time')

    # 不进行剔除,baseline
    prediction = model_baseline(x[:, L // 2, :].reshape(-1, 20))
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('baseline')

    # 不进行剔除,我们提出的网络
    prediction = model_pre(x)
    pre_angle.append(get_angle(prediction))
    pre_angle_name.append('network')

    # 异常值剔除
    z = f_ext(x).float().cpu()
    # 网络重构
    prediction = model(z).cpu()
    loss = loss_func(prediction, z).tolist()
    print(loss)
    if (loss < threshold):
        pre_angle[0] = 1
    print(pre_angle[0])
    print('____________________________')
    # 存成列表
    pre_angle_dict = dict(zip(pre_angle_name, pre_angle))
    pre_list.append(pre_angle_dict)
    # print(pre_angle_name)
    # print(pre_angle)
import json

# 将字典保存为JSON文件
with open("traj.json", "w") as f:
    json.dump(pre_list, f)
# 将字典保存为JSON文件
with open("traj_flag.json", "w") as f:
    json.dump(pre_list, f)