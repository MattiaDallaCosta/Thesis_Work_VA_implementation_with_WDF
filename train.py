import torch
import torch.nn as nn
import torch.optim as optim

from MLP import MLP2x16  # your model class in a separate file

# ... prepare X, Y ...

model = MLP2x16()
criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=1e-3)

# training loop
for epoch in range(200):
    optimizer.zero_grad()
    preds = model(X)
    loss = criterion(preds, Y)
    loss.backward()
    optimizer.step()

# save weights
torch.save(model.state_dict(), "mlp_2x16.pth")