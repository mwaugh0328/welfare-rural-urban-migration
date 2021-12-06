### General Equilibrium Welfare Analysis

This section describes basic computations to compute the welfare gains associated with permanent transfers (conditional or unconditional) in general equilibrium.

---

### Main Computations

**Compute Welfare Gains from Conditional Migration Transfers:** The most basic call starts inside the [``ge_taxation``](https://github.com/mwaugh0328/final_migration/tree/main/ge_taxations) folder. To perform the welfare analysis you:
```
>> tax_eq
```
which does several things.
  - First it replicates the baseline economy (some statistics may differ slightly relative to calibration or ``pe_welfare_analysis.m`` due to how sample's are constructed).

  - Second, it keeps policy functions fixed and performs the migration transfer.

  - Third, it keeps the household policy functions fixed, but finances the transfer with a labor income tax.

  - Fourth, policy functions adjust, rural wages adjust to clear the labor market, and a labor income tax to finance the transfer.

The output should look something like this.

```
-----------------------------------------------------------------------------------------------------
   06-Dec-2021 15:45:50


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


-----------------------------------------------------------------------------------------------------

Replicate Baseline

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.5991

Migrants, Mushfiqs Sample
    0.3634

Migrants, Whole Population
    0.3057

Wage Gap
    1.8897

Fraction of Rural with Access to Migration Subsidy
    0.4965

Mushfiqs Sample, Average Welfare (% ce variation)
     0

Social Welfare (% ce variation): All, Rural, Urban
     0     0     0

Gov Budget Constraint
     0

Tax rate in % on labor income
     0


-----------------------------------------------------------------------------------------------------

Permanent Migration Subsidy + Migration Policy Fixed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.5991

Migrants, Mushfiqs Sample
    0.3634

Migrants, Whole Population
    0.3057

Wage Gap
    1.8897

Fraction of Rural with Access to Migration Subsidy
    0.4965

Mushfiqs Sample, Average Welfare (% ce variation)
    2.0600

Social Welfare (% ce variation): All, Rural, Urban
    1.0300    1.6200    0.1500

Gov Budget Constraint
   -0.0100

Tax rate in % on labor income
     0


-----------------------------------------------------------------------------------------------------

Permanent Migration Subsidy + Migration Policy Fixed + Tax Financed


Solve for wages and tax rate


                                         Norm of      First-order
 Iteration  Func-count     f(x)          step          optimality
     0          7     9.43063e-05                        0.0218
     1         14     1.35196e-28     0.00432904       6.55e-14      

Equation solved.

fsolve completed because the vector of function values is near zero
as measured by the value of the function tolerance, and
the problem appears regular as measured by the gradient.

<stopping criteria details>
Elapsed time is 795.212953 seconds.
    0.5500    1.8182    0.9957

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.5991

Migrants, Mushfiqs Sample
    0.3634

Migrants, Whole Population
    0.3057

Wage Gap
    1.8897

Fraction of Rural with Access to Migration Subsidy
    0.4965

Mushfiqs Sample, Average Welfare (% ce variation)
    1.6200

Social Welfare (% ce variation): All, Rural, Urban
    0.5900    1.1900   -0.2900

Gov Budget Constraint
     0

Tax rate in % on labor income
    0.4300


-----------------------------------------------------------------------------------------------------

Permanent Migration Subsidy + Endogenous Migration GE + Tax Financed


Solve for wages and tax rate


                                         Norm of      First-order
 Iteration  Func-count     f(x)          step          optimality
     0          7       0.0182023                         0.784
     1         14     8.54369e-05      0.0293198         0.0509      
     2         21      1.6899e-09     0.00169709       0.000223      
     3         28     5.85325e-12    8.80307e-06       1.21e-05      

Equation solved, inaccuracy possible.

fsolve stopped because the vector of function values is near zero, as measured by the value
of the function tolerance. However, the last step was ineffective.

<stopping criteria details>
Elapsed time is 1155.844387 seconds.
    0.5700    1.8002    0.9868

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.6629

Migrants, Mushfiqs Sample
    0.6913

Migrants, Whole Population
    0.5614

Wage Gap
    2.0673

Fraction of Rural with Access to Migration Subsidy
    0.7392

Mushfiqs Sample, Average Welfare (% ce variation)
    2.2600

Social Welfare (% ce variation): All, Rural, Urban
    0.8000    1.8500   -1.2600

Gov Budget Constraint
     0

Tax rate in % on labor income
    1.3200
```

---

**Compute Welfare Gains from Unconditional Cash Transfer** This does the same type of analysis, but now the moving cost is given unconditionally to the rural poor, with rural poor being the same means test as for the migration transfer. To perform this you simply:
```
> cash_transfer
```
And it

- replicates the baseline (and it should look like exactly above)

- computes the welfare gains with households'' policy functions changing, clears the rural labor market, and then finances the unconditional transfer with a proportional labor income tax. The output should look like this:

```
-----------------------------------------------------------------------------------------------------
   06-Dec-2021 16:24:54


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


-----------------------------------------------------------------------------------------------------

Replicate Baseline

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.5991

Migrants, Mushfiqs Sample
    0.3634

Migrants, Whole Population
    0.3057

Wage Gap
    1.8897

Fraction of Rural with Access to Migration Subsidy
    0.4965

Mushfiqs Sample, Average Welfare (% ce variation)
     0

Social Welfare (% ce variation): All, Rural, Urban
     0     0     0

Gov Budget Constraint
     0

Tax rate in % on labor income
     0


-----------------------------------------------------------------------------------------------------

Permanent Unconditional Cash Transfer to Rural Poor + Endogenous Migration GE + Tax Financed


Solve for wages and tax rate


                                         Norm of      First-order
 Iteration  Func-count     f(x)          step          optimality
     0          7       0.0168699                         0.594
     1         14     6.89508e-05      0.0417787         0.0635      
     2         21     1.92015e-09     0.00115303        0.00032      
     3         28      7.8972e-12    7.01495e-06       1.69e-05      

Equation solved, inaccuracy possible.

fsolve stopped because the vector of function values is near zero, as measured by the value
of the function tolerance. However, the last step was ineffective.

<stopping criteria details>
Elapsed time is 1120.752180 seconds.
    0.5361    1.7997    0.9657

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.6610

Migrants, Mushfiqs Sample
    0.2070

Migrants, Whole Population
    0.2104

Wage Gap
    2.1716

Fraction of Rural with Access to Migration Subsidy
    0.8883

Mushfiqs Sample, Average Welfare (% ce variation)
    5.9400

Social Welfare (% ce variation): All, Rural, Urban
    2.7800    5.8900   -3.2900

Gov Budget Constraint
     0

Tax rate in % on labor income
    3.4300
```

---

### Accounting

What is in this folder:

- [``tax_eqs.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/tax_eq.m) main file to compute the welfare gains and associated statistics with a permanent, conditional migration transfer, financed by labor income taxes.

- [``cash_transfer.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/cash_transfer.m) main file to compute the welfare gains and associated statistics with a permanent, unconditional cash transfer, financed by labor income taxes.

- [``compute_eq.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/compute_eq.m) file to compute the economy given wages, tax policy (transfer type and tax rate). It calls files like [``just_policy.m``](https://github.com/mwaugh0328/final_migration/blob/main/utils/just_policy.m), [``just_simmulate.m``](https://github.com/mwaugh0328/final_migration/blob/main/utils/just_simmulate.m), [``ge_aggregate.m``](https://github.com/mwaugh0328/final_migration/blob/main/utils/ge_aggregate.m) in the [utility folder](https://github.com/mwaugh0328/final_migration/tree/main/utils).

- [``policy_valuefun.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/policy_valuefun.m) file that computes value functions holding fixed the households policy functions.

- [``tax_eq_preamble.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/tax_eq_preamble.m) preamble file with similar structure to other preambles. Adjust gird or other things here.
