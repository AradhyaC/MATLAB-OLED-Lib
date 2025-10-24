function oled_write(oled, text, options)
% oled_write - Write text on the display
%
%  This function writes text to OLED screen using page addressing mode.
%  OLED display memory is divided into 8 horizontal "pages", each 8 pixels
%  tall and 128 pixels wide (for a 128x64 display).
%  Each page represents one 8-pixel-high band of vertical pixels across 
%  the screen. Writing data to a page updates those 8 vertical pixels in
%  the specified columns.
%
%  Input Arguments
%    oled - OLED I2C device object
%      I2C object
%    text - Text to display on screen
%      character vector
%    column_start - Starting column
%      1 (default) | 1 to 128
%    column_end - Ending column
%      128 (default) | 1 to 128
%    page_start - Starting page
%      1 (default) | 1 to 8
%    page_end - Ending page
%      8 (default) | 1 to 8
%    font_scale - Changes the dimensions of the output picture
%      1 (default) | 2

%   Copyright 2024 Aradhya Chawla

    arguments
        oled (1,1) matlabshared.i2c.device
        text {mustBeText, mustBeNonempty}
        options.column_start {mustBeInteger, mustBeInRange(options.column_start,1,128)} = 1
        options.column_end {mustBeInteger, mustBeInRange(options.column_end,1,128)} = 128
        options.page_start {mustBeInteger, mustBeInRange(options.page_start,1,8)} = 1
        options.page_end {mustBeInteger, mustBeInRange(options.page_end,1,8)} = 8
        options.font_scale {mustBeInteger, mustBeInRange(options.font_scale,1,2)} = 1
    end

    column_start = options.column_start - 1;
    column_end = options.column_end - 1;
    page_start = options.page_start - 1;
    page_end = options.page_end - 1;
    font_scale = options.font_scale;
    
    % Resolve assets dir relative to THIS file, not current folder
    base_dir   = fileparts(mfilename('fullpath'));
    assets_dir = fullfile(base_dir, 'assets', 'characters');

    if isstring(text)
        text = convertStringsToChars(text);
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
            imgPath = fullfile(assets_dir, 'colon.png');
        else
            imgPath = fullfile(assets_dir, sprintf('%s.png', import_characters(i)));
        end
        charread = imread(imgPath);
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
    txt_to_print = upper(text);
    
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
end
