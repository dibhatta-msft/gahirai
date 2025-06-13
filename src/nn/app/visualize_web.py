import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../')))

import streamlit as st
import numpy as np
import matplotlib.pyplot as plt
from src.nn.network import SimpleNN, SimpleCNN

st.title("Neural Network Playground (NumPy)")

st.sidebar.header("Model Settings")
model_type = st.sidebar.selectbox("Choose model", ["SimpleNN", "SimpleCNN"])
epochs = st.sidebar.slider("Epochs", 10, 500, 100, 10)
lr = st.sidebar.number_input("Learning Rate", 0.001, 1.0, 0.1, 0.001)

if model_type == "SimpleNN":
    st.header("Simple Feedforward Neural Network")
    x = np.linspace(-1, 1, 100).reshape(-1, 1)
    y = 2 * x + 1 + 0.1 * np.random.randn(*x.shape)
    model = SimpleNN(1, 10, 1)
    losses = []
    for epoch in range(epochs):
        pred = model.forward(x)
        loss = np.mean((pred - y) ** 2)
        grad = 2 * (pred - y) / pred.size
        model.backward(grad)
        model.step(lr)
        losses.append(loss)
    st.subheader("Loss Curve")
    st.line_chart(losses)
    st.subheader("Model Fit")
    fig, ax = plt.subplots()
    ax.scatter(x, y, label='Data')
    ax.plot(x, model.forward(x), color='red', label='Model Prediction')
    ax.legend()
    st.pyplot(fig)

elif model_type == "SimpleCNN":
    st.header("Simple Convolutional Neural Network")
    img = np.random.rand(1, 1, 8, 8)
    model = SimpleCNN(1, 2, 3, 2)
    out = model.conv.forward(img)
    st.subheader("Random Input Image")
    st.image(img[0,0], width=200, caption="Input Image")
    st.subheader("Conv2D Filter Outputs")
    fig, axs = plt.subplots(1, out.shape[1], figsize=(8,4))
    for i in range(out.shape[1]):
        axs[i].imshow(out[0, i], cmap='viridis')
        axs[i].set_title(f'Filter {i+1}')
        axs[i].axis('off')
    st.pyplot(fig)

st.info("You can edit the code in this app to add more visualizations or controls!")
