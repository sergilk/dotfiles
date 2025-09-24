#!/bin/bash

action=$1

case $action in
    play) 
      mpv --no-video --really-quiet -ao=pipewire --volume=50 -profile=low-latency --cache=no "https://www.youtube.com/watch?v=jfKfPfyJRdk"
	  ;;
    stop)
		kill $(pgrep -f "mpv.*jfKfPfyJRdk")
	  ;;
    *)
        pgrep -f mpv.*jfKfPfyJRdk > /dev/null && echo "󰝚" || echo "󰝛"
      ;;
esac
