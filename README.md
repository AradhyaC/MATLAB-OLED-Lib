# MATLAB OLED Library
NOTE: Currently only supports SSD1315 0.96" OLED screen included in the Grove Beginner Kit for Arduino although this code will be regurarly updated to include other OLEDs.

## Usage
### Initialize_Oled()
Initializes and cleans up SSD1315 OLED Display provided with Grove Beginner Kit for Arduino.
#### Inputs:
a | Arduino object (with or without I2C Library)<br>
print_ready | Displays ready statement if true
#### Optional Inputs:
i2cAddress | i2c address for the Oled display (defualt='0X3C' for most)
#### Returns:
oled | I2C object for Grove OLED Display
a | Arduino object with I2C Library
<br>_________________________________________________________________________________________<br>
### clearDisplay()
Clears OLED display
#### Inputs:
oled | I2C object for Grove OLED Display
<br>_________________________________________________________________________________________<br>
### display_write()
Writes text or draws image as per user-defined requirements
#### Inputs:
oled | oled device object
display_mode | 1 = write text, 0 = draw image (more options coming soon)
clear_display | 1 = clear display before proceeding, 0 = do not clear
#### Inputs if display_mode = 1
column_start | starting point of columns (1 to 128)
column_end | ending point of columns (1 to 128)
page_start | starting point of pages (1 to 8)
page_end | ending point of pages (1 to 8)
font_scale | only 1 and 2 scales supported currently
input_text | text to display on screen
#### Inputs if display_mode = 0
imagePath | load sample or provide path to image
minThreshold | minimum (black) threshold of image
maxThreshold | maximum (white) threshold of image
