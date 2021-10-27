clear

jacobians = zeros(11,11); %Jacobians
elasticities = zeros(11,11); %Elasticities

%%%%%% Define values for measurement errors to put in tables (moment 1 and 11)
me_wage_var = 0.15;
me_consumption_var =0.19-0.189^2; %0.189^2+me_mom1_var=0.19


load('cal_baseline_s730.mat')
params = x1(1:end-1); % currently has moving cost in there
n_params = length(params); % how many paramters we need to do...

eps = 1.005; % This is the change. 1% around parameter (0.5 back and for)

els_moments = zeros(9,11);
jacobian_moments = zeros(9,11);

for xxx = 1:n_params

        disp(xxx)

        cal_eps_for = params;
        cal_eps_bak = params;

        cal_eps_for(xxx) = params(xxx).*eps; % forward
        cal_eps_bak(xxx) = params(xxx)./eps; % backward

        

        moments_for = calibrate_model(cal_eps_for,[],[],3);
        moments_bak = calibrate_model(cal_eps_bak,[],[],3); % moments backward

        %Add Measurement Errors and change to Var not SD (important for elasticities)
        % Now the output from calibrate_model is in sd, convert to
        % variance.
        moments_for(11) = moments_for(11)^2 + me_consumption_var; % use measurement error and change from sd to var as in varcovar matrix
        moments_bak(11) = moments_bak(11)^2 + me_consumption_var; % use measurement error and change from sd to var as in varcovar matrix
        
        moments_for(3) = moments_for(3)^2 + me_wage_var; % use measurement error
        moments_bak(3) = moments_bak(3)^2 + me_wage_var; % use measurement error
        
        change_cal = cal_eps_for(xxx)- cal_eps_bak(xxx);
        change_moments = moments_for - moments_bak;

        jacobian_moments(xxx,:) = change_moments ./change_cal; % compute change.
        els_moments(xxx,:)= (log(moments_for) - log(moments_bak)) ./ (log(cal_eps_for(xxx))-log(cal_eps_bak(xxx)))';

    % So each row is a parameter, then each column is the moment

end

order_table = [2,5,6,7,8,3,1,4,9];
order_moments = [11, 4, 5, 9, 6, 7, 8, 10, 1, 2, 3];

test = jacobian_moments(order_table,order_moments);
elasticities=els_moments(order_table,order_moments);

Matrix_E = [elasticities' zeros(11,2)];
Matrix_E(1,10)=1;
Matrix_E(11,11)=1;

Matrix_M = [test' zeros(11,2)];
Matrix_M(1,10)=1;
Matrix_M(11,11)=1;

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('experiment_variance_covaraince.mat')
%cons_growth   P_noassets    mig_rate    cons_gainols    mig_inc     mig_inc_y2  cons_gainlate  repeat_mig

load('aggregate_varaince_covaraiance.mat')
% wage_gap    p_rural   var_logwage

zeros_8x3=zeros(8,3); 
zeros_3x8=zeros(3,8);

V=[experiment_var_cov  zeros_8x3
   zeros_3x8         aggregate_var_cov];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Weighting Matrix

W = eye( 11 );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Gamma Matrix

g=1; %gamma parameter
g=[ones(1,8)*1/g ones(1,3)];
GAM=eye(11).*g;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M = Matrix_M;

SD_mat= inv(M'*W*M) * M' * W * GAM * V * GAM * W * M * inv(M'*W*M);

SD = diag(SD_mat)';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp([params(order_table) me_consumption_var me_wage_var; SD])

%5
%     0.5520    1.5368    0.6074    0.6587    0.5176    1.5528    1.3046    0.7465    0.1265    0.1543    0.1500
%     0.0075    0.4679    2.2733    2.6631    0.0368    0.0307    1.2997    0.0052    0.0262    0.0028    0.0780

%15
%     0.5520    1.5368    0.6074    0.6587    0.5176    1.5528    1.3046    0.7465    0.1265    0.1543    0.1500
%     0.0031    0.2472    1.1756    1.0485    0.1596    0.0116    0.2628    0.0040    0.0030    0.0014    0.0091

%30
%     0.5520    1.5368    0.6074    0.6587    0.5176    1.5528    1.3046    0.7465    0.1265    0.1543    0.1500
%     0.0071    0.3004    1.1599    1.2667    0.2111    0.0134    0.5708    0.0106    0.0031    0.0014    0.0174

%45
%     0.5520    1.5368    0.6074    0.6587    0.5176    1.5528    1.3046    0.7465    0.1265    0.1543    0.1500
%     0.0402    1.4500    3.6025    5.4714    0.8235    0.0302    3.7594    0.0800    0.0137    0.0020    0.0968

%55
%     0.5520    1.5368    0.6074    0.6587    0.5176    1.5528    1.3046    0.7465    0.1265    0.1543    0.1500
%     0.3329    8.9811   19.9759   34.2256    5.3082    0.1715   30.9671    0.8355    0.0870    0.0043    0.8887

%     0.5520    1.5368    0.6074    0.6587    0.5176    1.5528    1.3046    0.7465    0.1265    0.1543    0.1500
%     4.0639  104.5804  188.8443  375.4030   57.7842    2.4968  355.1551    9.7712    1.1052    0.0394   11.1587








