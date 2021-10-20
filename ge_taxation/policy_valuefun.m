function [assets, move, vfinal, cons_eqiv] = policy_valuefun(assets, move, params, perm_types, vcft)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The idea of this is to take policy functions, and directly compute the
% value function. No Max. So the idea is to feed in optimal policy and get out
% known value function. 
% What this allows us to do is to fix policy, but change
% enviorment and track how welfare changes (holding policy fixed).

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

shocks_rural = params.trans_shocks(:,1);
shocks_urban = params.trans_shocks(:,2);
trans_mat = params.trans_mat;
%grid = params.grid;

m_seasn = params.m_season;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_iterations = 5000;
tol = 10^-6; 
%It's loose here...tighten for welfare, but does not seem matter for
%quantities

n_shocks = params.n_shocks;
%A = sigma_nu.*(1-gamma).^-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up grid for asset holdings. This is the same across locations.
asset_space = params.asset_space;

n_asset_states = length(params.asset_space);

asset_grid  = meshgrid(asset_space,asset_space);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the matricies for value function itteration. Note that there is a
% value associated with each state: (i) asset (ii) shock (iii) location. 
% The third one is the new one...

v_prime_rural_not = zeros(n_asset_states,n_shocks,'double');
v_prime_rural_exp = zeros(n_asset_states,n_shocks,'double');

