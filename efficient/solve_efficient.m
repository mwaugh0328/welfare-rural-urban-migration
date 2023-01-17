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

[data_panel, params, ~] = just_simulate(params, move_de, solve_types, assets, specs, weights, vfun, [],[]);
% here we need to pass the Pareto Weights in so we correctly compute social
% welfare. Given the weights, it converts vfun into weights*vfun. Then
% below social welfare is constructed.

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
[fullinsruance_welfare] = compute_fullinsurance(assets, move_de, tfp, weights, params, specs);

cons_eqiv.all = ((fullinsruance_welfare.all ./ welfare_decentralized.all)).^(1./(1-params.pref_gamma)) - 1;

disp("Al, Welfare Gain in %: From Decentralized to Full Insurance, Fixed Allocation")
disp(100.*cons_eqiv.all)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('')
disp('Now compute the efficient allocation...')

[social_welfare, move_policy] = compute_analytical_efficient(x1, specs, tfp, weights);

cons_eqiv_effecient.all = ((social_welfare.all ./ welfare_decentralized.all)).^(1./(1-params.pref_gamma)) - 1;
% cons_eqiv_effecient.fromfull = ((social_welfare.all ./ fullinsruance_welfare.all)).^(1./(1-params.pref_gamma)) - 1;

disp("Welfare Gain in %: From Decentralized to Centralized/Efficient Allocation")
disp(100.*cons_eqiv_effecient.all)
disp("Welfare Gain in %: From Full Insurance to Centralized/Efficient Allocation")
disp(100.*(cons_eqiv_effecient.all -cons_eqiv.all))
disp("Gain in Aggregate Consumption")
disp(100.*(social_welfare.bigC ./ fullinsruance_welfare.bigC - 1))






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
