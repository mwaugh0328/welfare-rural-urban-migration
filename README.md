### [The Welfare Effects of Encouraging Rural-Urban Migration](http://www.waugheconomics.com/uploads/2/2/5/6/22563786/LMW.pdf)

<p align="center">
<img src="./figures/migration_policy_low_z_both.png">
</p>

---

This repository contains code to reproduce results from the paper ["The Welfare Effects of Encouraging Rural-Urban Migration"](http://www.waugheconomics.com/uploads/2/2/5/6/22563786/LMW.pdf). It also includes replication files (empirical and quantitative results) for the paper ["Underinvestment in a Profitable
Technology: The Case of Seasonal Migration in Bangladesh"](https://onlinelibrary.wiley.com/doi/abs/10.3982/ECTA10489) that were downloaded from Econometrica's code repository and obtained from the authors. I will provide support for the former, not for the later.

**Software Requirements:** Most of this code is in MATLAB and requires the Parallel Computing Toolbox (for computation of the model). Plotting is performed via python. Data analysis is in STATA.

---
The repository is organized with the following folders. The readme file within the folder describes how to execute code:

- **[Calibration](https://github.com/mwaugh0328/final_migration/tree/main/calibration)** contains the code to calibrate the model.

- **[Bootstrap](https://github.com/mwaugh0328/final_migration/tree/main/bootstrap)** computes bootstrap confidence intervals and montecarlo study to explore identification.

- **[Partial equilibrium welfare analysis](https://github.com/mwaugh0328/final_migration/tree/main/pe_welfare_analysis)** This computes the welfare effects of the one-time transfer. In addition, it outputs results (policy functions, migration rates, etc.) that are plotted in the [plotting file]().

- **[General equilibrium welfare analysis](https://github.com/mwaugh0328/final_migration/tree/main/ge_taxation)** Computes the welfare effects of a permanent transfer financed by taxes and clears the rural labor market.

- **[The efficient allocation](https://github.com/mwaugh0328/final_migration/tree/main/effecient)** Computes the solution to the planning problem.

- **[Utility functions](https://github.com/mwaugh0328/final_migration/tree/main/utils)** this folder contains functions that are used throughout all aspects of the code. A complete accounting is found in the readme file.  

- **[Plotting](https://github.com/mwaugh0328/final_migration/tree/main/plotting)** jupyter notebooks that import MATLAB ``.mat`` files and plots them.

- **[Figures](https://github.com/mwaugh0328/final_migration/tree/main/utils)** self explanatory. Should all be in `.png` and `.pdf` format.
