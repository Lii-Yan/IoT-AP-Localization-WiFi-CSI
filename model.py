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


# Neural Network Definitions

# LoSEstNet model for estimation
class CB_Bilstm(nn.Module):
    def __init__(self, input_size=15, hidden_size=128, output_size=1, num_layer=2):
        super(CB_Bilstm, self).__init__()

        self.cov1 = nn.Conv1d(4, 4, kernel_size=3, padding=1)
        self.cov2 = nn.Conv1d(4, 4, kernel_size=3, padding=1)
        self.layer0 = nn.Linear(20, input_size)

        self.bilstm1 = nn.LSTM(input_size, hidden_size, num_layer, batch_first=True, bidirectional=True)
        self.bilstm2 = nn.LSTM(2 * hidden_size, int(hidden_size / 4), num_layer, batch_first=True, bidirectional=True)
        self.bilstm3 = nn.LSTM(int(hidden_size / 2), int(hidden_size / 8), num_layer, batch_first=True,
                               bidirectional=True)

        self.layer4 = nn.Linear(int(hidden_size / 4), output_size)

    def forward(self, x1):
        batch_size, seq, feature_num, signal_num = x1.size(0), x1.size(1), x1.size(2), x1.size(3)
        x1 = x1.view(batch_size * seq, feature_num, signal_num)
        x1 = self.cov1(x1)
        x1 = F.relu(x1)
        x1 = self.cov2(x1)
        x1 = F.relu(x1)
        # Fully connected layer for dimension reduction
        x1 = x1.view(batch_size * seq, feature_num * signal_num)
        x1 = self.layer0(x1)
        # Reshape to batch size
        x1 = x1.view(batch_size, seq, -1)
        # LSTM training
        x1, _ = self.bilstm1(x1)
        x1, _ = self.bilstm2(x1)
        x1, _ = self.bilstm3(x1)

        x1 = self.layer4(x1)
        x1 = x1 * 2 - 1
        # Adjust output
        x1 = x1[:, seq // 2, :]
        return x1


# Simple feedforward neural network
class nnNet(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(Net, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        out = self.fc1(x)
        out = self.relu(out)
        out = self.fc2(out)
        return out


# Feature extraction network
class feature_extract(nn.Module):
    def __init__(self, input_size):
        super(feature_extract, self).__init__()
        self.cov1 = nn.Conv1d(4, 4, kernel_size=3, padding=1)
        self.cov2 = nn.Conv1d(4, 4, kernel_size=3, padding=1)
        self.layer0 = nn.Linear(20, input_size)

    def forward(self, x1):
        batch_size, seq, feature_num, signal_num = x1.size(0), x1.size(1), x1.size(2), x1.size(3)
        x1 = x1.view(batch_size * seq, feature_num, signal_num)
        x1 = self.cov1(x1)
        x1 = F.relu(x1)
        x1 = self.cov2(x1)
        x1 = F.relu(x1)
        # Fully connected layer for dimension reduction
        x1 = x1.view(batch_size * seq, feature_num * signal_num)
        x1 = self.layer0(x1)
        # Reshape to batch size
        x1 = x1.view(batch_size, seq, -1)
        return x1


# Anomaly detection network(AnoDetNet)
class EncDecAD(nn.Module):
    def __init__(self, input_size=20, output_size=20, num_layer=1):
        super(EncDecAD, self).__init__()
        self.lstm1 = nn.LSTM(input_size, input_size, num_layer, batch_first=True, bidirectional=False)
        self.layer1 = nn.Linear(input_size, input_size)
        self.lstm2 = nn.LSTM(input_size, output_size, num_layer, batch_first=True, bidirectional=False)

    def forward(self, x):
        x_out = torch.zeros(x.size()).float()
        # Encoding
        out1, (h1, c1) = self.lstm1(x)

        # Information transfer
        (h_init, c_init) = (h1, c1)  # (h_init,c_init )
        x_end = self.layer1(h1.permute(1, 0, 2))
        # Decoding
        x_out[:, x.size(1) - 1, :] = x_end.squeeze()

        (h_i, c_i) = (h_init, c_init)
        out_i = x_end
        for i in range(x.size(1)):
            out_i, (h_i, c_i) = self.lstm2(out_i, ((h_i, c_i)))
            x_out[:, x.size(1) - 2 - i, :] = out_i.squeeze()
        return x_out
