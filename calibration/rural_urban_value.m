function [assets, move, vfinal, cons_eqiv] = rural_urban_value(params,perm_types,vcft)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This solves for value and policy function for the rural-urban location problem
% described in the Paper

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
tol = 10^-4; 
%It's loose here...tighten for welfare, but does not seem matter for
%quantities

n_shocks = params.n_shocks;

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

policy_assets_rural_not = zeros(n_asset_states,n_shocks,n_rural_options,'uint8');
policy_assets_rural_exp = zeros(n_asset_states,n_shocks,n_rural_options,'uint8');

policy_assets_urban_new = zeros(n_asset_states,n_shocks,n_urban_options,'uint8');
policy_assets_urban_old = zeros(n_asset_states,n_shocks,n_urban_options,'uint8');

policy_assets_seasn_not = zeros(n_asset_states,n_shocks,'uint8');
policy_assets_seasn_exp = zeros(n_asset_states,n_shocks,'uint8');

policy_move_rural_not = zeros(n_asset_states,n_shocks,n_rural_options,'double');
policy_move_rural_exp = zeros(n_asset_states,n_shocks,n_rural_options,'double');

policy_move_urban_new = zeros(n_asset_states,n_shocks,n_urban_options,'double');
policy_move_urban_old = zeros(n_asset_states,n_shocks,n_urban_options,'double');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preallocate stuff that stays fixed (specifically potential period utility and
% net assets in the maximization routine....

utility_rural = zeros(n_asset_states,n_asset_states,n_shocks);
utility_urban = zeros(n_asset_states,n_asset_states,n_shocks);

utility_move_rural = zeros(n_asset_states,n_asset_states,n_shocks);
utility_move_urban = zeros(n_asset_states,n_asset_states,n_shocks);
utility_move_seasn = zeros(n_asset_states,n_asset_states,n_shocks);

% feasible_rural = false(n_asset_states,n_asset_states,n_shocks);
% feasible_urban = false(n_asset_states,n_asset_states,n_shocks);
% 
% feasible_move_rural = false(n_asset_states,n_asset_states,n_shocks);
% feasible_move_urban = false(n_asset_states,n_asset_states,n_shocks);
% feasible_move_seasn = false(n_asset_states,n_asset_states,n_shocks);

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

    
v_old_rural_not = -1.0.*ones(size(v_prime_rural_not))/(1-beta);
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
    
    
    [v_stay_rural_not, ~] = max(value_fun,[],2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of being being a seasonal migrant...

    value_fun = bsxfun(@plus,utility_move_seasn(:,:,zzz),expected_value_seasn_not);
    
    
    [v_move_seasn_not, ~] = max(value_fun,[],2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of a seasonal migrant...once in the ubran area...
% Note the TRANSITION to being experinced...
     
    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz).*ubar) ,...
        (lambda.*expected_value_rural_not + (1-lambda).*expected_value_rural_exp));
  
    
    [v_seasn_not, ~] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a new guy.

    value_fun = bsxfun(@plus, utility_move_rural(:,:,zzz) , expected_value_urban_new);
    
       
    [v_move_rural_not, ~] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of being in the rural area...the next line reflects the
% probability that experince disappears...

    value_fun = bsxfun(@plus, utility_rural(:,:,zzz),...
        pi_prob.*expected_value_rural_exp + (1-pi_prob).*expected_value_rural_not);
    

    [v_stay_rural_exp, ~] = max(value_fun,[],2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of being being a seasonal migrant...the next line reflects the
% probability that experince disappears...
    
    value_fun = bsxfun(@plus, utility_move_seasn(:,:,zzz),...
        pi_prob.*expected_value_seasn_exp + (1-pi_prob).*expected_value_seasn_not);
    
    [v_move_seasn_exp, ~] = max(value_fun,[],2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of a seasonal migrant...once in the ubran area...
% Note one remains being experinced... NO UBAR...AND REMAIN EXPERINCED

    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz)) , expected_value_rural_exp);

    
    [v_seasn_exp, ~] = max(value_fun,[],2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a OLD
% GUY...because I have EXPERIENCE


    value_fun = bsxfun(@plus, utility_move_rural(:,:,zzz) , ...
        pi_prob.*expected_value_urban_old + (1-pi_prob).*expected_value_urban_new);

       
    [v_move_rural_exp, ~] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               URBAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of an recent urban resident staying in the uban area. Note how
% the ubar is preseant.  

    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz).*ubar) , ...
        (lambda.*expected_value_urban_new + (1-lambda).*expected_value_urban_old) );
        
    [v_stay_urban_new, ~] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of an ''old'' urban resident staying in the uban area. Note how
