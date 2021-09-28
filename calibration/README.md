### Computation and calibration

This section describes basic computations, the calibration approach, and then describes the computational elements behind the computation of the model.

### Basic Computations
---
**Compute Model:** The most basic call starts inside the [``\revision_code\calibration``](https://github.com/mwaugh0328/welfare_migration/tree/master/revision_code/calibration) folder. From there to generate outcomes from the model and the partial equilibrium welfare numbers is here:

```
>> load('calibration_final.mat')

>> analyze_outcomes_prefshock(exp(new_val), 1)
```
Then it should compute everything and then spit out the moments. In ``analyze_outcomes_prefshock.m`` you can see each step (i) value function iteration (ii) simulation to construct stationary distribution (iii) implementation of experiment and (iv) collect results.

The results should mimic (or come very close) to those in Table 2, 6, and 8 in the January 2020 version of the paper.

The ``calibration_final.mat`` contains the final, calibrated parameter values reported in the paper as the array ``new_val``. They are in log units, so to convert to levels take ``exp``. The mapping from the values to their description is given by the structure ``labels`` which, for example,
```
>> labels(3)

ans = "urban TFP"
```
tells us that in the third position of ``new_val`` is urban TFP.

**Calibrating the Model:** The calibration routine is implemented by starting inside the [``\revision_code\calibration``](https://github.com/mwaugh0328/welfare_migration/tree/master/revision_code/calibration)
```
>> calibrate_wrap_tight
```
And then within it you can see how it works. It calls ``compute_outcomes_prefshock.m`` which is similar to the ``analyze...`` file above but is optimized for the calibration routine.  The key to get this thing to fit was using the ``ga`` solver which is essentially a search of the entire parameter space in a smart way. The current settins have a tight bounds on the parameter space. The original calibration routine had very loose bounds. Alternative approaches with different minimizers (``patternsearch`` ``fminsearch`` (with and without random start) and some ``NAG`` routines) are in the ``graveyard`` folder.

### In Depth: Computational Details.

This section describes each element of the code and the approach applied to computing the model.

- **Setting up the parameter space.** The baseline asset grid is with 100 points between 0 and an upper value chosen and ex-post verified that it does not play an economic role.

- **Solving the Households Problem.** The core function here is ``rural_urbaan_value.m`` that solves for a households optimal asset choice and migration probabilities given a households permanent ability.  Policy functions and value functions are solved through standard value function iteration on the gird over asset holdings and transitory shocks. Once convergence is achieved, the value functions and policy functions are returned.

- **Constructing the Stationary Distribution.** The stationary distribution is constructed via simulation: for households of different permanent types, long sample paths of activity are simulated in ``rural_urban_simmulate.m`` then last number of periods are recorded  

- **Computing and simulating the response to the experiment.**

- **Constructing model moments to match up with the data.**
