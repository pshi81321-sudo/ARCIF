function [Z, attack_flag, attack_intensity] = gen_measurements_adv(p, X, seed)
%GEN_MEASUREMENTS_ADV Time-varying and heavy-tailed deception attacks.
% attack_intensity is N x T (probability used at each node/time).
randn('seed', seed);
rand('seed', seed+1000);
N=p.N; T=p.T; m=p.m;
Z = zeros(m,N,T);
attack_flag = zeros(N,T);
attack_intensity = zeros(N,T);
period = 20;
burst = 8;
for k=1:T
    % time-varying intensity: bursts of high attack probability
    in_burst = mod(k, period) < burst;
    xk = X(:,k+1);
    for i=1:N
        intensity = p.pa * (1 + 2*in_burst);  % 0.15 normally, 0.45 in bursts
        attack_intensity(i,k) = intensity;
        pos = p.plat_pos(:,i);
        dx = xk(1)-pos(1); dy = xk(3)-pos(2);
        r = sqrt(dx^2+dy^2);
        th = atan2(dy, dx);
        z = [r; th];
        R = diag([p.sigma_r(i)^2, p.sigma_theta(i)^2]);
        z = z + sqrtm(R)*randn(m,1);
        if rand < intensity
            attack_flag(i,k) = 1;
            % heavy-tailed bias: mostly moderate, occasionally large
            if rand < 0.8
                b = [p.attack_bias(1)*randn(1); p.attack_bias(2)*randn(1)];
            else
                b = [p.attack_bias(1)*randn(1)*5; p.attack_bias(2)*randn(1)*5];
            end
            if rand < 0.5, b = -b; end
            z = z + b;
        end
        Z(:,i,k) = z;
    end
end
end
