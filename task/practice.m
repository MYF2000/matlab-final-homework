%% Practice block

% Invoked by run.m

%% Condition and debugging settings

% 20 safe trials
num_practice_trial = 20;

% % Temp!!!!!!!!!!!!!!
% num_practice_trial = 3;

temp_in_block_indexes = 1:num_practice_trial;
temp_in_blocks_indexes = 1:num_practice_trial;
temp_is_safe_condition_seq = ones(1, num_practice_trial);
temp_is_time_for_shock_seq = zeros(1, num_practice_trial);

% Cue: if the trial is a practice trial
is_practice = true;

%% Loop until press key Q at the end of the practice

exit_practice = false;
while exit_practice == false

    % ---------------------------------------------------------
    % Generate reward probability sequence
    % ---------------------------------------------------------

    temp_prob_reward_left_seq = generate_walk(start_prob, num_practice_trial, mu, sigma);
    temp_prob_reward_right_seq = generate_walk(start_prob, num_practice_trial, mu, sigma);

    % ---------------------------------------------------------
    % Generate the safe scene
    % ---------------------------------------------------------
    
    condition_seq = [1:num_practice_trial;...
        temp_in_blocks_indexes;...
        temp_is_safe_condition_seq;...
        temp_prob_reward_left_seq;...
        temp_prob_reward_right_seq;...
        temp_is_time_for_shock_seq];

    % ---------------------------------------------------------
    % Execute 20 trials
    % ---------------------------------------------------------

    for i_trial = condition_seq(1,:)
        trial
    end

    % ---------------------------------------------------------
    % Display the instruction until hit the certain key
    % ---------------------------------------------------------
    
    % Color the screen grey
    Screen('FillRect', window, grey);
    % Draw i03 to the screen
    Screen('DrawTexture', window, i03_texture);
    Screen('Flip', window);
    exit_loop = false;
    while exit_loop == false
    % Check the keyboard to see if a button has been pressed
    [keyIsDown, secs, keyCode] = KbCheck;
        % Depending on the button press to exit the loop
        % If press R, practice again
        if keyCode(key_r)
            % Play a beep sound
            sound(0.3 * sin(0.1 * pi * (1:2000)));
            exit_loop = true;
        elseif keyCode(key_q)
            % Play a beep sound
            sound(0.3 * sin(0.1 * pi * (1:2000)));
            exit_loop = true;
            exit_practice = true;
        end
    end
    
end