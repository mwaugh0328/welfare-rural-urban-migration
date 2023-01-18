function [weights] = make_weights(alpha_z, solve_types)

weights = exp( alpha_z .* (1./solve_types(:, 2))); % on urban productivity

weights = weights ./ sum(weights);

% these are the weights that would come from consumption shares
% weights = [ 0.0287
%     0.0288
%     0.0289
%     0.0292
%     0.0298
%     0.0305
%     0.0312
%     0.0318
%     0.0318
%     0.0320
%     0.0327
%     0.0337
%     0.0349
%     0.0364
%     0.0381
%     0.0400
%     0.0420
%     0.0442
%     0.0466
%     0.0491
%     0.0517
%     0.0545
%     0.0574
%     0.1360];