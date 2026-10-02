import torch
import torch.nn as nn
import scipy
import numpy as np
import matplotlib.pyplot as plt

from MLP import MLP2x16

model = MLP2x16("mlp_2x16_5_2e-5.pth")


dataset = scipy.io.loadmat("dataset.mat")["data_shuffled"]

train_size = round(7*dataset.shape[0]/10)
etest_size = round(2*dataset.shape[0]/10)

data_train = dataset[:train_size]
data_etest = dataset[train_size:train_size + etest_size]
data_test = dataset[train_size + etest_size:]

def make_tensors(data):
    X = torch.from_numpy(np.asarray(data[:,0], dtype=np.float64)).reshape(-1,1)
    Y = torch.from_numpy(np.asarray(data[:,1], dtype=np.float64)).reshape(-1,1)
    return X,Y


X_train, Y_train = make_tensors(data_train)
X_etest, Y_etest = make_tensors(data_etest)
X_test, Y_test = make_tensors(data_test)

criterion = nn.MSELoss()

model.eval()
with torch.no_grad():
    test_preds = model(X_test)
    test_loss = criterion(test_preds, Y_test)

Z = scipy.io.loadmat("Z.mat")["Z_sol"]
Z = Z[0,0]

V_true = 0.5 * (X_test + Y_test)
V_pred = 0.5 * (X_test + test_preds)

# Calculate Current: I = 0.5 * (a - b) / Z
I_true = 0.5 * (X_test - Y_test) / Z
I_pred = 0.5 * (X_test - test_preds) / Z


fig, (ax1, ax2) = plt.subplots(
    1, 2,
    figsize=(12, 5),
)
ax1.scatter(X_test, Y_test, s=.5, label="true")
ax1.scatter(X_test, test_preds, s=.5, label="predicted")
ax1.set_title("a and b")
ax1.set_xlabel("a")
ax1.set_ylabel("b")
ax1.legend()
ax1.grid(True)

ax2.scatter(V_true, I_true, s=.5, label="true")
ax2.scatter(V_pred, I_pred, s=.5, label="predicted")
ax2.set_title("V/I curve")
ax2.set_xlabel("V (V)")
ax2.set_ylabel("I (A)")
ax2.legend()
ax2.grid(True)

fig.tight_layout()
plt.show()
