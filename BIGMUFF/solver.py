import numpy as np
import sympy as sm
import scipy
import torch
from MLP import MLP2x16

def Solver(Vin, t, gain):

    model = MLP2x16("mlp_2x16_5_2e-5.pth")  
    fs = 1/(t[1]-t[0])
    V_dd = 9

    R = np.array([10,1e3,4.7,1e3,10])*1e3 # Resistance values as ordered in the circuit
    R_v = np.array([1e3,10])*1e3; # variable resistances

    C = np.array([1,10,47,1e3,1])*1e-9; # Capacitance values as ordered in the circuit

    Z_C = (1/fs)/(2*C); # Reference Resistance for capacitors

    #    Nl Ro C5 C3 C1 R1 Rd R2 R4 R5 in C2 C4
    Bv = np.matrix([[1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1],  # Nl
          [0, 1, 0, 0, 0, 0, 0, 0,-1,-1, 0, 0,-1],  # Ro
          [0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1],  # C5
          [0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0],  # C3
          [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0],  # C1
          [0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0]])  # R1

    #    Nl Ro C5 C3 C1 R1 Rd R2 R4 R5 in C2 C4
    Bi = np.matrix([[1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],  # Nl
          [0, 1, 0, 0, 0, 0, 0, 0, 0,-1, 0, 0,-1],  # Ro
          [0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1],  # C5
          [0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0],  # C3
          [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0],  # C1
          [0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0]])  # R1

    ports = Bi.shape[1]
    nl_ports = 1

    Z = sm.Matrix.diag(sm.Array([*[sm.nan] * nl_ports, R_v[1], Z_C[4], Z_C[2], Z_C[0], R[0], R_v[0] * (1 - gain) + R[2], R[1], R[3], R[4], 5e3, Z_C[1], Z_C[3]]))

    Zsym_symbols = sm.symbols(f"z0:{nl_ports*nl_ports}", real=True)
    Zsym = sm.Matrix(nl_ports, nl_ports, Zsym_symbols)

    Z[0:nl_ports,0:nl_ports] = Zsym

    Lambda = (Bi.T * (Bv * Z * Bi.T).inv()) * Bv

    S = sm.eye(ports) - 2 * Z * Lambda

    sol = sm.solve(S[0:nl_ports,0:nl_ports], Zsym, dict=True)

    vals_num = sm.Array([np.double(sm.N(sol[0][s])) for s in Zsym_symbols])

    Z_vals = sm.Matrix(Zsym.rows,Zsym.cols,vals_num)

    Z_sol = Z
    Z_sol[0:nl_ports,0:nl_ports] = Z_vals

    Lambda_sol = (Bi.T * (Bv * Z_sol * Bi.T).inv()) * Bv

    S_sol = sm.eye(ports) - 2 * Z_sol * Lambda_sol

    S_loc = np.asarray(S_sol[0:nl_ports,:])
    S_sol = np.asarray(S_sol)

    Vout = np.zeros(len(t), dtype=np.float64)
    a = np.asarray(scipy.io.loadmat("a_init_vals.mat")["a"],dtype=np.float64).reshape(-1)
    #a = np.zeros(ports, dtype=np.float64)
    b = np.zeros(ports, dtype=np.float64)

    for i in range(len(t)):
      b[[7, 10]] = [V_dd/2,Vin[i]]
      b[[2,3,4,11,12]] = a[[2,3,4,11,12]]; 

      a[:nl_ports] = S_loc @ b
      with torch.no_grad():
        b[0] = model(torch.tensor([[np.float64(a[0])]])).item()

      a = S_sol @ b
      Vout[i] = (a[1] + b[1]) / 2.0

    return Vout