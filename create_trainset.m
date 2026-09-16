clc
clear 
close all

%% Problem data

StopTime = 1;

Vmin = -.85;
Vmax = .85;

Z = load("Z.mat").Z_sol(1,1);

fs = 96000;

low_res_fs = 2e4;
high_res_fs = 7e5;

t_check = 0:1/fs:StopTime;

V_in_check = (0:1/(length(t_check)-1):1) *(abs(Vmin)+Vmax) + Vmin;

search_vals = [-0.8,-0.5,0.5,0.8];

[~, idx] = min(abs(V_in_check - search_vals.'),[],2);

t_val = t_check(idx);

t = [0:1/low_res_fs:t_val(1) - 1/low_res_fs, t_val(1):1/high_res_fs:t_val(2) - 1/high_res_fs, t_val(2):1/low_res_fs:t_val(3) - 1/low_res_fs, t_val(3):1/high_res_fs:t_val(4) - 1/high_res_fs, t_val(4):1/low_res_fs:StopTime, StopTime];
V_in = (t/StopTime) *(abs(Vmin)+Vmax) + Vmin;

% t = t_check;
% V_in = V_in_check;

%% Simulation

Vin_sim = [t.',V_in.'];

model_name = 'va_circuit';  % your .slx model name (no extension)
if ~bdIsLoaded(model_name)
    load_system(model_name);
end   

set_param(model_name, ...
    "StartTime", "0", ...
    "StopTime", num2str(StopTime), ...
    "SolverType", "Variable-step", ...
    "OutputOption", "SpecifiedOutputTimes", ...
    "OutputTimes", mat2str(t.'));

sim_out = sim(model_name); 

I_out = sim_out.i_out.';
t_out = sim_out.tout.';
%V_out = sim_out.v_out.';

%% dataset generation

dataset = [(V_in + Z*I_out); (V_in - Z*I_out)].';
% dataset = [(V_out + Z*I_out); (V_out - Z*I_out)].';

% Create a random permutation of row indices
p = randperm(size(dataset,1));

% Shuffle the rows (i.e., the couples)
data_shuffled = dataset(p, :);

save("dataset.mat", "data_shuffled");
