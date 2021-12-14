function [vfun, muc, solve_types, params] = efficient_policy(params,move, consumption)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


parfor xxx = 1:params.n_types 
        
[vfun(xxx), muc(xxx)] = efficient_valuefun(consumption(xxx), move(xxx), params, params.trans_mat,[]);
% Note, I need to know nothing about the actuall shocks here, jsut the
% assignment of consumption and moving for each shock state.
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
