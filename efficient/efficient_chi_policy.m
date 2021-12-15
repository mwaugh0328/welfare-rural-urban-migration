function [movepolicy] = efficient_chi_policy(params, mplscale, consumption, perm_types)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


parfor xxx = 1:params.n_types 
        
    [movepolicy(xxx), ~] = efficient_chi(consumption(xxx), mplscale, params, perm_types(xxx,:));

        
end

