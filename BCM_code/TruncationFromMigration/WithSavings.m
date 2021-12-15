

clear
%parameter values
for j=1;
parm.sigma = 5; %risk aversion
parm.beta = 0.99; %discount rate
parm.piG = 0.5; %probability of being a good migrator
parm.migrate = 10; %point at which distrbution is truncated if you migrate
parm.m = 2; %the net return to migration
parm.yhat = 7; % mean of income without migration
parm.sigma2 = 0.6; %standard deviation of income without migration
parm.states = 21; % number of state in income distribution without migration
parm.truncate = 2.5 %point at which income distribution is truncated
parm.F = 10/4; %cost of migration
parm.sub = 2; %subsistence pointç
parm.epsilon = 1e-5; %accuracy for convergence
parm.xgrid = 100;%grid points
parm.R = 1; %the return on savings


earningmodel =0; %change to 1 for a model in which migratoin is additional to at home earnings

% generate income distribution
[s,p] = tauch_huss(parm.yhat, 0 , parm.sigma2, parm.states); % note that when we do this we have to make sure tha thte lowest income is greater than zero.
      parm.s1 = s'; 
      parm.p1 = p(1,:)';
      
% truncate income distribution
      
for i=1:parm.states;
    if parm.s1(i) >parm.truncate;
        s_check(i) = parm.s1(i);
    elseif parm.s1(i) <= parm.truncate;
    s_check(i) = parm.truncate;
end
end
parm.s1= s_check;
clear s_check;

%create asset grid
xlow = parm.sub+0.1; %minimum asset level
xhigh = 20; %maximum asset level
parm.x=(xlow : (xhigh - xlow)/(parm.xgrid-1) :xhigh)'; %asset grid



% value functions
[G,CG] = valueG(parm);
[B,CB] = valueB(parm);

ppB = spline(parm.x,B);
ppG = spline(parm.x,G);

[V,CV,VN,VM] = valueV2(parm,ppB,ppG); %VN is the value if you are forced not to migrate

Migrate = (VM >=VN);
if isempty(find(Migrate))==0;
cutpoint_low(j) = (parm.x(min(find(Migrate))))';
    if max(find(Migrate)) < length(parm.x)
cutpoint_high = (parm.x(max(find(Migrate))))';
    else
        cutpoint_high = inf;
    end
elseif min(Migrate) ==0;
    cutpoint_low(j) =0;
else 
    cutpoint_low(j) = -inf;
end

sigma(j)=parm.sigma;
end
plot(sigma,cutpoint_low,'blue');
plot(parm.x,VN,'blue',parm.x,VM,'red');




