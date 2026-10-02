import numpy as np
import math
import scipy
import matplotlib.pyplot as plt

from solver import Solver

fs = 96000
StopTime = 0.1

t = np.append(np.arange(0,StopTime,1/fs), StopTime)
amp = .1
f = 50

Vin = amp * np.sin(2*math.pi*f*t)    

x = np.linspace(1e-8, 1 - 1e-8, 6)
b = 100
alpha_a = (b ** x - 1) / (b - 1);     # type A (log)
alpha_c = 1 - (b**(1 - x) - 1) / (b - 1)

Vout_sim = scipy.io.loadmat('Vout_full.mat')['Vout_full']

Out1 = Solver(Vin,t,alpha_c[5])
Out2 = Solver(Vin,t,alpha_c[4])
Out3 = Solver(Vin,t,alpha_c[3])
Out4 = Solver(Vin,t,alpha_c[2])
Out5 = Solver(Vin,t,alpha_c[1])
Out6 = Solver(Vin,t,alpha_c[0])

plt.figure(figsize=(10, 5))

plt.plot(t, Vin, label="Vin")
plt.plot(t, Out1, label="Vout")

plt.xlabel("Time (s)")
plt.ylabel("Voltage (V)")
plt.title("Input and output voltage")
plt.grid(True)
plt.legend()
plt.legend(loc="upper right")
plt.tight_layout()
plt.show()

# Assumptions:
# t: 1D NumPy array of length N
# Out1, ..., Out6: 1D arrays of length N
# Vout_sim: NumPy array with shape (6, 6, N)

gain_labels = [
    "100% gain",
    "80% gain",
    "60% gain",
    "40% gain",
    "20% gain",
    "0% gain",
]

# Corresponding WDF outputs
wdf_outputs = [
    Out1,
    Out2,
    Out3,
    Out4,
    Out5,
    Out6,
]

# MATLAB indices:
# Vout_sim(6,6,:) -> Python Vout_sim[5,5,:]
# Vout_sim(5,6,:) -> Python Vout_sim[4,5,:]
# ...
simulink_rows = [5, 4, 3, 2, 1, 0]

fig, axes = plt.subplots(
    nrows=3,
    ncols=2,
    figsize=(12, 9),
    sharex=True,
    sharey=True,
)

for ax, gain_label, wdf, row in zip(
    axes.flat,
    gain_labels,
    wdf_outputs,
    simulink_rows,
):
    simulink = np.asarray(Vout_sim[row, 5, :]).reshape(-1)
    wdf = np.asarray(wdf).reshape(-1)
    t_plot = np.asarray(t).reshape(-1)

    if not (len(t_plot) == len(wdf) == len(simulink)):
        raise ValueError(
            f"Length mismatch for {gain_label}: "
            f"t={len(t_plot)}, WDF={len(wdf)}, "
            f"Simulink={len(simulink)}"
        )

    ax.plot(t_plot, wdf, label="WDF")
    ax.plot(t_plot, simulink, label="Simulink")

    ax.set_title(gain_label)
    ax.set_xlabel("Time [s]")
    ax.set_ylabel("Amplitude [V]")
    ax.set_xlim(0, 0.1)
    ax.set_ylim(-1, 1)
    ax.grid(True)
    ax.legend(loc="upper right")

fig.suptitle(
    "Comparison of outputs from Simulink and WDF",
    fontsize=16,
)

fig.tight_layout(rect=(0, 0, 1, 0.95))
plt.show()


mse100 = np.mean((np.asarray(Vout_sim[5, 5, :]).reshape(-1) - Out1)**2)
mse80 = np.mean((np.asarray(Vout_sim[4, 5, :]).reshape(-1) - Out1)**2)
mse60 = np.mean((np.asarray(Vout_sim[3, 5, :]).reshape(-1) - Out1)**2)
mse40 = np.mean((np.asarray(Vout_sim[2, 5, :]).reshape(-1) - Out1)**2)
mse20 = np.mean((np.asarray(Vout_sim[1, 5, :]).reshape(-1) - Out1)**2)
mse0 = np.mean((np.asarray(Vout_sim[0, 5, :]).reshape(-1) - Out1)**2)


plt.figure(figsize=(10, 5))

plt.plot(["100", "80", "60", "40", "20", "0"], [mse100,mse80,mse60,mse40,mse20,mse0])

plt.xlabel("Gain [%]")
plt.ylabel("MSE")
plt.title("Input and output voltage")
plt.grid(True)
plt.tight_layout()
plt.show()


