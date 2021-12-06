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
   06-Dec-2021 14:44:38


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
    0.5978

Migrants, Mushfiqs Sample
    0.3651

Migrants, Whole Population
    0.3048

Wage Gap
    1.8835

Fraction of Rural with Access to Migration Subsity
    0.4961

Mushfiqs Sample, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption
         0   48.3800   24.4600    0.3700
         0   37.2100   22.8800    0.5000
         0   34.6900   24.5800    0.6200
         0   31.0400   25.4800    0.7100
         0   31.2400   35.2200    0.9600

Mushfiqs Sample, Average Welfare
     0

Social Welfare: All, Rural, Urban
     0     0     0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Accounting: HH Balance Sheet
Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    0.9200    0.9200    1.1100    0.0100         0         0    0.1900

Not Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    1.3700    1.3700    1.1100    0.0200         0         0   -0.2300

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Production Side Accounting: Production, Consumption, Moving Costs
    0.9200    1.1100    0.0100

    1.3700    1.1100    0.0200

Resource Constraint (Production Side): Monga, Non Monga
   -0.1900    0.2300

Gov Budget Constraint
     0

Tax rate in % on labor income
     0


-----------------------------------------------------------------------------------------------------

Permanent Migration Subsidy + Migration Policy Fixed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.5978

Migrants, Mushfiqs Sample
    0.3651

Migrants, Whole Population
    0.3048

Wage Gap
    1.8835

Fraction of Rural with Access to Migration Subsity
    0.4961

Mushfiqs Sample, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption
    2.9300   48.3800   24.4600    0.4100
    2.2100   37.2100   22.8800    0.5300
    2.0100   34.6900   24.5800    0.6500
    1.8200   31.0400   25.4800    0.7300
    1.3100   31.2400   35.2200    0.9900

Mushfiqs Sample, Average Welfare
    2.0500

Social Welfare: All, Rural, Urban
    1.0300    1.6200    0.1500

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Accounting: HH Balance Sheet
Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    0.9200    0.9200    1.1100    0.0100         0         0    0.1900

Not Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    1.3700    1.3700    1.1200    0.0100    0.0100         0   -0.2300

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Production Side Accounting: Production, Consumption, Moving Costs
    0.9200    1.1100    0.0100

    1.3700    1.1200    0.0100

Resource Constraint (Production Side): Monga, Non Monga
   -0.1900    0.2300

Gov Budget Constraint
   -0.0100

Tax rate in % on labor income
     0

-----------------------------------------------------------------------------------------------------

Permanent Migration Subsidy + Migration Policy Fixed + Tax Financed


Solve for wages and tax rate


                                         Norm of      First-order
 Iteration  Func-count     f(x)          step          optimality
     0          7     9.46194e-05                        0.0218
     1         14     2.18968e-29     0.00433987       2.56e-14      

Equation solved.

fsolve completed because the vector of function values is near zero
as measured by the value of the function tolerance, and
the problem appears regular as measured by the gradient.

<stopping criteria details>
Elapsed time is 67.147357 seconds.
    0.5500    1.8182    0.9957

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.5978

Migrants, Mushfiqs Sample
    0.3651

Migrants, Whole Population
    0.3048

Wage Gap
    1.8835

Fraction of Rural with Access to Migration Subsity
    0.4961

Mushfiqs Sample, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption
    2.4800   48.3800   24.4600    0.4100
    1.7600   37.2100   22.8800    0.5300
    1.5600   34.6900   24.5800    0.6400
    1.3800   31.0400   25.4800    0.7300
    0.8600   31.2400   35.2200    0.9800

Mushfiqs Sample, Average Welfare
    1.6100

Social Welfare: All, Rural, Urban
    0.5900    1.1900   -0.2900

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Accounting: HH Balance Sheet
Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    0.9200    0.9200    1.1100    0.0100         0         0    0.1900

Not Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    1.3700    1.3600    1.1100    0.0100    0.0100    0.0100   -0.2300

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Production Side Accounting: Production, Consumption, Moving Costs
    0.9200    1.1100    0.0100

    1.3700    1.1100    0.0100

Resource Constraint (Production Side): Monga, Non Monga
   -0.1900    0.2400

Gov Budget Constraint
     0

Tax rate in % on labor income
    0.4300


-----------------------------------------------------------------------------------------------------

Permanent Migration Subsidy + Endogenous Migration GE + Tax Financed


Solve for wages and tax rate


                                         Norm of      First-order
 Iteration  Func-count     f(x)          step          optimality
     0          7       0.0177991                         0.763
     1         14     3.66539e-05      0.0293054         0.0348      
     2         21      3.4662e-08     0.00106575       0.000578      
     3         28     8.76967e-11    5.75582e-05        2.7e-05      

Equation solved, inaccuracy possible.

fsolve stopped because the vector of function values is near zero, as measured by the value
of the function tolerance. However, the last step was ineffective.

<stopping criteria details>
Elapsed time is 127.662346 seconds.
    0.5697    1.8000    0.9869

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.6616

Migrants, Mushfiqs Sample
    0.6922

Migrants, Whole Population
    0.5594

Wage Gap
    2.0583

Fraction of Rural with Access to Migration Subsity
    0.7336

Mushfiqs Sample, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption
    3.5200   91.5900   48.5500    0.4400
    2.6000   80.1500   45.0700    0.5500
    2.0400   66.0100   44.4000    0.7200
    1.8400   59.6200   44.6400    0.8100
    1.2900   48.7100   48.2600    1.0400

