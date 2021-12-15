function [B,c_B,ppc_B,ppB] = valueb(parm, x, epsilon, ymean, yl, xgrid); 


B_mean  = 1/(1-parm.beta)*((parm.R-1)/parm.R*x + ymean).^(1-parm.sigma)/(1-parm.sigma);  
c_B      = min((parm.R-1)/parm.R*x + (yl)/parm.R,x);
B       = B_mean;

ppB=spline(x,B); 

iter=0; crit=1; c_B_new =c_B; B_new=B;

while crit >epsilon
    
    for i=1:xgrid
        
        [c_B_new(i) val]=fminbnd(@(c) objB(c,x(i),parm, ppB), parm.sub, x(i));
        
        B_new(i) = -val; % note: obj is the negative of the true objective function
    end

    % update interation housekeeping (criterion and iteration number)

     B_equiv     = ((1-parm.sigma)*(1-parm.beta)*B).^(1/(1-parm.sigma));
     B_new_equiv = ((1-parm.sigma)*(1-parm.beta)*B_new).^(1/(1-parm.sigma));
    [crit bla1]= max(abs( B_equiv - B_new_equiv ));
    [crit_c bla2]= max(abs( (c_B - c_B_new)./c_B )); crit_c= 100*(c_B_new(bla2) - c_B(bla2))/c_B(bla2);
    crit_percent= [B_new_equiv(bla1) - B_equiv(bla1)]*100/ymean;
    iter=iter+1;
   
    disp('iter on B')
    disp(iter)
    disp([crit_percent , crit_c*100]) ; % display iteration statissavetics in percentage + or -
    disp([x(bla1) , x(bla2)])  ; %displays where the action is on x-grid

    B=B_new; c_B=c_B_new; ppB=spline(x,B); % updates information after iteration
     
    if abs(crit_c*100) < 1e-4
      disp('howard iteration k=100')
         for k=1:100;
            B=-objB(c_B,x, parm, ppB); 
            ppB=spline(x,B);
         end
       end
end

ppc_B = spline(x,c_B); % splines policy function for simulations