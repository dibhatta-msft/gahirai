import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../../')))

import streamlit as st
import numpy as np
import matplotlib.pyplot as plt
from src.nn.network import SimpleNN, SimpleCNN
from src.nn.diffusion import SimpleDiffusion
from src.nn.state_space import SimpleStateSpace
from src.nn.unet import UNet
import torch

st.title("Neural Network Playground (NumPy)")

st.sidebar.header("Model Settings")
model_type = st.sidebar.selectbox("Choose model", ["SimpleNN", "SimpleCNN", "SimpleDiffusion", "SimpleStateSpace", "UNet"])
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

elif model_type == "SimpleDiffusion":
    st.header("Simple Diffusion Model")
    timesteps = st.sidebar.slider("Diffusion Timesteps", 10, 200, 50, 10)
    image_mode = st.sidebar.checkbox("Show 2D Image Diffusion", value=True)
    if image_mode:
        img_shape = st.sidebar.selectbox("Image Shape", [(28,28), (16,16), (8,8)], index=0)
        model = SimpleDiffusion(timesteps=timesteps)
        xs = model.sample_image_trajectory(img_shape=img_shape)
        st.subheader("Diffusion Image Trajectory")
        steps_to_show = st.slider("Steps to Show", 2, min(10, timesteps+1), 5)
        fig, axs = plt.subplots(1, steps_to_show, figsize=(2*steps_to_show, 2))
        for i, ax in enumerate(axs):
            idx = int(i * len(xs) / steps_to_show)
            ax.imshow(xs[idx], cmap='gray', vmin=0, vmax=1)
            ax.set_title(f"Step {idx}")
            ax.axis('off')
        st.pyplot(fig)
    else:
        x0 = np.linspace(-1, 1, 50)
        model = SimpleDiffusion(timesteps=timesteps)
        xs = model.sample_trajectory(x0)
        st.subheader("Diffusion Trajectory (1D)")
        fig, ax = plt.subplots()
        for i in range(0, len(xs), max(1, len(xs)//5)):
            ax.plot(xs[i], label=f"Step {i}")
        ax.set_title("Diffusion Process (Noisy Trajectory)")
        ax.set_xlabel("Index")
        ax.set_ylabel("Value")
        ax.legend()
        st.pyplot(fig)

elif model_type == "SimpleStateSpace":
    st.header("Simple State-Space Model")
    state_dim = st.sidebar.number_input("State Dim", 1, 10, 2, 1)
    input_dim = st.sidebar.number_input("Input Dim", 1, 5, 1, 1)
    output_dim = st.sidebar.number_input("Output Dim", 1, 5, 1, 1)
    model = SimpleStateSpace(state_dim=state_dim, input_dim=input_dim, output_dim=output_dim)
    timesteps = st.sidebar.slider("Simulation Steps", 10, 200, 100, 10)
    t = np.linspace(0, 10, timesteps)
    inputs = np.sin(t).reshape(-1, input_dim)
    outputs = model.simulate(inputs)
    st.subheader("State-Space Simulation")
    fig, ax = plt.subplots()
    for i in range(input_dim):
        ax.plot(inputs[:, i], label=f"Input {i}")
    for i in range(output_dim):
        ax.plot(outputs[:, i], label=f"Output {i}")
    ax.set_title("State-Space Model Simulation")
    ax.set_xlabel("Time Step")
    ax.legend()
    st.pyplot(fig)

elif model_type == "UNet":
    st.header("U-Net for Image Segmentation (PyTorch)")
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    unet = UNet(in_channels=1, out_channels=1).to(device)
    img_size = st.sidebar.selectbox("Image Size", [64, 128, 256], index=0)
    uploaded_file = st.file_uploader("Upload a grayscale image (png, jpg)", type=["png", "jpg", "jpeg"])
    if uploaded_file is not None:
        from PIL import Image
        pil_img = Image.open(uploaded_file).convert("L").resize((img_size, img_size))
        img = np.array(pil_img, dtype=np.float32) / 255.0
        st.subheader("Uploaded Image")
        st.image(img, width=200, caption="Input")
        # Dummy mask (for demo, since UNet is untrained)
        with torch.no_grad():
            input_tensor = torch.from_numpy(img[None, None]).float().to(device)
            pred_mask = torch.sigmoid(unet(input_tensor)).cpu().numpy()[0,0]
        st.subheader("Predicted Mask (Random Weights)")
        st.image(pred_mask, width=200, caption="Predicted Mask")
        st.info("This is a randomly initialized U-Net. For meaningful segmentation, you would need to train it on real data.")
    else:
        # Generate a synthetic image and mask
        np.random.seed(42)
        img = np.zeros((img_size, img_size), dtype=np.float32)
        mask = np.zeros((img_size, img_size), dtype=np.float32)
        # Draw a random circle as the object
        rr, cc = np.ogrid[:img_size, :img_size]
        center = (img_size//2, img_size//2)
        radius = img_size//4
        circle = (rr - center[0])**2 + (cc - center[1])**2 < radius**2
        img[circle] = 1.0
        mask[circle] = 1.0
        # Add noise
        img += 0.2 * np.random.randn(*img.shape)
        img = np.clip(img, 0, 1)
        with torch.no_grad():
            input_tensor = torch.from_numpy(img[None, None]).float().to(device)
            pred_mask = torch.sigmoid(unet(input_tensor)).cpu().numpy()[0,0]
        st.subheader("Input Image")
        st.image(img, width=200, caption="Input")
        st.subheader("Ground Truth Mask")
        st.image(mask, width=200, caption="Mask")
        st.subheader("Predicted Mask (Random Weights)")
        st.image(pred_mask, width=200, caption="Predicted Mask")
        st.info("This is a randomly initialized U-Net. For meaningful segmentation, you would need to train it on real data.")

st.info("You can edit the code in this app to add more visualizations or controls!")
