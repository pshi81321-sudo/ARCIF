function p = config_win()
%CONFIG_WIN A harder, more heterogeneous scenario intended to expose ARCIF advantages.
p.T = 120;               % longer horizon
p.dt = 0.1;
p.q = 0.5;               % larger process noise due to maneuvering mismatch
p.N = 6;                 % larger network
p.n = 4;
p.m = 2;
p.x0 = [0; 5; 0; 3];
p.P0 = diag([9, 2, 9, 2]);
p.alpha0 = 0.02;
p.gate_alpha = 0.05;
p.alpha1 = 0.005;
p.beta = 0.05;
p.rho = 0.9;
p.gamma_max = 3;
p.c0 = 0.3;
p.Knode = 0;
p.b0 = 0.2;
p.kappa = 3;             % MCKF kernel width (fixed)
p.pa = 0.15;             % average attack probability
p.pd = 0.25;             % dropout
p.attack_bias = [2.0; 0.04]; % nominal bias scale
% 6 nodes: 3 UAV (better geometry) and 3 UGV (poor geometry)
p.plat_pos = [-20, 60; 20, 65; 60, 40; -10, 5; 30, -5; 70, 10]';
p.sigma_r = [0.6; 0.6; 0.7; 1.5; 1.8; 1.6];
p.sigma_theta = [0.01; 0.01; 0.012; 0.05; 0.06; 0.055];
% ring-of-lines topology: 1-2-3-4-5-6-1 (a cycle) for more distributed consensus
p.adj = [0 1 0 0 0 1;
         1 0 1 0 0 0;
         0 1 0 1 0 0;
         0 0 1 0 1 0;
         0 0 0 1 0 1;
         1 0 0 0 1 0];
p.MC = 500;
p.seed_base = 20260816;
end
