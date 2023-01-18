function [movepolicy, move] = efficient_chi(consumption, mplscale, params, perm_types)%#codegen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% used to construct moving policy and value functions for effecient
% allocation

sigma = params.sigma_nu_not;

beta = params.beta; m = params.m; gamma = params.pref_gamma; abar = params.abar;

ubar = params.ubar; lambda = params.lambda; pi_prob = params.pi_prob;

trans_mat = params.trans_mat;

m_seasn = params.m_season;

z_rural = perm_types(1);
z_urban = perm_types(2);

shocks_rural = params.trans_shocks(:,1);
shocks_urban = params.trans_shocks(:,2);

mpl.urban = z_urban.*shocks_urban;

mpl.rural = repmat([mplscale.raw.rural.notmonga ; mplscale.raw.rural.monga], params.n_shocks/2,1).*z_rural.*shocks_rural;
% the issue here is that the shocks already have physical tfp and monga in
% them. So we only need to adjust by the alphaN^{alpha - 1) bit. this is
% what mpl.raw is doing (computed from effecient aggregate).

rural_move_cost = [0, m_seasn, m];
urban_move_cost = [0, m];

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

kappa.rural_not = zeros(n_shocks,1);
kappa.rural_exp = zeros(n_shocks,1);
kappa.seasn_not = zeros(n_shocks,1);
kappa.seasn_exp = zeros(n_shocks,1);
kappa.urban_new = zeros(n_shocks,1);
kappa.urban_old = zeros(n_shocks,1); 

for zzz = 1:n_shocks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    utility.rural_not(zzz) = A.*(consumption.rural_not(zzz)).^(1-gamma);
    
    muc.rural_not(zzz) = (consumption.rural_not(zzz)).^(-gamma);

    kappa.rural_not(zzz) = ( mpl.rural(zzz) - consumption.rural_not(zzz));
    % note that this is not the full kappa in notes. only the part that can
    % be pre-computed, key one needs to subtract off the moving cost index.
    
    % IMPORTAN...the mpl part is not quite correct when alpha < 1 AND 
    % when rents are thrown away. Otherwise, alpha = 1 or rents
    % redistributed then this works.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    utility.rural_exp(zzz) = A.*(consumption.rural_exp(zzz)).^(1-gamma);
    
    muc.rural_exp(zzz) = (consumption.rural_exp(zzz)).^(-gamma);
                
    kappa.rural_exp(zzz) = ( mpl.rural(zzz) - consumption.rural_exp(zzz));
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    utility.seasn_not(zzz) = ubar.*A.*(consumption.seasn_not(zzz)).^(1-gamma);
    
    muc.seasn_not(zzz) = ubar.*(consumption.seasn_not(zzz)).^(-gamma);
    % ubar is here...
    
    kappa.seasn_not(zzz) = ( mpl.urban(zzz) - consumption.seasn_not(zzz));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    utility.seasn_exp(zzz) = A.*(consumption.seasn_exp(zzz)).^(1-gamma);
    
    muc.seasn_exp(zzz) = (consumption.seasn_exp(zzz)).^(-gamma);
    
    kappa.seasn_exp(zzz) = ( mpl.urban(zzz) - consumption.seasn_exp(zzz));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    utility.urban_new(zzz) = ubar.*A.*(consumption.urban_new(zzz)).^(1-gamma);
    
    muc.urban_new(zzz) = ubar.*(consumption.urban_new(zzz)).^(-gamma);
    % ubar is here...
    
    kappa.urban_new(zzz) = ( mpl.urban(zzz) - consumption.urban_new(zzz));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    utility.urban_old(zzz,1) = A.*(consumption.urban_old(zzz)).^(1-gamma);

    muc.urban_old(zzz) = (consumption.urban_old(zzz)).^(-gamma);
    
    kappa.urban_old(zzz) = ( mpl.urban(zzz) - consumption.urban_old(zzz));
    

end

chi_rural_not = -10.*(ones(n_shocks,1));
move.rural_not = (1./3).*(ones(n_shocks,3));

chi_rural_exp = chi_rural_not;
move.rural_exp = move.rural_not;

chi_seasn_not = chi_rural_not;
chi_seasn_exp = chi_rural_not;

chi_urban_new = chi_rural_not;
move.urban_new = (1./2).*(ones(n_shocks,2));

chi_urban_old = chi_rural_not;
move.urban_old = move.urban_new;

