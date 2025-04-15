import ac
import acsys
import json
import requests
from third_party.sim_info import *

#AC Docs https://docs.google.com/document/d/13trBp6K1TjWbToUQs_nfFsB291-zVJzRZCNaTYt4Dzc/pub

#region GUI Globals
appName = "TelemetryCollector"
width, height = 335 , 400

buttonOffset = 150
buttonHeight = 85
buttonWidthOffset = 30
buttonWidth = 125
buttonWidthSpacing = 25
buttonFontSize = 20
buttonSizeIncrease = 1.1

labelOffset = 40
labelWidthOffset = 30
labelSpacing = 45
labelFontSize = 25
#endregion

#region Timed Globals
buttonSizeIncreaseDuration = 0.1

startButtonPressed = False
startButtonTimestamp = 1
endButtonPressed = False
endButtonTimestamp = 1
exportButtonPressed = False
exportButtonTimestamp = 1
startLapsButtonPressed = False
startLapsButtonTimestamp = 1

currentTime = 0
lapEndCooldownTimestamp = 0

insertCooldown = 0.1
nextInsertTimestamp = insertCooldown
#endregion

#region Telemetry Globals
lastVelocity = [0, 0, 0]
acceleration = [0, 0, 0]
currentSession = 0
currentLap = 0
lapTimes = {}
key = "945"

lapStartLocation = [0, 0, 0]
lapStartSet = False
lapEndLocation = [0, 0, 0]
lapEndSet = False

lapStarted = False
distanceForNewLap = 30
timeForNewLap = 10

insertQueries = []
#endregion Global Vars

session = requests.Session()

simInfo = SimInfo()

def acMain(ac_version):
    global appWindow # <- you'll need to update your window in other functions.

    appWindow = ac.newApp(appName)
    ac.setTitle(appWindow, appName)
    ac.setSize(appWindow, width, height)

    ac.addRenderCallback(appWindow, appGL) # -> links this app's window to an OpenGL render function

    assignLabels()
    assignButtons()

    highestSessionID = 0
    result = requests.get("http://localhost:8080/sessions")
    if str(result.content)[2:-3] != "null":
        results = str(result.content)[3:-5].replace("\\", "").split('},')
        decoder = json.JSONDecoder()
        for x in results:
            content = decoder.decode(str(x) + "}")
            if content["SessionID"] != None:
                highestSessionID = max(content["SessionID"], highestSessionID)

    global currentSession
    currentSession = highestSessionID + 1

    return appName

def assignLabels():
    global LapNumberLabel
    LapNumberLabel = ac.addLabel(appWindow, "Lap ")
    ac.setPosition(LapNumberLabel, labelWidthOffset, labelOffset)
    ac.setFontSize(LapNumberLabel, labelFontSize)

    global LapTimeLabel
    LapTimeLabel = ac.addLabel(appWindow, "")
    ac.setPosition(LapTimeLabel, labelWidthOffset, labelOffset + labelSpacing)
    ac.setFontSize(LapTimeLabel, labelFontSize)

def assignButtons():
    global SetLapStartButton
    SetLapStartButton = ac.addButton(appWindow, "\nSet Start")
    ac.setPosition(SetLapStartButton, buttonWidthOffset, buttonOffset)
    ac.setSize(SetLapStartButton, buttonWidth, buttonHeight)
    ac.setFontSize(SetLapStartButton, buttonFontSize)
    ac.setFontAlignment(SetLapStartButton, "center")
    ac.setFontAlignment
    ac.addOnClickedListener(SetLapStartButton, setLapStartButtonPress)

    global SetLapEndButton
    SetLapEndButton = ac.addButton(appWindow, "\nSet End")
    ac.setPosition(SetLapEndButton, buttonWidthOffset + buttonWidth + buttonWidthSpacing, buttonOffset)
    ac.setSize(SetLapEndButton, buttonWidth, buttonHeight)
    ac.setFontSize(SetLapEndButton, buttonFontSize)
    ac.setFontAlignment(SetLapEndButton, "center")
    ac.addOnClickedListener(SetLapEndButton, setLapEndButtonPress)

    global ExportToDBButton
    ExportToDBButton = ac.addButton(appWindow, "Export To DB")
    ac.setPosition(ExportToDBButton, buttonWidthOffset+(buttonWidth/2)+(buttonWidthSpacing/2), buttonOffset + 100)
    ac.setSize(ExportToDBButton, buttonWidth, 25)
    ac.setFontSize(ExportToDBButton, 16)
    ac.setFontAlignment(ExportToDBButton, "center")
    ac.addOnClickedListener(ExportToDBButton, exportToDB)

    global StartLapsButton
    StartLapsButton = ac.addButton(appWindow, "Start")
    ac.setPosition(StartLapsButton, buttonWidthOffset+(buttonWidth/2)+(buttonWidthSpacing/2), buttonOffset + 175)
    ac.setSize(StartLapsButton, buttonWidth, 40)
    ac.setFontSize(StartLapsButton, 24)
    ac.setFontAlignment(StartLapsButton, "center")
    ac.addOnClickedListener(StartLapsButton, startLaps)

