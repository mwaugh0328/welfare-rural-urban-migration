function [objective, social_welfare] = compute_effecient(c, cal, tfp, seed, flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nshocks = 5;
ntypes = 24;
ubar = cal(5);

cexp = repmat([1;1], nshocks,1);
cnotexp = ((1./ubar).*(cexp).^(-2)).^(-1./2);

for xxx = 1:ntypes
    
    consumption(xxx).rural_not = cexp;
    consumption(xxx).rural_exp = cexp;
    consumption(xxx).seasn_not = cnotexp;
    consumption(xxx).seasn_exp = cexp;
    consumption(xxx).urban_new = cnotexp;
    consumption(xxx).urban_old = cexp;
    
end 
%move = c;
move = make_movepolicy(c, nshocks*2, ntypes);

[solve_types, params] = effecient_preamble(cal, tfp, []); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[vfun, muc] = effecient_policy(params, move, consumption);

[data_panel, params, state_panel] = effecient_simmulate(params, move, consumption, solve_types, [], [], seed);

[~, ~, cons_fix, mpl] = effecient_aggregate(params,tfp, data_panel,0);

%effecient_chi(consumption(1), mpl, params, solve_types(1,:))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cexp = repmat(cons_fix, nshocks,1);

cnotexp = ((1./ubar).*(cexp).^(-2)).^(-1./2);

for xxx = 1:ntypes
    
    consumption(xxx).rural_not = cexp;
    consumption(xxx).rural_exp = cexp;
    consumption(xxx).seasn_not = cnotexp;
    consumption(xxx).seasn_exp = cexp;
    consumption(xxx).urban_new = cnotexp;
    consumption(xxx).urban_old = cexp;
    
end 

[vfun, muc] = effecient_policy(params, move, consumption);

%[data_panel] = effecient_simmulate(params, move, consumption, solve_types, vfun, muc);
[data_panel] = quick_sim(data_panel, state_panel, vfun, muc, consumption, params);

[social_welfare, ~] = effecient_aggregate(params,tfp, data_panel, flag);

objective = ((-1).*social_welfare.all);

% [labor, govbc] = just_aggregate(params, data_panel, wages, tfp, flag);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% xxx = [labor.demand.monga - labor.supply.monga;
%     labor.demand.notmonga - labor.supply.notmonga; govbc];