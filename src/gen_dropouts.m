function gamma = gen_dropouts(p, seed)
%GEN_DROPOUTS Generate directed packet dropout indicators.
% gamma(i,j,k)=1 means node j successfully receives node i's packet at time k.
rand('seed', seed);
N=p.N; T=p.T;
gamma = ones(N,N,T);
for k=1:T
    for i=1:N
        for j=1:N
            if i~=j
                gamma(i,j,k) = (rand > p.pd);
            else
                gamma(i,j,k) = 1;
            end
        end
    end
end
end
