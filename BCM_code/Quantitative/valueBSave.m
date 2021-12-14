function [B,CB] = valueBSave(parm)

B_mean = 1/(1-parm.beta)*((parm.yhat - parm.sub).^(1-parm.sigma)/(1-parm.sigma)); % a guess at the value function
B = B_mean*ones(1,length(parm.x)); %use the guess
CB  = parm.yhat;
ppB = spline(parm.x,B);


iter = 0; crit = 1; B_new = B; CB_new = CB;

while crit > parm.epsilon
    
    for i=1:length(parm.x)
        [CB_new(i),val] = fminbnd(@(c) objBSave(c,parm.x(i),parm,B), parm.sub,parm.x(i));
        B_new(i) = -val;    
    end
    B_equiv = ((1-parm.sigma)*(1-parm.beta)*B).^(1/(1-parm.sigma));
    B_new_equiv = ((1-parm.sigma)*(1-parm.beta)*B_new).^(1/(1-parm.sigma));
    [crit blah] = max(abs(B_equiv - B_new_equiv));
    [crit_c bla2]= max(abs( (CB - CB_new)./CB ));
    iter = iter+1;
    disp('iterating on B')
    disp(iter)
    disp(crit)
    B=B_new;
    CB = CB_new;
    ppB = spline(parm.x,B);
    
     %if abs(crit_c*100) < 1e-4
      %disp('howard iteration k=100')
       %  for k=1:100;
        %     B=-objBsave(CG,parm.x, parm, B);  
         %   ppG=spline(parm.x,B);
         %end
    % end
end
end

    
        