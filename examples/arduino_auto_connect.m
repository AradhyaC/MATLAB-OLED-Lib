function a = arduino_auto_connect()
    % Find any available and connected serial ports
    available_ports = serialportlist("available");
    
    % Check if at least one port is available before attempting to connect
    if ~isempty(available_ports)
        % Assume the last available port corresponds to the Arduino device
        port = available_ports(end);
        a = arduino(port);
    else
        error('No available serial ports found. Please connect your Arduino and try again.');
    end
end

