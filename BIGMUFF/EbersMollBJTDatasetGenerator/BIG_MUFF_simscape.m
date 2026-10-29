clc
clear 
close all

%% Problem data

fs = 96000;
StopTime = 5.1;

t = 0:1/fs:StopTime;
amp = .7;
f = 50;

Vin = [(0:1/fs:StopTime-.1)*0, amp * sin(2*pi*f*(t(t>(StopTime-.1))-(StopTime-.1)))];

Vin_sim = [t.',Vin.'];

%%

model_name = 'BIG_MUFF_PI_inputStage_ssc';  % your .slx model name (no extension)
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

Vout_sim = sim_out.Vout_sim;

figure
plot(t-5,[Vin.',Vout_sim])
grid on
xlim([0,.1])

Vout_sim_no_trans = Vout_sim(t>=(StopTime-.1));

%%

model_name = 'BIG_MUFF_PI_inputStage_ssc_R';  % your .slx model name (no extension)
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

Vout_sim_R = sim_out.Vout_sim;

figure
plot(t-5,[Vin.',Vout_sim_R])
grid on
xlim([0,.1])

Vout_sim_R_no_trans = Vout_sim_R(t>=(StopTime-.1));

%%

save("Vout_ss.mat", "Vout_sim_no_trans","Vout_sim_R_no_trans");


