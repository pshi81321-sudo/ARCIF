# ARCIF Reproducibility Package

This package reproduces the main 500-run Monte Carlo result for the ARCIF
challenging scenario (6-node heterogeneous network, coordinated-turn target,
time-varying burst attacks, heavy-tailed biases, packet dropouts).

## Environment
- GNU Octave (tested with Octave 4.2.2) or MATLAB.
- No additional toolboxes are required.

## Run
From the `reproducibility/` directory:

```
octave-cli main.m
```

or in MATLAB:

```
main
```

Expected runtime: approximately 10-15 minutes for 500 Monte Carlo runs
(5 methods, T=120, N=6) on a typical desktop.

## Outputs
- `src/win_results_500.mat` containing:
  - `r.methods`
  - `r.mean_met`
  - `r.std_met`
  - `pvals`, `rvals`, `padj`

These correspond to Table V (main comparison), Table VI (Wilcoxon statistics),
and Table VII (ablation; run `src/run_win_ablation500.m` if needed).

## Configuration
All scenario parameters are in `src/config_win.m`.
Seed base: 20260816.
Derived seeds: measurement = seed+5000, dropout = seed+9000.

## Note
The repository URL is intentionally left as `[REPO URL]` until the user
uploads the package and fills in the public link.
