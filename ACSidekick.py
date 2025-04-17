#Required For AC APPS
import ac
import acsys
from third_party.sim_info import *

#Internal
from src.TelemetrySender import TelemetrySender
from src.Utils import *

#AC Docs https://docs.google.com/document/d/13trBp6K1TjWbToUQs_nfFsB291-zVJzRZCNaTYt4Dzc/pub

appName = "ACSidekick"
width, height = 400 , 400

TemplateButton = None
dynamicElements = []

simInfo = SimInfo()

def acMain(ac_version):
    global appWindow # <- you'll need to update your window in other functions.

    appWindow = ac.newApp(appName)
    ac.setTitle(appWindow, appName)
    ac.setSize(appWindow, width, height)

    ac.addRenderCallback(appWindow, appGL) # -> links this app's window to an OpenGL render function

    TemplateWindow = Image(appWindow, Vector2(200, 200), Vector2(400, 400), "apps\python\ACSidekick\data\Image.png")
    TemplateLabel = Label(appWindow, Vector2(200, 50), "Testing App", 24)

    global TemplateButton
    TemplateButton = Button(appWindow, Vector2(200, 300), Vector2(100, 50), "press", 24)
    ac.addOnClickedListener(TemplateButton.ref, testOnClick)
    dynamicElements.append(TemplateButton)

    return appName

def appGL(deltaT):#-------------------------------- OpenGL UPDATE
    """
    This is where you redraw your openGL graphics
    if you need to use them .
    """
    pass # -> Delete this line if you do something here !

def testOnClick(x, y):
    TemplateButton.onClick()

def acUpdate(deltaT):#-------------------------------- AC UPDATE
    global currentTime
    global nextInsertTimestamp

    for element in dynamicElements:
        element.update(deltaT)