% the ubar is not preseant. 

    value_fun = bsxfun(@plus,utility_urban(:,:,zzz) , expected_value_urban_old );
        
    [v_stay_urban_old, ~] = max(value_fun,[],2);
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Again, here I get the expected value of being in the rural area, becuase
% I'm moving out of urban area. 

    value_fun = bsxfun(@plus,utility_move_urban(:,:,zzz), expected_value_rural_exp);
  
    [v_move_urban_old, ~] = max(value_fun,[],2);
    
    value_fun = bsxfun(@plus,utility_move_urban(:,:,zzz).*ubar, expected_value_rural_not);
           
    [v_move_urban_new, ~] = max(value_fun,[],2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute value functions... 
    % Here is the deal with the logit shocks. First, comput the
    % exp(v/sigma) for each choice
    
    %pi_rural_not = exp([v_stay_rural_not, v_move_seasn_not, v_move_rural_not]./sigma_nu_not);
    
    vfoo = max([v_stay_rural_not, v_move_seasn_not, v_move_rural_not],[],2);
    
    pi_rural_not = exp(([v_stay_rural_not, v_move_seasn_not, v_move_rural_not] - vfoo)./sigma_nu_not);
    
    % Then you compute the sum across this.
    
    pi_denom_rural_not = sum(pi_rural_not,2).*exp(vfoo./sigma_nu_not);
    
    % Here is the deal. The expected value function, is sigma*log( sum
    % exp(v/sigma)). Why? This is the expected value over the best option
    % and with the logit shocks it takes a simple form.
    
    v_prime_rural_not(:,zzz) = sigma_nu_not.*log(pi_denom_rural_not);
    
    %Sometimes there is an issue here the value above is not well
    %defined...then the seleciton is just on the best. IT handles
    %situations where the best might not be feasible. 
    
%     problem = isinf(v_prime_rural_not(:,zzz)); 
%     if sum(problem) > 0
%         %disp('yes')
%     v_prime_rural_not(problem,zzz) = max([ v_stay_rural_not(problem) , v_move_seasn_not(problem) , v_move_rural_not(problem)],[],2) ;
%     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See discussion above.
    
    vfoo = max([v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp], [], 2);
    
    pi_rural_exp = exp(([v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp] - vfoo)./sigma_nu_exp);
        
    pi_denom_rural_exp = sum(pi_rural_exp,2).*exp(vfoo./sigma_nu_not);
    
    v_prime_rural_exp(:,zzz) = sigma_nu_exp.*log(pi_denom_rural_exp);
    
%     problem = isinf(v_prime_rural_exp(:,zzz));
%     
%     if sum(problem) > 0        
%         %disp('yes')
%         v_prime_rural_exp(problem,zzz) = max([ v_stay_rural_exp(problem) , v_move_seasn_exp(problem) , v_move_rural_exp(problem)],[],2) ;
%     end     
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See discussion above.
    
    vfoo = max([v_stay_urban_new, v_move_urban_new], [], 2);
    
    pi_urban_new = exp(([v_stay_urban_new, v_move_urban_new] - vfoo)./sigma_nu_not);
   
    pi_denom_urban_new = sum(pi_urban_new,2).*exp(vfoo./sigma_nu_not);
    
    v_prime_urban_new(:,zzz) = sigma_nu_not.*log(pi_denom_urban_new);
    
%     problem = isinf(v_prime_urban_new(:,zzz));
%     
%     if sum(problem) > 0        
%         %disp('yes')
%       [v_prime_urban_new(problem,zzz), ~] = max([ v_stay_urban_new(problem) , v_move_urban_new(problem)],[],2) ;
%     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % See discussion above.
    
    vfoo = max([v_stay_urban_old, v_move_urban_old], [], 2);
    
    pi_urban_old = exp(([v_stay_urban_old, v_move_urban_old] - vfoo)./sigma_nu_exp);
       
    pi_denom_urban_old = sum(pi_urban_old, 2).*exp(vfoo./sigma_nu_exp);
    
    v_prime_urban_old(:,zzz) = sigma_nu_exp.*log(pi_denom_urban_old);
    
%     problem = isinf(v_prime_urban_old(:,zzz));
    
%     if sum(problem) > 0        
%         %disp('yes')
%       [v_prime_urban_old(problem,zzz), ~] = max([ v_stay_urban_old(problem) , v_move_urban_old(problem)],[],2) ;
%     end     
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % update the vaule function within the itteration. This is super
    % powerfull in speeding stuff up...
    
    v_hat_rural_not(:,zzz) = v_prime_rural_not(:,zzz); 
    
    v_hat_rural_exp(:,zzz) = v_prime_rural_exp(:,zzz); 
    
    v_hat_urban_new(:,zzz) = v_prime_urban_new(:,zzz); 
        
    v_hat_urban_old(:,zzz) = v_prime_urban_old(:,zzz); 
    
    v_hat_seasn_not(:,zzz) = v_seasn_not;
    
    v_hat_seasn_exp(:,zzz) = v_seasn_exp;
    
    end
    
    rural_not = norm(v_old_rural_not - v_prime_rural_not,Inf);
    
    rural_exp = norm(v_old_rural_exp - v_prime_rural_exp,Inf);
    
    urban_new = norm(v_old_urban_new - v_prime_urban_new,Inf);
    
    urban_old = norm(v_old_urban_old - v_prime_urban_old,Inf);
    
    if rural_not && ...
       rural_exp && ...     
       urban_new && ...
       urban_old < tol
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

if rural_not && ...
       rural_exp  && ...     
       urban_new && ...
       urban_old > tol
    disp('value function did not converge')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    v_hat_rural_not = v_old_rural_not;
    v_hat_rural_exp = v_old_rural_exp;
    
    v_hat_seasn_not = v_old_seasn_not;
    v_hat_seasn_exp = v_old_seasn_exp;
    
    v_hat_urban_new = v_old_urban_new;
    v_hat_urban_old = v_old_urban_old;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% At this point the value function is done. Now we just need to recover the
% policy funcitons. This is seperated b.c. 

for zzz = 1:n_shocks   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    expected_value_rural_not = beta.*(trans_mat(zzz,:)*v_hat_rural_not');
    
    expected_value_rural_exp = beta.*(trans_mat(zzz,:)*v_hat_rural_exp');
        
    expected_value_urban_new = beta.*(trans_mat(zzz,:)*v_hat_urban_new');
    
    expected_value_urban_old = beta.*(trans_mat(zzz,:)*v_hat_urban_old');
    
    expected_value_seasn_not = beta.*(trans_mat(zzz,:)*v_hat_seasn_not');
    
    expected_value_seasn_exp = beta.*(trans_mat(zzz,:)*v_hat_seasn_exp');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of being in the rural area...

    value_fun = bsxfun(@plus,utility_rural(:,:,zzz),expected_value_rural_not);
    
    [v_stay_rural_not, p_asset_stay_rural_not] = max(value_fun,[],2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of being being a seasonal migrant...

    value_fun = bsxfun(@plus,utility_move_seasn(:,:,zzz),expected_value_seasn_not);
    
    [v_move_seasn_not, p_asset_move_seasn_not] = max(value_fun,[],2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of a seasonal migrant...once in the ubran area...
% Note the TRANSITION to being experinced...
     
    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz).*ubar) ,...
        (lambda.*expected_value_rural_not + (1-lambda).*expected_value_rural_exp));
    
    [~, policy_assets_seasn_not(:,zzz)] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a new guy.

    value_fun = bsxfun(@plus, utility_move_rural(:,:,zzz) , expected_value_urban_new);

       
    [v_move_rural_not, p_asset_move_rural_not] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of being in the rural area...the next line reflects the
% probability that experince disappears...

    value_fun = bsxfun(@plus, utility_rural(:,:,zzz),...
        pi_prob.*expected_value_rural_exp + (1-pi_prob).*expected_value_rural_not);

    
    [v_stay_rural_exp,  p_asset_stay_rural_exp] = max(value_fun,[],2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of being being a seasonal migrant...the next line reflects the
% probability that experince disappears...
    
    value_fun = bsxfun(@plus, utility_move_seasn(:,:,zzz),...
        pi_prob.*expected_value_seasn_exp + (1-pi_prob).*expected_value_seasn_not);

    
    [v_move_seasn_exp, p_asset_move_seasn_exp] = max(value_fun,[],2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of a seasonal migrant...once in the ubran area...
% Note one remains being experinced... NO UBAR...AND REMAIN EXPERINCED

    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz)) , expected_value_rural_exp);

    
    [~, policy_assets_seasn_exp(:,zzz)] = max(value_fun,[],2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a OLD
% GUY...because I have EXPERIENCE

% SETTING THIS TO CHECK IF COLLAPSES

    value_fun = bsxfun(@plus, utility_move_rural(:,:,zzz) , ...
        pi_prob.*expected_value_urban_old + (1-pi_prob).*expected_value_urban_new);

       
    [v_move_rural_exp, p_asset_move_rural_exp] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               URBAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of an recent urban resident staying in the uban area. Note how
% the ubar is preseant.  

    value_fun = bsxfun(@plus, (utility_urban(:,:,zzz).*ubar) , ...
        (lambda.*expected_value_urban_new + (1-lambda).*expected_value_urban_old) );

        
    [v_stay_urban_new, p_asset_stay_urban_new] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of an ''old'' urban resident staying in the uban area. Note how
% the ubar is not preseant. 

    value_fun = bsxfun(@plus,utility_urban(:,:,zzz) , expected_value_urban_old );

        
    [v_stay_urban_old, p_asset_stay_urban_old] = max(value_fun,[],2);
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Again, here I get the expected value of being in the rural area, becuase
% I'm moving out of urban area. 

    value_fun = bsxfun(@plus,utility_move_urban(:,:,zzz), expected_value_rural_exp);

    [v_move_urban_old, p_asset_move_urban_old] = max(value_fun,[],2);
    
    value_fun = bsxfun(@plus,utility_move_urban(:,:,zzz).*ubar, expected_value_rural_not);
           
    [v_move_urban_new, p_asset_move_urban_new] = max(value_fun,[],2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    policy_assets_rural_not(:,zzz,:) = [ p_asset_stay_rural_not , p_asset_move_seasn_not , p_asset_move_rural_not ];
    
    policy_assets_rural_exp(:,zzz,:) = [ p_asset_stay_rural_exp , p_asset_move_seasn_exp , p_asset_move_rural_exp ];
    
    policy_assets_urban_new(:,zzz,:) = [ p_asset_stay_urban_new , p_asset_move_urban_new ];
    
    policy_assets_urban_old(:,zzz,:)  = [ p_asset_stay_urban_old , p_asset_move_urban_old ];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute value functions...
    
    vfoo = max([v_stay_rural_not, v_move_seasn_not, v_move_rural_not],[],2);
    
    pi_rural_not = exp(([v_stay_rural_not, v_move_seasn_not, v_move_rural_not] - vfoo)./sigma_nu_not);
    
    % Then you compute the sum across this.
    
    pi_denom_rural_not = sum(pi_rural_not,2);
    
    v_prime_rural_not(:,zzz) = sigma_nu_not.*log(pi_denom_rural_not.*exp(vfoo./sigma_nu_not));
    
    policy_move_rural_not(:,zzz,:) = cumsum(pi_rural_not./pi_denom_rural_not,2);
    
    policy_move_rural_not(:,zzz,:) = cumsum(pi_rural_not./pi_denom_rural_not,2);
    
%     pi_rural_not = exp([v_stay_rural_not, v_move_seasn_not, v_move_rural_not]./sigma_nu_not);
%         
%     pi_denom_rural_not = sum(pi_rural_not,2);
%     
%     v_prime_rural_not(:,zzz) = sigma_nu_not.*log(pi_denom_rural_not);
%     
%     problem = isinf(v_prime_rural_not(:,zzz));
%     
%     if sum(problem) > 0
%         %disp('yes')
%         [v_prime_rural_not(problem,zzz), policy] = max([ v_stay_rural_not(problem) , v_move_seasn_not(problem) , v_move_rural_not(problem)],[],2) ;
%     
%       pi_rural_not(problem,policy) = 1;
%      
%       pi_denom_rural_not = sum(pi_rural_not,2);
%     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    vfoo = max([v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp], [], 2);
    
    pi_rural_exp = exp(([v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp] - vfoo)./sigma_nu_exp);
        
    pi_denom_rural_exp = sum(pi_rural_exp,2);
    
    v_prime_rural_exp(:,zzz) = sigma_nu_exp.*log(pi_denom_rural_exp.*exp(vfoo./sigma_nu_not));
    
    policy_move_rural_exp(:,zzz,:)  = cumsum(pi_rural_exp./pi_denom_rural_exp,2);
                  
%     pi_rural_exp = exp([v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp]./sigma_nu_exp);
%         
%     pi_denom_rural_exp = sum(pi_rural_exp,2);
%     
%     v_prime_rural_exp(:,zzz) = sigma_nu_exp.*log(pi_denom_rural_exp);
%     
%     problem = isinf(v_prime_rural_exp(:,zzz));
%     
%     if sum(problem) > 0        
%         %disp('yes')
%       [v_prime_rural_exp(problem,zzz), policy] = max([ v_stay_rural_exp(problem) , v_move_seasn_exp(problem) , v_move_rural_exp(problem)],[],2) ;
%     
%       pi_rural_exp(problem,policy) = 1;
%      
%       pi_denom_rural_exp = sum(pi_rural_exp,2);
%     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    vfoo = max([v_stay_urban_new, v_move_urban_new], [], 2);
    
    pi_urban_new = exp(([v_stay_urban_new, v_move_urban_new] - vfoo)./sigma_nu_not);
   
    pi_denom_urban_new = sum(pi_urban_new,2);
    
    v_prime_urban_new(:,zzz) = sigma_nu_not.*log(pi_denom_urban_new.*exp(vfoo./sigma_nu_not));
    
    policy_move_urban_new(:,zzz,:) = cumsum(pi_urban_new./pi_denom_urban_new,2);
    
%     pi_urban_new = exp([v_stay_urban_new, v_move_urban_new]./sigma_nu_not);
%    
%     pi_denom_urban_new = sum(pi_urban_new,2);
%     
%     policy_move_urban_new(:,zzz,:) = cumsum(pi_urban_new./pi_denom_urban_new,2);
%     
%     v_prime_urban_new(:,zzz) = sigma_nu_not.*log(pi_denom_urban_new);
%     
%     problem = isinf(v_prime_urban_new(:,zzz));
%     
%     if sum(problem) > 0        
%         %disp('yes')
%       [v_prime_urban_new(problem,zzz), policy] = max([ v_stay_urban_new(problem) , v_move_urban_new(problem)],[],2) ;
%     
%       pi_urban_new(problem,policy) = 1;
%      
%       pi_denom_urban_new = sum(pi_urban_new,2);
%     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    vfoo = max([v_stay_urban_old, v_move_urban_old], [], 2);
    
    pi_urban_old = exp(([v_stay_urban_old, v_move_urban_old] - vfoo)./sigma_nu_exp);
       
    pi_denom_urban_old = sum(pi_urban_old, 2);
    
    v_prime_urban_old(:,zzz) = sigma_nu_exp.*log(pi_denom_urban_old.*exp(vfoo./sigma_nu_exp));
    
    policy_move_urban_old(:,zzz,:) = cumsum(pi_urban_old./pi_denom_urban_old, 2);
    
%     pi_urban_old = exp([v_stay_urban_old, v_move_urban_old]./sigma_nu_exp);
%        
%     pi_denom_urban_old = sum(pi_urban_old,2);
%     
%     policy_move_urban_old(:,zzz,:) = cumsum(pi_urban_old./pi_denom_urban_old,2);
%     
%     v_prime_urban_old(:,zzz) = sigma_nu_exp.*log(pi_denom_urban_old);
%     
%     problem = isinf(v_prime_urban_old(:,zzz));
%     
%     if sum(problem) > 0        
%         %disp('yes')
%       [v_prime_urban_old(problem,zzz), policy] = max([ v_stay_urban_old(problem) , v_move_urban_old(problem)],[],2) ;
%     
%       pi_urban_old(problem,policy) = 1;
%      
%       pi_denom_urban_old = sum(pi_urban_old,2);
%     end
%     
%     policy_move_urban_old(:,zzz,:) = cumsum(pi_urban_old./pi_denom_urban_old,2);
        
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The general structure is asset state, shock state, then the move choice.
% So for example, assets.rural_not should be of size (grid, n_shocks, 3)
% with 3 being the number of moving options to the guy

assets.rural_not = policy_assets_rural_not;
assets.rural_exp = policy_assets_rural_exp;
assets.seasn_not = policy_assets_seasn_not;
assets.seasn_exp = policy_assets_seasn_exp;
assets.urban_new = policy_assets_urban_new;
assets.urban_old = policy_assets_urban_old;

move.rural_not = policy_move_rural_not;
move.rural_exp = policy_move_rural_exp;
move.urban_new = policy_move_urban_new;
move.urban_old = policy_move_urban_old;
% Important! The move policy function is interms of cummulative
% distribution, so need to convert to specific probabilities when plotting
% etc. 

% The value functions are expressed in expected terms, before the logit
% shock is revealed. So the size is (grid, n_shocks) so the option has been
% integrated out. 
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

