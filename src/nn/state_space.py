import numpy as np

class SimpleStateSpace:
    """
    Minimal linear state-space model: x_{t+1} = Ax_t + Bu_t, y_t = Cx_t + Du_t
    """
    def __init__(self, state_dim, input_dim, output_dim):
        self.A = np.eye(state_dim)
        self.B = np.random.randn(state_dim, input_dim)
        self.C = np.random.randn(output_dim, state_dim)
        self.D = np.random.randn(output_dim, input_dim)
        self.state = np.zeros((state_dim,))

    def reset(self, state=None):
        if state is not None:
            self.state = state
        else:
            self.state = np.zeros_like(self.state)

    def step(self, u):
        self.state = self.A @ self.state + self.B @ u
        y = self.C @ self.state + self.D @ u
        return y

    def simulate(self, inputs):
        ys = []
        for u in inputs:
            y = self.step(u)
            ys.append(y)
        return np.array(ys)
