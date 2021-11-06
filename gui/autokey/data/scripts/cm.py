# cw

# .config/autokey/data/scripts/cw.py

"""
Use: 
cm: change monitor 

cm right : point mouse to the right monitor
cm left  : point mouse to the left monitor

Docs:

[How to move the mouse cursor between monitors with keys in Gnome3](https://itectec.com/ubuntu/ubuntu-how-to-move-the-mouse-cursor-between-monitors-with-keys-in-gnome3/)

[How to set focus follows mouse](https://itectec.com/ubuntu/ubuntu-how-to-set-focus-follows-mouse/)

[autokey](https://github.com/autokey/autokey)
"""

# State Machine
sm = {}

if store.has_key("sm"):
     sm  = store.get("sm")
else:
    sm = {
        "right"     : "left",
        "left"      : "right",
        "current"   : "right"
    }    
    store.set_value("sm" , sm)

next  =  sm[sm["current"]]
sm["current"] = next

cmd = "$HOME/configs/scripts/cw {}".format(next)
system.exec_command(cmd, getOutput=False)
