function f=obj(c,x, parm, B)
u = (c-parm.sub).^(1-parm.sigma)/(1-parm.sigma);
x_prime = parm.R*(x-c)*ones(1,length(parm.s)) + ones(length(c),1)*parm.s;
fi= parm.beta*[interp1(parm.x,B,x_prime,'linear')*parm.p];
ff = u + fi;
f = -ff;

