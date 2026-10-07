import torch
import torch.nn as nn


class MLP2x16(nn.Module):
    def __init__(self, weight_path=None):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(2, 16),   # input: 1 -> hidden1: 16
            #nn.ReLU(),          # or nn.Tanh(), nn.GELU(), etc.
            nn.GELU(),          # or nn.Tanh(), nn.GELU(), etc.
            nn.Linear(16, 16),  # hidden1: 16 -> hidden2: 16
            #nn.ReLU(),
            nn.GELU(),
            nn.Linear(16, 2)    # hidden2: 16 -> output: 1
        )
        self.to(torch.float64)
        if weight_path is not None:
            checkpoint = torch.load(
                weight_path,
                map_location="cpu",
                weights_only=True,
            )
            self.load_state_dict(checkpoint["model_state_dict"])
            self.eval()

    def forward(self, x):
        # x: shape (batch_size, 1)
        return self.net(x)