v_prime_urban_new = zeros(n_asset_states,n_shocks,'double');
v_prime_urban_old = zeros(n_asset_states,n_shocks,'double');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preallocate stuff that stays fixed (specifically potential period utility and
% net assets in the maximization routine....

utility_rural = zeros(n_asset_states,n_asset_states,n_shocks);
utility_urban = zeros(n_asset_states,n_asset_states,n_shocks);

utility_move_rural = zeros(n_asset_states,n_asset_states,n_shocks);
utility_move_urban = zeros(n_asset_states,n_asset_states,n_shocks);
utility_move_seasn = zeros(n_asset_states,n_asset_states,n_shocks);

net_assets = R.*asset_grid' - asset_grid;

mtest = asset_space < params.means_test;
% this is the mass of people that don't have to pay

mtest_move = m_seasn.*(~mtest)';
% This is the ``means tested moving cost'' so you only get it if you are
% poor enough. This shows up in the consumption set below, then this is the
% moving cost

for zzz = 1:n_shocks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    consumption = net_assets + labor_income_tax(z_rural.*shocks_rural(zzz), params.tax, 'rural') - abar;
    
    feasible_rural = consumption > 0;
    
    utility_rural(:,:,zzz) = A.*(max(consumption,1e-8)).^(1-gamma);
    
    utility_rural(:,:,zzz) = utility_rural(:,:,zzz) + -1e10.*(~feasible_rural);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    consumption = net_assets + labor_income_tax(z_rural.*shocks_rural(zzz), params.tax, 'rural') - mtest_move - abar;
    
    feasible_move_seasn = consumption > 0;
    
    utility_move_seasn(:,:,zzz) = A.*(max(consumption,1e-8)).^(1-gamma);
    
    utility_move_seasn(:,:,zzz)= utility_move_seasn(:,:,zzz) + -1e10.*(~feasible_move_seasn);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    consumption = net_assets + labor_income_tax(z_urban.*shocks_urban(zzz), params.tax, 'urban') - abar;
    
    feasible_urban = consumption >  0;
    
    utility_urban(:,:,zzz) = A.*(max(consumption,1e-8)).^(1-gamma);
    
    utility_urban(:,:,zzz) = utility_urban(:,:,zzz) + -1e10.*(~feasible_urban); 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    consumption = net_assets + labor_income_tax(z_rural.*shocks_rural(zzz), params.tax, 'rural') - m - abar;
    
    feasible_move_rural = consumption > 0;
    
    utility_move_rural(:,:,zzz) = A.*(max(consumption,1e-8)).^(1-gamma) ;
    
    utility_move_rural(:,:,zzz) = utility_move_rural(:,:,zzz) + -1e10.*(~feasible_move_rural); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    consumption = net_assets + labor_income_tax(z_urban.*shocks_urban(zzz), params.tax, 'urban') - m - abar;
    
    feasible_move_urban = consumption > 0;
    
    utility_move_urban(:,:,zzz) = A.*(max(consumption,1e-8)).^(1-gamma);
    
    utility_move_urban(:,:,zzz) = utility_move_urban(:,:,zzz) + -1e10.*(~feasible_move_urban);
    
    % Note the way the last two are setup. If you decide to move, your
    % still reciving the shocks associated with that location, it is only
    % untill next period that things switch. 
         
end

    
v_old_rural_not = 0*ones(size(v_prime_rural_not));
v_old_rural_exp = v_old_rural_not;

v_old_seasn_not = v_old_rural_not;
v_old_seasn_exp = v_old_rural_not;

v_old_urban_new = v_old_rural_not;
v_old_urban_old = v_old_rural_not;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Commence value function itteration.
% tic 
for iter = 1:n_iterations
    
    v_hat_rural_not = v_old_rural_not;
    v_hat_rural_exp = v_old_rural_exp;
    
    v_hat_seasn_not = v_old_seasn_not;
    v_hat_seasn_exp = v_old_seasn_exp;
    
    v_hat_urban_new = v_old_urban_new;
    v_hat_urban_old = v_old_urban_old;
    
    for zzz = 1:n_shocks   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the most time consuming part of the code....note I originally was
% generating a big matrix of expected values, but this is the commented out
% of the code, added it to the utility matrix, then took max. Now, I just
% create the expected value and then use the bsxfun function to add the
% utility matrix and the expected value. 
       
    expected_value_rural_not = beta.*(trans_mat(zzz,:)*v_hat_rural_not');
    
    expected_value_rural_exp = beta.*(trans_mat(zzz,:)*v_hat_rural_exp');
        
    expected_value_urban_new = beta.*(trans_mat(zzz,:)*v_hat_urban_new');
    
    expected_value_urban_old = beta.*(trans_mat(zzz,:)*v_hat_urban_old');
    
    expected_value_seasn_not = beta.*(trans_mat(zzz,:)*v_hat_seasn_not');
    
    expected_value_seasn_exp = beta.*(trans_mat(zzz,:)*v_hat_seasn_exp');
    
    % This says the expected value of unemployment reflects either getting
    % a job or staying unemployed. 
        
    % This is standard part, but just to remember...
    % Compute expected discounted value. The value function matrix is set up so
    % each row is an asset holding; each coloumn is a state for the shocks. So 
    % by multiplying the matrix, by the vector of the transition matrix given 
    % the state we are in, this should create the expected value that each level of
    % asset holdings will generate. 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of being in the rural area...

    value_fun = bsxfun(@plus,utility_rural(:,:,zzz),expected_value_rural_not);
    
    %[v_stay_rural_not, p_asset_stay_rural_not] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.rural_not(:,zzz,1));
    
    v_stay_rural_not = value_fun(idx);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of being being a seasonal migrant...

    value_fun = bsxfun(@plus,utility_move_seasn(:,:,zzz),expected_value_seasn_not);
    
    %[v_move_seasn_not, p_asset_move_seasn_not] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.rural_not(:,zzz,2));
    
    v_move_seasn_not = value_fun(idx);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of a seasonal migrant...once in the ubran area...
% Note the TRANSITION to being experinced...
     
    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz).*ubar) ,...
        (lambda.*expected_value_rural_not + (1-lambda).*expected_value_rural_exp));
    
    %[v_seasn_not, policy_assets_seasn_not(:,zzz)] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.seasn_not(:,zzz));
    
    v_seasn_not = value_fun(idx);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a new guy.

    value_fun = bsxfun(@plus, utility_move_rural(:,:,zzz) , expected_value_urban_new);

    %[v_move_rural_not, p_asset_move_rural_not] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.rural_not(:,zzz,3));
    
    v_move_rural_not = value_fun(idx);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of being in the rural area...the next line reflects the
