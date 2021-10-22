function [xxx] = compute_eq(wage_policy, cal, tfp, cft, vfun, taxprog, policyfun, flag)

wages = wage_policy(1:2);
taxrate = wage_policy(3);
tax = [taxrate, taxprog];

    
[move, solve_types, assets, params, specs, ~, ce] = just_policy(cal, wages, vfun, cft, tax, policyfun);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[data_panel, params] = just_simmulate(params, move, solve_types, assets, specs, ce, cft);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[labor, govbc] = ge_aggregate(params, data_panel,wages, tfp, flag);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xxx = [labor.demand.monga - labor.supply.monga;
    labor.demand.notmonga - labor.supply.notmonga; govbc];

