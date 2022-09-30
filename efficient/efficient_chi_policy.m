function [movepolicy] = efficient_chi_policy(params, mplscale, consumption, perm_types)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% work through each time and compute the moving policy function
% only need consumption, no weights. 
parfor xxx = 1:params.n_types 
        
    [movepolicy(xxx), ~] = efficient_chi(consumption(xxx), mplscale, params, perm_types(xxx,:));

        
end

