function [social_welfare, sim_panel] = compute_effecient(c, cal, tfp, move, position, sim_panel, flag);
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

[solve_types, params] = effecient_preamble(cal, tfp); 

movefoo = make_movepolicy(c,position,params);

move(position) = movefoo(position);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[data_panel, params, sim_panel] = effecient_simmulate(params, move, consumption,...
                                        solve_types, [], [], sim_panel, position);
 
                                                                      
[~, ~, cons_fix] = effecient_aggregate(params, tfp, data_panel,[]);

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

[data_panel, params, ~] = effecient_simmulate(params, move, consumption,...
                            solve_types, vfun, muc, [], position);
                      

[social_welfare, ~] = effecient_aggregate(params,tfp, data_panel,flag);


social_welfare = ((-1).*social_welfare);
% [labor, govbc] = just_aggregate(params, data_panel, wages, tfp, flag);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% xxx = [labor.demand.monga - labor.supply.monga;
%     labor.demand.notmonga - labor.supply.notmonga; govbc];