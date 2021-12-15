function [vfinal, muc, cons_eqiv] = efficient_valuefun(consumption, move, params, trans_mat, vcft)%#codegen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The idea of this is to take policy functions, and directly compute the
% value function. No Max. Setp 1 is to feed in optimal policy and get out
% known value function. Step 2 is it allows us to fix policy, but change
% enviorment

sigma_nu_exp = params.sigma_nu_exp;

sigma_nu_not = params.sigma_nu_not;

beta = params.beta; m = params.m; gamma = 2; abar = params.abar;

ubar = params.ubar; lambda = params.lambda; pi_prob = params.pi_prob;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_iterations = 5000;
tol = 10^-8;

n_shocks = params.n_shocks;

A = params.A;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the matricies for value function itteration. Note that there is a
% value associated with each state: (i) asset (ii) shock (iii) location. 
% The third one is the new one...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preallocate stuff that stays fixed (specifically potential period utility and
% net assets in the maximization routine....

utility.rural_not = zeros(n_shocks,1);
utility.rural_exp = zeros(n_shocks,1);
utility.seasn_not = zeros(n_shocks,1);
utility.seasn_exp = zeros(n_shocks,1);
utility.urban_new = zeros(n_shocks,1);
utility.urban_old = zeros(n_shocks,1);

muc.rural_not = zeros(n_shocks,1);
muc.rural_exp = zeros(n_shocks,1);
muc.seasn_not = zeros(n_shocks,1);
muc.seasn_exp = zeros(n_shocks,1);
muc.urban_new = zeros(n_shocks,1);
muc.urban_old = zeros(n_shocks,1); 


for zzz = 1:n_shocks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    utility.rural_not(zzz,1) = A.*(consumption.rural_not(zzz)).^(1-gamma);
    muc.rural_not(zzz,1) = (consumption.rural_not(zzz)).^(-gamma);
    
    utility.rural_exp(zzz,1) = A.*(consumption.rural_exp(zzz)).^(1-gamma);
    muc.rural_exp(zzz,1) = (consumption.rural_exp(zzz)).^(-gamma);
    
    utility.seasn_not(zzz,1) = ubar.*A.*(consumption.seasn_not(zzz)).^(1-gamma);
    
    muc.seasn_not(zzz,1) = ubar.*(consumption.seasn_not(zzz)).^(-gamma);
    % ubar is here...
    
    utility.seasn_exp(zzz,1) = A.*(consumption.seasn_exp(zzz)).^(1-gamma);
    muc.seasn_exp(zzz,1) = (consumption.seasn_exp(zzz)).^(-gamma);
    
    utility.urban_new(zzz,1) = ubar.*A.*(consumption.urban_new(zzz)).^(1-gamma);
    
    muc.urban_new(zzz,1) = ubar.*(consumption.urban_new(zzz)).^(-gamma);
    % ubar is here...
    
    utility.urban_old(zzz,1) = A.*(consumption.urban_old(zzz)).^(1-gamma);

    muc.urban_old(zzz,1) = (consumption.urban_old(zzz)).^(-gamma);
         
end

v_old_rural_not = (ones(n_shocks,1))./(1-beta);
v_old_rural_exp = v_old_rural_not;

v_old_seasn_not = v_old_rural_not;
v_old_seasn_exp = v_old_rural_not;

v_old_urban_new = v_old_rural_not;
v_old_urban_old = v_old_rural_not;

v_prime_rural_not = zeros(n_shocks,1);
    
v_prime_rural_exp = zeros(n_shocks,1);
v_prime_urban_new = zeros(n_shocks,1);
v_prime_urban_old = zeros(n_shocks,1);
    
v_seasn_not = zeros(n_shocks,1);
v_seasn_exp = zeros(n_shocks,1);
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
    % NOTE NEED TO BE CARFULL HERE...the value fun has a different rotation
    % without the assets...the expectation is thet the expected value is a
    % scalar..unlike normal vlue fun...we are not trnasposing the vhat
       
    expected_value_rural_not = beta.*(trans_mat(zzz,:)*v_hat_rural_not);
    
    expected_value_rural_exp = beta.*(trans_mat(zzz,:)*v_hat_rural_exp);
        
    expected_value_urban_new = beta.*(trans_mat(zzz,:)*v_hat_urban_new);
    
    expected_value_urban_old = beta.*(trans_mat(zzz,:)*v_hat_urban_old);
    
    expected_value_seasn_not = beta.*(trans_mat(zzz,:)*v_hat_seasn_not);
    
    expected_value_seasn_exp = beta.*(trans_mat(zzz,:)*v_hat_seasn_exp);
            
    % This is standard part, but just to remember...
    % Compute expected discounted value. The value function matrix is set up so
    % each row is an asset holding; each coloumn is a state for the shocks. So 
    % by multiplying the matrix, by the vector of the transition matrix given 
    % the state we are in, this should create the expected value that each level of
    % asset holdings will generate. 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of being in the rural area...

    v_stay_rural_not = bsxfun(@plus,utility.rural_not(zzz),expected_value_rural_not);
    

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of being being a seasonal migrant...

    v_move_seasn_not = bsxfun(@plus,utility.rural_not(zzz),expected_value_seasn_not);
    
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% This is the value of a seasonal migrant...once in the ubran area...
% Note the TRANSITION to being experinced...
     
    v_seasn_not(zzz,1) = bsxfun(@plus, utility.seasn_not(zzz) ,...
        (lambda.*expected_value_rural_not + (1-lambda).*expected_value_rural_exp));
    
%     %[v_seasn_not, policy_assets_seasn_not(:,zzz)] = max(value_fun,[],2);
%     
%     idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.seasn_not(:,zzz));
%     
%     v_seasn_not = value_fun(idx);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               NON-EXPERIENCED
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a new guy.

    v_move_rural_not = bsxfun(@plus, utility.rural_not(zzz) , expected_value_urban_new);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of being in the rural area...the next line reflects the
