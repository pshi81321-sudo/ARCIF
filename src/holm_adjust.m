function padj = holm_adjust(p)
%HOLM_ADJUST Holm-Bonferroni correction.
m = numel(p);
[ps, ord] = sort(p);
padj = zeros(m,1);
for i=1:m
    padj(ord(i)) = max(ps(1:i) .* (m - (0:i-1))');
end
padj = min(padj, 1);
end
