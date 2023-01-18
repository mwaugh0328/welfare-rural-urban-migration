### Computing the Efficient Allocation


<p align="center">
<img src="../figures/ce_vs_planner_v2.png">
</p>


This section describes computations to compute the efficient allocation.

---

### Main Computation

The most basic call starts inside the [``efficient``](../efficient) folder. To perform the analysis you:

```
>> solve_efficient
```

which does several things.

  - First it replicates the baseline economy.

  - Second, it keeps policy functions fixed and then redistributes output to equate the marginal utility of consumption across all households for all states, dates, and locations. This is the "full insurance" benchmark. Aggregates in this section should match up with baseline economy, the only difference is the allocation of consumption.

  - Third, it then solves for the efficient allocation accoring to Proposition 1 which both (i) equates the marginal utility of consumption and (ii) optimally moves households across space.

  - In the driver file there is a parameter ``pareto_alpha`` for which one can control the Pareto weights by permanent type; when set equall to zero the weights are equall, when negative more weight is put on higher ability types and vice versa.  

The output should look something like this.

```



```

As mentioned above, the first set of results replicates the baseline economy. If this is not matching up with expectations, then there is a problem somewhere.

The second set of results then computes the full insurance benchmark. This is executed in [``compute_fullinsurance``](./compute_fullinsurance.m)

The third set of results are the aggregates and welfare gains from the efficient allocation. This is executed in [``compute_analytical_efficient.m``](./compute_analytical_efficient.m)

---

### Accounting

Several components are here. One is the [full insurance allocation.](#code-for-full-insurance) The other is the [efficient allocation.](#code-for-efficient-allocation) The code that goes into each component is discussed in turn.

- [``solve_efficient.m``](./solve_efficient.m) main driver file.

#### Code for full insurance

- [``compute_fullinsurance.m``](./compute_fullinsurance.m) computes the full insurance benchmark.

- [`` policy_valuefun_fullinsurance.m``](./policy_valuefun_fullinsurance.m) solves for the value function associated with full insurance, yet migration policy functions are used from the baseline economy, so the labor allocation resulting from this should be exactly the same as in the baseline economy.

- [``quick_sim_fullinsurance.m``](./quick_sim_fullinsurance.m) function to take states from full simulation in [``just_simmulate``](../utils/just_simulate.m) and extract outcomes.

- [``fullinsurance_aggregate.m``](./fullinsurance_aggregate.m) function to take panel of outcomes and aggregate and report statistics.

- [``tax_eq_preamble.m``](./tax_eq_preamble.m) this unfortunatly is a hack to load the proper settings in the [``just_policy.m``](../utils/just_policy.m) function that is called. It then loads this local preamble.

---

#### Code for efficient allocation

- [``compute_analytical_efficient.m``](./compute_analytical_efficient.m) main driver file that takes primitives and then computes the efficient allocation.

- [``efficient_preamble.m``](./efficient_preamble.m) preamble file to set things up.

- [``onestep.m``](./onestep.m) takes some guessed values for consumption by season and then mpl by season and computes the allocation.

- [``efficient_chi_policy.m``](./efficient_chi_policy.m) wrapper file to construct the $\chi$ multipliers for each permanent productivity state.

- [``efficient_chi.m``](./efficient_chi.m) this is where it takes the guessed marginal utility of consumption and marginal product of labor, guesses a $\chi$'s which given the recursive formulation maps into a new $\chi$, then value-function-like iteration is used until the $\chi$'s converge and the migration probabilities are recovered.

- [``efficient_policy.m``](./efficient_policy.m) wrapper file to take the migration probabilities and consumption allocation and then compute value functions for households of different states and the marginal utility of consumption.

- [``efficient_valuefun.m``](./efficient_valuefun.m) computes value functions for households given optimal decision rules.

- [``efficient_simulate.m``](./efficient_simulate.m) wrapper file to simulate and construct the allocation.

- [``simulate_efficient.m``](./simulate_efficient.m) core file to simulate the model.

- [``quick_sim_efficient.m``](./quick_sim_efficient.m) quick simulation routine that takes states from [``efficient_simulate.m``](./efficient_simulate.m) and then returns outcomes.  

- [``efficient_aggregate.m``](./efficient_aggregate.m) file to aggregate from the simulation results.
