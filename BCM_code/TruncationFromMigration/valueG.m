function [G,CG] = valueG(parm)

G_mean = 1/(1-parm.beta)*((parm.yhat - parm.sub+parm.m).^(1-parm.sigma)/(1-parm.sigma)); % a guess at the value function
G = G_mean*ones(1,length(parm.x)); %use the guess
CG  = parm.x;
ppG = spline(parm.x,G);


iter = 0; crit = 1; G_new = G; CG_new = CG;

while crit > parm.epsilon
    
    for i=1:length(parm.x)
        [CG_new(i),val] = fminbnd(@(c) objG(c,parm.x(i),parm,ppG), parm.sub,parm.x(i) + parm.m);
        G_new(i) = -val;
         
    end
    G_equiv = ((1-parm.sigma)*(1-parm.beta)*G).^(1/(1-parm.sigma));
    G_new_equiv = ((1-parm.sigma)*(1-parm.beta)*G_new).^(1/(1-parm.sigma));
    [crit blah] = max(abs(G_equiv - G_new_equiv));
    [crit_c bla2]= max(abs( (CG - CG_new)./CG ));
    iter = iter+1;
    disp('iterating on G')
    disp(iter)
    disp(crit)
    G=G_new;
    CG = CG_new;
    ppG = spline(parm.x,G);
    
     %if abs(crit_c*100) < 1e-4
      %disp('howard iteration k=100')
       %  for k=1:100;
        %     G=-objG(CG,parm.x, parm, ppG);  
         %   ppG=spline(parm.x,G);
       %  end
    % end
end
end

    
        