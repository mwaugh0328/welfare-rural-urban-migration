### Partial Equilibrium Welfare Analysis

This section describes basic computations to compute the welfare gains associated with one time transfers (conditional or unconditional) .

### Main Computations
---
**Compute Model:** The most basic call starts inside the [``pe_welfare_analysis``](https://github.com/mwaugh0328/final_migration/tree/main/pe_welfare_analysis) folder. To perform the welfare analysis you:

```
>> load('..\calibration\calibrated_baseline.mat')

>> analyze_outcomes(x1, [], [], [], [], [], 1)
```
The five ``[]`` stand in for ``specs`` which is a structure defining grid, shocks, etc. if it is not specified, then a default is set in the ``preamble.m``, ``wages`` which are wages per efficiency unit if not specified it uses the ones in the default calibration, ``meanstest`` is a means test, ``vft_fun`` is a value function structure for which if specified welfare will be computed relative to this value, ``R`` is gross real interest rate, and a flag for output. Again, if none of this is specified, default values are used in the code.

Then it should compute everything and then spit out the moments. The output should look something like this
```
Migration Policy Function Fixed: Welfare by Income Quintile: Welfare, Migration Rate, Z, Experience
    0.7700   48.3100    0.5500   24.9800
    0.3100   38.0500    0.5500   23.9200
    0.2000   33.5600    0.5600   24.4700
    0.1500   31.1800    0.5600   25.3400
    0.1000   30.9800    0.6000   34.9800

Averages: Welfare, Migration Rate, Experience
    0.3000   36.4200   26.7400

PE Conditional Migration Transfer: Welfare by Income Quintile: Welfare, Migration Rate, Z , Experience
    1.1700   85.1600    0.5500   24.9800
    0.4500   62.6500    0.5500   23.9200
    0.2900   51.6700    0.5600   24.4700
    0.2000   45.7800    0.5600   25.3400
    0.1200   40.4100    0.6000   34.9800

Averages: Welfare, Migration Rate, Experience
    0.4400   57.1300   26.7400

PE Unconditional Cash Transfer: Welfare and Migration by Income Quintile
    1.0500   45.2500
    0.5600   36.8400
    0.4000   32.8700
    0.3200   30.8500
    0.2000   30.8200

PE Unconditional Cash Transfer: Average Welfare Gain, Migration Rate
    0.5100   35.3200

Wage Gap
    1.8898

Average Rural Population
    0.5991

Fraction of Rural with No Assets
    0.4761

Expr Elasticity: Year One, Two
    0.2075    0.0474

Control: Year One, Repeat Two
    0.3638    0.2578

LATE Estimate
    0.2924

LATE - OLS Estimate
    0.2004
```
The first table evaluates the welfare gains holding fixed the migration policy functions. So here, only people already planning on moving get the cash transfer. The second table then allows households to optimally adjust. The third table is the unconditional cash transfer, so people to not need to move. The final numbers are the calibration targets and should more or less match up with the output from ``coumpute_outcomes.m`` in the calibration folder.

---

### Accounting

What is in this folder.

- [``analyze_outcomes.m``](https://github.com/mwaugh0328/final_migration/blob/main/pe_welfare_analysis/analyze_outcomes.m) main file to take parameter values, solve households problem, simulate and construct stationary distribution, and then construct moments in the model as they are in the data, computes welfare gains associated with one-time transfer, outputs ``.mat`` files to plot policy functions.

- [``preamble_welfare_analysis.m``](https://github.com/mwaugh0328/final_migration/blob/main/pe_welfare_analysis/preamble_welfare_analysis.m) specifies the default parameter values and specifications on the asset grid, shock structure, number of simulations, the seed. If you want to change something about how stuff is computed, this is the file to change.
