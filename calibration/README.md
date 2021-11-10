### Calibration

This section describes basic computations, the calibration approach, and then describes the computational elements behind the computation of the model.

### Basic Computations
---
**Compute Model:** The most basic call starts inside the [``calibration``](https://github.com/mwaugh0328/final_migration/tree/main/calibration) folder. To generate moments from the model

```
>> load('calibrated_baseline.mat')

>> compute_outcomes(x1, [], [], vguess, 1)
```
Then it should compute everything and then spit out the moments. The output should look something like this (**note** this is from my fed computer which has R2018 and is different from the version with R2021)
```
Wage Gap
    1.8893

Average Rural Population
    0.6001

Fraction of Rural with No Assets
    0.4691

Expr Elasticity: Year One, Two
    0.2081    0.0471

Control: Year One, Repeat Two
    0.3621    0.7073

LATE Estimate
    0.2906

OLS Estimate
    0.0931
```
The two ``[]`` stand in for ``specs`` which is a structure defining grid, shocks, etc. if it is not specified, then a default is set in the ``preamble.m``. The next ``[]`` stands in for the seed on the random number generator. Again if nothing is given a default seed is set in ``preamble.m``. The  final value is a flag which can take on the value 0 and returns all moments across simulations, but displays no output. Or the flag 1 which displays the mean values across simulations.

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

---

**Calibrating the Model:** The calibration routine is implemented by starting inside the [``calibration``](https://github.com/mwaugh0328/final_migration/tree/main/calibration) folder and running
```
>> calibrate_basline.m
```
And then within it you can see how it works. It takes the moments then passes them and the parameter values ``calibrate_model.m`` which is just a wrapper file to run ``compute_outcomes.m`` and then construct moments for reporting or passing to a minimizer.

The baseline minimizer is ``fminsearchcon`` which is a constrained version of ``fminsearch``.  When this project first started, to get in the neighborhood we used the ``ga`` solver which is essentially a search of the entire parameter space in a smart way.

### Accounting

What is in this folder.

- ``compute_outcomes.m`` main file to take parameter values, solve households problem, simulate and construct stationary distribution, and then construct moments in the model as they are in the data.

- ``calibrate_model.m`` wrapper file that takes in moments and parameter values and returns output from model.

- ``calibrate_baseline.m`` to implement the full calibration.

- ``preamble.m`` specifies the default parameter values and specifications on the asset grid, shock structure, number of simulations, the seed. If you want to change something about how stuff is computed, this is the file to change. Not ``coumpute_outcomes.m`` To speed up or better compute things, the main value to change is ``specs.Nmontecarlo`` which specifies how many simulations to perform on top of things. The baseline when the model is calibrated is 30. But as low as 5 seems ok.

- ``identification.m`` computes the dlog(moments) / dlog(paramters) table.

- ``cal_rural_urban_simmulate.m`` designed to simulate the economy. Stripped down to run fast and compute only what is needed for calibration.

- ``cal_experiment_driver.m`` driver file to compute experiment many times given simulated sample paths from above. Calls the file below.

- ``cal_simmulate_experiment.m`` designed to simulate the experiment just in the calibration folder. It's stripped down to run fast and compute only what we need for calibration.

- ``compute_standard_errors.m`` and ``sd_calculation.m`` are new and old files to compute the jacobian and standard errors.  Deprecated, not relevant.
