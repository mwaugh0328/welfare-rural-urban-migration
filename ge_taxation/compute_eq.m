function [xxx] = compute_eq(wage_policy, cal, tfp, meanstest, meanstest_cash, vfun, taxprog, policyfun, transfer_type, flag)

wages = wage_policy(1:2);
taxrate = wage_policy(3);
tax = [taxrate, taxprog];

    
[move, solve_types, assets, params, specs, ~, ce] = just_policy(cal, wages, vfun, meanstest, meanstest_cash, tax, policyfun);
% either calls rurual_urban_valuefun (when hh reoptimize)
% or policyfun which computes value fun, holding fixed policy funciton

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[data_panel, params] = just_simmulate(params, move, solve_types, assets, specs, ce, meanstest, meanstest_cash);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[labor, govbc] = ge_aggregate(params, data_panel,wages, tfp, transfer_type, flag);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xxx = [labor.demand.monga - labor.supply.monga;
    labor.demand.notmonga - labor.supply.notmonga; govbc];

