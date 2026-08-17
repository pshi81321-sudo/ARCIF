# ARCIF — Resilient Consensus Information Filtering for UAV–UGV Cooperative Target Tracking

[![MATLAB/Octave](https://img.shields.io/badge/MATLAB-Octave-orange)](#)
[![Research Code](https://img.shields.io/badge/Research-Code-blue)](#)
[![IEEE TAES](https://img.shields.io/badge/IEEE-TAES-green)](#)
[![500 Monte Carlo](https://img.shields.io/badge/500-Monte%20Carlo-purple)](#)

**Attack-adaptive, communication-aware, observability-weighted distributed filtering for heterogeneous air-ground teams.**

> **Resilient Consensus Information Filtering for Heterogeneous UAV-UGV Cooperative Target Tracking Under Measurement Deception and Packet Dropouts**

The proposed **ARCIF** combines:
- 🎯 **Attack-Adaptive Gate (AAG)** — adapts to time-varying deception attacks
- 🧯 **Soft Robust Update (SRU)** — suppresses heavy-tailed biases without hard rejection
- 🧭 **Observability-Aware Consensus Weighting (OAW)** — lets high-quality UAV measurements lead when UGV observability is poor

---

## 🚀 Why ARCIF?

In a challenging **6-node heterogeneous scenario** with:

- coordinated-turn target maneuvers,
- time-varying burst deception attacks,
- heavy-tailed attack biases,
- and packet dropouts,

ARCIF achieves a **position RMSE of 0.588 m**, significantly outperforming four strong baselines over **500 Monte Carlo runs** (Holm-adjusted p < 0.001):

| Method | Position RMSE (m) |
|---|---|
| **ARCIF (ours)** | **0.588 ± 0.678** |
| D-MCKF | 0.706 ± 0.724 |
| Gated-DEKF | 1.514 ± 3.256 |
| CI-DEKF | 4.692 ± 7.347 |
| D-CIF | 4.836 ± 6.405 |

---

## 📦 Quick Start

### Requirements
- GNU Octave (tested on 4.2.2) or MATLAB
- No additional toolboxes required

### Run
```bash
cd reproducibility
octave-cli main.m
```

Or in MATLAB:

```matlab
main
```

Expected runtime: **~10–15 minutes** for the full 500-run Monte Carlo experiment.

---

## 📁 Repository Structure

```
reproducibility/
├── main.m                  # One-click entry point
├── README.md
└── src/
    ├── config_win.m        # Scenario parameters & seeds
    ├── config.m            # Stationary-scenario parameters
    ├── gen_true_trajectory_ct.m
    ├── gen_measurements_adv.m
    ├── filter_distributed.m
    ├── filter_ci_dekf.m
    ├── compute_metrics.m
    └── ...
```

---

## 🧪 Reproducibility

- **Seed base:** `20260816`
- **Derived seeds:** measurement = seed+5000, dropout = seed+9000
- All methods share the **same seeds, trajectories, attack realizations, and dropout realizations**.
- Output: `win_results_500.mat` containing per-run metrics and Wilcoxon/Holm statistics.

---

## 📄 Citation

If you find this code useful, please cite our paper (citation details will be added after publication).

---
