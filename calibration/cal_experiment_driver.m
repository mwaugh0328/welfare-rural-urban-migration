function [sim_expr, sim_cntr] = cal_experiment_driver(assets, move, assets_temp,...
    move_temp, params, perm_type, monga_index,...
    states, pref_shocks, move_shocks, sim_data)%#codegen

Nsims = length(monga_index);

%some magic numbers flowting in here, 13 = size of the panel that comes out
% this is determined by what is going on in simmulate_experiment...
% 11 = how long we want to run this out.

panel_size = size(sim_data,2) + 1;
follow_hh_expr = params.follow_hh_expr;

sim_expr = zeros(Nsims, panel_size, follow_hh_expr);
% sim_surv = zeros(Nsims,10,2);

sim_cntr = zeros(Nsims, size(sim_data,2), follow_hh_expr);

% This will implement the experiment in the monga season.

for xxx = 1:Nsims
    
    index = monga_index(xxx);
    
    state_at_expr = states(index,1:3);
    
    shock_states = states(index:index + (follow_hh_expr-1), 4);
    
    p_shocks = pref_shocks(index:index + (follow_hh_expr-1),1);
    
    m_shocks = move_shocks(index:index + (follow_hh_expr-1),1);
   
       
    [panel_expr] = cal_simulate_experiment(assets, move, assets_temp, move_temp, params, perm_type,...
    state_at_expr, shock_states, p_shocks, m_shocks);

    
    for zzz = 1:follow_hh_expr
        %this then just fills in the dataset the way we want it.
        
        sim_expr(xxx,:,zzz) = panel_expr(zzz,:);
        
        sim_cntr(xxx,:,zzz) = sim_data(index + (zzz-1),:); 
        
    end
 
end


    
end

