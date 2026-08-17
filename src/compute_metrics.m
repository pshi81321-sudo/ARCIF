function met = compute_metrics(p, X, Xh, Ph)
%COMPUTE_METRICS Compute time-averaged metrics for one run.
% Xh: n x N x T, Ph: n x n x N x T
if ndims(Xh) == 2
    Xh = reshape(Xh, [p.n, 1, p.T]);
    Ph = reshape(Ph, [p.n, p.n, 1, p.T]);
end
N=size(Xh,2); T=p.T; n=p.n;
pos_err = zeros(N,T); vel_err = zeros(N,T); nees = zeros(N,T); dis = zeros(1,T);
for k=1:T
    xk = X(:,k+1);
    for i=1:N
        err = Xh(:,i,k) - xk;
        pos_err(i,k) = sqrt(err(1)^2 + err(3)^2);
        vel_err(i,k) = sqrt(err(2)^2 + err(4)^2);
        nees(i,k) = (err' * (Ph(:,:,i,k) \ err)) / n;
    end
    % average pairwise position disagreement
    s = 0; cnt = 0;
    for i=1:N
        for j=i+1:N
            p1 = [Xh(1,i,k); Xh(3,i,k)];
            p2 = [Xh(1,j,k); Xh(3,j,k)];
            s = s + norm(p1-p2);
            cnt = cnt + 1;
        end
    end
    if cnt > 0
        dis(k) = s/cnt;
    else
        dis(k) = 0;
    end
end
met.pos_rmse = mean(pos_err(:));
met.vel_rmse = mean(vel_err(:));
met.nees = mean(nees(:));
met.disagreement = mean(dis(:));
end
