clc
clear 
close all

%%

StopTime = 1;

Vmin = -4.5;
Vmax = 4.5;

fs = 96000;

t = 0:1/fs:StopTime;

V_in = (0:1/(length(t)-1):1) *(abs(Vmin)+Vmax) + Vmin;

Vin_sim = [V_in.',t.'];

model_name = 'va_circuit';  % your .slx model name (no extension)
if ~bdIsLoaded(model_name)
    load_system(model_name);
end   

I_out = sim(model_name).i_out;