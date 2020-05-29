%% Initilization

% Invoked by run.m

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

PsychDefaultSetup(2);

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