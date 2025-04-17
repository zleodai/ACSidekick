#Required For AC APPS
import ac
import acsys
from third_party.sim_info import *

#Internal
from src.TelemetrySender import TelemetrySender as TelemetrySender

#AC Docs https://docs.google.com/document/d/13trBp6K1TjWbToUQs_nfFsB291-zVJzRZCNaTYt4Dzc/pub

#region GUI Globals
appName = "ACSidekick"
width, height = 335 , 400
#endregion

simInfo = SimInfo()

def acMain(ac_version):
    global appWindow # <- you'll need to update your window in other functions.

    appWindow = ac.newApp(appName)
    ac.setTitle(appWindow, appName)
    ac.setSize(appWindow, width, height)

    ac.addRenderCallback(appWindow, appGL) # -> links this app's window to an OpenGL render function

    createLabels()
    createButtons()

    return appName

def createLabels():
    global TemplateLabel
    TemplateLabel = ac.addLabel(appWindow, "Template")
    ac.setPosition(TemplateLabel, 0, 0)
    ac.setFontSize(TemplateLabel, 0)

def createButtons():
    global TemplateButton
    TemplateButton = ac.addButton(appWindow, "\nTemplate")
    ac.setPosition(TemplateButton, 0, 0)
    ac.setSize(TemplateButton, 0, 0)
    ac.setFontSize(TemplateButton, 0)
    ac.setFontAlignment(TemplateButton, "center")
    # ac.addOnClickedListener(TemplateButton, templateButtonPress)

def appGL(deltaT):#-------------------------------- OpenGL UPDATE
    """
    This is where you redraw your openGL graphics
    if you need to use them .
    """
    pass # -> Delete this line if you do something here !

def updateLabels():
    pass

def updateButtons():
    pass

def acUpdate(deltaT):#-------------------------------- AC UPDATE
    global currentTime
    global nextInsertTimestamp

    currentTime += deltaT

    updateLabels()
    updateButtons()