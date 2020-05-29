% Input: starting value, steps, mu(mean), and sigma(standard deviation)
% Ouput: a sequence whose values are determined by Gaussian random walks
function sequence = generate_walk(start_point, steps, mu, sigma)
    current_val = start_point;
    sequence = [];
    for i = 1:steps
        sequence(i) = current_val;
        % Randomly choose a value from normal distribution for changing in
        % certain value
        delta = mu + randn() * sigma;
        % A move of walk
        current_val = current_val + delta;
    end
end