% probability that experince disappears...

    v_stay_rural_exp = bsxfun(@plus, utility.rural_exp(zzz),...
        pi_prob.*expected_value_rural_exp + (1-pi_prob).*expected_value_rural_not);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of being being a seasonal migrant...the next line reflects the
% probability that experince disappears...
    
    v_move_seasn_exp = bsxfun(@plus, utility.rural_exp(zzz),...
        pi_prob.*expected_value_seasn_exp + (1-pi_prob).*expected_value_seasn_not);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% This is the value of a seasonal migrant...once in the ubran area...
% Note one remains being experinced... NO UBAR...AND REMAIN EXPERINCED

    v_seasn_exp(zzz,1) = bsxfun(@plus, utility.seasn_exp(zzz) , expected_value_rural_exp);

%     %[v_seasn_exp, policy_assets_seasn_exp(:,zzz)] = max(value_fun,[],2);
%     
%     idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.seasn_exp(:,zzz));
%     
%     v_seasn_exp = value_fun(idx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPERIENCED
% Compute value of moving...here I get the expected value of being in the
% urban area because I'm moving out the rural area and I become a OLD
% GUY...because I have EXPERIENCE

    v_move_rural_exp = bsxfun(@plus, utility.rural_exp(zzz) , ...
        pi_prob.*expected_value_urban_old + (1-pi_prob).*expected_value_urban_new);
   
%     %[v_move_rural_exp, p_asset_move_rural_exp] = max(value_fun,[],2);
%     
%     idx = sub2ind(size(value_fun), (1:n_asset_states)', assets.rural_exp(:,zzz,3));
%     
%     v_move_rural_exp = value_fun(idx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               URBAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of an recent urban resident staying in the uban area. Note how
% the ubar is preseant.  

    v_stay_urban_new = bsxfun(@plus, utility.urban_new(zzz) , ...
        (lambda.*expected_value_urban_new + (1-lambda).*expected_value_urban_old) );

%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value of an ''old'' urban resident staying in the uban area. Note how
% the ubar is not preseant. 

    v_stay_urban_old = bsxfun(@plus, utility.urban_old(zzz) , expected_value_urban_old );


               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Again, here I get the expected value of being in the rural area, becuase
% I'm moving out of urban area. 

    v_move_urban_old = bsxfun(@plus,utility.urban_old(zzz), expected_value_rural_exp);
 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    v_move_urban_new = bsxfun(@plus, utility.urban_new(zzz), expected_value_rural_not);
           

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute value functions...
     
    pitest = [move.rural_not(zzz,1),  diff(move.rural_not(zzz,:),1,2)];
    
    v_prime_rural_not(zzz,1) = sum(pitest.*(sigma_nu_not.*log(1./max(pitest, 10^-10))  + [v_stay_rural_not, v_move_seasn_not, v_move_rural_not]),2);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    pitest = [move.rural_exp(zzz,1),  diff(move.rural_exp(zzz,:),1,2)];
    
    v_prime_rural_exp(zzz,1) = sum(pitest.*(sigma_nu_not.*log(1./max(pitest, 10^-10))  + [v_stay_rural_exp, v_move_seasn_exp, v_move_rural_exp]),2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pitest = [move.urban_new(zzz,1), diff(move.urban_new(zzz,:),1,2)];
    
    v_prime_urban_new(zzz,1) = sum(pitest.*(sigma_nu_not.*log(1./max(pitest, 10^-10))  + [v_stay_urban_new, v_move_urban_new]),2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    pitest = [move.urban_old(zzz,1), diff(move.urban_old(zzz,:),1,2)];
    
    v_prime_urban_old(zzz,1)= sum(pitest.*(sigma_nu_not.*log(1./max(pitest, 10^-10))  + [v_stay_urban_old, v_move_urban_old]),2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    v_hat_rural_not(zzz,1) = v_prime_rural_not(zzz,1); 
    
    v_hat_rural_exp(zzz,1) = v_prime_rural_exp(zzz,1); 
    
    v_hat_urban_new(zzz,1) = v_prime_urban_new(zzz,1); 
        
    v_hat_urban_old(zzz,1) = v_prime_urban_old(zzz,1); 
    
    v_hat_seasn_not(zzz,1) = v_seasn_not(zzz,1);
    
    v_hat_seasn_exp(zzz,1) = v_seasn_exp(zzz,1);
    

    end
    
    rural_not = norm(v_old_rural_not-v_prime_rural_not,Inf);
    rural_exp = norm(v_old_rural_exp-v_prime_rural_exp,Inf);
    urban_new = norm(v_old_urban_new-v_prime_urban_new,Inf);
    urban_old = norm(v_old_urban_old-v_prime_urban_old,Inf);
    
    if rural_not && ...
       rural_exp  && ...     
       urban_new && ...
       urban_old < tol
%         disp('value function converged')
%         disp(toc)
         %disp(iter)
        break
    else

    v_old_rural_not = v_hat_rural_not;
    
    v_old_rural_exp = v_hat_rural_exp;
    
    v_old_urban_old = v_hat_urban_old;
    
    v_old_urban_new = v_hat_urban_new;
    
    v_old_seasn_not = v_hat_seasn_not;
    
    v_old_seasn_exp = v_hat_seasn_exp;

    
    end
 
end


if rural_not && ...
       rural_exp  && ...     
       urban_new && ...
       urban_old > tol
%     disp('value function did not converge')
%     disp(urban_old)
end

vfinal.rural_not = v_hat_rural_not;
vfinal.rural_exp = v_hat_rural_exp;
vfinal.seasn_not = v_hat_seasn_not;
vfinal.seasn_exp = v_hat_seasn_exp;
vfinal.urban_new = v_hat_urban_new;
vfinal.urban_old =  v_hat_urban_old;


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

