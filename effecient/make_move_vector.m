function make_move_vector(move)

ntypes = 24;
n_shocks = 5*2;

move_vec = [];
count = 0;

A = [];
rural_A = [eye(n_shocks), eye(n_shocks); zeros(n_shocks), zeros(n_shocks)];
urban_A = zeros(n_shocks);

%14.0000   76.0000   12.0000    1.0000   
%15.0000   79.0000   86.0000    2.0000
%12.0000   92.0000   35.0000    3.0000 
for xxx = 1:ntypes
    
    foo = move(xxx).rural_not;
  
     foo = [foo(:,1),  diff(foo,1,2)];
     foo = foo(:,1:2);

    move_vec = [move_vec ; foo(:)];
    A = blkdiag(A,rural_A);
    
    foo = move(xxx).rural_exp;
    
    foo = [foo(:,1),  diff(foo,1,2)];
    foo = foo(:,1:2);

    move_vec = [move_vec ; foo(:)];
    A = blkdiag(A,rural_A);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    foo = move(xxx).urban_new;

    foo = [foo(:,1),  diff(foo,1,2)];

    move_vec = [move_vec ; foo(:,1)];
    A = blkdiag(A,urban_A);
    
    foo = move(xxx).urban_old;
    
    foo = [foo(:,1),  diff(foo,1,2)];
    move_vec = [move_vec ; foo(:,1)];
    A = blkdiag(A,urban_A);
    bar = 1;
    
end
x0 = move_vec;


LB = (zeros(length(x0),1));
UB = (ones(length(x0),1));
b = ones(length(x0),1);

save anlyz_guess x0 LB UB A b