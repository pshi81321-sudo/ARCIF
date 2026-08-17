function [Xh, Ph] = filter_distributed(p, Z, gamma, method)
%FILTER_DISTRIBUTED Distributed consensus filters (increment-accumulation form).
% method: 'dcif' | 'gated' | 'mckf' | 'arcif' | arcif_* ablation variants
N=p.N; T=p.T; n=p.n; m=p.m;
use_adc = strcmp(method,'arcif_nooaw') || strcmp(method,'arcif_noaag') || strcmp(method,'arcif_notrust');
use_oaw = strcmp(method,'arcif') || strcmp(method,'arcif_noadc') || strcmp(method,'arcif_noaag') || strcmp(method,'arcif_notrust') || strcmp(method,'arcif_nosru');
use_trust = strcmp(method,'arcif') || strcmp(method,'arcif_noaag') || strcmp(method,'arcif_noadc') || strcmp(method,'arcif_nooaw') || strcmp(method,'arcif_nosru');
F = [1 p.dt 0 0; 0 1 0 0; 0 0 1 p.dt; 0 0 0 1];
Q = p.q * [p.dt^3/3 p.dt^2/2 0 0; p.dt^2/2 p.dt 0 0; 0 0 p.dt^3/3 p.dt^2/2; 0 0 p.dt^2/2 p.dt];
tau0 = chi2inv(1-p.alpha0, m);
tau_gate = chi2inv(1-p.gate_alpha, m);
Xh = zeros(n,N,T);
Ph = zeros(n,n,N,T);
x = repmat(p.x0, 1, N);
P = repmat(p.P0, [1 1 N]);
Y = zeros(n,n,N); y = zeros(n,N);
for i=1:N
    Y(:,:,i) = inv(P(:,:,i));
    y(:,i) = Y(:,:,i)*x(:,i);
end
c = zeros(1,N);
bias_hat = zeros(m,N);
last_I = cell(N,N); last_iota = cell(N,N); age = zeros(N,N);
for k=1:T
    for i=1:N
        x(:,i) = F*x(:,i);
        P(:,:,i) = F*P(:,:,i)*F' + Q;
        Y(:,:,i) = inv(P(:,:,i));
        y(:,i) = Y(:,:,i)*x(:,i);
    end
    I_loc = zeros(n,n,N); iota_loc = zeros(n,N); lam = zeros(1,N);
    for i=1:N
        pos = p.plat_pos(:,i);
        H = measurement_jacobian(x(:,i), pos);
        z_pred = [sqrt((x(1,i)-pos(1))^2+(x(3,i)-pos(2))^2); atan2(x(3,i)-pos(2), x(1,i)-pos(1))];
        R = diag([p.sigma_r(i)^2, p.sigma_theta(i)^2]);
        S = H*P(:,:,i)*H' + R;
        innov = Z(:,i,k) - z_pred;
        d = innov' / S * innov;
        if strcmp(method,'arcif') || strcmp(method,'arcif_noaag') || strcmp(method,'arcif_noadc') || strcmp(method,'arcif_nooaw') || strcmp(method,'arcif_notrust') || strcmp(method,'arcif_nosru')
            innov_norm = sqrtm(S) \ innov;
            bias_hat(:,i) = (1-p.beta)*bias_hat(:,i) + p.beta*innov_norm;
        end
        if strcmp(method,'dcif')
            lam(i) = 1;
        elseif strcmp(method,'gated')
            if d > tau_gate
                lam(i) = 0;
            else
                lam(i) = 1;
            end
        elseif strcmp(method,'mckf')
            lam(i) = exp(-0.5*d/p.kappa);
            if lam(i) < 0.05
                lam(i) = 0;
            end
        elseif strcmp(method,'arcif_noaag')
            c(i) = (1-p.beta)*c(i) + p.beta*(d > tau0);
            if d > tau0
                lam(i) = 0;
            else
                lam(i) = 1;
            end
        elseif strcmp(method,'arcif') || strcmp(method,'arcif_noadc') || strcmp(method,'arcif_nooaw') || strcmp(method,'arcif_notrust') || strcmp(method,'arcif_nosru')
            c(i) = (1-p.beta)*c(i) + p.beta*(d > tau0);
            alpha = p.alpha0 + c(i)*(p.alpha1-p.alpha0);
            tau = chi2inv(1-alpha, m);
            if d > tau
                lam(i) = 0;
            elseif strcmp(method,'arcif_nosru') && d > tau0
                lam(i) = 0;
            elseif d > tau0
                gamma_inf = min(p.gamma_max, d/tau0);
                lam(i) = 1/gamma_inf;
            else
                lam(i) = 1;
            end
        else
            error('Unknown method %s', method);
        end
        if use_trust
            bias_mag = norm(bias_hat(:,i));
            node_w = 1 / (1 + p.Knode * max(0, bias_mag-p.b0));
        else
            node_w = 1;
        end
        I_loc(:,:,i) = lam(i) * node_w * (H' / R * H);
        iota_loc(:,i) = lam(i) * node_w * (H' / R * (innov + H*x(:,i)));
    end
    Y_fused = zeros(n,n,N); y_fused = zeros(n,N);
    for i=1:N
        Yf = Y(:,:,i) + I_loc(:,:,i);
        yf = y(:,i) + iota_loc(:,i);
        for j=1:N
            if i==j || p.adj(i,j)==0, continue; end
            if gamma(j,i,k) == 1
                incI = I_loc(:,:,j); incit = iota_loc(:,j);
                last_I{i,j} = incI; last_iota{i,j} = incit; age(i,j) = 0;
            else
                if use_adc && ~isempty(last_I{i,j})
                    rho_age = p.rho^age(i,j);
                    incI = rho_age * last_I{i,j};
                    incit = rho_age * last_iota{i,j};
                    age(i,j) = age(i,j) + 1;
                else
                    incI = zeros(n,n); incit = zeros(n,1);
                end
            end
            Yf = Yf + incI;
            yf = yf + incit;
        end
        Y_fused(:,:,i) = Yf;
        y_fused(:,i) = yf;
    end
    if use_oaw
        mm = zeros(1,N);
        for i=1:N
            mm(i) = det(Y_fused(:,:,i))^(1/n);
        end
    else
        mm = ones(1,N);
    end
    Y_new = zeros(n,n,N); y_new = zeros(n,N);
    for i=1:N
        denom = mm(i) + sum(mm(p.adj(i,:)==1));
        wii = mm(i)/denom;
        Yn = wii*Y_fused(:,:,i);
        yn = wii*y_fused(:,i);
        for j=1:N
            if i==j || p.adj(i,j)==0, continue; end
            wij = mm(j)/denom;
            Yn = Yn + wij*Y_fused(:,:,j);
            yn = yn + wij*y_fused(:,j);
        end
        Y_new(:,:,i) = Yn;
        y_new(:,i) = yn;
    end
    for i=1:N
        Y(:,:,i) = Y_new(:,:,i);
        y(:,i) = y_new(:,i);
        P(:,:,i) = inv(Y(:,:,i));
        x(:,i) = P(:,:,i)*y(:,i);
        Xh(:,i,k) = x(:,i);
        Ph(:,:,i,k) = P(:,:,i);
    end
end
end
