%% Read image and makes it into a texture

function image_texture = make_image_texture(image_dir, window)
    % Load the image
    image = imread(image_dir);
    % Make the image into a texture
    image_texture = Screen('MakeTexture', window, image);
end