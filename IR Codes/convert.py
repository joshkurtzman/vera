import xml.etree.ElementTree as et
tree = et.parse('C:\\Users\\Josh\\Documents\\Workspaces\\github\\vera\\IR Codes\\I_Codeset_LGTV.xml')
root = tree.getroot()
commands = []
for action in root.find("actionList"):
    commands.append({"name" : action.find("name").text,
    "data" : action.find("ir").text })

import yaml
print(commands)
print(yaml.dump(commands))
