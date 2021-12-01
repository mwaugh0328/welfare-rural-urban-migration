### Partial Equilibrium Welfare Analysis

This section describes basic computations to compute the welfare gains associated with one time transfers (conditional or unconditional) .

---

### Main Computations

**Compute Model:** The most basic call starts inside the [``pe_welfare_analysis``](https://github.com/mwaugh0328/final_migration/tree/main/pe_welfare_analysis) folder. To perform the welfare analysis you:

```
>> addpath('../utils')

>> load('..\calibration\calibrated_baseline.mat')

>> analyze_outcomes(x1, [], [], [], [], [], 1)
```
The five ``[]`` stand in for ``specs`` which is a structure defining grid, shocks, etc. if it is not specified, then a default is set in the [``preamble_welfare_analysis.m``](https://github.com/mwaugh0328/final_migration/blob/main/pe_welfare_analysis/preamble_welfare_analysis.m), ``wages`` which are wages per efficiency unit if not specified it uses the ones in the default calibration, ``meanstest`` is a means test, ``vft_fun`` is a value function structure for which if specified welfare will be computed relative to this value, ``R`` is gross real interest rate, and a flag for output. Again, if none of this is specified, default values are used in the code.

Then it should compute everything and then spit out the moments. The output should look something like this
```
Saving policy functions in plotting folder...

Migration Policy Function Fixed: Welfare by Income Quintile: Welfare, Migration Rate, Z, Experience
    0.7600   47.5100    0.5500   24.8100
    0.3100   38.2100    0.5500   23.5200
    0.2000   32.8800    0.5600   24.5100
    0.1500   31.3200    0.5600   25.4600
    0.1000   31.3900    0.6000   34.9600

Averages: Mushfiqs sample Welfare, Migration Rate, Experience
    0.3000   36.2600   26.6500

Averages: All Rural, Welfare, Migration Rate
    0.1500   30.5700

PE Conditional Migration Transfer: Welfare by Income Quintile: Welfare, Migration Rate, Z , Experience
    1.1600   84.7600    0.5500   24.8100
    0.4500   62.9300    0.5500   23.5200
    0.2800   51.1800    0.5600   24.5100
    0.2000   46.4400    0.5600   25.4600
    0.1200   40.5400    0.6000   34.9600

Averages: Mushfiqs sample Welfare, Migration Rate, Experience
    0.4400   57.1700   26.6500

Averages: All Rural, Welfare, Migration Rate
    0.2200   43.8700

PE Unconditional Cash Transfer: Welfare and Migration by Income Quintile
    1.0500   44.6100
    0.5600   37.0300
    0.4000   32.1000
    0.3200   30.9000
    0.2000   31.2100

PE Unconditional Cash Transfer: Average Welfare Gain, Migration Rate
    0.5100   35.1700

Wage Gap
    1.8907

Average Rural Population
    0.5993

Fraction of Rural with No Assets
    0.4724

Expr Elasticity: Year One, Two
    0.2078    0.0499

Control: Year One, Repeat Two
    0.3639    0.2560

LATE Estimate
    0.2910

LATE - OLS Estimate
    0.1966
```

The first line reports that the policy functions are being saved in the [plotting folder](https://github.com/mwaugh0328/final_migration/tree/main/plotting).

The first table evaluates the welfare gains by income quintile, holding fixed the migration policy functions. So here, only people already planning on moving get the cash transfer. The averages compute, well, the averages for Mushfiq's sample and then the entire rural economy.

The second table then allows households to optimally adjust. Again averages for Musfiq's sample, then the entire rural economy.

The third table is the unconditional cash transfer, so people do not need to move. **IMPORTANT** the size of the cash transfer depending upon the question need to be modified in the [``preamble_welfare_analysis.m``](https://github.com/mwaugh0328/final_migration/blob/e33c12e76c7da2a210012d082578cbe9d368c965/pe_welfare_analysis/preamble_welfare_analysis.m#L47). The default is for welfare analysis where every household gets a transfer, but it is scaled down so the total outlay is exactly the same as in the conditional cash transfer. If one wants to compare to pure cash transfer, then delete the 0.56 part.

The final numbers are the calibration targets and should more or less match up with the output from [``compute_outcomes.m``](https://github.com/mwaugh0328/final_migration/blob/main/calibration/compute_outcomes.m) in the [calibration folder](https://github.com/mwaugh0328/final_migration/tree/main/calibration).

---

### Accounting

What is in this folder.

- [``analyze_outcomes.m``](https://github.com/mwaugh0328/final_migration/blob/main/pe_welfare_analysis/analyze_outcomes.m) main file to take parameter values, solve households problem, simulate and construct stationary distribution, and then construct moments in the model as they are in the data, computes welfare gains associated with one-time transfer, outputs ``.mat`` files to plot policy functions.

- [``preamble_welfare_analysis.m``](https://github.com/mwaugh0328/final_migration/blob/main/pe_welfare_analysis/preamble_welfare_analysis.m) specifies the default parameter values and specifications on the asset grid, shock structure, number of simulations, the seed. If you want to change something about how stuff is computed, this is the file to change.
