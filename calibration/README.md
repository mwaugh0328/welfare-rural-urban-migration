### Calibration

This section describes basic computations, the calibration approach, and then the computational elements behind the computation of the model.

---

### Basic Computations

**Compute Model:** The most basic call starts inside the [``calibration``](../calibration) folder. To generate moments from the model

```
>> addpath('../utils')

>> load('calibrated_baseline.mat')

>> load('calibrated_valuefunction_guess.mat')

>> compute_outcomes(x1, [], [], vguess, 1);
```
The first line adds the path to utility folder and the associated functions. Loads the calibrated parameters and then a good guess for the value function.

The two ``[]`` stand in for ``specs`` which is a structure defining grid, shocks, etc. if it is not specified, then a default is set in the [``preamble.m``](./preamble.m). The next ``[]`` stands in for the seed on the random number generator. Again if nothing is given a default seed is set in [``preamble.m``](./preamble.m). The  final value is a flag which can take on the value 0 and returns all moments across simulations, but displays no output. Or the flag 1 which displays the mean values across simulations.

The ``calibrated_baseline.mat`` contains the final, calibrated parameter values reported in the paper as the array ``x1``. Stuff is ordered in the following way:

1. Standard Deviation of transitory shocks
2. 1 / pareto shape parameter permanent shock
3. Urban TFP
4. Persistence of transitory shocks
5. Ubar
6. Getting experience, $\lambda$
7. Losing it, $\pi$
8. Gamma parameter in shock process
9. Logit shocks


Then it should compute everything and then spit out the moments. The output should look something like this with the MATLAB version and details reported.

```
02-Dec-2021 08:41:43


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

Wage Gap
 1.8893

Average Rural Population
 0.6001

Fraction of Rural with No Assets
 0.4696

Expr Elasticity: Year One, Two
 0.2072    0.0484

Control: Year One, Repeat Two
 0.3628    0.7064

LATE Estimate
 0.2912

OLS Estimate
 0.0947
```

---

**Calibrating the Model:** Implement the calibration routine by starting inside the [``calibration``](../calibration) folder and running
```
>> calibrate_basline.m
```
And then within it you can see how it works. It takes the moments then passes them and the parameter values [``calibrate_model.m``](../calibrate_model.m) which is just a wrapper file to run [``compute_outcomes.m``](../compute_outcomes.m) and then construct moments for reporting or passing to a minimizer.

The baseline minimizer is ``fminsearchcon`` which is a constrained version of [``fminsearch``](https://www.mathworks.com/help/matlab/ref/fminsearch.html).  When this project first started, to get in the neighborhood we used the [``ga``](https://www.mathworks.com/help/gads/ga.html) solver which is essentially a search of the entire parameter space in a smart way.

---

### Accounting

What is in this folder.

- [``compute_outcomes.m``](./compute_outcomes.m) main file to take parameter values, solve households problem, simulate and construct stationary distribution, and then construct moments in the model as they are in the data.

- [``calibrate_model.m``](./calibrate_model.m) wrapper file that takes in moments and parameter values and returns output from model.

- [``calibrate_baseline.m``](./calibrate_baseline.m) to implement the full calibration.

- [``preamble.m``](./preamble.m) specifies the default parameter values and specifications on the asset grid, shock structure, number of simulations, the seed. If you want to change something about how stuff is computed, this is the file to change. Not [``compute_outcomes.m``](./compute_outcomes.m) To speed up things, the main value to change is [``specs.Nmontecarlo``](https://github.com/mwaugh0328/final_migration/blob/bfafac24e1fcb9ee0ccd8122d412a053e69cc210/calibration/preamble.m#L68) which specifies how many simulations to perform on top of things. The baseline when the model is calibrated is 30. But as low as 5 seems ok.

- [``identification.m``](./identification.m) computes the dlog(moments) / dlog(paramters) table.

- [``cal_rural_urban_simulate.m``](./cal_rural_urban_simulate.m) designed to simulate the economy. Stripped down to run fast and compute only what is needed for calibration.

- [``cal_experiment_driver.m``](./cal_experiment_driver.m) driver file to compute experiment many times given simulated sample paths from above. Calls the file below.

- [``cal_simulate_experiment.m``](./cal_simulate_experiment.m) designed to simulate the experiment just in the calibration folder. It's stripped down to run fast and compute only what we need for calibration.

- [``compute_standard_errors.m``](./compute_standard_errors.m) and [``sd_calculation.m``](./sd_calculation.m) Deprecated, not relevant. Files to compute the jacobian and standard errors.  
