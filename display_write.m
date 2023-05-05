function display_write(oled, display_mode, clear_display, varargin)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Display Write
% Author: Aradhya Chawla
% Github: https://github.com/AradhyaC
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% FUNCTION
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Writes text or draws image as per user-defined requirements
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% REQUIRED INPUTS
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% oled : oled device object
% display_mode : 1 = write text, 0 = draw image (more options coming soon)
% clear_display : 1 = clear display before proceeding, 0 = do not clear
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS IF display_mode = 1
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% column_start : starting point of columns (1 to 128)
% column_end : ending point of columns (1 to 128)
% page_start : starting point of pages (1 to 8)
% page_end : ending point of pages (1 to 8)
% font_scale : only 1 and 2 scales supported currently
% input_text : text to display on screen
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUTS IF display_mode = 0
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% imagePath : load sample or provide path to image
% minThreshold : minimum (black) threshold of image
% maxThreshold : maximum (white) threshold of image

if display_mode == 1
    % Checks
    if nargin < 9
        waitfor(msgbox("Missing Values","Error","error"));
        return
    end
    
    % Check if column starts and end points are correct
    column_start = varargin{1} - 1;
    column_end = varargin{2} - 1;
    if column_start > 127 || column_start < 0 || ...
            column_end > 127 || column_end < 0
        waitfor(msgbox("Invalid column_start and/or column_end values", ...
            "Error","error"));
        return
    elseif column_end <= column_start
        waitfor(msgbox("column_end must be greater than column_start"));
        return
    end

    % Check if page start and end points are correct
    page_start = varargin{3} - 1;
    page_end = varargin{4} - 1;
    if page_start > 7 || page_start < 0 || page_end > 7 || page_end < 0
        waitfor(msgbox("Invalid page_start and/or page_end values", ...
            "Error","error"));
        return
    elseif page_end < page_start
        waitfor(msgbox("page_end must be greater than page_start"))
        return
    end

    % Check that supported font scale is requested
    font_scale = varargin{5};
    if font_scale < 1
        waitfor(msgbox("font_scale cannot be less than 1","Error","error"));
        return
    elseif font_scale > 2
        waitfor(msgbox("font_scale greater than 2 is not supported", ...
            "Error","error"));
        return
    end

    % make sure input text is not empty
    input_text = varargin{6};
    if (sum(isstrprop(input_text,'alpha')) + ...
            sum(isstrprop(input_text,'digit'))) - ...
            sum(isstrprop(input_text,'wspace')) < 0 || ...
            strcmp(input_text,'')
        waitfor(msgbox("input_text cannot be empty","Error","error"));
        return
    end
    
    % Clear display if requested
    if clear_display == 1
        clearDisplay(oled);
    elseif clear_display ~= 0
        waitfor(msgbox("Clear display can only be 0 or 1","Error","error"));
        return
    end

    % Variables
    import_characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ:+-';
    space_char = 0;
    col_start = column_start;
    col_end = column_end;
    page_begin = page_start;
    page_endpoint = page_end;

    % Read and store characters
    % Generate and store binary version of character images
    for i = 1:length(import_characters)
        if import_characters(i) == ':'
            charread = imread('assets/characters/colon.png');
        else
            charread = imread('assets/characters/'+ ...
                string(import_characters(i))+'.png');
        end
        charread = rgb2gray(charread);
        [h,w] = size(charread);
        for x = 1:1:h
            for y = 1:1:w
                if charread(x,y) == 255
                    charout(x,y) = '1';
                else
                    charout(x,y) = '0';
                end
            end
        end
        Characters(:,:,i) = charread;
        Char_bin(:,:,i) = charout;
    end
    % Split and store larger scaled characters into equal 8x8 grids
    if font_scale > 1
        [~,~,page] = size(Characters);
        for i = 1:page
            scale_col_loc = 1;
            scale_row_loc = 1;
            sChars(:,:,i) = imresize(Characters(:,:,i), ...
                [h*font_scale w*font_scale],'nearest');
            [a_scaled, b_scaled] = size(sChars(:,:,i));
            
            for x = 1:8:a_scaled
                for y = 1:8:b_scaled
                    temp_mat = sChars(x:x+7,y:y+7,i);
                    for h = 1:height(temp_mat)
                        for l = 1:width(temp_mat)
                            if temp_mat(h,l) == 255
                                temp_binmat(h,l) = '1';
                            else
                                temp_binmat(h,l) = '0';
                            end
                        end
                    end
                    if scale_row_loc - 1 == font_scale
                        scale_row_loc = 1;
                        scale_col_loc = scale_col_loc + 1;
                    end
                    scaled_char{scale_row_loc,scale_col_loc,i}=temp_binmat;
                    scale_row_loc = scale_row_loc + 1;
                end
            end
        end
    end
    
    % Text to print to screen
    txt_to_print = upper(input_text);
    
    % Set column i2cAddress (from 0 - 127)
    write(oled, [0, hex2dec('21'), col_start, col_end]);
    % Set page i2cAddress (from 0 - 7)
    write(oled, [0, hex2dec('22'), page_begin, page_endpoint]);
    
    col_tracker = col_start;
    page_tracker = page_begin;
    
    % Begin printing
    for i = 1:length(txt_to_print)
        cId = strfind(import_characters,txt_to_print(i));
        % Handling larger font printing
        if font_scale > 1
            [row,col,~] = size(scaled_char(:,:,cId));
            for r = 1:row
                for c = 1:col
                    % If text has space
                    if isspace(txt_to_print(i)) == true
                        cId = space_char;
                        for j = 1:8
                            col_tracker = col_tracker + 1;
                            write(oled,[hex2dec('40'), cId])
                        end
                    else
                        q = flipud(scaled_char{c,r,cId});
                        q = q';
                        for k = 1:8
                            col_tracker = col_tracker + 1;
                            write(oled,[hex2dec('40'), ...
                                bin2dec(string(q(k,:)))])
                        end
                    end
                end
                % Track and set current column and page
                if r ~= row
                    col_tracker = col_start;
                    write(oled, [0, hex2dec('21'), col_tracker, col_end]);
                    page_tracker = page_tracker + 1;
                    write(oled, [0, hex2dec('22'), page_tracker, ...
                        page_endpoint]);
                elseif r == row
                    page_tracker = page_begin;
                    write(oled, [0, hex2dec('22'), page_tracker, ...
                        page_endpoint]);
                    col_start = col_tracker;
                    write(oled, [0, hex2dec('21'), col_tracker, col_end]);
                end
    
                if col_tracker == 128
                    page_tracker = page_begin + font_scale;
                    page_begin = page_tracker;
                    col_tracker = column_start;
                    col_start = column_start;
                    write(oled, [0, hex2dec('22'), page_tracker, ...
                        page_endpoint]);
                    write(oled, [0, hex2dec('21'), col_tracker, col_end]);
                end
    
            end
        % For standard size characters
        else
            if isspace(txt_to_print(i)) == true
                cId = space_char;
                for j = 1:8
                    col_tracker = col_tracker + 1;
                    write(oled,[hex2dec('40'), cId])
                end
            else
                cId = flipud(Char_bin(:,:,cId));
                cId = cId';
                for j = 1:8
                    col_tracker = col_tracker + 1;
                    write(oled,[hex2dec('40'), bin2dec(string(cId(j,:)))])
                end
            end
        end
    end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DRAW IMAGE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
elseif display_mode == 0
    if nargin < 5
        waitfor(msgbox("Missing Values","Error","error"));
        return
    end

    % Variables
    imagePath = varargin{1};
    minThreshold = varargin{2};
    maxThreshold = varargin{3};

    % maximum threshold must always be larger than minimum threshold
    if maxThreshold <= minThreshold
        waitfor(msgbox("Maximum threshold must be greater than the minimum " + ...
            "threshold","Error","error"));
        return
    end

    % Clear display if requested
    if clear_display == 1
        clearDisplay(oled);
    elseif clear_display ~= 0
        waitfor(msgbox("Clear display can only be 0 or 1","Error","error"));
        return
    end

    % Loading image
    if strcmp(imagePath, 'sample')
        % Photo by Helena Lopes from Pexels: 
        % https://www.pexels.com/photo/white-horse-on-green-grass-1996333/
        image = imread('assets/images/sample.png');
    else
        try
            image = imread(imagePath);
        catch ME
            msgbox(["File does not exist or"; "Invalid file path"], ...
                'Error', 'error')
            return
        end
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
    thresholds = [minThreshold maxThreshold];
    
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
else
    waitfor(msgbox("Display mode can only be between 0 and 1", ...
        "Error","error"));
        return
end
