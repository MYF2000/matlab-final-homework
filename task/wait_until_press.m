% Input: key name
% Output: continue the process
function wait_until_press(key_name)
    exit_loop = false;
    while exit_loop == false
    % Check the keyboard to see if a button has been pressed
    [keyIsDown, secs, keyCode] = KbCheck;
    % Depending on the button press to exit the loop
        if keyCode(key_name)
            exit_loop = true;
        end
    end
end