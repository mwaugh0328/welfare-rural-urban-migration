function [data_panel] = quick_sim(data_panel, state_panel, vfun, muc, cons_policy, params)

consumption = 1; live_rural = 2; work_urban = 3; move = 4;
move_season  = 5; movingcosts = 6; season = 7; welfare = 8; experince = 9; production = 10;
maringal_utility = 11; ubar_cost = 12;

%[location, season, shock_states']

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cons_policy_rural_not = reshape([cons_policy(:).rural_not],params.n_shocks,params.n_perm_shocks);
vfun_rural_not = reshape([vfun(:).rural_not],params.n_shocks,params.n_perm_shocks);
muc_rural_not= reshape([muc(:).rural_not],params.n_shocks,params.n_perm_shocks);

cons_policy_rural_exp = reshape([cons_policy(:).rural_exp],params.n_shocks,params.n_perm_shocks);
vfun_rural_exp = reshape([vfun(:).rural_exp],params.n_shocks,params.n_perm_shocks);
muc_rural_exp= reshape([muc(:).rural_exp],params.n_shocks,params.n_perm_shocks);

cons_policy_seasn_not = reshape([cons_policy(:).seasn_not],params.n_shocks,params.n_perm_shocks);
vfun_seasn_not = reshape([vfun(:).seasn_not],params.n_shocks,params.n_perm_shocks);
muc_seasn_not= reshape([muc(:).seasn_not],params.n_shocks,params.n_perm_shocks);

cons_policy_seasn_exp = reshape([cons_policy(:).seasn_exp],params.n_shocks,params.n_perm_shocks);
vfun_seasn_exp = reshape([vfun(:).seasn_exp],params.n_shocks,params.n_perm_shocks);
muc_seasn_exp= reshape([muc(:).seasn_exp],params.n_shocks,params.n_perm_shocks);

cons_policy_urban_new= reshape([cons_policy(:).urban_new],params.n_shocks,params.n_perm_shocks);
vfun_urban_new = reshape([vfun(:).urban_new],params.n_shocks,params.n_perm_shocks);
muc_urban_new= reshape([muc(:).urban_new],params.n_shocks,params.n_perm_shocks);

cons_policy_urban_old = reshape([cons_policy(:).urban_old],params.n_shocks,params.n_perm_shocks);
vfun_urban_old = reshape([vfun(:).urban_old],params.n_shocks,params.n_perm_shocks);
muc_urban_old= reshape([muc(:).urban_old],params.n_shocks,params.n_perm_shocks);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
location_loc = 1;
perm_loc = 4;
trans_loc = 3;


for zzz = 1:length(data_panel)

    if state_panel(zzz,location_loc) == 1
                
        data_panel(zzz,consumption) = cons_policy_rural_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,welfare) = vfun_rural_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,maringal_utility) = muc_rural_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = 0;
        
        continue
    end
    
    if state_panel(zzz,location_loc) == 6

        data_panel(zzz,consumption) = cons_policy_urban_old(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,welfare) = vfun_urban_old(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,maringal_utility) = muc_urban_old(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = 0;
        
        continue
    end
    
    if state_panel(zzz,location_loc) == 3
        data_panel(zzz,consumption) = cons_policy_rural_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,welfare) = vfun_rural_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,maringal_utility) = muc_rural_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = 0;
        continue
    end
    
    if state_panel(zzz,location_loc) == 2

        data_panel(zzz,consumption) = cons_policy_seasn_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,welfare) = vfun_seasn_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,maringal_utility) = muc_seasn_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = cons_policy_seasn_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc)) - ...
            cons_policy_seasn_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
            % this is the extra amount of consumption that must go to an
            % inexepinced guy
        continue
    end

    if state_panel(zzz,location_loc) == 4
   
        data_panel(zzz,consumption) = cons_policy_seasn_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,welfare) = vfun_seasn_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,maringal_utility) = muc_seasn_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = 0;
        
        continue
    end
    
    if state_panel(zzz,location_loc) == 5
   
        data_panel(zzz,consumption) = cons_policy_urban_new(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,welfare) = vfun_urban_new(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,maringal_utility) = muc_urban_new(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = cons_policy_urban_new(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc)) - ...
            cons_policy_urban_old(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        continue
    end
    

    
end

        