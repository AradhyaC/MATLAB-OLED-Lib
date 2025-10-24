function oled_clear(oled)
% olead_clear - Clear the entire OLED display
%
%  Input Arguments
%    oled - OLED I2C device object
%      I2C object

%   Copyright 2024 Aradhya Chawla

    arguments
        oled (1,1) matlabshared.i2c.device
    end

    % Set column i2cAddress
    write(oled, [hex2dec('00'), hex2dec('21'), hex2dec('00'), hex2dec('7F')]); 
    % Set page i2cAddress
    write(oled, [hex2dec('00'), hex2dec('22'), hex2dec('00'), hex2dec('07')]); 
    for i = 1:9*8
        write(oled,[hex2dec('40'),uint64(0)]);
    end
end