def appGL(deltaT):#-------------------------------- OpenGL UPDATE
    """
    This is where you redraw your openGL graphics
    if you need to use them .
    """
    pass # -> Delete this line if you do something here !

def sendSessionLapPacket(carID):
    trackConfig = ac.getTrackConfiguration(carID) if ac.getTrackConfiguration(carID) != "" else "Default"
    result = requests.post("http://localhost:8080/addRow", 
        data=json.dumps({
            "SessionID" : currentSession,
            "LapID" : currentLap,
            "LapTime" : "int(lapTimes[currentLap]*1000)",
            "DriverName" : ac.getDriverName(carID), 
            "TrackName" : ac.getTrackName(carID), 
            "TrackConfiguration" : trackConfig, 
            "CarName" : ac.getCarName(carID)
        }), 
        headers={"Content-Type": "application/json"}
    )
    ac.log("Inserting with sessionID: " + str(currentSession) + ", lapID: " + str(currentLap) + "   result is above ^")
    ac.log(str(result.content))

def recordTelemetryPacket(carID):
    packetID = 0
    speedMPH = round(ac.getCarState(carID, acsys.CS.SpeedMPH), 6)
    gas = round(ac.getCarState(carID, acsys.CS.Gas), 6)
    brake = round(ac.getCarState(carID, acsys.CS.Brake), 6)
    steer = round(ac.getCarState(carID, acsys.CS.Steer), 6)
    clutch = round(ac.getCarState(carID, acsys.CS.Clutch), 6)
    gear = ac.getCarState(carID, acsys.CS.Gear)
    rpm = round(ac.getCarState(carID, acsys.CS.RPM), 6)
    turboBoost = round(ac.getCarState(carID, acsys.CS.TurboBoost), 6)
    localAngularVelocity = ac.getCarState(carID, acsys.CS.LocalAngularVelocity)
    velocity = ac.getCarState(carID, acsys.CS.Velocity)
    worldPosition = ac.getCarState(carID, acsys.CS.WorldPosition)
    aero = ac.getCarState(carID, acsys.CS.Aero)
    camberRad = ac.getCarState(carID, acsys.CS.CamberRad)
    slipAngle = ac.getCarState(carID, acsys.CS.SlipAngle)
    slipRatio = ac.getCarState(carID, acsys.CS.SlipRatio)
    selfAligningTorque = ac.getCarState(carID, acsys.CS.Mz)
    load = ac.getCarState(carID, acsys.CS.Load)
    tyreSlip = ac.getCarState(carID, acsys.CS.TyreSlip)
    thermalState = ac.getCarState(carID, acsys.CS.CurrentTyresCoreTemp)
    dynamicPressure = ac.getCarState(carID, acsys.CS.DynamicPressure)
    tyreDirtyLevel = ac.getCarState(carID, acsys.CS.TyreDirtyLevel)

    csvString = "PacketID,SessionID,LapID,PacketDatetime,SpeedMPH,Gas,Brake,Steer,Clutch,Gear,RPM,TurboBoost,LocalAngularVelocityX,LocalAngularVelocityY,LocalAngularVelocityZ,VelocityX,VelocityY,VelocityZ,WorldPositionX,WorldPositionY,WorldPositionZ,Aero_DragCoeffcient,Aero_LiftCoefficientFront,Aero_LiftCoefficientRear\n{0},{1},{2},{23},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22}".format(packetID,currentSession,currentLap,speedMPH,gas,brake,steer,clutch,gear,rpm,turboBoost,localAngularVelocity[0],localAngularVelocity[1],localAngularVelocity[2],velocity[0],velocity[1],velocity[2],worldPosition[0],worldPosition[1],worldPosition[2],aero,aero,aero, "2025-04-14")
    result = requests.post("http://localhost:8080/appendCSV", 
        data=csvString,
        headers={"Content-Type": "text/csv"}
    )
    ac.log(str(result.content))

def setLapStartButtonPress(x, y):
    ac.setPosition(SetLapStartButton, buttonWidthOffset - (buttonWidth * buttonSizeIncrease - buttonWidth)/2, buttonOffset - (buttonHeight * buttonSizeIncrease - buttonHeight)/2)
    ac.setSize(SetLapStartButton, buttonWidth * buttonSizeIncrease, buttonHeight * buttonSizeIncrease)

    global startButtonTimestamp
    global startButtonPressed
    startButtonTimestamp = currentTime + buttonSizeIncreaseDuration
    startButtonPressed = True

    global lapStartLocation
    global lapStartSet

    lapStartLocation = ac.getCarState(0, acsys.CS.WorldPosition)
    lapStartSet = True

