
clc; clear;
close all

warning('off','stats:regress:RankDefDesignMat');
addpath('../utils')
addpath('../calibration')

load('fake_data.mat')

Nruns = size(fake_data,1);

estimate = zeros(Nruns,9);
fval = zeros(Nruns,1);

for xxx = 1:Nruns
    
    disp(xxx)
    
    [estimate(xxx,:), fval(xxx,1)] = calibrate_montecarlo(fake_data(xxx,:));
    
    disp(estimate(xxx,:))
    disp(fval(xxx,1))
    
    save montecarlo_test_altstart estimate fval
    
end