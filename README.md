# MATLAB OLED Library
A MATLAB library for Grove-compatible SSD1315 OLED displays.

## Prerequisites
| Name                                                         | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [MATLAB Support Package for Arduino Hardware](https://www.mathworks.com/matlabcentral/fileexchange/47522-matlab-support-package-for-arduino-hardware) | Enables communication between MATLAB and Arduino boards. |
| [4-Pin Jumper Cable](https://www.seeedstudio.com/Grove-Universal-4-Pin-20cm-Unbuckled-Cable-5-PCs-Pack-p-749.html) | Required **only** if the OLED display has been removed from the Grove base board. |


## Usage
Place the function files in the same directory as your main script to use the provided API.
For example, if you are making a thermostat project, your directory should look like the following:

```
.
├── thermostat.m       <------- YOUR SCRIPTS
├── ...
├── oled_init.m
├── oled_write.m
├── oled_draw.m
├── oled_clear.m
└── assets
   ├── images
   └── characters
```


## Examples
```matlab
clearvars;

port = "/dev/ttyUSB0";
a = arduino(port, "Uno", Libraries="I2C");

oled = oled_init(a);
oled_write(oled, "Example Text", font_scale=2);
pause(10);
oled_clear(oled);
oled_draw(oled, path="assets/images/sample.png", min_threshold=10, max_threshold=100);
```

Additional example scripts are included in the `examples/` directory to demonstrate the API.

## Additional Notes
* If you don't remove the OLED screen from the base board, the default I2C address of the OLED screen is `0x3C`.
* If the screen is separate, you can scan for I2C devices using the [scanI2CBus()](https://www.mathworks.com/help/matlab/supportpkg/arduinoio.scani2cbus.html) function.
