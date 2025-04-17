import requests

class TelemetrySender:
    def __init__(self):
        pass

# def sendSessionLapPacket(carID):
#     trackConfig = ac.getTrackConfiguration(carID) if ac.getTrackConfiguration(carID) != "" else "Default"
#     result = requests.post("http://localhost:8080/addRow", 
#         data=json.dumps({
#             "SessionID" : currentSession,
#             "LapID" : currentLap,
#             "LapTime" : "int(lapTimes[currentLap]*1000)",
#             "DriverName" : ac.getDriverName(carID), 
#             "TrackName" : ac.getTrackName(carID), 
#             "TrackConfiguration" : trackConfig, 
#             "CarName" : ac.getCarName(carID)
#         }), 
#         headers={"Content-Type": "application/json"}
#     )
#     ac.log("Inserting with sessionID: " + str(currentSession) + ", lapID: " + str(currentLap) + "   result is above ^")
#     ac.log(str(result.content))

# def recordTelemetryPacket(carID):
#     packetID = 0
#     speedMPH = round(ac.getCarState(carID, acsys.CS.SpeedMPH), 6)
#     gas = round(ac.getCarState(carID, acsys.CS.Gas), 6)
#     brake = round(ac.getCarState(carID, acsys.CS.Brake), 6)
#     steer = round(ac.getCarState(carID, acsys.CS.Steer), 6)
#     clutch = round(ac.getCarState(carID, acsys.CS.Clutch), 6)
#     gear = ac.getCarState(carID, acsys.CS.Gear)
#     rpm = round(ac.getCarState(carID, acsys.CS.RPM), 6)
#     turboBoost = round(ac.getCarState(carID, acsys.CS.TurboBoost), 6)
#     localAngularVelocity = ac.getCarState(carID, acsys.CS.LocalAngularVelocity)
#     velocity = ac.getCarState(carID, acsys.CS.Velocity)
#     worldPosition = ac.getCarState(carID, acsys.CS.WorldPosition)
#     aero = ac.getCarState(carID, acsys.CS.Aero)
#     camberRad = ac.getCarState(carID, acsys.CS.CamberRad)
#     slipAngle = ac.getCarState(carID, acsys.CS.SlipAngle)
#     slipRatio = ac.getCarState(carID, acsys.CS.SlipRatio)
#     selfAligningTorque = ac.getCarState(carID, acsys.CS.Mz)
#     load = ac.getCarState(carID, acsys.CS.Load)
#     tyreSlip = ac.getCarState(carID, acsys.CS.TyreSlip)
#     thermalState = ac.getCarState(carID, acsys.CS.CurrentTyresCoreTemp)
#     dynamicPressure = ac.getCarState(carID, acsys.CS.DynamicPressure)
#     tyreDirtyLevel = ac.getCarState(carID, acsys.CS.TyreDirtyLevel)

#     csvString = "PacketID,SessionID,LapID,PacketDatetime,SpeedMPH,Gas,Brake,Steer,Clutch,Gear,RPM,TurboBoost,LocalAngularVelocityX,LocalAngularVelocityY,LocalAngularVelocityZ,VelocityX,VelocityY,VelocityZ,WorldPositionX,WorldPositionY,WorldPositionZ,Aero_DragCoeffcient,Aero_LiftCoefficientFront,Aero_LiftCoefficientRear\n{0},{1},{2},{23},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22}".format(packetID,currentSession,currentLap,speedMPH,gas,brake,steer,clutch,gear,rpm,turboBoost,localAngularVelocity[0],localAngularVelocity[1],localAngularVelocity[2],velocity[0],velocity[1],velocity[2],worldPosition[0],worldPosition[1],worldPosition[2],aero,aero,aero, "2025-04-14")
#     result = requests.post("http://localhost:8080/appendCSV", 
#         data=csvString,
#         headers={"Content-Type": "text/csv"}
#     )
#     ac.log(str(result.content))