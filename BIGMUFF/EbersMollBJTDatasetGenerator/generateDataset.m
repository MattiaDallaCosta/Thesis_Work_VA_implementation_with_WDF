close all; clear all; clc

%% Define the simulation parameters

fs = 96e3;
Ts = 1/fs;
stop_time = 1;

Vbe_points = 2000;
Vbc_points = 1500;

%t = 0:1/(n_points-1):1;

Vbe_min = -.8;
Vbe_max = .8;
Vbc_min = -10;
Vbc_max = 0;

Vbe_sig = (0:1/(Vbe_points-1):1)*(Vbe_max-Vbe_min)+Vbe_min;
Vbc_sig = (0:1/(Vbc_points-1):1)*(Vbc_max-Vbc_min)+Vbc_min;

outputs = zeros(Vbe_points,Vbc_points,2);

[ vbe_data, vbc_data ] = ndgrid(Vbe_sig,Vbc_sig); % creates a 2d grid of all the combinations of the vbe x vbc values

[ outputs(:,:,1), outputs(:,:,2) ] =  solve_ebers_moll_npn(vbe_data, vbc_data);

Z_mat = load("/home/host/Sdy/Thesis2/Thesis_Work_VA_implementation_with_WDF/BIGMUFF/Scatter.mat").Z_sol;

waves = cat(3, vbe_data + Z_mat(1,1) .* outputs(:,:,1), vbc_data + Z_mat(2,2) .* outputs(:,:,2), vbe_data - Z_mat(1,1) .* outputs(:,:,1), vbc_data - Z_mat(2,2) .* outputs(:,:,2));

dataset = reshape(waves, [], 4);
dataset = dataset(randperm(size(dataset, 1)), :);

save("dataset.mat", "dataset");