#	Screensaver
xscreensaver -no-splash &

#	Set cursor as pointer
xsetroot -cursor_name left_ptr

#	Set background
feh --bg-scale /home/drew/.xmonad/wallpaper/HardBoiled02.jpg

#	Start window manager
exec xmonad

#	Enable wifi
ip link set wlo1 up

#	Connect to network
systemctl start netctl-auto@wlo1.service

#	Set numlock on
numlockx &

#	Kill beep
xset -b
