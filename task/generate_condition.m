%% Generate condition sequence

%% ---------------------------------------------------------
% Specify the trials sequence of the formal task
% ---------------------------------------------------------

trials = 1:trials_num;
in_block_indexes = 1:trials_per_block;
in_blocks_indexes = repmat(in_block_indexes, 1, blocks_num);
is_safe_condition_seq = repmat([ones(1, trials_per_block)...
    zeros(1, trials_per_block)], 1, 2);
is_time_for_shock_seq = zeros(1, trials_num);
is_time_for_shock_seq(55) = 1;
is_time_for_shock_seq(75) = 2;
is_time_for_shock_seq(130) = 3;
is_time_for_shock_seq(149) = 4;

%% ---------------------------------------------------------
% Generate reward probability sequence
% ---------------------------------------------------------

% Generate reward probability sequence (Gaussian random walks)
prob_reward_left_seq = generate_walk(start_prob, trials_num, mu, sigma);
prob_reward_right_seq = generate_walk(start_prob, trials_num, mu, sigma);

%% ---------------------------------------------------------
% Spare use: just in case we need to generate an example plot
% of probability variance
% ---------------------------------------------------------

figure
plot(trials, prob_reward_left_seq)
hold on 
plot(trials, prob_reward_right_seq)
hold off
xlabel('Trial')
ylabel('Reward Probability')
title('The Reward Probability Changes with the Trial')
legend('Left', 'Right')
% Don't let the figure window display
set(gcf,'Visible','off')
% Save the figure as jpg file
saveas(gcf, 'reward_prob_seq.jpg')

%% ---------------------------------------------------------
% Create empty data objects:
% ---------------------------------------------------------

% Axis-1(Python NumPy representation) represents trials
% The first column represents trial number
% The second column represents response
% The third column represents reaction time (RT)
% The fourth column represents score ('score')
% The fifth column represents if outcome is reward ('is_reward')
% The sixth column represents if repeat last choice after receiving reward
% ('is_repeated_after_reward')
% The seventh column represents if repeat last choice after receiving punishment
% ('is_repeated_after_punishment')
data = [trials' nan(trials_num, 6)];
data = num2cell(data);
total_score = 0;

%% ---------------------------------------------------------
% Concatenate condition sequence
% ---------------------------------------------------------

condition_seq = [trials;...
    in_blocks_indexes;...
    is_safe_condition_seq; ...
    prob_reward_left_seq;...
    prob_reward_right_seq;...
    is_time_for_shock_seq];