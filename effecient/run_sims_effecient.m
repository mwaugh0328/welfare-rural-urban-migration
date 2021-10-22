nruns = 30;
rec_social_welfare = zeros(nruns,2);

for xxx = 1:nruns
    
    [social_welfare] = compute_analytical_effecient(new_cal, tfp, xxx);
    
    [~, alt_social_welfare] = compute_effecient(best.x1,  new_cal, tfp, xxx, 1);
    
    rec_social_welfare(xxx,:) = [social_welfare.all, alt_social_welfare.all];
    
end