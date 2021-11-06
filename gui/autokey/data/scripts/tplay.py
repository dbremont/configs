# tplay

"""
Use: 
tplay: tougle pause / play

Docs:

[playerctl](https://github.com/altdesktop/playerctl)

- headphones mpris media player command-line controller for vlc, mpv, RhythmBox, web browsers, cmus, mpd, spotify and others.

pause='playerctl pause' 
play='playerctl play'
"""

# State Machine
sm = {}

if store.has_key("tplay"):
     sm  = store.get("tplay")
else:
    sm = {
        "pause"     : "play",
        "play"      : "pause",
        "current"   : "pause"
    }    
    store.set_value("tplay" , sm)

next  =  sm[sm["current"]]
sm["current"] = next

cmd = "/usr/bin/playerctl {}".format(next)
system.exec_command(cmd, getOutput=False)