
% DEPRECATED


%Standard Errors Calculation and Elasticity Matrix for LMW 2019 ECMA  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here is the code that generates the standard errors and the elasticity matrix. 
%
% Basic idea is take in the parmeters. We should have 9 parameters. The
% "compute_outcome_prefshock" file will pop out 11 moments. 
% We change the parameters by a small amount. 
% Record the change in the moments relative to the change in the parameters. 
%
% Then after that we can reorder the "table" as we want.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%% Elasticities for parameters with respect to Moments
% order of moments from compute_outcome.m is:
% cons_growth P_noassets mig_rate cons_gainols  mig_inc  mig_inc_y2 cons_gainlate wage_gap p_rural var_logwage 
% order of parameters: 
% order_table = [2,5,6,7,8,3,1,4,9]=[theta,ubar,lambda,pi_prob,gamma,A_u,sigma_s,rho,sigma_nu // sigma_rc, sigma_ui]
% order_moments: 
% 1- Wage gap
% 2- The rural share
% 3- The urban standard deviation... note that this is position number 3 (see below)
% 4- Fraction with no liquid assets
% 5- seasonal migration in control
% 6- increase in r1 (22 percent)
% 7- increase in r2 (9.2 percent)
% 8- LATE estiamte
% 9- OLS estimate
% 10- mig_cond_mig
% 11- Standard deviation of consumption growth. 
% Therefore, order_moments = [11, 4, 5, 9, 6, 7, 8, 10, 1, 2, 3];
%    =[cons_growth P_noassets mig_rate cons_gainols  mig_inc  mig_inc_y2 cons_gainlate mig_cond_mig wage_gap p_rural var_logwage ];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

    clear
    T=3;%number of changes to try different jacobians and elasticity matrices.
    Matrix_M_new=zeros(11,11*(T+1)); %Jacobians
    Matrix_E_new=zeros(11,11*(T+1)); %Elasticities

    %%%%%% Define values for measurement errors to put in tables (moment 1 and 11)
    me_mom11_var=0.15;
    me_mom11_sd=0.39;
    me_mom1_var=0.19-0.189^2; %0.189^2+me_mom1_var=0.19
    me_mom1_sd=me_mom1_var^0.5;

    for j=1:T
    load('calibration_final.mat')
    new_cal=exp(new_val);
    params = new_cal;

    n_params = length(params); % how many paramters we need to do...

        if j==1
        eps = 1.00375; % This is the change. 0.75 % around parameter (0.375 back and for)
        elseif j==2
        eps = 1.005; % This is the change. 1% around parameter (0.5 back and for)
        elseif j==3
        eps = 1.00625; % This is the change. 1.25% around parameter (0.625 back and for)
        end    

    els_moments = zeros(9,11);
    jacobian_moments = zeros(9,11);

    for xxx = 1:n_params

        disp(xxx)

        cal_eps_for = params;
        cal_eps_bak = params;

        cal_eps_for(xxx) = params(xxx).*eps; % forward
        cal_eps_bak(xxx) = params(xxx)./eps; % backward

        change_cal = (cal_eps_for(xxx))-(cal_eps_bak(xxx));

        moments_for = compute_outcomes_prefshock(cal_eps_for,0); % moments forward
        moments_bak = compute_outcomes_prefshock(cal_eps_bak,0); % moments backward

            %Add Measurement Errors and change to Var not SD (important for elasticities)
            moments_for(11) = moments_for(11)^2+me_mom1_var; % use measurement error and change from sd to var as in varcovar matrix
            moments_bak(11) = moments_bak(11)^2+me_mom1_var; % use measurement error and change from sd to var as in varcovar matrix
            moments_for(3) = moments_for(3)+me_mom11_var; % use measurement error
            moments_bak(3) = moments_bak(3)+me_mom11_var; % use measurement error

        change_moments = moments_for - moments_bak;

        jacobian_moments(xxx,:) = change_moments'./change_cal; % compute change.
        els_moments(xxx,:)=(log(moments_for) - log(moments_bak))/(log(cal_eps_for(xxx))-log(cal_eps_bak(xxx)));

    % So each row is a parameter, then each column is the moment

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % aggregate_moments = [1.89, 0.61, 0.625, 0.47];
            %%% Description:
            % Wage gap
            % The rural share
            % The urban variance... note that this is position number 3 (see below)
            % Fraction with no liquid assets
    % experiment_hybrid_v2 = [0.36, 0.22, 0.092, 0.30, 0.10, 0.25/0.36, 0.40];
            %%% Description:
            % seasonal migration in control
            % increase in r1 (22 percent)
            % increase in r2 (9.2 percent)
            % LATE estiamte
            % OLS estimate
            % Repeat migration.
            % Standard deviation of consumption growth.

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % to have same order as var-covar matrix:
            %order parameters: theta ubar lambda pi gamma A_u sigma_s rho sigma_nu 
            %order_moments: cons_growth P_noassets mig_rate cons_gainols mig_inc  ...
            %           mig_inc_y2 cons_gainlate sigma_nu_not wage_gap p_rural var_logwage];
        order_table = [2,5,6,7,8,3,1,4,9];
        order_moments = [11, 4, 5, 9, 6, 7, 8, 10, 1, 2, 3];
        test = jacobian_moments(order_table,order_moments);
        elasticities=els_moments(order_table,order_moments);
        %round(test,2)';

        Matrix_E = [elasticities' zeros(11,2)];
        Matrix_E(1,10)=1;
        Matrix_E(11,11)=1;
        Matrix_E_new(:,j*11+1:j*11+11)=Matrix_E;

        Matrix_M = [test' zeros(11,2)];
        Matrix_M(1,10)=1;
        Matrix_M(11,11)=1;
        Matrix_M_new(:,j*11+1:j*11+11)=Matrix_M;
    end

%For T=5
M_mean=(1/3)*(Matrix_M_new(:,12:22)+Matrix_M_new(:,23:33)+Matrix_M_new(:,34:44));
Matrix_M_new(:,1:11)=M_mean;

E_mean=(1/3)*(Matrix_E_new(:,12:22)+Matrix_E_new(:,23:33)+Matrix_E_new(:,34:44));
Matrix_E_new(:,1:11)=E_mean;
    % this generates T+1 M matrices insde Matrix_M_new to perform se: the first is
    % the mean of all the rest of the jacobians
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Variance Covariance Matrix

                   %cons_growth   P_noassets    mig_rate    cons_gainols    mig_inc     mig_inc_y2  cons_gainlate  repeat_mig
Exp_mom_varcovar=  [0.00128584	 0.00001115	  -0.00003059    0.00019928	  0.00002116	0.00004212	 0.00000031    -0.00007174     % cons_growth
                    0.00001115	 0.00012712	  0.00000817	 0.00001947	  -0.00001500	-0.00000289	 -0.00003335   -0.00001168     % P_noassets
                    -0.00003059	 0.00000817	  0.00069678	 -0.00000131  -0.00036251	-0.00017265	 0.00034881    0.00001397      % mig_rate
                    0.00019928	 0.00001947	  -0.00000131    0.00199811	  -0.00001064	0.00001570	 -0.00037858   -0.00025705     % cons_gainols
                    0.00002116	 -0.00001500  -0.00036251	 -0.00001064  0.00057068	0.00020858	 -0.00031222   0.00000863      % mig_inc
                    0.00004212	 -0.00000289  -0.00017265	 0.00001570   0.00020858	0.00059693	 -0.00019477   -0.00037700     % mig_inc_y2 
                    0.00000031	 -0.00003335  0.00034881	 -0.00037858  -0.00031222	-0.00019477	 0.00934914     0.00004016     % cons_gainlate
                    -0.00007174  -0.00001168  0.00001397     -0.00025705  0.00000863    -0.00037700  0.00004016    0.00208298];    % repeat_mig

                 
                    % wage_gap    p_rural   var_logwage             
Surv_mom_varcovar=  [ 0.032606   -0.000514  0.008279     % wage_gap
                      -0.000514   0.000186  -0.000083    % p_rural
                      0.008279   -0.000083  0.003475];   % var_logwage                  

zeros_8x3=zeros(8,3); 
zeros_3x8=zeros(3,8);

V=[Exp_mom_varcovar  zeros_8x3
   zeros_3x8         Surv_mom_varcovar];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Weighting Matrix

W= eye( 11 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Gamma Matrix

g=1; %gamma parameter
g=[ones(1,8)*1/g ones(1,3)];
GAM=eye(11).*g;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% SD Calculations 
%%% for all:
sd_all=zeros(T+1,11);
for j=0:T
M=Matrix_M_new(:,j*11+1:j*11+11);
SD_mat= inv(M'*W*M) * M' * W * GAM * V * GAM * W * M * inv(M'*W*M);
SD=diag(SD_mat)';
sd_all(j+1,:)=SD;
end
mean_sd_all=[params(order_table) me_mom1_var me_mom11_var; sd_all];

disp('Parameter Estimate and S.E.')
disp(mean_sd_all([1,2],:))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Sensitivity of parameters with respect to moments (Andrews et al 2017):
% for the 1%
M=Matrix_M_new(:,23:33);
sensitivity = - inv(M'*W*M) * M' * W ; 

% for the mean
M=Matrix_M_new(:,1:11);
sensitivity = - inv(M'*W*M) * M' * W  ;



