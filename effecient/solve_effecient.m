clear

%load('../pe_welfare_analysis/cal_ols_same.mat')
load('../calibration/calibrated_baseline.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now let's run the main file, this creates the wages for the decentralized
% equillibrium

cd('../pe_welfare_analysis')

[targets, wage] = analyze_outcomes(x1, [], [], [], [], [], [], 1);

cd('../effecient')

wage_de = [wage.monga, wage.notmonga];
%These are teh wages in the decentralized equillibrium, then we are going
%to pass this through one last time to get policy functions and the
%primitive TFP. The move policy function below is used to construct a good
%initial guess for the optimization and bounds on the problem.

[move_de, solve_types, assets, params, specs, vfun, ce] = just_policy(x1, wage_de, [], [], [], [], []);
% What this does is construct the policy functions and value functions
% given the wage.

[data_panel, params] = just_simmulate(params, move_de, solve_types, assets, specs, vfun, [],[]);
% this then simmulates the economy

[labor, govbc, tfp, ~, welfare_decentralized] = ge_aggregate(params, data_panel, wage_de, [], 'baseline', 1);

% then aggregates.

% The key here is the results should be exactly the same as the
% analyze_outcomes code. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('')
disp('Fix the allocation, but redistribute and equate muc across hh')

[~, fullinsruance_welfare] = compute_fullinsurance(assets, move_de, x1, tfp, params, specs, 1);

cons_eqiv.all = ((fullinsruance_welfare.all ./ welfare_decentralized.all)).^(1./(1-params.pref_gamma)) - 1;
% This is just the standard thing. Think of guys behind the vale, so social
% welfare in the effecient allocation relative to decentralized. This is
% what each should recive (expost paths and outcomes may be different) but
% this is again a behind the vale calcuation.

% you could also compute, take this compared to a rural guy, what would he
% get in expectation if living in the effecient world or urban.
cons_eqiv.rural = ((fullinsruance_welfare.all ./ welfare_decentralized.rural)).^(1./(1-params.pref_gamma)) - 1;
cons_eqiv.urban = ((fullinsruance_welfare.all ./ welfare_decentralized.urban)).^(1./(1-params.pref_gamma)) - 1;

disp("Al, Welfare Gain in %: From Decentralized to Full Insurance, Fixed Allocation")
disp(100.*cons_eqiv.all)
% disp("Rural, Welfare Gain in %: From Decentralized to Full Insurance, Fixed Allocation")
% disp(100.*cons_eqiv.rural)
% disp("Urban, Welfare Gain in %: From Decentralized to Full Insurance, Fixed Allocation")
% disp(100.*cons_eqiv.urban)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('')
disp('')
disp('Now compute the effecient allocation...')

[social_welfare, move_policy] = compute_analytical_effecient(x1, tfp, []);

cons_eqiv_effecient.all = ((social_welfare.all ./ welfare_decentralized.all)).^(1./(1-params.pref_gamma)) - 1;
cons_eqiv_effecient.fromfull = ((social_welfare.all ./ fullinsruance_welfare.all)).^(1./(1-params.pref_gamma)) - 1;

disp("Welfare Gain in %: From Decentralized to Centralized/Effecient Allocaiton")
disp(100.*cons_eqiv_effecient.all)
disp("Welfare Gain in %: From Full Insurance to Centralized/Effecient Allocaiton")
disp(100.*(cons_eqiv_effecient.all -cons_eqiv.all))




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
% cd('..\effecient')
















