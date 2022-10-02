clear

addpath('../utils')
load('../calibration/calibrated_baseline.mat')
load('../ge_taxation/wages.mat')

wage_de = [wages.monga, wages.notmonga];

disp('-----------------------------------------------------------------------------------------------------')
disp(datetime(now,'ConvertFrom','datenum'))
disp(' ')
ver
disp('-----------------------------------------------------------------------------------------------------')
disp(' ')

pareto_alpha = -0.00;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('')
disp('Replicating the baseline economy...')
%This set of code will replicate the baseline economy. If it does not, then
%there is a problem some where.

[move_de, solve_types, assets, params, specs, vfun, ce] = just_policy(x1, wage_de, [], [], [], [], []);
% What this does is construct the policy functions and value functions
% given the wage.

[weights] = make_weights(pareto_alpha, solve_types)

[data_panel, params] = just_simulate(params, move_de, solve_types, assets, specs, weights, vfun, [],[]);
% this then simmulates the economy

[labor, govbc, tfp, ~, welfare_decentralized] = ge_aggregate(params, data_panel, wage_de, [], 'baseline', 1, 1);

% then aggregates.

% The key here is the results should be exactly the same as the
% analyze_outcomes code.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
% disp('')
% disp('')
% disp('Fix the labor allocation, but redistribute and equate marginal utility of consumption across hh...')
% 
% [~, fullinsruance_welfare] = compute_fullinsurance(assets, move_de, x1, tfp, weights, params, specs, 1);
% 
% cons_eqiv.all = ((fullinsruance_welfare.all ./ welfare_decentralized.all)).^(1./(1-params.pref_gamma)) - 1;
% % This is just the standard thing. Think of guys behind the vale, so social
% % welfare in the effecient allocation relative to decentralized. This is
% % what each should recive (expost paths and outcomes may be different) but
% % this is again a behind the vale calcuation.
% 
% % you could also compute, take this compared to a rural guy, what would he
% % get in expectation if living in the effecient world or urban.
% cons_eqiv.rural = ((fullinsruance_welfare.all ./ welfare_decentralized.rural)).^(1./(1-params.pref_gamma)) - 1;
% cons_eqiv.urban = ((fullinsruance_welfare.all ./ welfare_decentralized.urban)).^(1./(1-params.pref_gamma)) - 1;
% 
% disp("Al, Welfare Gain in %: From Decentralized to Full Insurance, Fixed Allocation")
% disp(100.*cons_eqiv.all)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('')
disp('Now compute the efficient allocation...')

[social_welfare, move_policy] = compute_analytical_efficient(x1, tfp, weights, []);

cons_eqiv_effecient.all = ((social_welfare.all ./ welfare_decentralized.all)).^(1./(1-params.pref_gamma)) - 1;
% cons_eqiv_effecient.fromfull = ((social_welfare.all ./ fullinsruance_welfare.all)).^(1./(1-params.pref_gamma)) - 1;

disp("Welfare Gain in %: From Decentralized to Centralized/Efficient Allocation")
disp(100.*cons_eqiv_effecient.all)
% disp("Welfare Gain in %: From Full Insurance to Centralized/Efficient Allocation")
% disp(100.*(cons_eqiv_effecient.all -cons_eqiv.all))




% cd('..\plotting')
%
% seasont = repmat([0,1],1,specs.n_trans_shocks);
%
% %save movepolicy_ols_late.mat lowz medz lowz_exp
%
% lowz = flipud(repmat(move_policy(4).rural_not(seasont == 1, 1)',[length(specs.asset_space),1]));
% medz = flipud(repmat(move_policy(6).rural_not(seasont == 1, 1)',[length(specs.asset_space),1]));
% lowz_exp = flipud(repmat(move_policy(6).rural_exp(seasont == 1, 1)',[length(specs.asset_space),1]));
%
%
% save movepolicy_effecient.mat lowz medz lowz_exp
%
% cd('..\efficient')
