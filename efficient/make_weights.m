function [weights] = make_weights(alpha_z, solve_types)

weights = exp( alpha_z .* (1./solve_types(:, 2))); % on urban productivity

weights = weights ./ sum(weights);

