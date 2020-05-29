%% A trial

% Must under the initiliaztion of run.m
% Must be invoked by practice.m or formal_experiment.m

% ---------------------------------------------------------
% Input
% ---------------------------------------------------------

% - window, frames_per_sec, waitframes @{initilization.m}
% - white, black @{initilization.m}
% - (position variables) @{initilization.m}
% - top_priority_level @{initilization.m}
% - destination_rect_left, destination_rect_right @{initilization.m}
% - left_safe_texture, right_safe_texture @{initilization.m}
% - left_threat_texture, right_safe_texture @{initilization.m}
% - key_f, key_j @{initilization.m}
% - total_score @{initilization.m}
% - condition_seq @{practice.m or formal_experiment.m}

% ---------------------------------------------------------
% Output
% --------------------------------------------------------- 

% - data (renewed)
% - total_score (renewed)
% - screen animation in a single trial

%% Set the priority

Priority(top_priority_level);

%% Initilize getters

in_block_index = condition_seq(2, i_trial);
is_safe = condition_seq(3, i_trial);
prob_reward_left = condition_seq(4, i_trial);
prob_reward_right = condition_seq(5, i_trial);
is_time_for_shock = condition_seq(6, i_trial);

%% Generate certain background

if is_safe
    % Color the screen blue
    % (not standard blue, just comply with the instruction background)
    Screen('FillRect', window, [16 114 189] .* (1/255));
    % Specify the texture to be displayed
    left_texture = left_safe_texture;
    right_texture = right_safe_texture;
elseif ~ is_safe
    % Color the screen red
    Screen('FillRect', window, [1 0 0]);
    % Specify the texture to be displayed
    left_texture = left_threat_texture;
    right_texture = right_threat_texture;
end

%% Present safe/threat condition instruction

% If at the beginning of a block
if in_block_index == 1 && is_safe == 1
    % Present safe condition instruction for 2 seconds
    Screen('DrawTexture', window, i04_texture);
    Screen('Flip', window);
    WaitSecs(2);
elseif in_block_index == 1 && is_safe == 0
    % Present threat condition instruction for 2 seconds
    Screen('DrawTexture', window, i05_texture);
    Screen('Flip', window);
    WaitSecs(2);
end

%% Present the fixation point for 0.5 second

% Set the size of the arms of the fixation cross
fix_cross_dim_pix = 20;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
x_coords = [-fix_cross_dim_pix fix_cross_dim_pix 0 0];
y_coords = [0 0 -fix_cross_dim_pix fix_cross_dim_pix];
all_coords = [x_coords; y_coords];
% Specify line width (in pixels)
line_width_pix = 4;
% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', window, all_coords,...
    line_width_pix, white, [x_center y_center], 2);
% Flip to the screen and wait for 0.5 second
Screen('Flip', window);
WaitSecs(0.5);

%% If is time for shock, present shock

% if this variable not equals to 0
if is_time_for_shock ~= 0
    % Sound shock
    sound_index = is_time_for_shock;
    if sound_index == 1
        sound(y01, Fs01);
    elseif sound_index == 2
        sound(y02, Fs02);
    elseif sound_index == 3
        sound(y03, Fs03);
    elseif sound_index == 4
        sound(y04, Fs04);
    end
    % Frame shock for 2 seconds
    for i = 1:round(2 * frames_per_sec / 5)
        % Flip to purple screen
        Screen('FillRect', window, [0.5 0 0.5]);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        % Flip to red screen
        Screen('FillRect', window, [1 0 0]);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        % Flip to orange screen
        Screen('FillRect', window, [1 0.9 0.3]);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        % Flip to black screen
        Screen('FillRect', window, black);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        % Flip to red screen
        Screen('FillRect', window, [1 0 0]);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
end

%% Select a bandit within 3 seconds

% Play a beep sound
sound(0.4 * sin(1:1000));
% Flip to the screen and set the timestamp
vbl = Screen('Flip', window);
onset = vbl;
% Within 3 seconds
for i = 1:3 * frames_per_sec
    % Draw the safe bandits
    Screen('DrawTexture', window, left_texture, [], destination_rect_left);
    Screen('DrawTextures', window, right_texture, [], destination_rect_right);
    % Check the keyboard
    [keyIsDown, secs, keyCode] = KbCheck;
    % If press key F or key J, display and get the respond, the RT(ms) 
    % and then break the for-loop
    if keyCode(key_f)
        response = 'left';
        RT = round((GetSecs - onset) * 1000);
        break
    elseif keyCode(key_j)
        response = 'right';
        RT = round((GetSecs - onset) * 1000);
        break
    % If press key ESC, quit the scene
    % (this key is only available on MacOS)
    elseif keyCode(key_esc)
        disp('terminated by user')
        sca;
        break
    % Else if 3 seconds passed
    elseif i == 3 * frames_per_sec
        response = 'NA';
        RT = 'NA';
    end
    % Refresh the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
end

% Play a beep sound, allow the  participant to realize
% that the decision has been made
sound(0.3 * sin(0.1 * pi * (1:2000)));

%% Generate the reward/punishment outcome and display it

% Get the current reward probability
% and set the text displayed in following frames
if strcmp(response, 'left')
    reward_prob = prob_reward_left;
    text_x_position = x_position_left * 0.9;
elseif strcmp(response, 'right')
    reward_prob = prob_reward_right;
    text_x_position = x_position_right * 0.9;
elseif strcmp(response, 'NA')
    text_x_position = x_center * 0.9;
    score_text = 'NA';
    score = 0;
    is_reward = 'NA';
end
% Stochastically determine the reward/punishment (if has)
if ~ strcmp(response, 'NA')
    if rand <= reward_prob
        score = 4;
        score_text = '+4$';
        is_reward = 1;
    else
        score = -4;
        score_text = '-4$';
        is_reward = 0;
    end
end

% % For quick stress test
% WaitSecs(0.1);

%% Present the score text

if strcmp(num2str(is_reward), '1')
    Screen('TextSize', window, 70);
    DrawFormattedText(window, score_text, text_x_position,...
        'center', white);
elseif strcmp(num2str(is_reward), '1')
    
elseif strcmp(num2str(is_reward), 'NA')
    
end
Screen('Flip', window);

%% If not in practice mode, record the data 
% and renew the total point (not in practice)

if is_practice == false
    % Store the "response" into data matrix
    data{i_trial, 2} = response;
    % Store the "RT" into data matrix
    data{i_trial, 3} = RT;
    % Store the "score" into data matrix
    data{i_trial, 4} = score;
    % Store the "is_reward" into data matrix
    data{i_trial, 5} = is_reward;
    % Renew the total score
    if ~strcmp(num2str(total_score), 'NA')
        total_score = total_score + score;
    end
end

%% Debug use

% if i_trial == 75
%     sca;
% end