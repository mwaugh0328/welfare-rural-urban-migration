### Appendix

This section describes the code that goes into computing various checks and alternative calibrations of the model.

---

- [``print_out_appendix.m``](./print_out_appendix.m) will print out all the different results.


- [``compute_outcomes_appendix.m``](./compute_outcomes_appendix.m) is the analog to [``compute_outcomes``](../calibration/compute_outcomes.m) in the calibration folder. Again, setup to handel various permutations.

- [``calibrate_model_appendix.m``](./calibrate_model_appendix.m) is the wrapper file to take in paramters and then return moments or objective function.

- [``compute_outcomes_additive.m``](./compute_outcomes_additive.m) specifically designed for additive utility cost. Calls [``rural_urban_value_additive.m``](../utils/rural_urban_value_additive.m) which specifically solves for the hh problem with the additive utility cost.

- [``preamble_appendix.m``](./preamble_appendix.m) preamble specifically designed for the appendix.


Then there are many files with the following naming convention:

- ``appenix_*`` contains ``.mat`` with the resulting calibrated parameters. For example, ``appendix_cal_low_R.mat`` results from the calibration with an lower $R$.

- ``calibrate_*`` are dirver files that implement the calibration under the given parameter restrictions. They call [``calibrate_model_appendix.m``](./calibrate_model_appendix.m) which is specifically setup to handel various permutations.

- ``welfare_*`` which computes the welfare gains associated with alternative parameterizations.

---

Below is a complete accounting of what is in my directory.

```
11/08/2021  05:37 PM               304 appendix_additive_cost.mat
11/08/2021  05:37 PM               834 appendix_batch_file.m
11/08/2021  05:37 PM               356 appendix_cal_high_beta.mat
11/08/2021  05:37 PM               347 appendix_cal_high_R.mat
11/08/2021  05:37 PM               355 appendix_cal_low_beta.mat
11/08/2021  05:37 PM               352 appendix_cal_low_R.mat
11/08/2021  05:37 PM               368 appendix_cal_perm_movingcost.mat
11/08/2021  05:37 PM               346 appendix_cal_subsistence.mat
11/08/2021  05:37 PM               369 appendix_cal_subsistence_high.mat
11/08/2021  05:37 PM               297 appendix_fix_rho.mat
11/08/2021  05:37 PM               297 appendix_fix_ubar.mat
11/18/2021  06:29 PM             2,317 calibrate_additive.m
11/08/2021  05:37 PM             2,450 calibrate_additive_appendix.m
11/08/2021  05:37 PM             2,489 calibrate_fix_rho.m
11/08/2021  05:37 PM             2,261 calibrate_fix_rho_wrap.m
11/08/2021  05:37 PM             2,489 calibrate_fix_ubar.m
11/08/2021  05:37 PM             2,265 calibrate_fix_ubar_wrap.m
11/08/2021  05:37 PM             2,283 calibrate_highR.m
11/08/2021  05:37 PM             2,288 calibrate_high_beta.m
11/08/2021  05:37 PM             2,281 calibrate_lowR.m
11/08/2021  05:37 PM             2,287 calibrate_low_beta.m
11/08/2021  05:37 PM             2,447 calibrate_model_appendix.m
11/08/2021  05:37 PM             2,307 calibrate_perm_movingcost.m
11/08/2021  05:37 PM             2,291 calibrate_subsistence.m
11/08/2021  05:37 PM             2,312 calibrate_subsistence_high.m
11/08/2021  05:37 PM            17,831 compute_outcomes_additive.m
11/08/2021  05:37 PM            17,813 compute_outcomes_appendix.m
11/08/2021  05:37 PM             3,317 preamble_appendix.m
11/18/2021  06:29 PM             8,593 print_out_appendix.m
12/15/2021  11:51 AM             1,566 README.md
11/18/2021  06:29 PM             1,022 welfare_alt_params.m
11/18/2021  06:29 PM               286 welfare_fix_rho.m
11/18/2021  06:29 PM               288 welfare_fix_ubar.m
11/18/2021  06:29 PM               416 welfare_perm_movingcost.m
11/18/2021  06:29 PM               383 welfare_subsistence.m
```