% probability that experince disappears...

    value_fun = bsxfun(@plus, utility_rural(:,:,zzz),...
        pi_prob.*expected_value_rural_exp + (1-pi_prob).*expected_value_rural_not);

    
    %[v_stay_rural_exp,  p_asset_stay_rural_exp] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.rural_exp(:,zzz,1));
    
    v_stay_rural_exp = value_fun(idx);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of being being a seasonal migrant...the next line reflects the
% probability that experince disappears...
    
    value_fun = bsxfun(@plus, utility_move_seasn(:,:,zzz),...
        pi_prob.*expected_value_seasn_exp + (1-pi_prob).*expected_value_seasn_not);

    %[v_move_seasn_exp, p_asset_move_seasn_exp] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.rural_exp(:,zzz,2));
    
    v_move_seasn_exp = value_fun(idx);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of a seasonal migrant...once in the ubran area...
% Note one remains being experinced... NO UBAR...AND REMAIN EXPERINCED

    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz)) , expected_value_rural_exp);

    %[v_seasn_exp, policy_assets_seasn_exp(:,zzz)] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.seasn_exp(:,zzz));
    
    v_seasn_exp = value_fun(idx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a OLD
% GUY...because I have EXPERIENCE

    value_fun = bsxfun(@plus, utility_move_rural(:,:,zzz) , ...
        pi_prob.*expected_value_urban_old + (1-pi_prob).*expected_value_urban_new);
   
    %[v_move_rural_exp, p_asset_move_rural_exp] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.rural_exp(:,zzz,3));
    
    v_move_rural_exp = value_fun(idx);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               URBAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of an recent urban resident staying in the uban area. Note how
% the ubar is preseant.  

    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz).*ubar) , ...
        (lambda.*expected_value_urban_new + (1-lambda).*expected_value_urban_old) );

        
    %[v_stay_urban_new, p_asset_stay_urban_new] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.urban_new(:,zzz,1));
    
    v_stay_urban_new = value_fun(idx);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of an ''old'' urban resident staying in the uban area. Note how
