### Partial Equilibrium Welfare Analysis

This section describes basic computations to compute the welfare gains associated with one time transfers (conditional or unconditional) .

---

### Main Computations

**Compute Welfare Gains:** The most basic call starts inside the [``pe_welfare_analysis``](../pe_welfare_analysis) folder. To perform the welfare analysis you:

```
>> addpath('../utils')

>> load('../calibration/calibrated_baseline.mat')

>> analyze_outcomes(x1, [], [], [], [], [], [], 1)
```
The five ``[]`` stand in for ``specs`` which is a structure defining grid, shocks, etc. if it is not specified, then a default is set in the [``preamble_welfare_analysis.m``](./preamble_welfare_analysis.m), ``wages`` which are wages per efficiency unit if not specified it uses the ones in the default calibration, ``meanstest`` is a means test, ``vft_fun`` is a value function structure for which if specified welfare will be computed relative to this value, ``R`` is gross real interest rate, and a flag for output. Again, if none of this is specified, default values are used in the code.

Then it should compute everything and then spit out the moments. The output should look something like this
```
-----------------------------------------------------------------------------------------------------
   06-Dec-2021 23:18:46


-----------------------------------------------------------------------------------------------------
MATLAB Version: 9.10.0.1739362 (R2021a) Update 5
MATLAB License Number: 618777
Operating System: Microsoft Windows 10 Pro Version 10.0 (Build 19043)
Java Version: Java 1.8.0_202-b08 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
-----------------------------------------------------------------------------------------------------
MATLAB                                                Version 9.10        (R2021a)
Curve Fitting Toolbox                                 Version 3.5.13      (R2021a)
Econometrics Toolbox                                  Version 5.6         (R2021a)
Financial Instruments Toolbox                         Version 3.2         (R2021a)
Financial Toolbox                                     Version 6.1         (R2021a)
GPU Coder                                             Version 2.1         (R2021a)
Global Optimization Toolbox                           Version 4.5         (R2021a)
MATLAB Coder                                          Version 5.2         (R2021a)
MATLAB Compiler                                       Version 8.2         (R2021a)
MATLAB Compiler SDK                                   Version 6.10        (R2021a)
Optimization Toolbox                                  Version 9.1         (R2021a)
Parallel Computing Toolbox                            Version 7.4         (R2021a)
Partial Differential Equation Toolbox                 Version 3.6         (R2021a)
Statistics and Machine Learning Toolbox               Version 12.1        (R2021a)
-----------------------------------------------------------------------------------------------------

Saving policy functions in plotting folder...



Migration Policy Function Fixed: Welfare by Income Quintile: Welfare, Migration Rate, Z, Experience
    0.7700   48.3100    0.5500   24.9800
    0.3100   38.0500    0.5500   23.9200
    0.2000   33.5600    0.5600   24.4700
    0.1500   31.1800    0.5600   25.3400
    0.1000   30.9800    0.6000   34.9800

Averages, Mushfiqs sample: Welfare, Migration Rate, Experience
    0.3000   36.4200   26.7400

Averages, All Rural: Welfare, Migration Rate
    0.1500   30.5800


PE Conditional Migration Transfer: Welfare by Income Quintile: Welfare, Migration Rate, Z , Experience
    1.1700   85.1600    0.5500   24.9800
    0.4500   62.6500    0.5500   23.9200
    0.2900   51.6700    0.5600   24.4700
    0.2000   45.7800    0.5600   25.3400
    0.1200   40.4100    0.6000   34.9800

Averages, Mushfiqs sample: Welfare, Migration Rate, Experience
    0.4400   57.1300   26.7400

Averages, All Rural: Welfare, Migration Rate
    0.2200   43.8600


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

Below Median Consumption: Migration Below 800 Taka assets, Above 800 Taka
    0.4077    0.2779

Above Median Consumption: Migration Below 800 Taka assets, Above 800 Taka
    0.4091    0.3788

```

The first line reports that the policy functions are being saved in the [plotting folder](../plotting).

The first table evaluates the welfare gains by income quintile, holding fixed the migration policy functions. So here, only people already planning on moving get the cash transfer. The averages compute, well, the averages for Mushfiq's sample and then the entire rural economy.

The second table then allows households to optimally adjust. Again averages for Musfiq's sample, then the entire rural economy.

The third table is the unconditional cash transfer, so people do not need to move. **IMPORTANT** the size of the cash transfer depending upon the question need to be modified in the [``preamble_welfare_analysis.m``](https://github.com/mwaugh0328/final_migration/blob/e33c12e76c7da2a210012d082578cbe9d368c965/pe_welfare_analysis/preamble_welfare_analysis.m#L47). The default is for welfare analysis where every household gets a transfer, but it is scaled down so the total outlay is exactly the same as in the conditional cash transfer. If one wants to compare to pure cash transfer, then delete the 0.56 part.

The final numbers are the calibration targets and should more or less match up with the output from [``compute_outcomes.m``](../calibration/compute_outcomes.m) in the [calibration folder](../calibration).

---

### Accounting

What is in this folder.

- [``analyze_outcomes.m``](./analyze_outcomes.m) main file to take parameter values, solve households problem, simulate and construct stationary distribution, and then construct moments in the model as they are in the data, computes welfare gains associated with one-time transfer, outputs ``.mat`` files to plot policy functions.

- [``preamble_welfare_analysis.m``](./preamble_welfare_analysis.m) specifies the default parameter values and specifications on the asset grid, shock structure, number of simulations, the seed. If you want to change something about how stuff is computed, this is the file to change.
