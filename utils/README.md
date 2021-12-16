### Utility functions

This folder contains functions that are used throughout all aspects of the code. A complete accounting is below, but core components are highlighted first.

- [``rural_urban_simulate.m``](rural_urban_simulate.m) **core file** used to simulate the economy and construct stationaty distribution and used in nearly every part of the analysis.

- [``rural_urban_value.m``](rural_urban_value.m) **core file** used to solve the households problem by value function itteration and used in nearly every part of the analysis.

- [``cash_experiment_welfare.m``](cash_experiment_welfare.m) computes the policy functions associated with a one time, unconditional cash experiment.

- [``experiment_driver.m``](experiment_driver.m) used to simulate and construct panel for a experiment (conditional migration or cash).

- [``field_experiment_welfare.m``](field_experiment_welfare.m) computes the polciy functions associated with a one time, conditional migration transfer.

- [``fix_allocations_experiment_welfare.m``](fix_allocations_experiment_welfare.m) computes welfare associated with a experiment (conditional migration or cash) holding policy functions, i.e. migration fixed.

- [``fminsearchcon.m``](fminsearchcon.m) constrained ``fminsearch`` function and downloaded from [https://www.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon](https://www.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon)

- [``ge_aggregate.m``](ge_aggregate.m) setup to aggregate outcomes in general equilibrium computational experiments.

- [``just_aggregate.m``](just_aggregate.m) aggregation file, not sure where it is used, may be deprecated.

- [``just_policy.m``](just_policy.m) only solves the households problem and returns value functions and policy funcitons.

- [``just_simulate.m``](just_simulate.m) only simulates the economy.

- [``labor_income_tax.m``](labor_income_tax.m) takes labor income and returns after tax labor income and tax collected. Location of taxation and progressivity can be changed here.

- [``pareto_approx.m``](pareto_approx.m) computes the discretized approximation to a Pareto distribution.

- [``report_experiment.m``](report_experiment.m) function to set things up to report what happend in the experiment

- [``report_welfare_quintiles.m``](report_welfare_quintiles.m) function to report welfare by income quintile

- [``report_welfare_quintiles_tax.m``](report_welfare_quintiles_tax.m) same as above but setup to work with ge, tax computational experiments

- [``rouwenhorst.m``](rouwenhorst.m) approach to approximate AR(1) process

- [``rural_urban_value_additive.m``](rural_urban_value_additive.m) solves the households problem with additive utility migration costs

- [``simmulate_experiment.m``](simmulate_experiment.m) simulates the conditional migration or cash transfer experiment.
