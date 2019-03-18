% This script solves the OPF problem for a simple 2-bus power grid,
% using MATPOWER.

clear; close all;

% Load MATPOWER test case.
msc = loadcase('case6ww');

% Keep only 2 buses.
n = 2;
new_msc = msc;

% Create simple 2-bus network.
new_msc.bus = [1, 3, 0, 0, 0, 0, 1, 1., 0., 230, 1, 10, 0 ;
               2, 1, 5, 5, 0, 0, 1, 1., 0., 230, 1, 10, 0 ];
new_msc.gen = [1, 0, 0, 100, -100, 1.05, 100, 1, 100, 0];
new_msc.branch = [1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 1, -360, 360];
new_msc.gencost = [2, 0, 0, 2, 1, 0];

runopf(new_msc)