Mushfiqs Sample, Average Welfare
    2.2600

Social Welfare: All, Rural, Urban
    0.8000    1.8500   -1.2500

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Accounting: HH Balance Sheet
Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    0.9500    0.9300    1.1300         0         0    0.0100    0.2000

Not Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    1.3800    1.3600    1.1200    0.0100    0.0300    0.0200   -0.2400

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Production Side Accounting: Production, Consumption, Moving Costs
    0.9500    1.1300         0

    1.3700    1.1200    0.0100

Resource Constraint (Production Side): Monga, Non Monga
   -0.1800    0.2500

Gov Budget Constraint
     0

Tax rate in % on labor income
    1.3100
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
   06-Dec-2021 14:52:49


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
    0.5978

Migrants, Mushfiqs Sample
    0.3651

Migrants, Whole Population
    0.3048

Wage Gap
    1.8835

Fraction of Rural with Access to Migration Subsity
    0.4961

Mushfiqs Sample, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption
         0   48.3800   24.4600    0.3700
         0   37.2100   22.8800    0.5000
         0   34.6900   24.5800    0.6200
         0   31.0400   25.4800    0.7100
         0   31.2400   35.2200    0.9600

Mushfiqs Sample, Average Welfare
     0

Social Welfare: All, Rural, Urban
     0     0     0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Accounting: HH Balance Sheet
Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    0.9200    0.9200    1.1100    0.0100         0         0    0.1900

Not Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    1.3700    1.3700    1.1100    0.0200         0         0   -0.2300

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Production Side Accounting: Production, Consumption, Moving Costs
    0.9200    1.1100    0.0100

    1.3700    1.1100    0.0200

Resource Constraint (Production Side): Monga, Non Monga
   -0.1900    0.2300

Gov Budget Constraint
     0

Tax rate in % on labor income
     0


-----------------------------------------------------------------------------------------------------

Permanent Unconditional Cash Transfer to Rural Poor + Endogenous Migration GE + Tax Financed


Solve for wages and tax rate


                                         Norm of      First-order
 Iteration  Func-count     f(x)          step          optimality
     0          7       0.0167479                         0.598
     1         14     6.32198e-05       0.041029         0.0597      
     2         21     7.25148e-09     0.00119767       0.000497      
     3         28     7.05313e-11    2.00982e-05       4.23e-05      

Equation solved, inaccuracy possible.

fsolve stopped because the vector of function values is near zero, as measured by the value
of the function tolerance. However, the last step was ineffective.

<stopping criteria details>
Elapsed time is 126.169667 seconds.
    0.5361    1.7998    0.9659

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aggregate Statistics
Average Rural Population
    0.6590

Migrants, Mushfiqs Sample
    0.2054

Migrants, Whole Population
    0.2084

Wage Gap
    2.1600

Fraction of Rural with Access to Migration Subsity
    0.8831

Mushfiqs Sample, Welfare by Income Quintile: Welfare, Migration Rate, Experience, Consumption
    8.8700   15.5000   12.2400    0.3900
    7.1000   17.6200   13.8600    0.5300
    5.5800   22.6600   14.9300    0.7500
    4.8400   23.2700   17.0000    0.8200
    3.5500   23.6600   20.4900    1.0300

Mushfiqs Sample, Average Welfare
    5.9900

Social Welfare: All, Rural, Urban
    2.8000    5.9300   -3.2600

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Accounting: HH Balance Sheet
Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    0.8900    0.8600    1.0600         0    0.0200    0.0300    0.2100

Not Monga: Production, After Tax Income, Consumption, Moving Costs, Gov Cost, Tax Collected, Net Asset Position
    1.3800    1.3300    1.0700    0.0200    0.0500    0.0500   -0.2400

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Production Side Accounting: Production, Consumption, Moving Costs
    0.8800    1.0600         0

    1.3700    1.0700    0.0200

Resource Constraint (Production Side): Monga, Non Monga
   -0.1900    0.2800

Gov Budget Constraint
     0

Tax rate in % on labor income
    3.4100
```

---

### Accounting

What is in this folder:

- [``tax_eqs.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/tax_eq.m) main file to compute the welfare gains and associated statistics with a permanent, conditional migration transfer, financed by labor income taxes.

- [``cash_transfer.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/cash_transfer.m) main file to compute the welfare gains and associated statistics with a permanent, unconditional cash transfer, financed by labor income taxes.

- [``compute_eq.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/compute_eq.m) file to compute the economy given wages, tax policy (transfer type and tax rate). It calls files like [``just_policy.m``](https://github.com/mwaugh0328/final_migration/blob/main/utils/just_policy.m), [``just_simmulate.m``](https://github.com/mwaugh0328/final_migration/blob/main/utils/just_simmulate.m), [``ge_aggregate.m``](https://github.com/mwaugh0328/final_migration/blob/main/utils/ge_aggregate.m) in the [utility folder](https://github.com/mwaugh0328/final_migration/tree/main/utils). 

- [``policy_valuefun.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/policy_valuefun.m) file that computes value functions holding fixed the households policy functions.

- [``tax_eq_preamble.m``](https://github.com/mwaugh0328/final_migration/blob/main/ge_taxation/tax_eq_preamble.m) preamble file with simmilar structure to other preambles. Adjust gird or other things here.
