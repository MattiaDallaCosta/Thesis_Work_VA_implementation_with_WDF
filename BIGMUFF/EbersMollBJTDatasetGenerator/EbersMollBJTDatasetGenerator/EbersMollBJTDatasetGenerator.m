close all; clear all; clc

%% Define the simulation parameters

fs = 96e3;
Ts = 1/fs;

f0 = 1e3;
stop_time = 20/f0;
t = 0:Ts:stop_time;

output_signals_Vbe_sin = [];
output_signals_Vbc_sin = [];

%% Simulate the Circuit
% Vbc DC [-10V, 2V]; Vbe Sinusoid [-1.5V, 1.5V]
n_points = 256;

Vbc_ramp = linspace(-10, 2, n_points);
Vbe = [t', linspace(0, 1.5, length(t))' .* sin(2*pi*f0*t')];

for i = 1:n_points
    Vbc = [t', repelem(Vbc_ramp(i), length(t))'];
    
    % Simulate the circuit with the defined Vbc and Vbe
    simOut = sim("EbersMollBJTModel_ssc");

    % Collect Simulation Data
    t_sim = simOut.tout;
    outputs = simOut.yout;

    Ibc = outputs.getElement('Ibc').Values.Data;
    Ibe = outputs.getElement('Ibe').Values.Data;

    output_signals_Vbe_sin = [output_signals_Vbe_sin; Vbc(:,2), Ibc, Vbe(:,2), Ibe];
end

%% Simulate the Circuit
% Vbc Sinusoid [0V, 10V]; Vbe DC [0V, 1.5V]
n_points = 256;
 
Vbe_ramp = linspace(0, 1.5, n_points);
Vbc = [t', linspace(0, 10, length(t))' .* sin(2*pi*f0*t')];

for i = 1:n_points
    Vbe = [t', repelem(Vbe_ramp(i), length(t))'];
    
    % Simulate the circuit with the defined Vbc and Vbe
    simOut = sim("EbersMollBJTModel_ssc");

    % Collect Simulation Data
    t_sim = simOut.tout;
    outputs = simOut.yout;

    Ibc = outputs.getElement('Ibc').Values.Data;
    Ibe = outputs.getElement('Ibe').Values.Data;

    output_signals_Vbc_sin = [output_signals_Vbc_sin; Vbc(:,2), Ibc, Vbe(:,2), Ibe];
end
%% Test Plots
t_plot = 0:Ts:Ts*(length(output_signals_Vbe_sin)-1);


figure()
plot(t_plot, output_signals_Vbe_sin(:, 1))
hold on
plot(t_plot, output_signals_Vbe_sin(:, 3))

figure()
plot(t_plot, output_signals_Vbe_sin(:, 2))
hold on
plot(t_plot, output_signals_Vbe_sin(:, 4))
