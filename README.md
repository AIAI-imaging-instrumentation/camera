# camera
Control the ThorLabs DCC3240M camera from matlab

## Installation

Install ThorCam using the default options

Make sure you have a matlab compatible compiler installed. The lab computers have Windows SDK 7.https://www.microsoft.com/en-us/download/details.aspx?id=8279

Open matlab, change directory to imaging_instrumentation/mymatueye and run the install script

Restart matlab

Add imaging_instrumentation/mymatueye to path

initialize camera with 

    c = Camera(0);
