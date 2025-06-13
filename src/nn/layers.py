import numpy as np

class Linear:
    def __init__(self, in_features, out_features):
        self.W = np.random.randn(in_features, out_features) * np.sqrt(2. / in_features)
        self.b = np.zeros(out_features)
        self.x = None
        self.dW = None
        self.db = None

    def forward(self, x):
        self.x = x
        return x @ self.W + self.b

    def backward(self, grad_output):
        self.dW = self.x.T @ grad_output
        self.db = np.sum(grad_output, axis=0)
        return grad_output @ self.W.T

    def step(self, lr):
        self.W -= lr * self.dW
        self.b -= lr * self.db

class ReLU:
    def __init__(self):
        self.x = None

    def forward(self, x):
        self.x = x
        return np.maximum(0, x)

    def backward(self, grad_output):
        return grad_output * (self.x > 0)

class Conv2D:
    def __init__(self, in_channels, out_channels, kernel_size, stride=1, padding=0):
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.kernel_size = kernel_size
        self.stride = stride
        self.padding = padding
        self.W = np.random.randn(out_channels, in_channels, kernel_size, kernel_size) * np.sqrt(2. / (in_channels * kernel_size * kernel_size))
        self.b = np.zeros(out_channels)
        self.x = None
        self.dW = None
        self.db = None

    def forward(self, x):
        # x: (batch, in_channels, H, W)
        self.x = x
        batch, in_c, H, W = x.shape
        out_H = (H + 2 * self.padding - self.kernel_size) // self.stride + 1
        out_W = (W + 2 * self.padding - self.kernel_size) // self.stride + 1
        out = np.zeros((batch, self.out_channels, out_H, out_W))
        x_padded = np.pad(x, ((0,0),(0,0),(self.padding,self.padding),(self.padding,self.padding)))
        for i in range(out_H):
            for j in range(out_W):
                x_slice = x_padded[:, :, i*self.stride:i*self.stride+self.kernel_size, j*self.stride:j*self.stride+self.kernel_size]
                for k in range(self.out_channels):
                    out[:, k, i, j] = np.sum(x_slice * self.W[k, :, :, :], axis=(1,2,3))
        out += self.b[None, :, None, None]
        return out

    def backward(self, grad_output):
        # Not implemented for brevity, but can be added for full backprop
        pass

    def step(self, lr):
        # Not implemented for brevity
        pass
