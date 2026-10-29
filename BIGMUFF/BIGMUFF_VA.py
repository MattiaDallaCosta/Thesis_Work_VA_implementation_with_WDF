import numpy as np
import math
import scipy
import matplotlib.pyplot as plt

from solver import Solver
from solver import Solver_R

fs = 96000
StopTime = .1

t = np.append(np.arange(0,StopTime,1/fs), StopTime)
amp = 9
f = 50

Vin = amp * np.sin(2*math.pi*f*t) 

#Vin = t*0

Out1 = Solver(Vin,t)
#Out1 = Solver_R(Vin,t)

Vout_sim = scipy.io.loadmat("EbersMollBJTDatasetGenerator/Vout_ss.mat")["Vout_sim_no_trans"]
#Vout_sim = scipy.io.loadmat("EbersMollBJTDatasetGenerator/Vout_ss.mat")["Vout_sim_R_no_trans"]

plt.figure(figsize=(10, 5))

# plt.plot(t, Vin, label="Vin")
plt.plot(t, Out1, label="Vout")
plt.plot(t, Vout_sim, label="Vout_sim")

plt.xlabel("Time (s)")
plt.ylabel("Voltage (V)")
plt.title("Input and output voltage")
plt.grid(True)
plt.legend()
plt.legend(loc="upper right")
plt.tight_layout()
plt.show()