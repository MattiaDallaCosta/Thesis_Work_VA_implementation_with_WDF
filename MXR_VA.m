clear
close all
clc

%%

fs = 96e3; % sampling frequency
StopTime = 1.3;
t = 0:1/fs:StopTime; % time axis

amp = 0.5;
f = 100;
Vin(t>=0.3) = amp*sin(2*pi*f*t(t<=1));

Vin=Vin.';

% V_dd = 9;
% 
% R = [10,1e3,4.7,1e3,10]*1e3; % Resistance values as ordered in the circuit
% R_v = [1e3,10]*1e3; % variable resistances
% 
% C = [1,10,47,1e3,1]*1e-9; % Capacitance values as ordered in the circuit
% 
% Z_C = (1/fs)./(2.*C); % Reference Resistance for capacitors
% 
% %    Nl Ro C4 C3 C1 R1 Rd R2 R4 R5 in C2 C4
% Bv = [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1;  % Nl
%       0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1;  % Ro
%       0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1;  % C4
%       0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0;  % C3
%       0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0;  % C1
%       0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0]; % R1
% 
% %    Nl Ro C4 C3 C1 R1 Rd R2 R4 R5 in C2 C4
% Bi = [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1;  % Nl
%       0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1;  % Ro
%       0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1;  % C4
%       0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0;  % C3
%       0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0;  % C1
%       0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0]; % R1
% 
% ports = length(Bi);
% nl_ports = 1;
% 
% Z_d = [nan(1,nl_ports), R_v(2), Z_C([4,3,1]), R(1), R_v(1)+R(3), R([2,4,5]), 5e3,Z_C([2,4])];
% %Z_d = [nan(1,nl_ports), R_v(2), Z_C([4,3,1]), R(1), R(3), R([2,4,5]), 5e3,Z_C([2,4])];
% 
% Z = sym(diag(Z_d));
% 
% Zsym = sym('z',[nl_ports nl_ports],'real');
% 
% Z(1:nl_ports,1:nl_ports) = Zsym;
% 
% Lambda = (Bi.'/(Bv*Z*Bi.'))*Bv;
% 
% S = eye(ports) - 2*Z*Lambda;
% 
% %%
% sol = solve(S(1:nl_ports,1:nl_ports) == 0, Zsym(:));
% 
% %%
% 
% % vars as passed to solve (column vector, same order)
% vars = Zsym(:);
% 
% % get solution values in the vars order and convert to numeric
% if isstruct(sol)
%     vals_cell = arrayfun(@(v) sol.(char(v)), vars, 'UniformOutput', false);
%     vals_num  = cellfun(@double, vals_cell);
% else
%     % sol is numeric: assume it matches vars order or is a row vector.
%     vals_num = double(sol(:));
% end
% 
% % reshape
% z_vals = reshape(vals_num, size(Zsym));
% 
% Z_sol = diag(Z_d);
% Z_sol(1:nl_ports,1:nl_ports) = z_vals;
% 
% Lambda_sol = (Bi.'/(Bv*Z_sol*Bi.'))*Bv;
% S_sol = eye(ports) - 2*Z_sol*Lambda_sol;
% 
% S_loc = S_sol(1:nl_ports,:);
% 
% %% Output
% Vout = zeros(length(t), 1);
% a = zeros(ports, 1);
% b = zeros(ports, 1);
% 
% %% loop
% 
% for i = 1:length(t)
%     % Update reflected waves
%     b([8,11]) = [V_dd/2, Vin(i)]; % Input and power supply voltage
%     b([3,4,5,12,13]) = a([3,4,5,12,13]); % Capacitors
% 
%     % local scattering
%     a(1:nl_ports) = S_loc * b;
%     % some stuff that i didn't understand
% 
%     [b_nl, r_nl] = ADiodesWrightOmega_rho1(a(1,1),Z_sol(1,1));
% 
%     b(1,1) = b_nl;
% 
%     Z_sol(1,1) = Z_sol(1,1);
% 
%     %global scattering
%     a = S_sol*b;
% 
%     Vout(i) = (a(2) + b(2))/2;
% end

Out1 = solveCircuit(Vin,t,1,1);
Out2 = solveCircuit(Vin,t,0.8,1);
Out3 = solveCircuit(Vin,t,0.6,1);
Out4 = solveCircuit(Vin,t,0.4,1);
Out5 = solveCircuit(Vin,t,0.2,1);
Out6 = solveCircuit(Vin,t,0,1);

