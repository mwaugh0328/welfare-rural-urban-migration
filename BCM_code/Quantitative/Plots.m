%creates plots from Master_smallv2

%load the data
clear all;
clear -global;

for stdev = 1:4;
    for j = 1:10;
        load(sprintf('Data/iteration_RA%1$d_Stdev%2$d',j,stdev));
        Cutpoint(j,stdev) = cutpoint;
       % Cutpoint_I(j,stdev) = cutpoint_I;
        %Cutpoint_Cash(j,stdev) = cutpoint_Cash;
        %Cutpoint_Cond(j,stdev) = cutpoint_Cond;
        if stdev == 1 & j ==1;
        Prop_athome(j,stdev,:) = prop_athome;
        elseif size(Prop_athome,3) < length(prop_athome);
        Prop_athome(:,:,length(prop_athome)) = 0;
        elseif length(prop_athome) < size(Prop_athome,3);
        prop_athome(size(Prop_athome,3)) = 0;
        end
        Prop_athome(j,stdev,:) = prop_athome;
        Stdev(stdev) = sigma2;
    end
end

%Stdev = [0.7 .8 .9 1 1.1 1.2]
%first, we want to plot the probability of migrating, assuming that there is no money saved
A = ones(j,1);
standarddeviation = A*Stdev;
P = 1-normcdf(Cutpoint,xhat,standarddeviation); % P is a matrix with a row for each RA level and a column for each stdev.
%P_I = 1-normcdf(Cutpoint_I,xhat,standarddeviation);
%P_Cond = 1- normcdf(Cutpoint_Cond,xhat,standarddeviation);
%P_Cash = 1- normcdf(Cutpoint_Cash,xhat,standarddeviation);
%Delta_I = P_I - P;
%Delta_Cond = P_Cond - P;
%Delta_Cash = P_Cash - P;


% next we want to calculate the number of people that have left to migrate after a certain number of days - -this will be 1-prop_athome.
%Prop_athome(:,:,6) = 0;
%inv = ones(size(Prop_athome,1),size(Prop_athome,2),size(Prop_athome,3));
prop_left = 1-Prop_athome; %prop_left is a 3d array with first dimension for ra second for stdev and third for days.

%plots of migration probabilities
clear figure;

for i = 1:length(Stdev);
figure = figure();
plot(Sigma,prop_left(:,i,1),Sigma,prop_left(:,i,2),Sigma,prop_left(:,i,3),Sigma,prop_left(:,i,4),Sigma,prop_left(:,i,5),Sigma,prop_left(:,i,6),Sigma,prop_left(:,i,7),Sigma,prop_left(:,i,8),Sigma,prop_left(:,i,9),Sigma,prop_left(:,i,10),Sigma,prop_left(:,i,8),Sigma,prop_left(:,i,9),Sigma,prop_left(:,i,10),Sigma,prop_left(:,i,11),Sigma,prop_left(:,i,12),Sigma,prop_left(:,i,13));
axis([2 18 0 1.005]);
hleg1 = legend('1 Period', '2 Periods', '3 Periods', '4 Periods', '5 Periods', '6 Periods', '7 Periods', '8 Periods','9 Periods', '10 Periods');
xlabel('Risk Aversion');
ylabel('Portion of Population Migrated');
title(sprintf('Migrated Population Over Time - Stdev %d',i));
print(figure,'-dpdf',sprintf('Figures/PortionMigrated_%d.pdf',i)); %note that the title has to be set at the same time as sigma2
clear figure;
end





