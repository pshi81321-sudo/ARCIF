function results = run_win_experiment(p, MC, methods)
%RUN_WIN_EXPERIMENT Compare methods on the harder scenario.
% All required functions are in this src directory.
if nargin < 3
    methods = {'dcif','gated','mckf','ci_dekf','arcif'};
end
M = numel(methods);
met = zeros(MC, M, 4);
for r=1:MC
    seed = p.seed_base + r;
    X = gen_true_trajectory_ct(p, seed, 0.25);
    [Z,~,~] = gen_measurements_adv(p, X, seed+5000);
    gamma = gen_dropouts(p, seed+9000);
    for mi=1:M
        if strcmp(methods{mi},'ci_dekf')
            [Xh,Ph] = filter_ci_dekf(p, Z, gamma);
        else
            [Xh,Ph] = filter_distributed(p, Z, gamma, methods{mi});
        end
        mm = compute_metrics(p,X,Xh,Ph);
        met(r,mi,:) = [mm.pos_rmse, mm.vel_rmse, mm.nees, mm.disagreement];
    end
    if mod(r,20)==0
        fprintf('MC %d/%d\n', r, MC);
    end
end
results.methods = methods;
results.met = met;
results.mean_met = squeeze(mean(met,1));
results.std_met = squeeze(std(met,0,1));
end
