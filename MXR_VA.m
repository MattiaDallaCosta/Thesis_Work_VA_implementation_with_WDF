clear
close all
clc

%%

fs = 96e3; % sampling frequency
StopTime = .1;
t = 0:1/fs:StopTime; % time axis

amp = .1;
f = 50;
Vin = amp*sin(2*pi*f*t);

Vin=Vin.';

%Vin = t *0;

x = linspace(1e-8, 1 - 1e-8, 6);
b = 100;
alpha_a = (b.^x - 1) / (b - 1);     % type A (log)
alpha_c = 1 - (b.^(1 - x) - 1) / (b - 1);

Vout_sim = load("Vout_full.mat").Vout_full;

Out1 = solveCircuit(Vin,t,alpha_c(6));
Out2 = solveCircuit(Vin,t,alpha_c(5));
Out3 = solveCircuit(Vin,t,alpha_c(4));
Out4 = solveCircuit(Vin,t,alpha_c(3));
Out5 = solveCircuit(Vin,t,alpha_c(2));
Out6 = solveCircuit(Vin,t,alpha_c(1));

%% Plots

figure
sgtitle("comparison of outputs from simulink and WDF")
subplot(3,2,1)
plot(t,[Out1, squeeze(Vout_sim(6,6,:))])
title('100% gain')
xlabel('Time [s]')
ylabel('Amplitude [V]')
legend("Wdf", "Simulink")
xlim([0,0.1])
ylim([-1, 1])
grid on
subplot(3,2,2)
plot(t, [Out2, squeeze(Vout_sim(5,6,:))])
title('80% gain')
xlabel('Time [s]')
ylabel('Amplitude [V]')
legend("Wdf", "Simulink")
xlim([0,0.1])
ylim([-1, 1])
grid on
subplot(3,2,3)
plot(t, [Out3, squeeze(Vout_sim(4,6,:))])
title('60% gain')
xlabel('Time [s]')
ylabel('Amplitude [V]')
legend("Wdf", "Simulink")
xlim([0,0.1])
ylim([-1, 1])
grid on
subplot(3,2,4)
plot(t, [Out4, squeeze(Vout_sim(3,6,:))])
title('40% gain')
xlabel('Time [s]')
ylabel('Amplitude [V]')
legend("Wdf", "Simulink")
xlim([0,0.1])
ylim([-1, 1])
grid on
subplot(3,2,5)
plot(t, [Out5, squeeze(Vout_sim(2,6,:))])
title('20% gain')
xlabel('Time [s]')
ylabel('Amplitude [V]')
legend("Wdf", "Simulink")
xlim([0,0.1])
ylim([-1, 1])
grid on
subplot(3,2,6)
plot(t, [Out6, squeeze(Vout_sim(1,6,:))])
title('0% gain')
xlabel('Time [s]')
ylabel('Amplitude [V]')
legend("Wdf", "Simulink")
xlim([0,0.1])
ylim([-1, 1])
grid on

%%

figure
plot(t,[Out1, Out2, Out3, Out4, Out5, Out6])
grid on
sgtitle("Crest comparison of outputs at different gains")
xlabel('Time [s]')
ylabel('Amplitude [V]')
legend("100% gain", "80% gain", "60% gain", "40% gain", "20% gain", "0% gain")
xlim([-0.001, 0.05])
ylim([0,0.55])