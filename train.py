import torch
import torch.nn as nn
import torch.optim as optim
import scipy
import numpy as np

from MLP import MLP2x16  # your model class in a separate file

# loading dividing and preparing dataset

dataset = scipy.io.loadmat("dataset.mat")["data_shuffled"]

train_size = round(7*dataset.shape[0]/10)
etest_size = round(2*dataset.shape[0]/10)

data_train = dataset[:train_size]
data_etest = dataset[train_size:train_size + etest_size]
data_test = dataset[train_size + etest_size:]

def make_tensors(data):
    X = torch.from_numpy(np.asarray(data[:,0], dtype=np.float32)).reshape(-1,1)
    Y = torch.from_numpy(np.asarray(data[:,1], dtype=np.float32)).reshape(-1,1)
    return X,Y


X_train, Y_train = make_tensors(data_train)
X_etest, Y_etest = make_tensors(data_etest)
X_test, Y_test = make_tensors(data_test)

print("Training:", X_train.shape, Y_train.shape)
print("Evaluation:", X_etest.shape, Y_etest.shape)
print("Test:", X_test.shape, Y_test.shape)

#definition of neural net

# --------------------------------------------------
# Model, loss, optimizer
# --------------------------------------------------

model = MLP2x16()
criterion = nn.MSELoss()
optimizer = optim.Adam(model.parameters(), lr=1e-2)


# --------------------------------------------------
# Training and evaluation
# --------------------------------------------------

num_epochs = 1000

train_losses = []
etest_losses = []

best_etest_loss = float("inf")
best_state = None

for epoch in range(num_epochs):

    # Training mode
    model.train()

    optimizer.zero_grad()

    train_preds = model(X_train)
    train_loss = criterion(train_preds, Y_train)

    train_loss.backward()
    optimizer.step()

    # Evaluation mode
    model.eval()

    with torch.no_grad():
        etest_preds = model(X_etest)
        etest_loss = criterion(etest_preds, Y_etest)

    train_loss_value = train_loss.item()
    etest_loss_value = etest_loss.item()

    if etest_loss.item() < best_etest_loss:
        best_etest_loss = etest_loss.item()
        best_state = {
            key: value.detach().clone()
            for key, value in model.state_dict().items()
        }

    train_losses.append(train_loss_value)
    etest_losses.append(etest_loss_value)

    if epoch % 10 == 0 or epoch == num_epochs - 1:
        print(
            f"Epoch {epoch + 1:4d}/{num_epochs} | "
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

import matplotlib.pyplot as plt

plt.semilogy(train_losses, label="training")
plt.semilogy(etest_losses, label="evaluation")
plt.xlabel("Epoch")
plt.ylabel("MSE loss")
plt.grid(True)
plt.legend()
plt.show()