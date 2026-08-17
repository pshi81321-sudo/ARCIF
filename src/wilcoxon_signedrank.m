function [p, r] = wilcoxon_signedrank(x, y)
%WILCOXON_SIGNEDRANK Paired Wilcoxon signed-rank test (normal approx).
% p: two-sided p-value; r: rank-biserial effect size.
d = x - y;
d = d(d ~= 0);
n = numel(d);
if n == 0
    p = 1; r = 0; return;
end
[~, idx] = sort(abs(d));
ranks = zeros(n,1);
i = 1;
while i <= n
    j = i;
    while j+1 <= n && abs(d(idx(j+1))) == abs(d(idx(i)))
        j = j + 1;
    end
    avg = (i+j)/2;
    for t=i:j
        ranks(idx(t)) = avg;
    end
    i = j+1;
end
sp = sum(ranks(d>0));
sn = sum(ranks(d<0));
W = sp;
mu = n*(n+1)/4;
sigma = sqrt(n*(n+1)*(2*n+1)/24);
if sigma == 0
    p = 1;
else
    z = (W - mu)/sigma;
    p = erfc(abs(z)/sqrt(2)); % two-sided normal tail
    p = min(p, 1);
end
r = (sp - sn)/(sp + sn + eps);
end
