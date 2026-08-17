function [Xh, Ph] = filter_ci_dekf(p, Z, gamma)
%FILTER_CI_DEKF Distributed covariance-intersection EKF with fixed gating.
N=p.N; T=p.T; n=p.n; m=p.m;
F = [1 p.dt 0 0; 0 1 0 0; 0 0 1 p.dt; 0 0 0 1];
Q = p.q * [p.dt^3/3 p.dt^2/2 0 0; p.dt^2/2 p.dt 0 0; 0 0 p.dt^3/3 p.dt^2/2; 0 0 p.dt^2/2 p.dt];
tau_gate = chi2inv(1-p.gate_alpha, m);
x = repmat(p.x0, 1, N);
P = repmat(p.P0, [1 1 N]);
Xh = zeros(n,N,T); Ph = zeros(n,n,N,T);
for k=1:T
    for i=1:N
        x(:,i) = F*x(:,i);
        P(:,:,i) = F*P(:,:,i)*F' + Q;
    end
    % local robust update
    xl = x; Pl = P;
    for i=1:N
        pos = p.plat_pos(:,i);
        H = measurement_jacobian(x(:,i), pos);
        z_pred = [sqrt((x(1,i)-pos(1))^2+(x(3,i)-pos(2))^2); atan2(x(3,i)-pos(2), x(1,i)-pos(1))];
        R = diag([p.sigma_r(i)^2, p.sigma_theta(i)^2]);
        S = H*P(:,:,i)*H' + R;
        innov = Z(:,i,k) - z_pred;
        d = innov' / S * innov;
        if d <= tau_gate
            K = P(:,:,i)*H'/S;
            xl(:,i) = x(:,i) + K*innov;
            Pl(:,:,i) = (eye(n)-K*H)*P(:,:,i);
            Pl(:,:,i) = (Pl(:,:,i)+Pl(:,:,i)')/2;
        end
    end
    % CI fusion with received neighbors
    for i=1:N
        used = false(1,N); used(i)=true;
        idxs = i;
        for j=1:N
            if i~=j && p.adj(i,j)>0 && gamma(j,i,k)==1
                used(j)=true; idxs(end+1)=j;
            end
        end
        L = numel(idxs);
        w = ones(1,L)/L;
        Ysum = zeros(n,n); ysum = zeros(n,1);
        for a=1:L
            j = idxs(a);
            Yj = inv(Pl(:,:,j));
            Ysum = Ysum + w(a)*Yj;
            ysum = ysum + w(a)*Yj*xl(:,j);
        end
        P(:,:,i) = inv(Ysum);
        x(:,i) = P(:,:,i)*ysum;
        Xh(:,i,k)=x(:,i); Ph(:,:,i,k)=P(:,:,i);
    end
end
end
