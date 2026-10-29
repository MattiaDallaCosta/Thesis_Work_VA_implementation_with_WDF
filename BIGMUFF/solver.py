import numpy as np
import sympy as sm
import scipy
import torch
from MLP import MLP2x16

def Solver(Vin, t):

    model = MLP2x16("mlp_2x16_best.pth")  
    fs = 1/(t[1]-t[0])
    V_dd = 9

    S_sol = scipy.io.loadmat('Scatter.mat')['S_sol']
    S_loc = scipy.io.loadmat('Scatter.mat')['S_loc']
    nl_ports = int(np.asarray(scipy.io.loadmat('Scatter.mat')['nl_ports']).item())

    ports = S_sol.shape[0]

    Vout = np.zeros(len(t), dtype=np.float64)
    a = np.asarray(scipy.io.loadmat("a_init_vals.mat")["a"],dtype=np.float64).reshape(-1)
    b = np.zeros(ports, dtype=np.float64)
    #a = np.zeros(ports, dtype=np.float64)

    for i in range(len(t)):
      print(t[i], end='\r')
      b[[6, 8]] = [V_dd, Vin[i]]
      b[[4,5,7]] = a[[4,5,7]]; 

      a[:nl_ports] = S_loc @ b
      with torch.no_grad():
        b[0:2] = model(torch.tensor([[np.float64(a[0]), np.float64(a[1])]])).squeeze(0)

      a = S_sol @ b
      Vout[i] = (a[10] + b[10]) / 2.0

    # scipy.io.savemat(
    #     "a_init_vals.mat",
    #     {
    #         "a": a,
    #     }
    # )
    return Vout

def Solver_R(Vin, t):

    fs = 1/(t[1]-t[0])
    V_dd = 9

    S_sol = scipy.io.loadmat('Scatter_R.mat')['S_sol']
    S_loc = scipy.io.loadmat('Scatter_R.mat')['S_loc']
    nl_ports = int(np.asarray(scipy.io.loadmat('Scatter_R.mat')['nl_ports']).item())

    ports = S_sol.shape[0]

    Vout = np.zeros(len(t), dtype=np.float64)
    a = np.asarray(scipy.io.loadmat("a_init_vals_r.mat")["a"],dtype=np.float64).reshape(-1)
    b = np.zeros(ports, dtype=np.float64)
    #a = np.zeros(ports, dtype=np.float64)

    for i in range(len(t)):
      print(t[i], end='\r')
      b[[6, 8]] = [V_dd, Vin[i]]
      b[[4,5,7]] = a[[4,5,7]]; 

      a = S_sol @ b
      Vout[i] = (a[10] + b[10]) / 2.0

    #  scipy.io.savemat(
    #      "a_init_vals_r.mat",
    #      {
    #          "a": a,
    #      }
    #  )
    return Vout