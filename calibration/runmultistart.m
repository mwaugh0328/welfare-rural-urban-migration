clc; clear;
close all

warning('off','stats:regress:RankDefDesignMat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1.3065    0.4961    1.4559    0.7239    1.4440    0.5445    0.4921    0.6590
%1.3066    0.4961    1.4598    0.7219    1.4479    0.5745    0.5109    0.6590
best = [1.2939    0.5439    1.5979    0.7364    1.5188    0.5268    0.4580    0.5393    0.0504    0.0863];

rns = 30;

guess = zeros(rns,length(best));

new_cal = zeros(rns,10);
fval = 100*ones(rns,1);

guess_ptrb = .01*randn(rns,length(best));

options = optimset('Display','iter','MaxFunEvals',.3e3);

guess = best;

for zzz = 1:rns
    
    guess = best + guess_ptrb(zzz,:);
    
    tic
    [new_cal(zzz,:), fval(zzz)] =fminsearch(@(xxx) calibrate_model(exp(xxx),1),log(guess),options);
    toc
    
    %[xx,yy]= min(fval);

    %best = exp(new_cal(yy,:));

    save multistart new_cal fval
 
end