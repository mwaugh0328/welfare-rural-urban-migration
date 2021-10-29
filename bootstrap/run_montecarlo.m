
clc; clear;
close all

warning('off','stats:regress:RankDefDesignMat');
addpath('../utils')
addpath('../calibration')

load('fake_data.mat')

Nruns = size(fake_data,1);
disp(Nruns)

estimate = zeros(Nruns,9);
fval = zeros(Nruns,1);
exitflag = zeros(Nruns,1);

for xxx = 1:Nruns
    
    disp(xxx)
    
    [estimate(xxx,:), fval(xxx,1), exitflag(xxx,1)] = calibrate_montecarlo(fake_data(xxx,:));
    
    disp(estimate(xxx,:))
    
    disp(fval(xxx,1))
    
    temp_estimate = estimate(1:xxx,:);
    temp_fval = fval(1:xxx,:);
    temp_exitflag = exitflag(1:xxx,:);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    save montecarlo_fed estimate fval exitflag
    save('montecarlo_fed_estimate.csv', 'temp_estimate', '-ascii')
    save('montecarlo_fed_fval.csv', 'temp_fval', '-ascii')
    save('montecarlo_fed_exitflag.csv', 'temp_exitflag', '-ascii')
    
    system('git add montecarlo_fed.mat')
    system('git add montecarlo_fed*.csv')
    system('git commit -am "fed computer"')
    system('git push')
    
end