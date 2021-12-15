function [data_panel] = quick_sim_fullinsurance(data_panel, state_panel, muc, cons_policy, params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is what the panel looks like from just_simmulate/
income = 1; consumption = 2; assets = 3; live_rural = 4; work_urban = 5;
move = 6; move_season = 7; movingcosts = 8; season = 9; net_asset = 10;
welfare = 11; experince = 12; fiscalcost = 13; tax = 14; production = 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we want to reogranize it soe it's like the panel from the effecient
% allocation on...
%consumption = 1; live_rural = 2; work_urban = 3; move = 4;
%move_season  = 5; movingcosts = 6; season = 7; welfare = 8; experince = 9; production = 10;
%maringal_utility = 11;

data_panel = data_panel(:,[consumption, live_rural, work_urban, move,...
                        move_season, movingcosts, season, welfare, experince, production]);

data_panel = [data_panel, zeros(length(data_panel),2)];
                    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
consumption = 1; live_rural = 2; work_urban = 3; move = 4;
move_season  = 5; movingcosts = 6; season = 7; welfare = 8; experince = 9; production = 10;
maringal_utility = 11; ubar_cost = 12;

nshocks = params.n_shocks;
ntypes = params.n_perm_shocks;

%[location, season, shock_states']

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cons_policy_rural_not = reshape([cons_policy(:).rural_not],nshocks,ntypes);
%vfun_rural_not = reshape([vfun(:).rural_not],nshocks,ntypes);
muc_rural_not= reshape([muc(:).rural_not],nshocks,ntypes);

cons_policy_rural_exp = reshape([cons_policy(:).rural_exp],nshocks,ntypes);
%vfun_rural_exp = reshape([vfun(:).rural_exp],nshocks,ntypes);
muc_rural_exp= reshape([muc(:).rural_exp],nshocks,ntypes);

cons_policy_seasn_not = reshape([cons_policy(:).seasn_not],nshocks,ntypes);
%vfun_seasn_not = reshape([vfun(:).seasn_not],nshocks,ntypes);
muc_seasn_not= reshape([muc(:).seasn_not],nshocks,ntypes);

cons_policy_seasn_exp = reshape([cons_policy(:).seasn_exp],nshocks,ntypes);
%vfun_seasn_exp = reshape([vfun(:).seasn_exp],nshocks,ntypes);
muc_seasn_exp= reshape([muc(:).seasn_exp],nshocks,ntypes);

cons_policy_urban_new= reshape([cons_policy(:).urban_new],nshocks,ntypes);
%vfun_urban_new = reshape([vfun(:).urban_new],nshocks,ntypes);
muc_urban_new= reshape([muc(:).urban_new],nshocks,ntypes);

cons_policy_urban_old = reshape([cons_policy(:).urban_old],nshocks,ntypes);
%vfun_urban_old = reshape([vfun(:).urban_old],nshocks,ntypes);
muc_urban_old= reshape([muc(:).urban_old],nshocks,ntypes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

location_loc = 2;
perm_loc = 5;
trans_loc = 4;

for zzz = 1:length(data_panel)

    if state_panel(zzz,location_loc) == 1
                
        data_panel(zzz,consumption) = cons_policy_rural_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        %data_panel(zzz,welfare) = vfun_rural_not(state_panel(zzz,3),state_panel(zzz,4));
        
        data_panel(zzz,maringal_utility) = muc_rural_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = 0;
        
        continue
    end
    
    if state_panel(zzz,location_loc) == 6

        data_panel(zzz,consumption) = cons_policy_urban_old(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        %data_panel(zzz,welfare) = vfun_urban_old(state_panel(zzz,3),state_panel(zzz,4));
        
        data_panel(zzz,maringal_utility) = muc_urban_old(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = 0;
        
        continue
    end
    
    if state_panel(zzz,location_loc) == 3
        data_panel(zzz,consumption) = cons_policy_rural_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        %data_panel(zzz,welfare) = vfun_rural_exp(state_panel(zzz,3),state_panel(zzz,4));
        
        data_panel(zzz,maringal_utility) = muc_rural_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = 0;
        
        continue
    end
    
    if state_panel(zzz,location_loc) == 2

        data_panel(zzz,consumption) = cons_policy_seasn_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        %data_panel(zzz,welfare) = vfun_seasn_not(state_panel(zzz,3),state_panel(zzz,4));
        
        data_panel(zzz,maringal_utility) = muc_seasn_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = cons_policy_seasn_not(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc)) - ...
            cons_policy_seasn_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
            % this is the extra amount of consumption that must go to an
            % inexepinced guy
        
        continue
    end

    if state_panel(zzz,location_loc) == 4
   
        data_panel(zzz,consumption) = cons_policy_seasn_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        %data_panel(zzz,welfare) = vfun_seasn_exp(state_panel(zzz,3),state_panel(zzz,4));
        
        data_panel(zzz,maringal_utility) = muc_seasn_exp(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = 0;
        
        continue
    end
    
    if state_panel(zzz,location_loc) == 5
   
        data_panel(zzz,consumption) = cons_policy_urban_new(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        %data_panel(zzz,welfare) = vfun_urban_new(state_panel(zzz,3),state_panel(zzz,4));
        
        data_panel(zzz,maringal_utility) = muc_urban_new(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        data_panel(zzz,ubar_cost) = cons_policy_urban_new(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc)) - ...
            cons_policy_urban_old(state_panel(zzz,trans_loc),state_panel(zzz,perm_loc));
        
        continue
    end
    

    
end

        