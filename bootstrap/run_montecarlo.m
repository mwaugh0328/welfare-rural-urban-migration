
clc; clear;
close all

warning('off','stats:regress:RankDefDesignMat');
addpath('../utils')
addpath('../calibration')

load('fake_data.mat')

Nruns = 3;
%size(fake_data,1);

estimate = zeros(Nruns,9);
fval = zeros(Nruns,1);
exitflag = zeros(Nruns,1);

for xxx = 1:Nruns
    
    disp(xxx)
    
    [estimate(xxx,:), fval(xxx,1), exitflag(xxx,1)] = calibrate_montecarlo(fake_data(xxx,:));
    
    disp(estimate(xxx,:))
    disp(fval(xxx,1))
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    save montecarlo_fed estimate fval exitflag
    save('montecarlo_fed_estimate.csv', 'estimate', '-ascii')
    save('montecarlo_fed_fval.csv', 'estimate', '-ascii')
    
    system('git add montecarlo_fed.mat')
    system('git add montecarlo_fed*.csv')
    system('git commit -am "test of matlab/git"')
    system('git push')
    
end