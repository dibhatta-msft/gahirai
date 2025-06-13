import numpy as np
import matplotlib.pyplot as plt
from ..network import SimpleNN, SimpleCNN

def plot_loss(losses, title='Loss Curve'):
    plt.figure(figsize=(6,4))
    plt.plot(losses)
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.title(title)
    plt.grid(True)
    plt.show()

def visualize_simple_nn():
    # Generate toy data: y = 2x + 1 + noise
    x = np.linspace(-1, 1, 100).reshape(-1, 1)
    y = 2 * x + 1 + 0.1 * np.random.randn(*x.shape)
    model = SimpleNN(1, 10, 1)
    losses = []
    for epoch in range(100):
        pred = model.forward(x)
        loss = np.mean((pred - y) ** 2)
        grad = 2 * (pred - y) / pred.size
        model.backward(grad)
        model.step(0.1)
        losses.append(loss)
    plot_loss(losses, title='SimpleNN Loss Curve')
    plt.scatter(x, y, label='Data')
    plt.plot(x, model.forward(x), color='red', label='Model Prediction')
    plt.legend()
    plt.title('SimpleNN Fit')
    plt.show()

def visualize_simple_cnn():
    # Visualize a random filter response on a random image
    img = np.random.rand(1, 1, 8, 8)
    model = SimpleCNN(1, 2, 3, 2)
    out = model.conv.forward(img)
    plt.figure(figsize=(8,4))
    for i in range(out.shape[1]):
        plt.subplot(1, out.shape[1], i+1)
        plt.imshow(out[0, i], cmap='viridis')
        plt.title(f'Filter {i+1}')
        plt.axis('off')
    plt.suptitle('Conv2D Filter Outputs')
    plt.show()

if __name__ == '__main__':
    visualize_simple_nn()
    visualize_simple_cnn()