def setLapEndButtonPress(x, y):
    ac.setPosition(SetLapEndButton, buttonWidthOffset - (buttonWidth * buttonSizeIncrease - buttonWidth)/2 + buttonWidth + buttonWidthSpacing, buttonOffset - (buttonHeight * buttonSizeIncrease - buttonHeight)/2)
    ac.setSize(SetLapEndButton, buttonWidth * buttonSizeIncrease, buttonHeight * buttonSizeIncrease)

    global endButtonTimestamp
    global endButtonPressed
    endButtonTimestamp = currentTime + buttonSizeIncreaseDuration
    endButtonPressed = True

    global lapEndLocation
    global lapEndSet

    lapEndLocation = ac.getCarState(0, acsys.CS.WorldPosition)
    lapEndSet = True

def startLaps(x, y):
    ac.setPosition(StartLapsButton, buttonWidthOffset+(buttonWidth/2)+(buttonWidthSpacing/2) - (buttonWidth * buttonSizeIncrease - buttonWidth)/2, buttonOffset + 175 - (40 * buttonSizeIncrease - 40)/2)
    ac.setSize(StartLapsButton, buttonWidth * buttonSizeIncrease, 40 * buttonSizeIncrease)

    global startLapsButtonPressed
    global startLapsButtonTimestamp
    startLapsButtonTimestamp = currentTime + buttonSizeIncreaseDuration
    startLapsButtonPressed = True
    
    global lapStarted
    global currentLap
    lapStarted = True
    currentLap += 1

def exportToDB(x, y):
    ac.setPosition(ExportToDBButton, buttonWidthOffset+(buttonWidth/2)+(buttonWidthSpacing/2) - (buttonWidth * buttonSizeIncrease - buttonWidth)/2, buttonOffset + 100 - (25 * buttonSizeIncrease - 25)/2)
    ac.setSize(ExportToDBButton, buttonWidth * buttonSizeIncrease, 25 * buttonSizeIncrease)

    global exportButtonTimestamp
    global exportButtonPressed
    exportButtonTimestamp = currentTime + buttonSizeIncreaseDuration
    exportButtonPressed = True

    sendSessionLapPacket(0)

    # global insertQueries
    # for insertQuery in insertQueries:
    #     urllib.request.urlopen(insertQuery)
    
    # insertQueries = []

def updateLabels():
    ac.setText(LapNumberLabel, "Lap {0}".format(currentLap))
    ac.setText(LapTimeLabel, "{0:.3f}".format(lapTimes[currentLap]))

def updateButtons():
    global startButtonPressed
    global endButtonPressed
    global exportButtonPressed
    global startLapsButtonPressed

    if startButtonPressed and currentTime > startButtonTimestamp:
        ac.setPosition(SetLapStartButton, buttonWidthOffset, buttonOffset)
        ac.setSize(SetLapStartButton, buttonWidth, buttonHeight)
        startButtonPressed = False
    if endButtonPressed and currentTime > endButtonTimestamp:
        ac.setPosition(SetLapEndButton, buttonWidthOffset + buttonWidth + buttonWidthSpacing, buttonOffset)
        ac.setSize(SetLapEndButton, buttonWidth, buttonHeight)
        endButtonPressed = False
    if exportButtonPressed and currentTime > exportButtonTimestamp:
        ac.setPosition(ExportToDBButton, buttonWidthOffset+(buttonWidth/2)+(buttonWidthSpacing/2), buttonOffset + 100)
        ac.setSize(ExportToDBButton, buttonWidth, 25)
        exportButtonPressed = False
    if startLapsButtonPressed and currentTime > startLapsButtonTimestamp:
        ac.setPosition(StartLapsButton, buttonWidthOffset+(buttonWidth/2)+(buttonWidthSpacing/2), buttonOffset + 175)
        ac.setSize(StartLapsButton, buttonWidth, 40)
        startLapsButtonPressed = False

def acUpdate(deltaT):#-------------------------------- AC UPDATE
    """
    This is where you update your app window ( != OpenGL graphics )
    such as : labels , listener , ect ...
    """
    global currentTime
    global nextInsertTimestamp
    global lastVelocity
    global acceleration
    global currentLap

    if currentLap in lapTimes.keys():
        lapTimes[currentLap] += deltaT
    else:
        lapTimes[currentLap] = deltaT

    currentTime += deltaT

    updateLabels()
    updateButtons()

    currentVelocity = ac.getCarState(0, acsys.CS.LocalVelocity)
    acceleration = [(currentVelocity[0] - lastVelocity[0])/deltaT/1000, (currentVelocity[1] - lastVelocity[1])/deltaT/1000, (currentVelocity[2] - lastVelocity[2])/deltaT/1000]
    lastVelocity = currentVelocity

    if lapStarted and currentTime > nextInsertTimestamp:
        recordTelemetryPacket(0)
        nextInsertTimestamp = currentTime + insertCooldown

    if lapStarted and lapStartSet and lapEndSet:
        location = ac.getCarState(0, acsys.CS.WorldPosition)
        distance = abs(lapEndLocation[0] - location[0]) + abs(lapEndLocation[1] - location[1]) + abs(lapEndLocation[2] - location[2])
        if distance < distanceForNewLap and lapTimes[currentLap] > timeForNewLap:
            sendSessionLapPacket(0)
            currentLap += 1