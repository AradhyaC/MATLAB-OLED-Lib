# MATLAB OLED Display Interface Library
NOTE: Currently only supports SSD1315 0.96" OLED screen included in the Grove Beginner Kit for Arduino.
## Prerequisites
| Name | Description |
| ---- | ----------- |
| MATLAB | https://www.mathworks.com/products/matlab.html |
| MATLAB Support Package for Arduino Hardware | https://www.mathworks.com/matlabcentral/fileexchange/47522-matlab-support-package-for-arduino-hardware |
| Grove Cable of any size (only if you're using the Grove Beginner Kit for Arduino and you have removed the OLED from the base board *) | https://www.seeedstudio.com/Grove-Universal-4-Pin-20cm-Unbuckled-Cable-5-PCs-Pack-p-749.html |

## Usage
Unpack and place the files in the same directory as your main code script to use the functions below.<br>
For example, if you are making a thermostat your file directory should look like the following:

**Thremostat Project Folder**<br>
│─ *thermostat.m*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(or whatever your main file is called)<br>
│─ *Initialize_Oled.m*<br>
│─ *display_write.m*<br>
│─ *test_write_draw.m*<br>
│─ *clearDisplay.m*<br>
│─ *LICENSE*<br>
│─ *README.md*<br>
│─ assets<br>
│&nbsp;&nbsp;&nbsp;&nbsp;│─ images<br>
│&nbsp;&nbsp;&nbsp;&nbsp;│─ characters<br>

## Functions
### Initialize_Oled()
Initializes and cleans up SSD1315 OLED Display provided with Grove Beginner Kit for Arduino.
```
Inputs:
a | Arduino object (with or without I2C Library)
print_ready | Displays ready statement if true
```
```
Optional Inputs:
i2cAddress | i2c address for the Oled display (defualt='0X3C' for most)
```
```
Returns:
oled | I2C object for Grove OLED Display
a | Arduino object with I2C Library
```
<br><br>
### clearDisplay()
Clears OLED display
```
Inputs:
oled | I2C object for Grove OLED Display
```
<br><br>
### display_write()
Writes text or draws image as per user-defined requirements
```
Inputs:
oled | oled device object
display_mode | 1 = write text, 0 = draw image (more options coming soon)
clear_display | 1 = clear display before proceeding, 0 = do not clear
```
```
Inputs if display_mode = 1
column_start | starting point of columns (1 to 128)
column_end | ending point of columns (1 to 128)
page_start | starting point of pages (1 to 8)
page_end | ending point of pages (1 to 8)
font_scale | only 1 and 2 scales supported currently
input_text | text to display on screen
```
```
Inputs if display_mode = 0
imagePath | load sample or provide path to image
minThreshold | minimum (black) threshold of image
maxThreshold | maximum (white) threshold of image
```
## Example files & Testing
### test_write_draw.m
This is a test file for demonstration and testing.<br>The first two expected function calls demonstrate the writing and drawing capabilities of the function.
<br> The following lines of commented code are the erronous function calls that test invalid outputs.<br>
### clock_example.m
This file demonstrates the full functionality of the function library by creating a live clock face that displays date, time, city, timezone, and updates every minute.
<br>
## Additional Notes
In the case of the *Grove Beginner Kit for Arduino* :
1. you **do not** need to remove the OLED screen from the base board.
2. the I2C Address of the OLED screen is the default ```0x3C```.
<br> Only a font scale of 1 and 2 are currently supported by the function library.
<br>
