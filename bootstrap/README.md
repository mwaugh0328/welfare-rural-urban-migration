### Bootstrap

This section describes code in folder. It uses code from [calibration](https://github.com/mwaugh0328/final_migration/tree/main/calibration) and the [utils](https://github.com/mwaugh0328/final_migration/tree/main/utils) folder.

**IMPORTANT I** Before running ``calibrate_montecarlo.m`` or ``run_montecarlo.m`` set the number of simulations to do within the calibration routine. So set ``specs.Nmontecarlo`` in the [``preable.m``](https://github.com/mwaugh0328/final_migration/blob/6875e6c7be55c4aa9dc1d770c34affb31a8182dd/calibration/preamble.m#L68) file in the calibration folder. I set it to 5. I think it's ok for this.

**IMPORTANT II** in [``run_montecarlo.m``](https://github.com/mwaugh0328/final_migration/blob/main/bootstrap/run_montecarlo.m) I have git commands which will auto push the ``.mat`` file to the repository. If you don't have [``git``](https://git-scm.com/) either install or disable command.


- [``create_fake_data.m``](https://github.com/mwaugh0328/final_migration/blob/main/bootstrap/create_fake_data.m) This will create a model simulated set of moments. It calls [``compute_outcomes.m``](https://github.com/mwaugh0328/final_migration/blob/main/calibration/compute_outcomes.m) in the calibration folder and returns and saves a set of moments. The number of simulated moments will correspond to ``specs.Nmontecarlo`` in the [``preable.m``](https://github.com/mwaugh0328/final_migration/blob/6875e6c7be55c4aa9dc1d770c34affb31a8182dd/calibration/preamble.m#L68) file in the calibration folder.

- [``calibrate_montecarlo.m``](https://github.com/mwaugh0328/final_migration/blob/main/bootstrap/calibrate_montecarlo.m) takes in a set of moments, loads starting value and value function guess, then starts the minimization routine to find the model parameter values that best fit the moments given. Calls [``calibrate_model.m``](https://github.com/mwaugh0328/final_migration/blob/main/calibration/calibrate_model.m) from the [calibration](https://github.com/mwaugh0328/final_migration/tree/main/calibration)  folder.


- [``run_montecarlo.m``](https://github.com/mwaugh0328/final_migration/blob/main/bootstrap/run_montecarlo.m) Essentially a loop on ``calibrate_montecarlo.m`` over the set of simulated moments. So for each iteration, grab moments, calibrate, record values and then do it again. Saves results each iteration.

---

TODO:

- upload code used on BU server.
