import numpy as np
import math
import scipy
import matplotlib.pyplot as plt

from solver import Solver

fs = 96000
StopTime = 0.1

t = np.append(np.arange(0,StopTime,1/fs), StopTime)
amp = .5
f = 50

Vin = amp * np.sin(2*math.pi*f*t)

x = np.linspace(1e-8, 1 - 1e-8, 6)
b = 100
alpha_a = (b ** x - 1) / (b - 1);     # type A (log)

Vout_full = scipy.io.loadmat('Vout_full.mat')['Vout_full']

Vout = Solver(Vin,t,1)

plt.figure(figsize=(10, 5))

plt.plot(t, Vin, label="Vin")
plt.plot(t, Vout, label="Vout")

plt.xlabel("Time (s)")
plt.ylabel("Voltage (V)")
plt.title("Input and output voltage")
plt.grid(True)
plt.legend()
plt.legend(loc="upper right")
plt.tight_layout()
plt.show()
#print([len(Vout_full[1,1,:]), len(t), len(Vin)])

