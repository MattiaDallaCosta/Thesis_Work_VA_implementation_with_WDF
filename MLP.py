import torch
import torch.nn as nn


class MLP2x16(nn.Module):
    def __init__(self): #, weights):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(1, 16),   # input: 1 -> hidden1: 16
            nn.ReLU(),          # or nn.Tanh(), nn.GELU(), etc.
            nn.Linear(16, 16),  # hidden1: 16 -> hidden2: 16
            nn.ReLU(),
            nn.Linear(16, 1)    # hidden2: 16 -> output: 1
        )
        #self.load_state_dict(torch.load(weights, map_location="cpu", weights_only=True))
        #self.eval()

    def forward(self, x):
        # x: shape (batch_size, 1)
        return self.net(x)