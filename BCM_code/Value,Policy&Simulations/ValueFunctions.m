% Draws Value Functions for first revision of Monga paper for Econometrica.

% Models buffer stock/ investment decision for monga paper.


%   Strategy:  The value functoin is
%       V(x) = \{ max_{c} u(c) + \beta E V(R(x-c) + y(s)) , \pi_G G(x+m - F) + (1-\pi_G) B (x-F)\}   
%
%   where:
%       
%       G(x) = \max_{c} u(c) + \beta E G(R(x-c -F + m) + y(s))
% and
%       B(x) = \max_{c} u (c) + \beta E B(R(x-c)+ y(s))
% 
%   Strategy is to compute G and B and then to simply plug them in.
%
%define the parameters
%clear
%clearvars -global


global sigma beta yl yh R ppG ppB ppV s1 p1 m F piG sub; 

% sigma: risk aversion
% beta: discount rate
% yl: lowest possible income 
% R: = gross return on savings
% ppg: is the value function in the good state (on a spline)
% ppb: is the value function in the bad state (on a spline)
% s1: set of labor income states
% p1: probabilities of labor income states
% m: is how much more you earn each period if you discover that you are
% good at migrating - it is a certain return
% pig: probability of realizing the good state
% F: is the cost of migrating
% we assume a nomrally distributed income process.
% xhat: mean of the labor income
% sigma2 : standard deviation of labor income
% states: number of states
%sub: subsistence requirement
% set the parameters: make sure beta*R <1 (recall this is a buffer stock model)
%lognormal: = 1 if we want a log normal distribution
%xgrid: how many points in the asset grid.
%UC: utility cost of migrating - this is very hard to define because it
%will depend, by in large on the utility function - we can try to define
%it as the solution to an equation?
% I : incentive size
%Cond: size of credit transfer - i.e. conditional on having a bad state.
%cash: the size of the cash bonus.
%truncate is teh point at whic the distribution is truncated.
 
sigma=1.4; 
beta=.98;
R=1;
piG=0.5;
F=10.2/4; 
m = 3.5; 
sub = 0;
xhat = 6;
sigma2 = 0.6;
states = 25;
truncate = 3
epsilon = 1e-10;
lognormal = 0;
xgrid= 300; 
DollarCost = 0; %dollar cost of the utility cost
z=sym('z','real');
UC = 0 %solve((xhat + DollarCost)^(1-sigma)/(1-sigma) - z == (xhat)^(1-sigma)/(1-sigma), z); 
%UC = double(UC); 
I = 6/4;
Cond = 6/4; %note that this should not be positive at the same time as I.
Cash = 6/4; % this also should never be positive at the same time as I and Cond.



%calculate states

if lognormal == 1;
    [s,p] = tauch_huss(log(xhat- sigma2^2/2), 0 , sigma2, states); % note that when we do this we have to make sure tha thte lowest income is greater than zero.
    s1 = exp(s');
    p1 = p(1,:)';
else
     [s,p] = tauch_huss(xhat, 0 , sigma2, states); % note that when we do this we have to make sure tha thte lowest income is greater than zero.
      s1 = s'; 
      p1 = p(1,:)';
end

%truncate the distribution
for i=1:states;
    if s1(i) >truncate;
        s_check(i) = s1(i);
    elseif s1(i) <= truncate;
    s_check(i) = truncate;
end
end
s1= s_check;
clear s_check p_check; 

%create parameter space


parm.R = R;
parm.beta = beta;
parm.sigma = sigma;
parm.p = p1;
parm.s=s1;
parm.sub = sub;
parm.F = F;
parm.m=m;
parm.piG = piG;
parm.UC = UC;
parm.I = I;
parm.Cond = Cond; 
parm.Cash = Cash;

ymean=s1*p1; %for later use
yl=min(s1); yh=max(s1);  % to determine the bounds on teh asset grid
xhigh= 20; xlow = max(sub,min(s1)); %need to think about the upper bound ...
x=(xlow : (xhigh - xlow)/(xgrid-1) :xhigh)';

% calculate the value function G

[G,c_G,ppc_G,ppG] = valuegv2(parm, x, epsilon, ymean,yl, xgrid);

% Calculate the value function B

[B,c_B,ppc_B,ppB] = valueb(parm, x, epsilon, ymean,yl, xgrid);

% Calculate the value function V

[V,c,ppc,ppV, V_no] = valuev(parm, x, epsilon, ymean,yl, xgrid, ppG, ppB);

% deermine whether migration takes place
ppV_no = spline(x,V_no);
M = ((parm.piG*ppval(ppG,x) + (1-parm.piG)*(ppval(ppB,x-parm.F))-parm.UC)  > V_no');
   
% calculate the interpolated value of cash on hand for which migration
% takes place

if isempty(find(M)) == 0; %%% note that this may be problematic if the matrix is empty.
    cutpoint = (x(min(find(M)))); %+ x(min(find(M))-1))/2;
elseif min(M) ==0;
    cutpoint =0;
else
    cutpoint = max(x) + 10; %% not sure where to put cutpoint if it is that you never go in the set of values of x.
end

% now get percentages


% plot policy and value functions and save to file

V_mig = (parm.piG*ppval(ppG,x) + (1-parm.piG)*(ppval(ppB,x-parm.F)));

figure = figure();
hax = axes;
plot(x,V_no,'blue',x,V_mig,'black');
SP = cutpoint;
line([SP SP],get(hax,'YLim'),'Color',[0 0 0],'LineStyle','--');
hleg1 =  legend('V_N','V_M', 'Migration Cutoff') ;
xlabel('Cash on Hand');
print(figure,'-dpdf',sprintf('Figures/Values.pdf'));

