function [s,p] = tauch_huss(xbar, rho, sigma,n)
%xbar: mean of the x process
% rho:  persistence parameter
% sigma: volatility
% n: number of nodes


% returns the states (s) and transition probabilities p

[xx,wx] = gauss_herm(n);
s = xx*sigma*sqrt(2) + xbar;
x = xx(:,ones(n,1));
z = x';
w = wx(:,ones(n,1))';

p = (exp(z.*z-(z-rho*x).*(z-rho*x)).*w)./sqrt(pi);
sx = sum(p')';
p = p./sx(:,ones(n,1));
