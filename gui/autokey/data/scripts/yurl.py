"""
TODO Documentar Esto
Me Falta 
"""

import re
import time

# Esto parece magico
# Si le quito esto por desgracia, no obtengo url del clipboard, por que, no se.
time.sleep(0.25)

reCaracteresAceptados =  '[^a-zA-Z0-9 \n\.]';

clipboard.fill_clipboard("")

# Esto es algo bonito, algunas nombres de las ventanas continene metacaracteres regex, 
# y lo por lo tanto hay que escaparlos.

originalTitle = window.get_active_title();

winTitle = re.sub(reCaracteresAceptados, '.', window.get_active_title()) 
winClass = window.get_active_class()

cmd = f'/home/dvictoriano/Code/Utils/uyurl "{winTitle}"'

system.exec_command(cmd)

url = clipboard.get_clipboard()
texto  = f'[{originalTitle}]({url})'
texto  = texto.replace("Google Chrome", " ")

clipboard.fill_clipboard(texto)

# Para quitar el foco de la barra de navegacion
keyboard.send_key("<f10>")
keyboard.send_key("<escape>")
    