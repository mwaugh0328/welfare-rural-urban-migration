function [z , zprob] = pareto_approx(N, theta)

xmin = (theta-1)./theta;

avg = (theta./(theta-1)).*xmin;

zhat = zeros(N+1,1);

zhat(N+1) = xmin./(1-0.90).^(1./theta); % z so that 10 percent are truncated.
zhat(1) = xmin;

% zstep = (z(N) - z(1))./(N-1);
% 
zprob = zeros(N,1);
 
zspace = logspace(log10(zhat(1)),log10(zhat(N+1)),N+1);

zstep = diff(zspace);

z = zeros(N,1);

for xxx = 1:N
    z(xxx) = zspace(xxx) + zstep(xxx)/2;
    if xxx == N
        z(xxx) = zhat(N+1).*(theta./(theta-1));
    end
end 

for xxx = 1:N
    if xxx == N
        zprob(xxx) = 1-pareto_cdf(zhat(N+1),xmin,theta);
    else
        zprob(xxx) = pareto_cdf(z(xxx)+zstep(xxx)/2,xmin,theta) - ...
            pareto_cdf(z(xxx)-zstep(xxx)/2,xmin,theta);
    end
       
end


function p = pareto_cdf(x,xmin,theta)
    p = max(1 - (xmin./x).^theta, 0);

