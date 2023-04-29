function clearDisplay(oled)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Clear Display
% Author: Aradhya Chawla
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% FUNCTION
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Clears OLED display
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Set column i2cAddress
write(oled, [hex2dec('00'), hex2dec('21'), hex2dec('00'), hex2dec('7F')]); 
% Set page i2cAddress
write(oled, [hex2dec('00'), hex2dec('22'), hex2dec('00'), hex2dec('07')]); 
for i = 1:9*8
    write(oled,[hex2dec('40'),uint64(0)]);
end
end