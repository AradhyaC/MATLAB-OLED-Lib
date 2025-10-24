% Copyright (c) 2024 Aradhya Chawla
% SPDX-License-Identifier: MIT
% See the LICENSE file in the project root for license information.
%
% GitHub: https://github.com/AradhyaC

clearvars;
addpath(fileparts(fileparts(mfilename('fullpath'))));

try
    a = arduino_auto_connect();
    
    % Initialize explicitly
    % a = arduino(port, ...);
catch ME
    error([ME.identifier, ': ', ME.message ...
        ' Explicitly initialize the Arduino object.']);
end

% Initialize OLED device
oled = oled_init(a);

% Test drawing an image on the screen
oled_draw(oled, path="../assets/images/sample.png");
pause(5);

oled_clear(oled);
