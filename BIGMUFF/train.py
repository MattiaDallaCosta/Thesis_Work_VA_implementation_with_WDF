from scipy.constants import epsilon_0
import torch
import torch.nn as nn
import torch.optim as optim
import scipy
import numpy as np
from torch.utils.data import TensorDataset, DataLoader
import matplotlib.pyplot as plt

from MLP import MLP2x16  # your model class in a separate file

class NMSELoss(nn.Module):
    def __init__(self, epsilon=1e-8):
        super(NMSELoss, self).__init__()
        self.epsilon = epsilon
    
    def forward(self, b_pred, b_true):
        mse = torch.sum((b_true - b_pred) ** 2, dim = 0)
        norm = torch.norm(b_true ** 2, dim = 0)
        nmse = torch.sum(mse/(norm + self.epsilon))

        return nmse

# loading dividing and preparing dataset

dataset = scipy.io.loadmat("EbersMollBJTDatasetGenerator/dataset.mat")["dataset"]

print("dataset:", dataset.shape)

train_size = round(7*dataset.shape[0]/10)
etest_size = round(2*dataset.shape[0]/10)

data_train = dataset[:train_size]
data_etest = dataset[train_size:train_size + etest_size]
data_test = dataset[train_size + etest_size:]

def make_tensors(data):
    X = torch.from_numpy(np.asarray(data[:,0:2], dtype=np.float64)).reshape(-1,2)
    Y = torch.from_numpy(np.asarray(data[:,2:4], dtype=np.float64)).reshape(-1,2)
    return X,Y


X_train, Y_train = make_tensors(data_train)
X_etest, Y_etest = make_tensors(data_etest)
X_test, Y_test = make_tensors(data_test)

print("Training:", X_train.shape)
print("Evaluation:", X_etest.shape)
print("Test:", X_test.shape)

train_dataset = TensorDataset(X_train, Y_train)
train_loader = DataLoader(
    train_dataset,
    batch_size=128,
    shuffle=True,
)


#definition of neural net

# --------------------------------------------------
# Model, loss, optimizer
# --------------------------------------------------

model = MLP2x16()
criterion = NMSELoss()
optimizer = optim.Adam(model.parameters(), lr=9e-4)

# scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=350, gamma=0.8)
scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
    optimizer,
    mode="min",
    factor=0.7,
    patience=2,
    min_lr=1e-8,
)

# --------------------------------------------------
# Training and evaluation
# --------------------------------------------------

num_epochs = 150

train_losses = []
etest_losses = []

best_etest_loss = float("inf")
best_state = None

for epoch in range(num_epochs):

    # Training mode
    model.train()

    epoch_loss = 0.0
    for X_batch, Y_batch in train_loader:
        optimizer.zero_grad()

        train_preds = model(X_batch)
        train_loss = criterion(train_preds, Y_batch)

        train_loss.backward()
        optimizer.step()
        epoch_loss += train_loss.item() * X_batch.size(0)

    epoch_loss /= len(train_loader.dataset)

    # scheduler.step()

    # Evaluation mode
    model.eval()

    with torch.no_grad():
        etest_preds = model(X_etest)
        etest_loss = criterion(etest_preds, Y_etest)

    train_loss_value = epoch_loss #.item()
    etest_loss_value = etest_loss.item()

    if etest_loss.item() < best_etest_loss:
        best_etest_loss = etest_loss.item()
        best_state = {
            key: value.detach().clone()
            for key, value in model.state_dict().items()
        }
    scheduler.step(etest_loss)

    train_losses.append(train_loss_value)
    etest_losses.append(etest_loss_value)

    if epoch % 10 == 0 or epoch == num_epochs - 1:
        print(
            f"Epoch {epoch:4d}/{num_epochs} | "
            f"train loss: {train_loss_value:.6e} | "
            f"etest loss: {etest_loss_value:.6e}"
        )


# --------------------------------------------------
# Final test evaluation
# --------------------------------------------------

model.eval()

with torch.no_grad():
    test_preds = model(X_test)
    test_loss = criterion(test_preds, Y_test)

print(f"\nFinal test loss: {test_loss.item():.6e}")

model.load_state_dict(best_state)

# Test the restored best model
model.eval()
with torch.no_grad():
    test_preds = model(X_test)
    test_loss = criterion(test_preds, Y_test)

print(f"Final test loss (best state):      {test_loss.item():.6e}")


# --------------------------------------------------
# Save model and training history
# --------------------------------------------------

torch.save(
    {
        "model_state_dict": model.state_dict(),
        "train_losses": train_losses,
        "etest_losses": etest_losses,
    },
    "mlp_2x16.pth",
)


plt.semilogy(train_losses, label="training")
plt.semilogy(etest_losses, label="evaluation")
plt.xlabel("Epoch")
plt.ylabel("MSE loss")
plt.grid(True)
plt.legend()
plt.show()
