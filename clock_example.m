% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Clock Example using OLED Library for MATLAB
% Author: Aradhya Chawla
% Github: https://github.com/AradhyaC
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% FUNCTION
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generates an updating clock face with time, date, city, and timezone.
% Stops when D6 button is held for some time.
% Primary aim is to test if it is possible to update/refresh the screen
% reasonably.
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clear all; close all; clc

% Get Arduino object (define port and  board type if more than one
% connected)
a = arduino;
% Initialize OLED device
[oled,a] = Initialize_Oled(a,0);

% Get system date and time info
t = datetime('now','TimeZone','local');
% Get system date
date = string(datetime('now','TimeZone','local','Format','dd'));
% Get current day
d = day(t, 'name');
% Get current month
m = month(t, 'name');
% Get current year
y = year(t);
% Get current hour
h = string(datetime('now','TimeZone','local','Format','HH'));
% Get current minute
mnt = string(datetime('now','TimeZone','local','Format','mm'));

% Get system timezone info
tZone = datetime('now','TimeZone','local','Format','z Z');
% Get current city
zone = strsplit(tZone.TimeZone,'/');
zone = zone{:,2};
if contains(zone,'_')
    zone = strrep(zone,'_',' ');
end

% Convert days to short-form if output does not fit on one line
d_chars = char(d{1});
d_short = d_chars(1:3);

% Convert month to short-form if output does not fit on one line
m_chars = char(m{1});
m_short = m_chars(1:3);

% Set font scale and write day date month year to screen
font_scale = 1;
date_text = sprintf('%s %s %s %s',d{1},date,m{1},string(y(1)));
date_txt_length = length(date_text)*8;
column_start = (128 - date_txt_length)/2; % getting starting position
% Set to short-form version of date and month if output 
% does not fit on one line
if column_start < 0
    date_text = sprintf('%s %s %s %s',d_short,date,m_short,string(y(1)));
    date_txt_length = length(date_text)*8;
    column_start = (128 - date_txt_length)/2;
end
% Call to write date
display_write(oled, 1, 1, column_start, 128, 1, 2, font_scale, date_text)

% Set font scale and write hours and minutes to screen
font_scale = 2;
time_text = sprintf('%s:%s',h,mnt);
time_text_length = length(time_text)*8*font_scale;
column_start = (128 - time_text_length)/2;

display_write(oled, 1, 0, column_start, 128, 3, 4, font_scale, time_text)

% Set font scale and write timezone zone to screen
font_scale = 1;
zone_text = char(zone);
zone_text_length = length(zone_text)*8;
column_start = (128 - zone_text_length)/2;

display_write(oled, 1, 0, column_start, 128, 6, 6, font_scale, zone_text)


% Set font scale and write timezone info to screen
font_scale = 1;
tZone_text = char(tZone);
tZone_text_length = length(tZone_text)*8;
column_start = (128 - tZone_text_length)/2;

display_write(oled, 1, 0, column_start, 128, 7, 7, font_scale, tZone_text)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TIME UPDATE LOOP
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

stop = false;
while ~stop
    tZone_new = datetime('now','TimeZone','local','Format','z Z');
    zone_new = strsplit(tZone_new.TimeZone,'/');
    zone_new = zone_new{:,2};
    if contains(zone_new,'_')
        zone_new = strrep(zone_new,'_',' ');
    end
    t_new = datetime('now','TimeZone','local');
    date_new = string(datetime('now','TimeZone','local','Format','dd'));
    d_new = day(t_new, 'name');
    m_new = month(t_new, 'name');
    y_new = year(t_new);
    h_new = string(datetime('now','TimeZone','local','Format','HH'));
    mnt_new = string(datetime('now','TimeZone','local','Format','mm'));


    if ~strcmp(zone_new, zone) || ~strcmp(char(tZone_new), char(tZone))
        % Update day date month year on screen
        d_chars = char(d_new{1});
        d_short = d_chars(1:3);
        
        m_chars = char(m_new{1});
        m_short = m_chars(1:3);

        font_scale = 1;
        date_text = sprintf('%s %s %s %s',d_new{1},date_new, ...
            m_new{1},string(y_new(1)));
        date_txt_length = length(date_text)*8;
        column_start = (128 - date_txt_length)/2;

        if column_start < 0
            date_text = sprintf('%s %s %s %s',d_short,date, ...
                m_short,string(y(1)));
            date_txt_length = length(date_text)*8;
            column_start = (128 - date_txt_length)/2;
        end
        
        display_write(oled, 1, 1, column_start, 128, 1, 2, font_scale, ...
            date_text)
        
        d = d_new;
        m = m_new;
        y = y_new;
        date = date_new;
        
        % Update hours and minutes on screen
        font_scale = 2;
        time_text = sprintf('%s:%s',h_new,mnt_new);
        time_text_length = length(time_text)*8*font_scale;
        column_start = (128 - time_text_length)/2;
        
        display_write(oled, 1, 0, column_start, 128, 3, 4, font_scale, ...
            time_text)
        h = h_new;
        mnt = mnt_new;
        
        % Update timezone zone on screen
        font_scale = 1;
        zone_text = char(zone_new);
        zone_text_length = length(zone_text)*8;
        column_start = (128 - zone_text_length)/2;
        
        display_write(oled, 1, 0, column_start, 128, 6, 6, ...
            font_scale, zone_text)
        
        
        % Update timezone info on screen
        font_scale = 1;
        tZone_text = char(tZone_new);
        tZone_text_length = length(tZone_text)*8;
        column_start = (128 - tZone_text_length)/2;
        
        display_write(oled, 1, 0, column_start, 128, 7, 7, ...
            font_scale, tZone_text)
    elseif ~strcmp(mnt_new, mnt) || ~strcmp(h_new, h)
        % Update minutes and hours
        font_scale = 2;
        time_text = sprintf('%s:%s',h_new,mnt_new);
        time_text_length = length(time_text)*8*font_scale;
        column_start = (128 - time_text_length)/2;
        
        display_write(oled, 1, 0, column_start, 128, 3, 4, font_scale, ...
            time_text)
        h = h_new;
        mnt = mnt_new;

    elseif ~strcmp(d_new{1}, d{1}) || ~strcmp(m_new{1},m{1}) || ...
            ~strcmp(string(y_new(1)), string(y(1))) || ...
            ~strcmp(date_new, date)
        % update day month year date
        d_chars = char(d_new{1});
        d_short = d_chars(1:3);
        
        m_chars = char(m_new{1});
        m_short = m_chars(1:3);

        font_scale = 1;
        date_text = sprintf('%s %s %s %s',d_new{1},date_new, ...
            m_new{1},string(y_new(1)));
        date_txt_length = length(date_text)*8;
        column_start = (128 - date_txt_length)/2;

        if column_start < 0
            date_text = sprintf('%s %s %s %s',d_short,date, ...
                m_short,string(y(1)));
            date_txt_length = length(date_text)*8;
            column_start = (128 - date_txt_length)/2;
        end
        
        display_write(oled, 1, 0, column_start, 128, 1, 2, font_scale, ...
            date_text)
        
        d = d_new;
        m = m_new;
        y = y_new;
        date = date_new;
    end
    stop = readDigitalPin(a, 'D6');
end
% Clear display before disconnecting
clearDisplay(oled);
clear all
