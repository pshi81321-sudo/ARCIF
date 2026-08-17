function X = gen_true_trajectory_ct(p, seed, omega)
%GEN_TRUE_TRAJECTORY_CT Generate a coordinated-turn trajectory.
% The filter still uses a CV model, creating realistic model mismatch.
if nargin < 3, omega = 0.25; end
randn('seed', seed);
X = zeros(p.n, p.T+1);
X(:,1) = p.x0 + sqrtm(p.P0)*randn(p.n,1);
dt = p.dt;
Q = p.q * [dt^3/3 dt^2/2 0 0; dt^2/2 dt 0 0; 0 0 dt^3/3 dt^2/2; 0 0 dt^2/2 dt];
for k=1:p.T
    x = X(:,k);
    px=x(1); vx=x(2); py=x(3); vy=x(4);
    w = omega;
    if abs(w) < 1e-6
        F = [1 dt 0 0; 0 1 0 0; 0 0 1 dt; 0 0 0 1];
    else
        sw = sin(w*dt); cw = cos(w*dt);
        F = [1 sw/w -(1-cw)/w 0;
             0 cw 0 -sw;
             0 (1-cw)/w 1 sw/w;
             0 sw 0 cw];
    end
    X(:,k+1) = F*x + sqrtm(Q)*randn(p.n,1);
end
end
