# Camera
Control the ThorLabs DCC3240M camera from matlab

## Installation

Install ThorCam using the default options

Make sure you have a matlab compatible compiler installed. The lab computers have Windows SDK 7.https://www.microsoft.com/en-us/download/details.aspx?id=8279

Open matlab, change directory to imaging_instrumentation/mymatueye and run the install script

Restart matlab

Add imaging_instrumentation/mymatueye to path

## Usage

Initialize camera with 

    c = Camera(0);
    
delete

    delete(c);
    
clear variable

    clear c
    
Capture image

    img = c.capture();
    
Note that the camera and Matlab use a different memory ordering, so in order to
make the image orientation match that of the camera, you'll probably want to
take the transpose of the image

    img = c.capture()';
    
Currently, there are four different camera properties you can change.
For more details, see section 2.6.1 of [this manual](https://www.thorlabs.com/drawings/267e4a3c18de8042-011876CC-948C-111C-2F00ADA1760E447C/DCC3240M-Manual.pdf).

    c.pixelclock
    c.framerate
    c.exposure
    c.aoi

To set these parameters, assign the new value directly. e.g.:

    c.pixelclock = 10;
    
Pixelclock, framerate, and exposure can only be set to discrete values. As long
as your target is withing the acceptable range, the camera should round to an
acceptable value. If you need to know the value exactly, check it after you set
it

    c.pixelclock = desiredpixelclock;
    actualpixelclock = c.pixelclock;
    
The following parameters are available to indicate allowed values:

    c.allowedpixelclock; % vector of allowed pixel clock values
    c.expsourerange; % [min, increment, max]
    c.frameraterange; % [min, max]
    
The aoi parameter takes a length 4 vector

    c.aoi = [xcorner, ycorner, width, height];
    
Test your aoi settings to ensure the image is what you expect

Changing these parameters will often result in other values changing. If
specific values are required, check them before acquiring.
