function [panel, states] = simulate_efficient(cons_policy, move_policy, ...
                    params, perm_types, trans_shocks, shock_states, pref_shock, moveshock, vfun, muc)%#codegen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This simmulates a time series/cross section of variables that we can map
% to data. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up grid for asset holdings. 

z_rural = perm_types(1); z_urban = perm_types(2); 
% These are the permanent shocks. 

m = params.m;
m_seasn = params.m_season;
lambda = params.lambda;
pi = params.pi_prob;
% These control unemployment risk. 

r_shocks = trans_shocks(:,1); 
u_shocks = trans_shocks(:,2);

expr_shock = pref_shock;

N_obs = params.N_obs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_series = length(shock_states);

shock_states = shock_states(1:end);

% The initial location state...
location = zeros(time_series+1,1); 
location(1) = 1;
% This will start the person in rural area, so 2 = urban, 1 = rural. This
% should not matter either. 

move = zeros(time_series,1);
move_seasn = zeros(time_series,1);
move_cost = zeros(time_series,1);

production = zeros(time_series,1);

consumption = zeros(time_series,1);

season = zeros(time_series,1);

welfare = zeros(time_series,1);
marg_utility = zeros(time_series,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here is the deal...I like the .indexing a lot which I got used ot in
% python and julia. This is slow in matlab especially with many function
% evaluations. 

move_policy_rural_not = move_policy.rural_not(:,:);
move_policy_rural_exp = move_policy.rural_exp(:,:);
move_policy_urban_new = move_policy.urban_new(:,:);
move_policy_urban_old = move_policy.urban_old(:,:);

muc_rural_not = muc.rural_not(:);
muc_rural_exp = muc.rural_exp(:);
muc_seasn_not = muc.seasn_not(:);
muc_seasn_exp = muc.seasn_exp(:);
muc_urban_new = muc.urban_new(:);
muc_urban_old = muc.urban_old(:); 

cons_policy_rural_not = cons_policy.rural_not(:);
cons_policy_rural_exp = cons_policy.rural_exp(:);
cons_policy_seasn_not = cons_policy.seasn_not(:);
cons_policy_seasn_exp = cons_policy.seasn_exp(:);
cons_policy_urban_new = cons_policy.urban_new(:);
cons_policy_urban_old = cons_policy.urban_old(:);

vfun_rural_not = vfun.rural_not(:);
vfun_rural_exp = vfun.rural_exp(:);
vfun_seasn_not = vfun.seasn_not(:);
vfun_seasn_exp = vfun.seasn_exp(:);
vfun_urban_new = vfun.urban_new(:);
vfun_urban_old = vfun.urban_old(:); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin simmulation...

%hard_rural_choice = cast([1,2,3],'uint8');
%hard_urban_choice = cast([1,2],'uint8');

for xxx = 1:time_series
    
    %logit_shock = moveshock(xxx); % this is the logit shock, each period.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Work through stuff conditional on a location....

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rural NO-EXPERIENCE

    if location(xxx) == 1 % rural area
        
        % first figure out where they are going
        %prob_options = cumsum(move_policy.rural_not(asset_state,shock_states(xxx),:));
        % this does a lot...so for the move policy, grab the matrix for
        % location rural, not experinced, then asset state, shock state.
        % this will return a 1 by 3 matrix with the choice probabilities.
        % Then we take cummulative sum. So the interpertation is
        % a cummulative probability distribution over the shocks.
        
        %choice = find(move_policy.rural_not(shock_states(xxx),:) > logit_shock,1);
        %p = move_policy_rural_not(shock_states(xxx),:);
        %test = 
        %choice = hard_rural_choice(move_policy_rural_not(shock_states(xxx),:) > moveshock(xxx));
        %choice = choice(1);
        
        choice = find(move_policy_rural_not(shock_states(xxx),:) > moveshock(xxx), 1);
        
        %choice = -(sum((move_policy_rural_not(asset_state,shock_states(xxx),:)) > logit_shock)-4);
        % given the logit shock above, we just find which choice this guy
        % will make. 
        
        move(xxx,1) = (choice == 3); % move if choice above is 3
        move_seasn(xxx,1) = (choice == 2); % seasonal move if choice above is 2.
                
        consumption(xxx,1) = cons_policy_rural_not(shock_states(xxx));
        
        production(xxx,1) = z_rural.*r_shocks(shock_states(xxx));
                
        welfare(xxx,1) = vfun_rural_not(shock_states(xxx));
        marg_utility(xxx,1) = muc_rural_not(shock_states(xxx));
        
        location(xxx+1) = location(xxx);
                    
        if move_seasn(xxx,1) == 1
            location(xxx+1) = 2;
            move_cost(xxx,1) = m_seasn;
        elseif move(xxx,1) == 1
            location(xxx+1) = 5;
            move_cost(xxx,1) = m;            
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these are the seasonal moves. 
        
    elseif location(xxx) == 2 % seasonal movers....
        
        welfare(xxx,1) = vfun_seasn_not(shock_states(xxx));
        marg_utility(xxx,1) = muc_seasn_not(shock_states(xxx));
        
        consumption(xxx,1) = cons_policy_seasn_not(shock_states(xxx));
        
        production(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
                
       if expr_shock(xxx) < (1-lambda)
            location(xxx+1,1) = 3; % get experince
       else 
            location(xxx+1,1) = 1; 
       end
               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RURAL EXPERIENCE

    elseif location(xxx) == 3
        
        %prob_options = cumsum((reshape(move_policy.rural_exp(asset_state,shock_states(xxx),:),1,3)));
        % this does a lot...so for the move policy, grab the matrix for
        % location rural, EXPERINCED, then asset state, shock state.
        % this will return a 1 by 3 matrix with the choice probabilities.
        % Then we  take cummulative sum. So the interpertation is
        % a cummulative probability distribution over the shocks.
        
        %choice = hard_rural_choice(move_policy_rural_exp(shock_states(xxx),:) > logit_shock);
        %choice = choice(1);
        
        choice = find(move_policy_rural_exp(shock_states(xxx),:) > moveshock(xxx),1);
               
        move(xxx,1) = (choice == 3); % move if choice above is 3
        move_seasn(xxx,1) = (choice == 2); % seasonal move if choice above is 2.
        
        welfare(xxx,1) = vfun_rural_exp(shock_states(xxx));
        marg_utility(xxx,1) = muc_rural_exp(shock_states(xxx));
        
        production(xxx,1) = z_rural.*r_shocks(shock_states(xxx));
        
        consumption(xxx,1) = cons_policy_rural_exp(shock_states(xxx));

        location(xxx+1) = location(xxx);
        
        if expr_shock(xxx) < (1-pi)
            
            location(xxx+1) = 1; % loose experince
            % then check if they are moving and adjust. 
            
            if move_seasn(xxx,1) == 1 
                location(xxx+1,1) = 2; %Non experinced season (you lost it)
                move_cost(xxx,1) = m_seasn;

            elseif move(xxx,1) == 1
                location(xxx+1) = 5; % non experinces perm moves (you lost it)
                move_cost(xxx,1) = m;
            end
        else 
            if move_seasn(xxx,1) == 1 
                location(xxx+1,1) = 4; % retain experince, season move
                move_cost(xxx,1) = m_seasn;
            elseif move(xxx,1) == 1
                location(xxx+1) = 6; % retain experince perm move.
                move_cost(xxx,1) = m;
            end
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Experinced Seaonsal movers...

    elseif location(xxx) == 4
        
        welfare(xxx,1) = vfun_seasn_exp(shock_states(xxx));
        marg_utility(xxx,1) = muc_seasn_exp(shock_states(xxx));
                
        production(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
        
        consumption(xxx,1) = cons_policy_seasn_exp(shock_states(xxx));
     
        location(xxx+1) = 3;
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% URBAN GUYS...

    elseif location(xxx) == 5
        
        %prob_options = cumsum((reshape(move_policy.urban_new(asset_state,shock_states(xxx),:),1,2)));
        % this does a lot...so for the move policy, grab the matrix for
        % location URBAN,No Experince, then asset state, shock state.
        % this will return a 1 by 2 matrix with the choice probabilities.
        % Then we take cummulative sum. So the interpertation is
        % a cummulative probability distribution over the shocks.
        
        %choice = hard_urban_choice(move_policy_urban_new(shock_states(xxx),:) > logit_shock);
        %choice = choice(1);
        
        choice = find(move_policy_urban_new(shock_states(xxx),:) > moveshock(xxx),1);

        move(xxx,1) = (choice == 2);
        % If choice equals 2, then move back.
        
        welfare(xxx,1) = vfun_urban_new(shock_states(xxx));
        marg_utility(xxx,1) = muc_urban_new(shock_states(xxx));
        
        production(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
        
        consumption(xxx,1) = cons_policy_urban_new(shock_states(xxx));

        location(xxx+1) = location(xxx);
        
        if move(xxx,1) == 1 
            location(xxx+1,1) = 1; % Return to being rural...
            move_cost(xxx,1) = m;
        elseif expr_shock(xxx) < (1-lambda)
            location(xxx+1,1) = 6; % Lose the aversion to urban area
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% URBAN Experince GUYS....

    elseif location(xxx) == 6
        
        %prob_options = cumsum((reshape(move_policy.urban_old(asset_state,shock_states(xxx),:),1,2)));
        % this does a lot...so for the move policy, grab the matrix for
        % location URBAN, Experince, then asset state, shock state.
        % this will return a 1 by 2 matrix with the choice probabilities.
        % Then we take cummulative sum. So the interpertation is
        % a cummulative probability distribution over the shocks.
        
        choice = find(move_policy_urban_old(shock_states(xxx),:) > moveshock(xxx),1);
        
        %choice = hard_urban_choice(move_policy_urban_old(shock_states(xxx),:) > logit_shock);
        %choice = choice(1);        
        
        move(xxx,1) = (choice == 2);
        % If choice equals 2, then move back.
        
        welfare(xxx,1) = vfun_urban_old(shock_states(xxx));
        marg_utility(xxx,1) = muc_urban_old(shock_states(xxx));
        
        production(xxx,1) = z_urban.*u_shocks(shock_states(xxx));
        
        consumption(xxx,1) = cons_policy_urban_old(shock_states(xxx));

        
        location(xxx+1) = location(xxx);
        
        if move(xxx,1) == 1 
            location(xxx+1,1) = 3; % Return to being rural...
            move_cost(xxx,1) = m;
        end      
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Record stuf to move to the next state!
        

end

season = mod(shock_states(:),2);   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Record the stuff....
% trans_shocks(shock_states,:); This is a way to see how transitory shocks
% matter. 
location = location(1:end-1,1);

% This is important. So this now generates assets
% held at date t (not chosen). So one can construce the budget constraint.

live_rural = location == 1 | location == 2 | location == 3 | location == 4;
work_urban = location == 2 | location == 4 | location == 5 | location == 6;
experince  = location == 3;

panel = [consumption, live_rural, work_urban, move, ...
    move_seasn, move_cost, season, welfare, experince, production, marg_utility];

states = [location, season, shock_states'];

panel = panel(time_series-(N_obs-1):end,:);
states = states(time_series-(N_obs-1):end,:);



