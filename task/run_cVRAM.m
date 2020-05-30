%% Controlling the overall experiment progress, including:

% 1. Initilization (subject information registration; empty data objects, PTB settings, etc.);
% 2. Opening instructions;
% 3. Experiment tasks;
% 4. Data outputing API;
% 5. Ending.

% CONSERVE VRAM VER.

%% ========================================================
% 1. Initilization
% =========================================================

%% ---------------------------------------------------------
% Something basic
% ---------------------------------------------------------

sca;
close all;
clearvars;

%% ---------------------------------------------------------
% Subject information registration
% ---------------------------------------------------------

% Pop an input dialog box asking for subject ID
% (use questionnaire to collect gender and age information)
subject_id = inputdlg('Enter your subject ID');
subject_id = subject_id{1};

%% ---------------------------------------------------------
% PTB setup
% ---------------------------------------------------------

Screen('Preference', 'ConserveVRAM', 64);

%% ---------------------------------------------------------
% Make PTB screen settings
% ---------------------------------------------------------

% Specify the screen
screen_number = max(Screen('Screens'));
% Define black and white
white = WhiteIndex(screen_number);
black = BlackIndex(screen_number);
% Background color
grey = [165 165 165] .* (1/255);
% Open the window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screen_number, grey);
% Get the size of the on screen window
[screen_x_pixels, screen_y_pixels] = Screen('WindowSize', window);
% Get the center position of the window
[x_center, y_center] = RectCenter(windowRect);
% Retreive the maximum priority number
top_priority_level = MaxPriority(window);
% Anti-aliasing
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Defensive debugging
disp('defensive debugging: screen setting completed')

%% ---------------------------------------------------------
% Make PTB accurate timing settings
% ---------------------------------------------------------

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);
% Interstimulus interval time in seconds and frames
isi_time_secs = 1;
frames_per_sec = round(isi_time_secs / ifi);
% Number of frames to wait before re-drawing
waitframes = 1;
% Defensive debugging
disp('defensive debugging: timing setting completed')

%% ---------------------------------------------------------
% Make PTB keyboard settings
% ---------------------------------------------------------

% Unify key names settings
KbName('UnifyKeyNames')
% The available keys to press
% Escape: Quit the program (esp. for debugging)
% (this key code is only available on MacOS)
key_esc = KbName('ESCAPE');
% R: Practice again
key_r = KbName('r');
% Q: Continue(halfway) or quit(end)
key_q = KbName('q');
% F: Select left bandit
key_f = KbName('f');
% J: Select right bendit
key_j = KbName('j');
% Defensive debugging
disp('defensive debugging: keyboard setting completed')

%% ---------------------------------------------------------
% Make PTB sound and image settings
% ---------------------------------------------------------

% Preload wave sound
[y01, Fs01] = audioread('sound01.wav');
[y02, Fs02] = audioread('sound02.wav');
[y03, Fs03] = audioread('sound03.wav');
[y04, Fs04] = audioread('sound04.wav');
% Defensive debugging
disp('defensive debugging: sound setting completed')

%% ---------------------------------------------------------
% Prepare textures
% ---------------------------------------------------------

% Make the images into textures
i01_texture = make_image_texture('instruction01_opening.png', window);
i02_texture = make_image_texture('instruction02_opening.png', window);
i03_texture = make_image_texture('instruction03_practice_complete.png', window);
i04_texture = make_image_texture('instruction04_safe.png', window);
i05_texture = make_image_texture('instruction05_threat.png', window);
i06_texture = make_image_texture('instruction06_ending.png', window);
left_safe_texture = make_image_texture('bandit_left_safe.jpeg', window);
left_threat_texture = make_image_texture('bandit_left_threat.jpeg', window);
right_safe_texture = make_image_texture('bandit_right_safe.jpeg', window);
right_threat_texture = make_image_texture('bandit_right_threat.jpeg', window);
% Specify the position of bandits and text
y_position = screen_y_pixels * 0.5;
x_position_left = screen_x_pixels * 0.3;
x_position_right = screen_x_pixels * 0.7;
% Specify the destination
base_rect = [0 0 225 225];
destination_rect_left = CenterRectOnPointd(base_rect, x_position_left, y_position);
destination_rect_right = CenterRectOnPointd(base_rect, x_position_right, y_position);
% Defensive debugging
disp('defensive debugging: general scene setting completed')
disp('defensive debugging: PTB initilization completed')

%% ---------------------------------------------------------
% Set basic params of the probability sequence used hereafter
% ---------------------------------------------------------

% Set random seed
rng('shuffle');
% Set the starting probability
start_prob = 0.5;
% Set the mean value of moves in random walks
mu = 0;
% Set the standard deviation of moves in random walks,
% can't be too large or too small
sigma = 0.01;

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