% old_chi_rural_not = zeros(n_shocks,1);
% old_chi_rural_exp = zeros(n_shocks,1);
% 
% old_chi_seasn_not = zeros(n_shocks,1);
% old_chi_seasn_exp = zeros(n_shocks,1);
%     
% old_chi_urban_new  = zeros(n_shocks,1);
% old_chi_urban_exp = zeros(n_shocks,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tic 
for iter = 1:n_iterations
    
    old_chi_rural_not = chi_rural_not;
    old_chi_rural_exp = chi_rural_exp;
    
    old_chi_seasn_not = chi_seasn_not;
    old_chi_seasn_exp = chi_seasn_exp;
    
    old_chi_urban_new = chi_urban_new;
    old_chi_urban_old = chi_urban_old;
    
    for zzz = 1:n_shocks   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the first step is to compute expected values and moving probabilities
    % for a given zzz shock...
    
    % This is for Rural Non-Experinced
                
    EV_chi_rural_not_stay = beta.*(trans_mat(zzz,:)*chi_rural_not);
    % chi_rural_not should be nshocks by 1. Then this is the value of chi,
    % for a guy in rural, staying. Note, the chi_rural_not integrates out
    % the value of the preference shock next period already.
    
    EV_chi_rural_not_seasn = beta.*(trans_mat(zzz,:)*chi_seasn_not);
    % same deal, but this is rural, going on a seasonal move.
    
    EV_chi_rural_not_urban = beta.*(trans_mat(zzz,:)*chi_urban_new);
    % same deal
    
    %these next steps then compute the moving probabilities
    
    mu_rural_not = exp( (-muc.rural_not(zzz).*rural_move_cost + [EV_chi_rural_not_stay, EV_chi_rural_not_seasn, EV_chi_rural_not_urban])./sigma);
        
    move.rural_not(zzz,:) = mu_rural_not ./ sum(mu_rural_not , 2); % these are the probabilities of moving...
    
    EV_chi_rural_not = sum(move.rural_not(zzz,:).*[EV_chi_rural_not_stay, EV_chi_rural_not_seasn, EV_chi_rural_not_urban] , 2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Seasonal Movers, non-experinced
    
    EV_chi_seasn_not_rural = beta.*(trans_mat(zzz,:)*chi_rural_not);
    
    EV_chi_seasn_exp_rural = beta.*(trans_mat(zzz,:)*chi_rural_exp);
    
    EV_chi_seasn_not = lambda.*EV_chi_seasn_not_rural + (1-lambda).*EV_chi_seasn_exp_rural;
    
    %note: no moving probabilities her bc you go to rural, only uncertainty
    % is over experince and productivity.

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is for Rural-Experinced
    
    EV_chi_rural_exp_stay = pi_prob.*beta.*(trans_mat(zzz,:)*chi_rural_exp) + (1-pi_prob).*beta.*(trans_mat(zzz,:)*chi_rural_not);
    % these guys may loose it, need to take this into account

    EV_chi_rural_exp_seasn = pi_prob.*beta.*(trans_mat(zzz,:)*chi_seasn_exp) + (1-pi_prob).*beta.*(trans_mat(zzz,:)*chi_seasn_not);
    
    EV_chi_rural_exp_urban = pi_prob.*beta.*(trans_mat(zzz,:)*chi_urban_old) + (1-pi_prob).*beta.*(trans_mat(zzz,:)*chi_urban_new);
   
    %these next steps then compute the moving probabilities
    
    mu_rural_exp = exp( (-muc.rural_exp(zzz).*rural_move_cost + [EV_chi_rural_exp_stay, EV_chi_rural_exp_seasn, EV_chi_rural_exp_urban])./sigma);
        
    move.rural_exp(zzz,:) = mu_rural_exp ./ sum(mu_rural_exp,2); 
    
    EV_chi_rural_exp = sum(move.rural_exp(zzz,:).*[EV_chi_rural_exp_stay, EV_chi_rural_exp_seasn, EV_chi_rural_exp_urban],2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Seasonal Movers, experinced
    
    EV_chi_seasn_exp = beta.*(trans_mat(zzz,:)*chi_rural_exp);
    
    % Here, no move probs bc you go straight to rural, but you with prob 1
    % retain experince
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is for Urban-Non-Experinced
    
    EV_chi_urban_new_stay = lambda.*beta.*(trans_mat(zzz,:)*chi_urban_new) + (1-lambda).*beta.*(trans_mat(zzz,:)*chi_urban_old);
    % if your new and stay, this is the prob that you transit to old

    EV_chi_urban_new_rural = beta.*(trans_mat(zzz,:)*chi_rural_not);
    
    %these next steps then compute the moving probabilities
    
    mu_urban_new = exp( (-muc.urban_new(zzz).*urban_move_cost + [EV_chi_urban_new_stay, EV_chi_urban_new_rural])./sigma);
        
    move.urban_new(zzz,:) = mu_urban_new ./ sum(mu_urban_new,2); 
    
    EV_chi_urban_new = sum(move.urban_new(zzz,:).*[EV_chi_urban_new_stay, EV_chi_urban_new_rural],2);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is for Urban-Experinced
    
    EV_chi_urban_old_stay = beta.*(trans_mat(zzz,:)*chi_urban_old);

    EV_chi_urban_old_rural = beta.*(trans_mat(zzz,:)*chi_rural_exp);

    %these next steps then compute the moving probabilities
    
    mu_urban_old = exp( (-muc.urban_old(zzz).*urban_move_cost + [EV_chi_urban_old_stay, EV_chi_urban_old_rural])./sigma);
        
    move.urban_old(zzz,:) = mu_urban_old ./ sum(mu_urban_old,2); 
    
    EV_chi_urban_old = sum(move.urban_old(zzz,:).*[EV_chi_urban_old_stay, EV_chi_urban_old_rural],2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now compute itteration step
    
    %                               NON-EXPERIENCED in rural
    % This is the period, social value of rural (j'), non-experinced guys (x =
    % 0), given some shock s. 

    Enu_rural_not = sum(move.rural_not(zzz,:).*(sigma.*log(1./max(move.rural_not(zzz,:), 10^-10))));
    % remember this is saying what is your expected value of prefrence
    % shock when in rural (from perspective of lookng forward
    
    social_value = ( utility.rural_not(zzz) +  Enu_rural_not ) ... 
                        +  muc.rural_not(zzz).*( kappa.rural_not(zzz) - sum(move.rural_not(zzz,:).*rural_move_cost,2) );
                    
                    % take utility + integrate over the preference shocks
                    % for those in rural area + (second line) value of their product net of
                    % consumption and moving costs evaluated at muc
                               
    chi_rural_not(zzz,1) = bsxfun(@plus, social_value, EV_chi_rural_not);
    % and so this will be a scalar for each zzz shock state

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                               NON-EXPERIENCED Seasonal movers

    % no Enu because everyone is going back to urban, same with the costs. This
    % is equivalent to costs being infinite everywhere but return to rural, so
    % prefrence shock is zero value, move cost index is zero

    social_value = ( utility.seasn_not(zzz) ) ... 
                        +  muc.seasn_not(zzz).*( kappa.seasn_not(zzz) );


    chi_seasn_not(zzz,1) = bsxfun(@plus, social_value , EV_chi_seasn_not );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                               NON-EXPERIENCED urban

    Enu_urban_new = sum(move.urban_new(zzz,:).*(sigma.*log(1./max(move.urban_new(zzz,:), 10^-10))));

    social_value = ( utility.urban_new(zzz) + Enu_urban_new ) ... 
                        +  muc.urban_new(zzz).*( kappa.urban_new(zzz) - sum(move.urban_new(zzz,:).*urban_move_cost,2) );

    chi_urban_new(zzz,1) = bsxfun(@plus, social_value , EV_chi_urban_new);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                               EXPERIENCED in rural
    
    Enu_rural_exp = sum(move.rural_exp(zzz,:).*(sigma.*log(1./max(move.rural_exp(zzz,:), 10^-10))));
    % remember this is saying what is your expected value of prefrence
    % shock when in rural (from perspective of lookng forward
    
    social_value = ( utility.rural_exp(zzz) +  Enu_rural_exp ) ... 
                        +  muc.rural_exp(zzz).*( kappa.rural_exp(zzz) - sum(move.rural_exp(zzz,:).*rural_move_cost,2) );
    
    chi_rural_exp(zzz,1) = bsxfun(@plus, social_value, EV_chi_rural_exp );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                               EXPERIENCED in seasonal
    
    % remember this is saying what is your expected value of prefrence
    % shock when in rural (from perspective of lookng forward
    
    social_value = ( utility.seasn_exp(zzz) ) ... 
                        +  muc.seasn_exp(zzz).*( kappa.seasn_exp(zzz) );
    
    
    chi_seasn_exp(zzz,1) = bsxfun(@plus, social_value, EV_chi_seasn_exp);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                               EXPERIENCED in urban
    
    % remember this is saying what is your expected value of prefrence
    % shock when in rural (from perspective of lookng forward
    
    Enu_urban_old = sum(move.urban_old(zzz,:).*(sigma.*log(1./max(move.urban_old(zzz,:), 10^-10))));
    
    social_value = ( utility.urban_old(zzz) + Enu_urban_old ) ... 
                        +  muc.urban_old(zzz).*( kappa.urban_old(zzz) - sum(move.urban_old(zzz,:).*urban_move_cost,2));
    
    chi_urban_old(zzz,1) = bsxfun(@plus, social_value, EV_chi_urban_old);
    
         
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end

    rural_not = norm(old_chi_rural_not - chi_rural_not,Inf);
    
    rural_exp = norm(old_chi_rural_exp - chi_rural_exp,Inf);
    
    urban_new = norm(old_chi_urban_new - chi_urban_new,Inf);
    
    urban_old = norm(old_chi_urban_old - chi_urban_old,Inf);
    
%    disp([rural_not,rural_exp,urban_new,urban_old])
%disp(iter)
%     
    if rural_not && ...
       rural_exp  && ...     
       urban_new && ...
       urban_old < tol
%         disp('value function converged')
%         disp(toc)
%         disp([chi_urban_old])
        break
    end
 
end

if iter == n_iterations
    disp('not converging')
end

movepolicy.rural_not = cumsum(move.rural_not,2);
movepolicy.rural_exp = cumsum(move.rural_exp,2);
movepolicy.urban_old = cumsum(move.urban_old,2);
movepolicy.urban_new = cumsum(move.urban_new,2);


end

