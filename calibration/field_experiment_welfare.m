function [assets, move, cons_eqiv] = field_experiment_welfare(params, perm_types, value_funs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This solves for the policy functions for the field experiment. The idea
% is to take the optimal value functions, then solve for the optimal policy
% functions given the one time move. See the notes for more description.
%
% Update, now will dompute welfare gains in units of lifetime consumption
% equivalent and one-time consumption equivalent. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigma_nu_exp = params.sigma_nu_exp;

sigma_nu_not = params.sigma_nu_not;

n_rural_options = params.rural_options; n_urban_options = params.urban_options;

R = params.R;

z_rural = perm_types(1);
z_urban = perm_types(2);
% These are the permanent shocks. 

beta = params.beta; m = params.m; gamma = params.pref_gamma; abar = params.abar;
A = params.A;

ubar = params.ubar; lambda = params.lambda; pi_prob = params.pi_prob;

m_seasn = params.m_season;

shocks_rural = params.trans_shocks(:,1);
shocks_urban = params.trans_shocks(:,2);
trans_mat = params.trans_mat;

n_shocks = length(shocks_rural);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

v_hat_rural_not  = value_funs.rural_not;
v_hat_rural_exp  = value_funs.rural_exp;

v_hat_seasn_not = value_funs.seasn_not;
v_hat_seasn_exp = value_funs.seasn_exp;

v_hat_urban_new  = value_funs.urban_new;
v_hat_urban_old  = value_funs.urban_old;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up grid for asset holdings. This is the same across locations.

asset_space = params.asset_space;
n_asset_states = length(params.asset_space);

asset_grid  = meshgrid(asset_space,asset_space);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the matricies for value function itteration. Note that there is a
% value associated with each state: (i) asset (ii) shock (iii) location. 
% The third one is the new one...

policy_assets_rural_not = zeros(n_asset_states,n_shocks,n_rural_options,'uint8');
policy_assets_rural_exp = zeros(n_asset_states,n_shocks,n_rural_options,'uint8');

policy_move_rural_not = zeros(n_asset_states,n_shocks,n_rural_options,'double');
policy_move_rural_exp = zeros(n_asset_states,n_shocks,n_rural_options,'double');

v_expr_rural_not = zeros(n_asset_states,n_shocks);
v_expr_rural_exp = zeros(n_asset_states,n_shocks);
%v_expr_rural_not_gift = zeros(n_asset_states,n_shocks);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preallocate stuff that stays fixed (specifically potential period utility and
% net assets in the maximization routine....

utility_rural = zeros(n_asset_states,n_asset_states,n_shocks);
utility_move_seasn = zeros(n_asset_states,n_asset_states,n_shocks);
utility_move_rural = zeros(n_asset_states,n_asset_states,n_shocks);


feasible_rural = false(n_asset_states,n_asset_states,n_shocks);
feasible_move_rural = false(n_asset_states,n_asset_states,n_shocks);
feasible_move_seasn = false(n_asset_states,n_asset_states,n_shocks);

net_assets = R.*asset_grid' - asset_grid;

for zzz = 1:n_shocks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    consumption = net_assets + z_rural.*shocks_rural(zzz) - abar;
    
    feasible_rural(:,:,zzz) = consumption > 0;
    
    utility_rural(:,:,zzz) = A.*(max(consumption,1e-10)).^(1-gamma);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    consumption = net_assets + z_rural.*shocks_rural(zzz) - abar;
    % NO MOVING COST HERE!!!!!!!!!!!
    
    feasible_move_seasn(:,:,zzz) = consumption > 0;
    
    utility_move_seasn(:,:,zzz) = A.*(max(consumption,1e-10)).^(1-gamma);
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    consumption = net_assets + z_rural.*shocks_rural(zzz) - m - abar;
    
    feasible_move_rural(:,:,zzz) = consumption > 0;
    
    utility_move_rural(:,:,zzz) = A.*(max(consumption,1e-10)).^(1-gamma) ;
             
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Note that ubar or urban shocks to not show up anywhere here. Why? because
%of the timing, the ubar is all built into the value functions of seasonal
%move and the ubran more. 

for zzz = 1:n_shocks
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    expected_value_rural_not = beta.*(trans_mat(zzz,:)*v_hat_rural_not');
    
    expected_value_rural_exp = beta.*(trans_mat(zzz,:)*v_hat_rural_exp');
        
    expected_value_urban_new = beta.*(trans_mat(zzz,:)*v_hat_urban_new');
    
    expected_value_urban_old = beta.*(trans_mat(zzz,:)*v_hat_urban_old');
    
    expected_value_seasn_not = beta.*(trans_mat(zzz,:)*v_hat_seasn_not');
    
    expected_value_seasn_exp = beta.*(trans_mat(zzz,:)*v_hat_seasn_exp');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           NOT-EXPERIENCED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of being in the rural area...

    value_fun = bsxfun(@plus,utility_rural(:,:,zzz),expected_value_rural_not);
    
    value_fun(~feasible_rural(:,:,zzz)) = -1e10;
    
    [v_stay_rural_not, p_asset_stay_rural_not] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of being being a seasonal migrant...NOTE NO MOVING COST
% HERE THIS IS THE EXPERIMENT

    value_fun = bsxfun(@plus,utility_move_seasn(:,:,zzz),expected_value_seasn_not);
    
    value_fun(~feasible_move_seasn(:,:,zzz)) = -1e10;
    
    [v_move_seasn_not, p_asset_move_seasn_not] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a new guy.

    value_fun = bsxfun(@plus, utility_move_rural(:,:,zzz) , expected_value_urban_new);
    
    value_fun(~feasible_move_rural(:,:,zzz)) = -1e10;
       
    [v_move_rural_not, p_asset_move_rural_not] = max(value_fun,[],2);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    policy_assets_rural_not(:,zzz,:) = [ p_asset_stay_rural_not , p_asset_move_seasn_not , p_asset_move_rural_not ];
               
    vfoo = max([v_stay_rural_not, v_move_seasn_not, v_move_rural_not],[],2);
    
    pi_rural_not = exp(([v_stay_rural_not, v_move_seasn_not, v_move_rural_not] - vfoo)./sigma_nu_not);
        
    pi_denom_rural_not = sum(pi_rural_not,2);
    
    v_expr_rural_not(:,zzz) = sigma_nu_not.*log(pi_denom_rural_not) + vfoo;
    
    policy_move_rural_not(:,zzz,:) = cumsum(pi_rural_not./pi_denom_rural_not,2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This part asks, what is the value IF EXPERINCE WAS GIVEN, holding fixed
% policy... the idea here is to try and tease out how much the ubar is
% eating into the welfare gains...

%     value_fun = bsxfun(@plus,utility_move_seasn(:,:,zzz),expected_value_seasn_exp);
%     % this the is the value fun if given experince...
%     
%     value_fun(~feasible_move_seasn(:,:,zzz)) = -1e10;
%     
%     [v_move_seasn_gift, p_asset_move_seasn_gift] = max(value_fun,[],2);
%     
%     v_expr_rural_not_gift(:,zzz) = v_expr_rural_not(:,zzz);
%     % Everything is the same as if you had no experince...
%     
%     %v_expr_rural_not_gift(policy_move_rural_not(:,zzz)== 2,zzz) = v_move_seasn_gift(policy_move_rural_not(:,zzz)== 2);
%     
%     v_expr_rural_not_gift(policy_move_rural_not(:,zzz)== 2,zzz) = v_expr_rural_not(policy_move_rural_not(:,zzz)== 2,zzz)...
%         -expected_value_seasn_not(policy_move_rural_not(:,zzz)== 2)' + expected_value_seasn_exp(policy_move_rural_not(:,zzz)== 2)'; 
%     
%     test = 1;
    % but those guys who moved, get the expeince...
    
%     u_opt_not_gift(:,zzz) = u_opt_not(:,zzz);
%     u_opt_not_gift(:,zzz) = utility_move_seasn(policy_move_rural_not(:,zzz)== 2,p_asset_move_seasn_gift,zzz);
    
%     policy_assets_rural_not_gift(:,zzz) = policy_assets_rural_not(:,zzz);
%     policy_assets_rural_not_gift(policy_move_rural_not(:,zzz)== 2,zzz) = p_asset_move_seasn_gift(policy_move_rural_not(:,zzz)== 2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           EXPERIENCED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of being in the rural area...

    value_fun = bsxfun(@plus, utility_rural(:,:,zzz),...
        pi_prob.*expected_value_rural_exp + (1-pi_prob).*expected_value_rural_not);
    
    value_fun(~feasible_rural(:,:,zzz)) = -1e10;
    
    [v_stay_rural_exp, p_asset_stay_rural_exp] = max(value_fun,[],2);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of being being a seasonal migrant...

    value_fun = bsxfun(@plus, utility_move_seasn(:,:,zzz),...
        pi_prob.*expected_value_seasn_exp + (1-pi_prob).*expected_value_seasn_not);
    
    value_fun(~feasible_move_seasn(:,:,zzz)) = -1e10;
    
    [v_move_seasn_exp, p_asset_move_seasn_exp] = max(value_fun,[],2);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a new guy.

    value_fun = bsxfun(@plus, utility_move_rural(:,:,zzz) , ...
        pi_prob.*expected_value_urban_old + (1-pi_prob).*expected_value_urban_new);
    
    value_fun(~feasible_move_rural(:,:,zzz)) = -1e10;
       
    [v_move_rural_exp, p_asset_move_rural_exp] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    policy_assets_rural_exp(:,zzz,:) = [ p_asset_stay_rural_exp , p_asset_move_seasn_exp , p_asset_move_rural_exp ];
    
    vfoo = max([v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp], [], 2);
    
    pi_rural_exp = exp(([v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp] - vfoo)./sigma_nu_exp);
        
    pi_denom_rural_exp = sum(pi_rural_exp, 2);
    
    v_expr_rural_exp(:,zzz) = sigma_nu_exp.*log(pi_denom_rural_exp) + vfoo;
    
    policy_move_rural_exp(:,zzz,:)  = cumsum(pi_rural_exp./pi_denom_rural_exp, 2);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This generates the permenant percent increse... uncomment the first line
% to get the ``gift of experince'' result

%cons_eqiv(:,:,1) = ((v_expr_rural_not_gift./v_hat_rural_not)).^(1./(1-gamma)) - 1;

cons_eqiv.rural_not = ((v_expr_rural_not./v_hat_rural_not)).^(1./(1-gamma)) - 1;
cons_eqiv.rural_exp = ((v_expr_rural_exp./v_hat_rural_exp)).^(1./(1-gamma)) - 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This generates the one time equivalent variation...

% cons_eqiv(:,:,1) = (((v_expr_rural_not_gift-v_hat_rural_not)./u_opt_not + 1)).^(1./(1-gamma))- 1;
% cons_eqiv(:,:,1) = (((v_expr_rural_not-v_hat_rural_not)./u_opt_not + 1)).^(1./(1-gamma))- 1;
% cons_eqiv(:,:,2) = (((v_expr_rural_exp-v_hat_rural_exp)./u_opt_exp + 1)).^(1./(1-gamma))- 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

assets.rural_not = policy_assets_rural_not;
assets.rural_exp = policy_assets_rural_exp;

move.rural_not = policy_move_rural_not;
move.rural_exp = policy_move_rural_exp;

% These are the asset policies that are associated with the temporary move
% The moving policies. 








