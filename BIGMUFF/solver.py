import numpy as np
import sympy as sm
import scipy
import torch
from MLP import MLP2x16

def Solver(Vin, t):

    model = MLP2x16("mlp_2x16.pth")  
    fs = 1/(t[1]-t[0])
    V_dd = 9

    S_sol = scipy.io.loadmat('Scatter.mat')['S_sol']
    S_loc = scipy.io.loadmat('Scatter.mat')['S_loc']
    nl_ports = scipy.io.loadmat('Scatter.mat')['nl_ports']

    ports = S_sol.shape[0]

    Vout = np.zeros(len(t), dtype=np.float64)
    #a = np.asarray(scipy.io.loadmat("a_init_vals.mat")["a"],dtype=np.float64).reshape(-1)
    b = np.zeros(ports, dtype=np.float64)
    a = np.zeros(ports, dtype=np.float64)

    for i in range(len(t)):
      b[[4, 10]] = [Vin[i], V_dd/2]
      b[[0,3,8]] = a[[0,3,8]]; 

      a[:nl_ports] = S_loc @ b
      with torch.no_grad():
        b[0] = model(torch.tensor([[np.float64(a[0])]])).item()

      a = S_sol @ b
      Vout[i] = (a[1] + b[1]) / 2.0

    return Vout