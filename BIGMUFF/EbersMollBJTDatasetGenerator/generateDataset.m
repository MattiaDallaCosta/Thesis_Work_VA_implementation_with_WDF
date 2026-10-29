close all; clear all; clc

%% Define the simulation parameters

fs = 96e3;
Ts = 1/fs;
stop_time = 1;

Vbe_low_points = 700;
Vbe_high_points = 700;
Vbc_points = 1000;

%t = 0:1/(n_points-1):1;

Vbe_min = -.8;
Vbe_max = .8;
Vbe_mid = .5;
Vbc_min = -10;
Vbc_max = 0;

Vbe_sig = [(0:1/(Vbe_low_points-1):1)*(Vbe_mid-Vbe_min)+Vbe_min, (0:1/(Vbe_high_points-1):1)*(Vbe_max-Vbe_mid)+Vbe_mid];
Vbc_sig = (0:1/(Vbc_points-1):1)*(Vbc_max-Vbc_min)+Vbc_min;

outputs = zeros(Vbe_low_points + Vbe_high_points,Vbc_points,2);

[ vbe_data, vbc_data ] = ndgrid(Vbe_sig,Vbc_sig); % creates a 2d grid of all the combinations of the vbe x vbc values

[ outputs(:,:,1), outputs(:,:,2) ] =  solve_ebers_moll(vbe_data, vbc_data);

Z_mat = load("/home/host/Sdy/Thesis2/Thesis_Work_VA_implementation_with_WDF/BIGMUFF/Scatter.mat").Z_sol(1:2,1:2);

V = cat(3, vbe_data, vbc_data);

[height, width, ~] = size(V);

I_flat = permute(outputs, [3, 1, 2]);      
I_flat = reshape(I_flat, 2, []);     
IZ_flat = Z_mat * I_flat;                

IZ = reshape(IZ_flat, 2, height, width);
IZ = permute(IZ, [2, 3, 1]);

a = V + IZ;

b = V - IZ;

dataset = cat(3, a, b);

dataset = reshape(dataset, [], 4);
dataset = dataset(randperm(size(dataset, 1)), :);

% vce_data = vbe_data - vbc_data;
% 
% alpha_f = 0.9993;
% I_c = alpha_f .* outputs(:,:,1) - outputs(:,:,2);

save("dataset.mat", "dataset");
