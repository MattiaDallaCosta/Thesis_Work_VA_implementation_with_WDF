clc
clear 
close all

%% Problem data

StopTime = 1;

Vmin = -.85;
Vmax = .85;

Z = load("Z.mat").Z_sol(1,1);

fs = 96000;

t = 0:1/fs:StopTime;

V_in = (0:1/(length(t)-1):1) *(abs(Vmin)+Vmax) + Vmin;

%% Simulation

Vin_sim = [t.',V_in.'];

model_name = 'va_circuit';  % your .slx model name (no extension)
if ~bdIsLoaded(model_name)
    load_system(model_name);
end   

sim_out = sim(model_name,"StartTime", "0", "StopTime", num2str(StopTime)); 

I_out = sim_out.i_out.';
%V_out = sim_out.v_out.';

%% dataset generation

dataset = [(V_in + Z*I_out); (V_in - Z*I_out)].';
% dataset = [(V_out + Z*I_out); (V_out - Z*I_out)].';

% Create a random permutation of row indices
p = randperm(size(dataset,1));

% Shuffle the rows (i.e., the couples)
data_shuffled = dataset(p, :);

save("dataset.mat", "data_shuffled");