% the ubar is not preseant. 

    value_fun = bsxfun(@plus,utility_urban(:,:,zzz) , expected_value_urban_old );

    %[v_stay_urban_old, p_asset_stay_urban_old] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.urban_old(:,zzz,1));
    
    v_stay_urban_old = value_fun(idx);
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Again, here I get the expected value of being in the rural area, becuase
% I'm moving out of urban area. 

    value_fun = bsxfun(@plus,utility_move_urban(:,:,zzz), expected_value_rural_exp);
 
    %[v_move_urban_old, p_asset_move_urban_old] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.urban_old(:,zzz,2));
    
    v_move_urban_old = value_fun(idx);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    value_fun = bsxfun(@plus,utility_move_urban(:,:,zzz).*ubar, expected_value_rural_not);
           
    %[v_move_urban_new, p_asset_move_urban_new] = max(value_fun,[],2);
    
    idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.urban_new(:,zzz,2));
    
    v_move_urban_new = value_fun(idx);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute value functions...
     
    pitest = [move.rural_not(:,zzz,1), squeeze( diff(move.rural_not(:,zzz,:),1,3))];
    
    v_prime_rural_not(:,zzz) = sum(pitest.*(sigma_nu_not.*log(1./max(pitest, 10^-25))  + [v_stay_rural_not, v_move_seasn_not, v_move_rural_not]),2);
    % Note need to compute it this way...if fixes the migration
    % probabilities and then computes EV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    pitest = [move.rural_exp(:,zzz,1), squeeze( diff(move.rural_exp(:,zzz,:),1,3))];
    
    v_prime_rural_exp(:,zzz) = sum(pitest.*(sigma_nu_not.*log(1./max(pitest, 10^-25))  + [v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp]),2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pitest = [move.urban_new(:,zzz,1), squeeze(diff(move.urban_new(:,zzz,:),1,3))];
    
    v_prime_urban_new(:,zzz) = sum(pitest.*(sigma_nu_not.*log(1./max(pitest, 10^-25))  + [v_stay_urban_new, v_move_urban_new]),2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pitest = [move.urban_old(:,zzz,1), squeeze( diff(move.urban_old(:,zzz,:),1,3))];
    
    v_prime_urban_old(:,zzz) = sum(pitest.*(sigma_nu_not.*log(1./max(pitest, 10^-25))  + [v_stay_urban_old, v_move_urban_old]),2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v_hat_rural_not(:,zzz) = v_prime_rural_not(:,zzz); 
    
    v_hat_rural_exp(:,zzz) = v_prime_rural_exp(:,zzz); 
    
    v_hat_urban_new(:,zzz) = v_prime_urban_new(:,zzz); 
        
    v_hat_urban_old(:,zzz) = v_prime_urban_old(:,zzz); 
    
    v_hat_seasn_not(:,zzz) = v_seasn_not;
    
    v_hat_seasn_exp(:,zzz) = v_seasn_exp;

    end
    
    rural_not = norm(v_old_rural_not-v_prime_rural_not,Inf);
    rural_exp = norm(v_old_rural_exp-v_prime_rural_exp,Inf);
    urban_new = norm(v_old_urban_new-v_prime_urban_new,Inf);
    urban_old = norm(v_old_urban_old-v_prime_urban_old,Inf);
    
    mxtol = max([rural_not, rural_exp, urban_new, urban_old]);
    
    if mxtol < tol
%         disp('value function converged')
%         disp(toc)
%         disp(iter)
        break
    else
        
    v_old_rural_not = v_prime_rural_not;
    
    v_old_rural_exp = v_prime_rural_exp;
    
    v_old_urban_old = v_prime_urban_old;
    
    v_old_urban_new = v_prime_urban_new;
    
    v_old_seasn_not = v_hat_seasn_not;
    
    v_old_seasn_exp = v_hat_seasn_exp;

    
    end
 
end


if mxtol > tol
    disp('value function did not converge')
end

vfinal.rural_not = v_prime_rural_not;
vfinal.rural_exp = v_prime_rural_exp;
vfinal.seasn_not = v_hat_seasn_not;
vfinal.seasn_exp = v_hat_seasn_exp;
vfinal.urban_new = v_prime_urban_new;
vfinal.urban_old = v_prime_urban_old;


if isempty(vcft) 
    
    cons_eqiv.rural_not = 0.*vfinal.rural_not;
    cons_eqiv.rural_exp = 0.*vfinal.rural_exp;

    cons_eqiv.seasn_not = 0.*vfinal.rural_not;
    cons_eqiv.seasn_exp = 0.*vfinal.rural_exp;

    cons_eqiv.urban_new = 0.*vfinal.urban_new;
    cons_eqiv.urban_old = 0.*vfinal.urban_old;
    
else
    % This computes the welfare gain associated with the counter factual
    % value functions, vcft...
    cons_eqiv.rural_not = ((vfinal.rural_not./vcft.rural_not)).^(1./(1-gamma)) - 1;
    cons_eqiv.rural_exp = ((vfinal.rural_exp./vcft.rural_exp)).^(1./(1-gamma)) - 1;

    cons_eqiv.seasn_not = ((vfinal.rural_not./vcft.rural_not)).^(1./(1-gamma)) - 1;
    cons_eqiv.seasn_exp = ((vfinal.rural_exp./vcft.rural_exp)).^(1./(1-gamma)) - 1;

    cons_eqiv.urban_new = ((vfinal.urban_new./vcft.urban_new)).^(1./(1-gamma)) - 1;
    cons_eqiv.urban_old = ((vfinal.urban_old./vcft.urban_old)).^(1./(1-gamma)) - 1;

end


end

