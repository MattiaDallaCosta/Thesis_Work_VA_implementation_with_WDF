% clear
close all
clc

%%
fs = 96000;

R = [39,47,470,10,1e-1,1]*1e3; % Resistance values as ordered in the circuit

C = [1e6,470,1e6]*1e-12; % Capacitance values as ordered in the circuit

Z_C = (1/fs)./(2.*C); % Reference Resistance for capacitors

%    C3 Ro R5 C1 R1 BE BC R2 C2 R3 R4
Q = [1, 0, 0, 0, 0, 0, 1, 0, 1, 1,-1;   % C3
     0, 1, 0, 0, 0, 0, 1, 0, 1, 1,-1;   % Ro
     0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0;   % R5
     0, 0, 0, 1, 0,-1,-1,-1,-1,-1, 0;   % C1
     0, 0, 0, 0, 1,-1,-1,-1,-1,-1, 0];  % R1

%    BC BE R5 Ro R1 R2 R3 R4 C1 C2 C3
Q = [1, 0, 0, 0, 0, 0, 1,-1, 0, 1,-1;   % BC
     0, 1, 0, 0, 0,-1, 0,-1,-1, 0,-1;   % BE
     0, 0, 1, 0, 0,-1, 0,-1,-1, 0,-1;   % R5
     0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1;   % Ro
     0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0];  % R1

ports = length(Q);
nl_ports = 2;

Z_d = [Z_C(3), R(6), R(5), Z_C(1), R(1), nan(1,nl_ports), R(2), Z_C(2), R(3), R(4)];
Z_d = [nan(1,nl_ports), R([5,6,1,2,3,4]), Z_C];

Z = sym(diag(Z_d));

Zsym = sym('z',[nl_ports nl_ports],'real');

Z(1:nl_ports,1:nl_ports) = Zsym;

S = 2* Q.' * inv(Q*inv(Z)*Q.') * Q * inv(Z) - eye(ports);

sol = solve(S(1:nl_ports,1:nl_ports) == 0, Zsym(:));

% vars as passed to solve (column vector, same order)
vars = Zsym(:);

% get solution values in the vars order and convert to numeric
if isstruct(sol)
    vals_cell = arrayfun(@(v) sol.(char(v)), vars, 'UniformOutput', false);
    vals_num  = cell2mat(cellfun(@double, vals_cell, 'UniformOutput', false));
else
    % sol is numeric: assume it matches vars order or is a row vector.
    vals_num = double(sol(:));
end

% reshape
z_vals = reshape(vals_num, size(Zsym));

Z_sol = diag(Z_d);
Z_sol(1:nl_ports,1:nl_ports) = z_vals;

S_sol = 2* Q.' * inv(Q*inv(Z_sol)*Q.') * Q * inv(Z_sol) - eye(ports);

S_loc = S_sol(1:nl_ports,:);

save("Scatter.mat", "S_sol", "S_loc", "nl_ports");
