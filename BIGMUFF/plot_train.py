import matplotlib.pyplot as plt
import torch
import torch.nn as nn
import torch.optim as optim
import scipy
import numpy as np
from MLP import MLP2x16  # your model class in a separate file

# --------------------------------------------------
# Final test evaluation
# --------------------------------------------------

model = MLP2x16("mlp_2x16.pth") 

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

model.eval()

with torch.no_grad():
    test_preds = model(X_test)

Z = scipy.io.loadmat("Scatter.mat")["Z_sol"]
Z = np.diag(Z[0:2,0:2])

V_true = 0.5 * (X_test + Y_test)
V_pred = 0.5 * (X_test + test_preds)

print("V_true:", V_true.shape)
print("V_pred:", V_pred.shape)

print(Z)

# Calculate Current: I = 0.5 * (a - b) / Z
I_true1 = 0.5 * (X_test[:,0] - Y_test[:,0]) / Z[0]
I_pred1 = 0.5 * (X_test[:,0] - test_preds[:,0]) / Z[0]
I_true2 = 0.5 * (X_test[:,1] - Y_test[:,1]) / Z[1]
I_pred2 = 0.5 * (X_test[:,1] - test_preds[:,1]) / Z[1]

# print("I_true:", I_true.shape)
# print("I_pred:", I_pred.shape)


fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(
    2, 2,
    figsize=(12, 5),
)
ax1.scatter(X_test[:,0], Y_test[:,0], s=.5, label="true")
ax1.scatter(X_test[:,0], test_preds[:,0], s=.5, label="predicted")
ax1.set_title("a and b for be")
ax1.set_xlabel("a (V)")
ax1.set_ylabel("b (V)")
ax1.legend()
ax1.grid(True)

ax3.scatter(X_test[:,1], Y_test[:,1], s=.5, label="true")
ax3.scatter(X_test[:,1], test_preds[:,1], s=.5, label="predicted")
ax3.set_title("a and b for bc")
ax3.set_xlabel("a (V)")
ax3.set_ylabel("b (V)")
ax3.legend()
ax3.grid(True)

ax2.scatter(V_true[:,0], I_true1, s=.5, label="true")
ax2.scatter(V_pred[:,0], I_pred1, s=.5, label="predicted")
ax2.set_title("V/I curve for be")
ax2.set_xlabel("V (V)")
ax2.set_ylabel("I (A)")
ax2.legend()
ax2.grid(True)

ax4.scatter(V_true[:,1], I_true2, s=.5, label="true")
ax4.scatter(V_pred[:,1], I_pred2, s=.5, label="predicted")
ax4.set_title("V/I curve for bc")
ax4.set_xlabel("V (V)")
ax4.set_ylabel("I (A)")
ax4.legend()
ax4.grid(True)

fig.tight_layout()
plt.show()
