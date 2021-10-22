addpath('../calibration')
addpath('../ge_taxation')

load calibration_final
new_cal = exp(new_val);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now let's run the main file, this creates the wages for the decentralized
% equillibrium

[targets, wage] = analyze_outcomes(new_cal, [], [], [], [], 1);

cd('..\effecient')

wage_de = [wage.monga, wage.notmonga];
%These are teh wages in the decentralized equillibrium, then we are going
%to pass this through one last time to get policy functions and the
%primitive TFP. The move policy function below is used to construct a good
%initial guess for the optimization and bounds on the problem.

[move_de, solve_types, assets, params, specs, vfun, ce] = just_policy(new_cal, wage_de, [], [], [], []);


ntypes = 24;
n_shocks = 5*2;

asset_loc = 15;

move_vec = [];
count = 0;

A = [];
rural_A = [eye(10), eye(10); zeros(10), zeros(10)];
urban_A = zeros(10);

%14.0000   76.0000   12.0000    1.0000   
%15.0000   79.0000   86.0000    2.0000
%12.0000   92.0000   35.0000    3.0000 
for xxx = 1:ntypes
    
    foo = squeeze(move_de(xxx).rural_not(12,:,:));
  
    foo = [foo(:,1),  diff(foo,1,2)];
    foo = foo(:,1:2);

    move_vec = [move_vec ; foo(:)];
    A = blkdiag(A,rural_A);
    
    foo = squeeze(move_de(xxx).rural_exp(92,:,:));
    
    foo = [foo(:,1),  diff(foo,1,2)];
    foo = foo(:,1:2);

    move_vec = [move_vec ; foo(:)];
    A = blkdiag(A,rural_A);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    foo = squeeze(move_de(xxx).urban_new(35,:,:));

    foo = [foo(:,1),  diff(foo,1,2)];
    move_vec = [move_vec ; foo(:,1)];
    A = blkdiag(A,urban_A);
    
    foo = squeeze(move_de(xxx).urban_old(3,:,:));
    
    foo = [foo(:,1),  diff(foo,1,2)];
    move_vec = [move_vec ; foo(:,1)];
    A = blkdiag(A,urban_A);
    bar = 1;
    
end
x0 = move_vec;


LB = (zeros(length(x0),1));
UB = (ones(length(x0),1));
b = ones(length(x0),1);

save init_guess x0 LB UB A b