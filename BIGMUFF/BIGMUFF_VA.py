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

Out1 = Solver(Vin,t)