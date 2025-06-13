# Neural Network (nn) Module

This folder contains a minimal neural network framework implemented from scratch using NumPy, along with PyTorch equivalents for easy swapping. It is designed for educational purposes to help you understand backpropagation, convolutional networks, and how to visualize them.

## Folder Structure

- `layers.py` — Core neural network layers implemented with NumPy:
  - `Linear`: Fully connected layer
  - `ReLU`: Activation function
  - `Conv2D`: 2D convolution layer
- `network.py` — Model definitions:
  - `SimpleNN`: Feedforward neural network
  - `SimpleCNN`: Simple convolutional neural network
- `train.py` — Training utilities:
  - `train`: Training loop for NumPy models
  - `mse_loss`: Mean squared error loss function
- `pytorch_layers.py` — PyTorch equivalents:
  - `TorchSimpleNN`: Feedforward neural network using PyTorch
  - `TorchSimpleCNN`: Convolutional neural network using PyTorch
- `app/` — Visualization tools:
  - `visualize.py`: Scripts to visualize training loss, model predictions, and convolutional filter outputs
- `__init__.py` — Module imports for convenience

## Usage

- You can experiment with the NumPy models and training loop for a hands-on understanding of backpropagation and CNNs.
- The PyTorch models are provided for easy replacement and comparison.
- Use the scripts in `app/visualize.py` to see how the models learn and what the convolutional filters do.

## Requirements

- `numpy`
- `matplotlib` (for visualization)
- `torch` (for PyTorch models)

Install requirements with:

```bash
pip install numpy matplotlib torch
```

## Extending

You can add more layers, models, or visualization scripts as you explore more advanced topics like diffusion models or state space models.
