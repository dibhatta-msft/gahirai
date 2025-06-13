import numpy as np

class SimpleDiffusion:
    """
    Minimal 1D and 2D diffusion model for educational purposes.
    """
    def __init__(self, timesteps=100, beta_start=1e-4, beta_end=0.02):
        self.timesteps = timesteps
        self.betas = np.linspace(beta_start, beta_end, timesteps)
        self.alphas = 1.0 - self.betas
        self.alpha_bars = np.cumprod(self.alphas)

    def q_sample(self, x0, t, noise=None):
        if noise is None:
            noise = np.random.randn(*x0.shape)
        sqrt_alpha_bar = np.sqrt(self.alpha_bars[t])
        sqrt_one_minus_alpha_bar = np.sqrt(1 - self.alpha_bars[t])
        return sqrt_alpha_bar * x0 + sqrt_one_minus_alpha_bar * noise

    def sample_trajectory(self, x0):
        xs = [x0]
        x = x0.copy()
        for t in range(self.timesteps):
            x = self.q_sample(x, t)
            xs.append(x)
        return xs

    def sample_image_trajectory(self, img_shape=(28, 28)):
        """
        Start from a blank or random image and diffuse it to pure noise.
        Returns a list of images at each step.
        """
        x0 = np.zeros(img_shape)
        xs = [x0]
        x = x0.copy()
        for t in range(self.timesteps):
            x = self.q_sample(x, t)
            xs.append(x)
        return xs