Outv1 = solveCircuit(Vin,t,1,0.7);
Outv2 = solveCircuit(Vin,t,1,0.5);
Outv3 = solveCircuit(Vin,t,1,0.3);


%% Plots

figure
subplot(3,2,1)
plot(t,Out1)
xlim([0.2,0.5])
ylim([-1, 1])
grid on
subplot(3,2,2)
plot(t, Out2)
xlim([0.2,0.5])
ylim([-1, 1])
grid on
subplot(3,2,3)
plot(t, Out3)
xlim([0.2,0.5])
ylim([-1, 1])
grid on
subplot(3,2,4)
plot(t, Out4)
xlim([0.2,0.5])
ylim([-1, 1])
grid on
subplot(3,2,5)
plot(t, Out5)
xlim([0.2,0.5])
ylim([-1, 1])
grid on
subplot(3,2,6)
plot(t, Out6)
xlim([0.2,0.5])
ylim([-1, 1])
grid on

%%

figure
title("Crest comparison of outputs at different gains")
plot(t-0.3,[Out1, Out2, Out3, Out4, Out5, Out6])
grid on
legend("100% gain", "80% gain", "60% gain", "40% gain", "20% gain", "0% gain")
xlim([0.2995, 0.315]-0.3)
ylim([-0.8,0])
%%
function [Vout] = solveCircuit(Vin, t, gain, vol)

fs = 1/(t(2)-t(1));

V_dd = 9;

R = [10,1e3,4.7,1e3,10]*1e3; % Resistance values as ordered in the circuit
R_v = [1e3,10]*1e3; % variable resistances

C = [1,10,47,1e3,1]*1e-9; % Capacitance values as ordered in the circuit

Z_C = (1/fs)./(2.*C); % Reference Resistance for capacitors

%    Nl Ro C4 C3 C1 R1 Rd R2 R4 R5 in C2 C4
Bv = [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1;  % Nl
      0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1;  % Ro
      0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1;  % C4
      0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0;  % C3
      0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0;  % C1
      0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0]; % R1

%    Nl Ro C4 C3 C1 R1 Rd R2 R4 R5 in C2 C4
Bi = [1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1;  % Nl
      0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1;  % Ro
      0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1;  % C4
      0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0;  % C3
      0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0;  % C1
      0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 1, 0]; % R1

ports = length(Bi);
nl_ports = 1;

Z_d = [nan(1,nl_ports), R_v(2), Z_C([4,3,1]), R(1), R_v(1)*(1-gain)+R(3), R([2,4,5]), 5e3,Z_C([2,4])];

Z = sym(diag(Z_d));

Zsym = sym('z',[nl_ports nl_ports],'real');

Z(1:nl_ports,1:nl_ports) = Zsym;

Lambda = (Bi.'/(Bv*Z*Bi.'))*Bv;

S = eye(ports) - 2*Z*Lambda;

sol = solve(S(1:nl_ports,1:nl_ports) == 0, Zsym(:));

% vars as passed to solve (column vector, same order)
vars = Zsym(:);

% get solution values in the vars order and convert to numeric
if isstruct(sol)
    vals_cell = arrayfun(@(v) sol.(char(v)), vars, 'UniformOutput', false);
    vals_num  = cellfun(@double, vals_cell);
else
    % sol is numeric: assume it matches vars order or is a row vector.
    vals_num = double(sol(:));
end

% reshape
z_vals = reshape(vals_num, size(Zsym));

Z_sol = diag(Z_d);
Z_sol(1:nl_ports,1:nl_ports) = z_vals;

Lambda_sol = (Bi.'/(Bv*Z_sol*Bi.'))*Bv;
S_sol = eye(ports) - 2*Z_sol*Lambda_sol;

S_loc = S_sol(1:nl_ports,:);

Vout = zeros(length(t), 1);
a = zeros(ports, 1);
b = zeros(ports, 1);

for i = 1:length(t)
    % Update reflected waves
    b([8,11]) = [V_dd/2, Vin(i)]; % Input and power supply voltage
    b([3,4,5,12,13]) = a([3,4,5,12,13]); % Capacitors

    % local scattering
    a(1:nl_ports) = S_loc * b;
    % some stuff that i didn't understand
    
    [b_nl, ~] = ADiodesWrightOmega_rho1(a(1,1),Z_sol(1,1));

    b(1,1) = b_nl;

    Z_sol(1,1) = Z_sol(1,1);

    %global scattering
    a = S_sol*b;

    Vout(i) = (a(2) + b(2))/2;
end

Vout = Vout*vol;
    
end