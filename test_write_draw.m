%clear all; close all; clc
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Testing File for writing and drawing
% Author: Aradhya Chawla
% Github: https://github.com/AradhyaC
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% FUNCTION
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Tests to ensure correct functionality of drawing and writing operations
% of library
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   REFERENCE
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%   WRITE
% function display_write(oled, display_mode, clear_display, column_start,
% column_end, page_start, page_end, font_scale, input_text)
%
%   DRAW
% function display_write(oled, display_mode, clear_display, imagePath,
% minThreshold, maxThreshold)


% Get Arduino object (define port and  board type if more than one
% connected)
%a = arduino;

% Initialize OLED device
%[oled,a] = Initialize_Oled(a,0);

% Constants
testString = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ:+-';
% 
% % Expected input for writing text
% display_write(oled, 1, 1, 1, 128, 1, 8, 1, testString)
% clearDisplay(oled);
% % pause(3);
% Expected input for drawing sample image
display_write(oled, 0, 1, 'sample', 10, 100)
clearDisplay(oled);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TESTING FOR WRITING
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % wrong display mode --> expected error message
% display_write(oled, 2, 1, 1, 128, 1, 8, 1, testString)
% 
% % wrong clear_display value --> expected error message
% display_write(oled, 1, 2, 1, 128, 1, 8, 1, testString)
% 
% % incorrect column start value --> expected error message
% display_write(oled, 1, 1, 0, 128, 1, 8, 1, testString)
% 
% % incorrect column end value --> expected error message
% display_write(oled, 1, 1, 1, 129, 1, 8, 1, testString)
%
% % incorrect column end value --> expected error message
% display_write(oled, 1, 1, 1, 0, 1, 8, 1, testString)
% 
% % incorrect column start and end value --> expected error message
% display_write(oled, 1, 1, 13, 1, 1, 8, 1, testString)
% 
% % incorrect page start value --> expected error message
% display_write(oled, 1, 1, 1, 128, 0, 8, 1, testString)
% 
% % incorrect page end value --> expected error message
% display_write(oled, 1, 1, 1, 129, 1, 9, 1, testString)
% 
% % incorrect page start and end value --> expected error message
% display_write(oled, 1, 1, 1, 129, 8, 1, 1, testString)
% 
% % fontscale value less than 1 --> expected error message
%  display_write(oled, 1, 1, 1, 128, 1, 8, 0, testString)
% 
% % fontscale value greater than 2 --> expected error message
%  display_write(oled, 1, 1, 1, 128, 1, 8, 3, testString)
% 
% % empty input text --> expected error message
%  display_write(oled, 1, 1, 1, 128, 1, 8, 1, '')
% 
% % input text with spaces only --> expected error message
%  display_write(oled, 1, 1, 1, 128, 1, 8, 1, '   ')
% 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TESTING FOR DRAWING
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% % Incorrect image path --> expected error message
% display_write(oled, 0, 1, 'asdasf/xyz.jpg', 10, 100)
% 
% % Incorrect clear_display value --> expected error message
% display_write(oled, 0, 2, 'sample', 10, 100)
% 
% % Incorrect thresholds --> expected error message
% display_write(oled, 0, 1, 'sample', 100, 10)
