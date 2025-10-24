function oled = oled_init(a, options)
% oled_init - Initialize and clean up SSD1315 OLED display
%
%  Syntax
%    oled = oled_init(a);
%    oled = oled_init(a, i2c_address='0x3C');
%
%  Input Arguments
%    a - Arduino object (with or without I2C Library)
%    i2c_address - I2C address of OLED display
%      '0x3C' (default) | character vector | string scalar
%
%  Output Arguments
%    oled - OLED I2C device object
%      I2C object

%   Copyright 2024 Aradhya Chawla
    
    arguments
        a (1,1) arduino
        options.i2c_address {mustBeText} = '0x3C' 
    end
    
    i2c_address = options.i2c_address;

    % Raise an error if `a` is not initalized with I2C Library
    if ~ismember('I2C', a.Libraries)
        error(['Arduino object must be initialized with the I2C library. ', ...
           'Use: a = arduino(port, Libraries="I2C");']);
    end
    
    % Scan for I2C Devices
    bus_list = scanI2CBus(a);
    if isempty(bus_list)
        error('No I2C devices detected on the bus.');
    end

    % Check if OLED screen is attached
    if ~any(strcmpi(bus_list, i2c_address))
        error('OLED screen not found at address %s.', ...
            i2c_address);
    end
    
    % OLED Display I2C Object
    oled = device(a,'I2CAddress', i2c_address);

    % According to the SSD1315 datasheet (Rev. 1.1):
    % 1. The minimal power-on initialization sequence is described in Section 6.9.1 
    %    "Power ON and OFF sequence with External VCC."
    % 2. It specifies powering VDD, toggling RES#, then powering VCC, and finally 
    %    sending the AFh command to turn on the display.
    % 3. This implementation uses a more complete startup sequence (contrast, 
    %    addressing mode, charge pump enable, etc.) for better reliability on
    %    Arduino boards that don't guarantee proper power sequencing.
    %
    % Link: https://cursedhardware.github.io/epd-driver-ic/SSD1315.pdf

    write(oled, [hex2dec('00'), hex2dec('AE')]);                               % Turn off the display
    write(oled, [hex2dec('00'), hex2dec('20'), hex2dec('00')]);                % Set memory mode
    write(oled, [hex2dec('00'), hex2dec('21'), hex2dec('00'), hex2dec('7F')]); % Set column address
    write(oled, [hex2dec('00'), hex2dec('22'), hex2dec('00'), hex2dec('07')]); % Set page address
    write(oled, [hex2dec('00'), hex2dec('81'), hex2dec('FF')]);                % Set contrast control
    write(oled, [hex2dec('00'), hex2dec('C0')]);                               % Set scan direction
    write(oled, [hex2dec('00'), hex2dec('A0')]);                               % Set segment remap
    write(oled, [hex2dec('00'), hex2dec('A6')]);                               % Set normal display
    write(oled, [hex2dec('00'), hex2dec('40')]);                               % Set display start line
    write(oled, [hex2dec('00'), hex2dec('8D'), hex2dec('14')]);                % Enable charge pump regulator
    pause(0.1);                                                                % Let charge pump stabilize
    write(oled, [hex2dec('00'), hex2dec('AF')]);                               % Turn on the display
    
    % Display greeting
    oled_clear(oled);
    oled_write(oled, 'OLED DISPLAY INITIALIZED');
    pause(1);
    oled_clear(oled);
end
