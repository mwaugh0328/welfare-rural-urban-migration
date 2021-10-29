### Calibration

This section describes basic computations, the calibration approach, and then describes the computational elements behind the computation of the model. Much of the code in this section exploits bespoke elements to speed up the that do not work in other folders.

### Basic Computations
---
**Compute Model:** The most basic call starts inside the [``calibration``](https://github.com/mwaugh0328/final_migration/tree/main/calibration) folder. To generate moments from the model

```
>> load('calibrated_baseline.mat')

>> analyze_outcomes_prefshock(exp(new_val), 1)
```
Then it should compute everything and then spit out the moments.

The results should mimic (or come very close) to those in Table 2, 6, and 8 in the January 2020 version of the paper.

The ``calibrated_baseline.mat`` contains the final, calibrated parameter values reported in the paper as the array ``new_val``. They are in log units, so to convert to levels take ``exp``. The mapping from the values to their description is given by the structure ``labels`` which, for example,
```
>> labels(3)

ans = "urban TFP"
```
tells us that in the third position of ``new_val`` is urban TFP.

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

- ``preamble.m`` specifies the
