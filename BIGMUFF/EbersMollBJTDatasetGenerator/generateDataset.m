close all; clear all; clc

%% Define the simulation parameters

fs = 96e3;
Ts = 1/fs;

f0 = 1e3;
stop_time = 20/f0;
t = 0:Ts:stop_time;