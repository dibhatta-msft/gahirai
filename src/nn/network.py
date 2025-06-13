import numpy as np
from .layers import Linear, ReLU, Conv2D

class SimpleNN:
    def __init__(self, in_features, hidden_features, out_features):
        self.layers = [
            Linear(in_features, hidden_features),
            ReLU(),
            Linear(hidden_features, out_features)
        ]

    def forward(self, x):
        for layer in self.layers:
            x = layer.forward(x)
        return x

    def backward(self, grad_output):
        for layer in reversed(self.layers):
            grad_output = layer.backward(grad_output)

    def step(self, lr):
        for layer in self.layers:
            if hasattr(layer, 'step'):
                layer.step(lr)

class SimpleCNN:
    def __init__(self, in_channels, out_channels, kernel_size, num_classes):
        self.conv = Conv2D(in_channels, out_channels, kernel_size)
        self.relu = ReLU()
        self.fc = Linear(out_channels, num_classes)

    def forward(self, x):
        x = self.conv.forward(x)
        x = self.relu.forward(x)
        x = np.mean(x, axis=(2,3))  # Global average pooling
        x = self.fc.forward(x)
        return x

    def backward(self, grad_output):
        grad_output = self.fc.backward(grad_output)
        # No backward for pooling
        grad_output = self.relu.backward(grad_output)
        # Conv2D backward not implemented

    def step(self, lr):
        self.conv.step(lr)
        self.fc.step(lr)
