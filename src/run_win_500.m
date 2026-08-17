p = config_win();
p.MC = 500;
fprintf('Running win scenario MC=500 T=%d N=%d\n', p.T, p.N);
r = run_win_experiment(p, p.MC, {'dcif','gated','mckf','ci_dekf','arcif'});
arc = r.met(:,5,1);
pvals = zeros(4,1); rvals = zeros(4,1);
for i=1:4
    [pval, rb] = wilcoxon_signedrank(arc, r.met(:,i,1));
    pvals(i)=pval; rvals(i)=rb;
end
padj = holm_adjust(pvals);
save('win_results_500.mat','r','pvals','rvals','padj','p');
fprintf('Saved win_results_500.mat\n');
for i=1:numel(r.methods)
    fprintf('%s pos=%.4f+-%.4f\n', r.methods{i}, r.mean_met(i,1), r.std_met(i,1));
end
fprintf('pvals: '); disp(pvals');
fprintf('padj: '); disp(padj');
