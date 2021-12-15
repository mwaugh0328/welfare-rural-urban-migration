function [G,c_G,ppc_G,ppG] = valueg(parm, x, epsilon, ymean, yl, xgrid); 

G_mean  = 1/(1-parm.beta)*((parm.R-1)/parm.R*x + ymean - parm.F + parm.m).^(1-parm.sigma)/(1-parm.sigma);  % initial guesses
c_G       = min((parm.R-1)/parm.R*x + (yl+parm.m)/parm.R,x);
G       = G_mean;

ppG=spline(x,G); % convert to spline for interplation


% iterate until convergence

iter=0; crit=1; G_new=G; ; c_G_new =c_G;

while crit >epsilon

    for i=1:xgrid
        [c_G_new(i) val]=fminbnd(@(c) objGv2(c ,x(i), parm, ppG), parm.sub , x(i)+parm.m);% upper bound is adjusted because they will migrate before they choose consumption levels.
        G_new(i) = -val; % note: obj is the negative of the true objective function
    end
    % update iteration housekeeping (criterion and iteration number)
     G_equiv     = ((1-parm.sigma)*(1-parm.beta)*G).^(1/(1-parm.sigma));
     G_new_equiv = ((1-parm.sigma)*(1-parm.beta)*G_new).^(1/(1-parm.sigma));
    [crit bla1]= max(abs( G_equiv - G_new_equiv ));
    [crit_c bla2]= max(abs( (c_G - c_G_new)./c_G )); crit_c= 100*(c_G_new(bla2) - c_G(bla2))/c_G(bla2);
    crit_percent= [G_new_equiv(bla1) - G_equiv(bla1)]*100/ymean;
    iter=iter+1;
    
    disp('iter on G')
    disp(iter)
    disp([crit_percent , crit_c*100]) ; % display iteration statissavetics in percentage + or -
    disp([x(bla1) , x(bla2)])  ; %displays where the action is on x-grid
    
     G=G_new; c_G=c_G_new; ppG=spline(x,G); % updates information after iteration
    
    %Howard Iteration
  if abs(crit_c*100) < 1e-4
      disp('howard iteration k=100')
         for k=1:100;
             G=-objGv2(c_G,x, parm, ppG);  
            ppG=spline(x,G);
         end
     end
end

ppc_G = spline(x,c_G); % splines policy function 
