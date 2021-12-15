

clear
%parameter values
for j=1;
parm.sigma = 0.8; %risk aversion
parm.beta = 0.99; %discount rate
parm.piG = 0.5; %probability of being a good migrator
parm.migrate = 10; %point at which distrbution is truncated if you migrate
parm.m = 2; %the net return to migration
parm.yhat = 7; % mean of income without migration
parm.sigma2 = 3; %standard deviation of income without migration
parm.states = 21; % number of state in income distribution without migration
parm.truncate = 2.5 %point at which income distribution is truncated
parm.F = 10/4; %cost of migration
parm.sub = 0; %subsistence pointç
parm.epsilon = 1e-5; %accuracy for convergence
parm.xgrid = 50;%grid points
xlow = parm.sub+0.2; %minimum asset level
xhigh = 20; %maximum asset level
parm.x=(xlow : (xhigh - xlow)/(parm.xgrid-1) :xhigh)'; %asset grid
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

%generate migration truncated distribution of income
for i=1:parm.states;
    if parm.s1(i) >parm.migrate;
        s_check(i) = parm.s1(i);
    elseif parm.s1(i) <= parm.migrate;
    s_check(i) = parm.migrate;
end
end
parm.sm= s_check;
clear s_check;



[G,CG] = valueG(parm);
[B,CB] = valueB(parm);

G = ((parm.migrate - parm.sub).^(1-parm.sigma))/(1-parm.sigma) + parm.beta*( (((parm.sm-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
B = (parm.x -parm.F - parm.sub).^(1-parm.sigma)/(1-parm.sigma) + parm.beta*( (((parm.s1-parm.sub).^(1-parm.sigma))/(1-parm.sigma))*parm.p1)/(1-parm.beta);
for i=1:length(parm.x);
    if parm.x(i)-parm.F - parm.sub<0
        B(i)= -inf;
    end
end
%çB(imag(B) ~= 0) = -inf;
M = parm.piG*G + (1-parm.piG)*B;

[V,ppV] = valueV(parm, M);

Z = (parm.x - parm.sub).^(1-parm.sigma)/(1-parm.sigma) + parm.beta*(ppval(ppV,parm.s1)*parm.p1);
for i=1:length(parm.x)
if M(i) ==-inf
M(i)= min(Z) -0.1;
end
end

Migrate = (M >=Z);
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
plot(parm.x,M,'blue',parm.x,Z,'red');




