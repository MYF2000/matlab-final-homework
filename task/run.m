%% Controlling the overall experiment progress, including:

% 1. Initilization (subject information registration; empty data objects, PTB settings, etc.);
% 2. Opening instructions;
% 3. Experiment tasks;
% 4. Data outputing API;
% 5. Ending.

%% ========================================================
% 1. Initilization
% =========================================================

% Prepare essential variables
initilization;

%% ========================================================
% 2. Opening instructions
% =========================================================

% Draw i01 to the screen
Screen('DrawTexture', window, i01_texture);
Screen('Flip', window);
% Press key Q to continue
wait_until_press(key_q);
% Sine wave sound effect
sound(0.3 * sin(0.1 * pi * (1:2000)));
% Wait 0.5 second in order to prevent continuous effect of the key Q
WaitSecs(0.5);
% Draw i02 to the screen
Screen('DrawTexture', window, i02_texture);
Screen('Flip', window);
% Press key Q to continue
wait_until_press(key_q);
% Sine wave sound effect, amplitude indicates loudness
sound(0.3 * sin(0.1 * pi * (1:2000)));

%% ========================================================
% 3. Experiment tasks
% =========================================================

% ---------------------------------------------------------
% Set the number of trials
% ---------------------------------------------------------

blocks_num = 4;
trials_per_block = 40;
trials_num = trials_per_block * blocks_num;

% ---------------------------------------------------------
% Practicing block: safe trials *20
% ---------------------------------------------------------

practice;

% A cue indicating if the trial script should record the bahavior
is_practice = false;

% ---------------------------------------------------------
% Generate condition sequence:
% (safe-threat-safe-threat) * 40 trials
% ---------------------------------------------------------

generate_condition;

% ---------------------------------------------------------
% Start formal experiment
% ---------------------------------------------------------

formal_experiment;

% Prevent mysterious crash due to press the key too instantly
WaitSecs(0.3);

% % !!!!!!!!!!!!!!!!!!!!!!!
% sca;

%% ========================================================
% 4. Data outputing API
% =========================================================

% Use certain logical rules to generate the data of 5th and 6th columns
for i = 1:trials_num
    if i == 1
        data{1, 6} = 'NA';
        data{1, 7} = 'NA';
    % If receive reward last trial
    elseif data{i-1, 5} == 1
        data{i, 7} = 'NA';
        % Check if repeat last choice
        if strcmp(data{i-1, 2}, data{i, 2})
            data{i, 6} = 1;
        elseif ~strcmp(data{i-1, 2}, data{i, 2})
            data{i, 6} = 0;
        end
    % If receive punishment last trial 
    elseif data{i-1, 5} == 0
        data{i, 6} = 'NA';
        % Check if repeat last choice
        if strcmp(data{i-1, 2}, data{i, 2})
            data{i, 7} = 1;
        elseif ~strcmp(data{i-1, 2}, data{i, 2})
            data{i, 7} = 0;
        end
    % If there is no response last trial
    elseif strcmp(data{i-1, 5}, 'NA')
        data{i, 6} = 'NA';
        data{i, 7} = 'NA';
    end
end
% Generate headers and subject_id column
nan_mat = num2cell(nan(1, 6));
id = repmat({subject_id}, trials_num, 1);
headers = {'subject_id', 'trial_num', 'response', 'RT', 'score', 'is_reward',...
    'is_repeated_after_reward', 'is_repeated_after_punishment'};
data = [id data];
% Generate final output matrix and form a xls file
data_output = [headers; data];
writecell(data_output, ['subject_' num2str(subject_id) '_data.xls']);
% Display: data manipulation completed
disp('Experiment data output completed')

disp('=========================================================')
disp('>>>            Processing... Please wait!             <<<')
disp('=========================================================')

%% ========================================================
% 5. Ending
% =========================================================

% Ending instruction
Screen('DrawTexture', window, i06_texture);
Screen('Flip', window);
% Press key Q to continue
wait_until_press(key_q);
% Quit PTB interface
sca;

% Collect anxiety evaluation point
prompt = {'Enter your anxiety level under the SAFE condition (0 - not at all; 10 - very much so)',...
    'Enter your anxiety level under the THREAT condition (0 - not at all; 10 - very much so)'};
dims = [1 100];
dlgtitle = 'Type your evaluation:';
definput = {'NA', 'NA'};
answer = inputdlg(prompt, dlgtitle, dims, definput);
evaluation_safe = answer{1};
evaluation_threat = answer{2};
ev_safe = {'evaluation_safe', evaluation_safe};
ev_threat = {'evaluation_threat', evaluation_threat};
ev_output = [{'subject_id'} subject_id ev_safe ev_threat];
% Write evaluation point into another output file
disp('=========================================================')
disp('*** [Please wait, system is outputing data...] ***')
disp('=========================================================')
writecell(ev_output, ['subject_' subject_id '_ev.xls']);
disp('=========================================================')
disp('*** [Output 100% completed.] ***')
disp('=========================================================')
% Compute and display score bonus amount
disp('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$')
disp(['your score is ' num2str(total_score) '.'])
bonus = 1 + 0.01 * total_score;
if bonus < 1
    bonus = 1;
end
disp(['Your actual bonus is ' num2str(bonus) ' yuan.'])
disp('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$')
disp(['You can check the reward_prob_seq.jpg for your reward probability sequence.'])