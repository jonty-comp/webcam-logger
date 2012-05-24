Webcam Logging, Processing & Retreival
======================================

This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

What is this software?
----------------------

This software is a set of scripts designed for logging a small/medium collection of IP Cameras with minimum overhead and maximum space-efficiency.

Operation
---------

-Specify the cameras you wish to capture in the cameras.xml file.  Some parameters don't do anything yet.
-Open the capture.pl file and set the location of the log to somewhere with lots of space.  Personally I mount my fileserver on $log/log via NFS, which enables the script to continue capturing the current image if the log for some reason fills to capacity.
-Copy the webcams_process.sh script into /etc/cron.daily and set the log path correctly.  This script will take yesterday's images and process them into one video for each camera, with massive space savings compared to keeping the individual images.
-If required, move and adapt the frame.php script into your web root.  This file is only a sample I wrote to give an example of how to access images from the archive.

Bugs
----

Probably numerous.  File an issue with any bugs/feature requests you come up with!
