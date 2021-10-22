

addpath('../calibration')
addpath('../ge_taxation')

load calibration_final
load wages


% [move_de, solve_types, assets, params, vfun, ce] = just_policy(exp(new_val), wages, [], [], [], []);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% [data_panel, params] = just_simmulate(params, move_de, solve_types, assets, vfun, []);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% [labor, govbc, tfp] = just_aggregate(params,data_panel, wages, [], 0);


[move_de, solve_types, assets, params, specs, vfun, ce] = just_policy(exp(new_val), testwage, [], [], [], []);

[data_panel, params] = just_simmulate(params, move, solve_types, assets, specs, ce, []);

[labor, govbc, tfp] = aggregate(params, data_panel, testwage, [], 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ntypes = 24;
n_shocks = 5*2;

[move_vec_p, move_vec_all, A] = make_movevec(move_de, 12, params);

testmove = make_movepolicy(move_vec_all,[],params);

movefoo = make_movepolicy(move_vec_p,12,params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x0 = move_vec_p;

position = 12;

tic
[social_welfare, foobar] = compute_effecient(x0, exp(new_val), tfp, testmove, position, foobar, 1);
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LB = (zeros(length(x0),1));
UB = (ones(length(x0),1));
b = ones(length(x0),1);

tic

opts = optimoptions('patternsearch','Display','iter','UseParallel',true,'MaxFunEvals',500);

x1 = patternsearch(@(xxx) compute_effecient(xxx, exp(new_val), tfp, testmove, position, 0)...
    , x0, A,b,[],[],(LB),(UB),[],opts);

toc


















