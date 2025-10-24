function oled_draw(oled, options)
% oled_draw - Draw image on the display
%
%  This function reads an image, converts it to grayscale, and then 
%  displays it on the OLED screen using I2C communication.
%  Since the OLED is monochrome (black and white), the image is binarized 
%  using two user-defined thresholds that determine which pixels appear 
%  black (min) or white (max) on the screen.
%
%  Input Arguments
%    oled - OLED I2C device object
%      I2C object
%    image_path - Path to image
%      character vector | string scalar
%    min_threshold - Minimum (black) threshold
%      0 to 255
%    max_threshold - Maximum (white) threshold
%      0 to 255

%   Copyright 2024 Aradhya Chawla

    arguments
        oled (1,1) matlabshared.i2c.device
        options.path {mustBeText} = 'assets/images/sample.png'
        options.min_threshold (1,1) {mustBeInteger, mustBeInRange(options.min_threshold,0,255)} = 10
        options.max_threshold (1,1) {mustBeInteger, mustBeInRange(options.max_threshold,0,255)} = 100
    end
    
    path = options.path;
    min_threshold = options.min_threshold;
    max_threshold = options.max_threshold;
    % maximum threshold must always be larger than minimum threshold
    if max_threshold <= min_threshold
        error("Maximum threshold (%d) must be greater than the minimum (%d)", ...
            max_threshold, min_threshold);
    end

    try
        image = imread(path);
    catch ME
        error("File does not exist or invalid file path");
    end
    
    % Convert to grayscale for monochromatic display
    bwImage = rgb2gray(image);

    % Get picture height and width
    [pH,pW] = size(bwImage);

    % Defining screen dimensions
    screen_height = 64;
    screen_width = 128;

    % Get picture height to screen height ratio
    pHS_ratio = pH/screen_height;
    % Get picture width to screen width ratio
    pWS_ratio = pW/screen_width;

    % Determine and proceed to scale along the largest dimension
    if pHS_ratio > pWS_ratio
        c = 1;
        image_resized = imresize(bwImage,[screen_height,NaN]);
        [pHr,pWr] = size(image_resized);
        wlRemainder = floor((screen_width - pWr)/2);
        wrRemainder = ceil((screen_width - pWr)/2);
        hlRemainder = '0';
        hrRemainder = '0';
    elseif pHS_ratio < pWS_ratio
        c = 2;
        image_resized = imresize(bwImage,[NaN,screen_width]);
        [pHr,pWr] = size(image_resized);
        wlRemainder = '0';
        wrRemainder = '0';
        hlRemainder = floor((screen_height - pHr)/2);
        hrRemainder = ceil((screen_height - pHr)/2);
    else
        c = 3;
        image_resized = imresize(bwImage,[screen_height,screen_width]);
        [pHr,pWr] = size(image_resized);
        wlRemainder = floor((screen_width - pWr)/2);
        wrRemainder = ceil((screen_width - pWr)/2);
        hlRemainder = floor((screen_height - pHr)/2);
        hrRemainder = ceil((screen_height - pHr)/2);
    end
    
    % Converting to binary matrix
    thresholds = [min_threshold max_threshold];
    
    for i = 1:pHr
        for j = 1:pWr
            if image_resized(i,j) < thresholds(2) && ...
                    image_resized(i,j) > thresholds(1)
                binImage(i,j) = '0';
            else
                binImage(i,j) = '1';
            end
        end
    end
    
    % Filling in gaps
    f1 = repmat(hlRemainder,pHr,wlRemainder);
    f2 = repmat(hrRemainder,pHr,wrRemainder);
    if c == 1
        final_image = [f1 binImage f2];
    elseif c == 2
        final_image = [f1;binImage;f2];
    else
        final_image = binImage;
    end
    temp_Count = 1;
    for i = 1:8:64
        image_rows(:,:,temp_Count) = final_image(i:i+7,:);
        temp_Count = temp_Count + 1;
    end
    temp_Count = 1;
    for i = 1:8
        temp_mat = image_rows(:,:,i);
        for j = 1:8:128
            image_matrix(:,:,temp_Count) = temp_mat(:,j:j+7);
            temp_Count = temp_Count + 1;
        end
    end
    
    % Set column i2cAddress
    write(oled, [hex2dec('00'), hex2dec('21'), 0, 127]);
    % Set page i2cAddress
    write(oled, [hex2dec('00'), hex2dec('22'), 0, 7]);
    
    % Draw to screen
    for i = 1:128
        temp_mat = flipud(image_matrix(:,:,i));
        temp_mat = temp_mat';
        for j = 1:8
            write(oled,[hex2dec('40'), bin2dec(string(temp_mat(j,:)))])
        end
    end
end
