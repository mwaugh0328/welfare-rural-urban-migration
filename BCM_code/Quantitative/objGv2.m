function f=obj(c,x1, parm,G)
u = (c-parm.sub).^(1-parm.sigma)/(1-parm.sigma);
x_prime = parm.R*(x1-c+ parm.m)*ones(1,length(parm.s)) + ones(length(c),1)*(parm.s); %ones gives a vecotr of ones of length the same as s1 first one is a column second one a row
fi= parm.beta*[interp1(parm.x,G,x_prime,'linear')*parm.p]; %% ppval returns the values of the spline along the points of x_prime%
ff = u - parm.UC + fi;
f = -ff;

