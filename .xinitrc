xrandr --output HDMI-0 --mode "1920x1080" --rate 144 --primary &
gnome-keyring-daemon --start --components=secrets &
feh --bg-fill ~/wallpapers/mountain-illustration.png &
exec i3
