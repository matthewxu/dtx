yum install Xvfb
#run xvfb
#Xvfb :1 -fp /usr/share/X11/fonts/misc -screen 0 1024x768x24 &
#or startx -- `which Xvfb` :1 -screen 0 1024x768x24
#run application on xvfb
#DISPLAY=localhost:7 xulrunner application.ini
