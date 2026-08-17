function p = config()
%CONFIG Return simulation parameters.
p.T = 60;               % number of steps
p.dt = 0.1;             % sampling interval
p.q = 0.1;              % process noise intensity
p.N = 3;                % number of platforms
p.n = 4;                % state dimension
p.m = 2;                % measurement dimension
p.x0 = [10; 2; 10; 1.5];
p.P0 = diag([4, 1, 4, 1]);
p.alpha0 = 0.02;
p.gate_alpha = 0.01; % baseline fixed-gate false-alarm rate (99% gate)
p.alpha1 = 0.005;
p.beta = 0.05;
p.rho = 0.90;
p.gamma_max = 2;
p.c0 = 0.30;      % node-trust threshold for estimated attack ratio
p.Knode = 0;      % node-trust gain (disabled in baseline; kept for ablation)
p.b0 = 0.20;       % node-bias threshold (normalized innovation EWMA magnitude)
p.kappa = 5;            % correntropy kernel width for MCKF
p.pa = 0.15;            % attack probability (baseline)
p.pd = 0.20;            % dropout probability (baseline)
p.attack_bias = [2.5; 0.05]; % moderate stealthy bias (range m, bearing rad)
% Platform positions and measurement noise: nodes 1-2 UAV, node 3 UGV
p.plat_pos = [0, 40; 60, 20; 30, -10]';
p.sigma_r = [0.8; 0.8; 1.2];
p.sigma_theta = [0.015; 0.015; 0.03];
p.adj = [0 1 0; 1 0 1; 0 1 0]; % line graph (undirected)
p.MC = 500;
p.seed_base = 20260815;
end
