import torch
import torch.nn as nn

class TorchSimpleNN(nn.Module):
    def __init__(self, in_features, hidden_features, out_features):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(in_features, hidden_features),
            nn.ReLU(),
            nn.Linear(hidden_features, out_features)
        )

    def forward(self, x):
        return self.net(x)

class TorchSimpleCNN(nn.Module):
    def __init__(self, in_channels, out_channels, kernel_size, num_classes):
        super().__init__()
        self.conv = nn.Conv2d(in_channels, out_channels, kernel_size)
        self.relu = nn.ReLU()
        self.fc = nn.Linear(out_channels, num_classes)

    def forward(self, x):
        x = self.conv(x)
        x = self.relu(x)
        x = x.mean(dim=(2,3))  # Global average pooling
        x = self.fc(x)
        return x
