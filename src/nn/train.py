import numpy as np

def mse_loss(pred, target):
    return np.mean((pred - target) ** 2), 2 * (pred - target) / pred.size

def train(model, x, y, epochs=100, lr=0.01):
    for epoch in range(epochs):
        pred = model.forward(x)
        loss, grad = mse_loss(pred, y)
        model.backward(grad)
        model.step(lr)
        if epoch % 10 == 0:
            print(f"Epoch {epoch}, Loss: {loss:.4f}")
