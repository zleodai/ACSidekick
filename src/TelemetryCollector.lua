---@class DBLink
---@field port number
DBLink = {}
DBLink.__index = DBLink

---@param port number
function DBLink:new(port)
    local dbLink = {}
    setmetatable(dbLink, DBLink)
    dbLink.port = port
    return dbLink
end

---@param packet table
function DBLink:uploadPacket(packet)
    url = string.format("http://localhost:%d/appendCSV", self.port)
    body = ToCSV(packet)
    header = {
        ["Content-Type"] = "text/csv"
    }
    packetID = packet.PacketID
    web.post(url, header, body, function (err, response)
        outputString = ""
        outputString = outputString .. "Attempting To Insert CSV"
        outputString = outputString .. string.format("\n\nPacketID:\n%s", packetID)
        outputString = outputString .. string.format("\n\nUrl:\n%s",url)
        outputString = outputString .. string.format("\n\nBody:\n%s",body)
        outputString = outputString .. string.format("\n\nHeader:\n%s", '"Content-Type" = "text/csv"')
        outputString = outputString .. string.format("\n\nAttempt Result:\n%s", response.body)
        ac.log(outputString)
        file = io.open("luaLog.txt", "w")
        file:write(outputString)
        file:close()
    end)
end

---@param packet table
function ToCSV(packet)
    csvHeaders = ""
    csvData = ""
    for k, v in pairs(packet) do
        csvHeaders = csvHeaders .. string.format("%s,", tostring(k))
        if (type(v) == "number") then
            csvData = csvData .. string.format("%s, ", string.format("%s", v))
        else
            csvData = csvData .. string.format("%s, ", v)
        end
    end
    return csvHeaders .. "\n" .. csvData
end

---@param packetID number
---@param sessionID number
---@param lapID number
---@param time string
---@param data ac.StateCar
function CreatePacket(packetID, sessionID, lapID, time, data)
    local packet = {}
    packet.PacketID = packetID
    packet.SessionID = sessionID
    packet.LapID = lapID
    packet.PacketDatetime = time
    packet.SpeedMPH = data.speedMs
    packet.Gas = data.gas
    packet.Brake = data.brake
    packet.Steer = data.steer
    packet.Clutch = data.clutch
    packet.Gear = data.gear
    packet.RPM = data.rpm
    packet.TurboBoost = data.turboBoost
    packet.LocalAngularVelocityX = data.localAngularVelocity.x
    packet.LocalAngularVelocityY = data.localAngularVelocity.y
    packet.LocalAngularVelocityZ = data.localAngularVelocity.z
    packet.VelocityX = data.velocity.x
    packet.VelocityY = data.velocity.y
    packet.VelocityZ = data.velocity.z
    packet.WorldPositionX = data.position.x
    packet.WorldPositionY = data.position.y
    packet.WorldPositionZ = data.position.z
    packet.Aero_DragCoeffcient = data.aeroDrag
    packet.Aero_LiftCoefficientFront = data.aeroLiftFront
    packet.Aero_LiftCoefficientRear = data.aeroLiftRear

    wheelData = playerCar.wheels
    packet.FL_CamberRad = wheelData[0].camber
    packet.FR_CamberRad = wheelData[1].camber
    packet.RL_CamberRad = wheelData[2].camber
    packet.RR_CamberRad = wheelData[3].camber
    packet.FL_SlipAngle = wheelData[0].slipAngle
    packet.FR_SlipAngle = wheelData[1].slipAngle
    packet.RL_SlipAngle = wheelData[2].slipAngle
    packet.RR_SlipAngle = wheelData[3].slipAngle
    packet.FL_SlipRatio = wheelData[0].slipRatio
    packet.FR_SlipRatio = wheelData[1].slipRatio
    packet.RL_SlipRatio = wheelData[2].slipRatio
    packet.RR_SlipRatio = wheelData[3].slipRatio
    packet.FL_SelfAligningTorque = wheelData[0].mz
    packet.FR_SelfAligningTorque = wheelData[1].mz
    packet.RL_SelfAligningTorque = wheelData[2].mz
    packet.RR_SelfAligningTorque = wheelData[3].mz
    packet.FL_Load = wheelData[0].loadK
    packet.FR_Load = wheelData[1].loadK
    packet.RL_Load = wheelData[2].loadK
    packet.RR_Load = wheelData[3].loadK
    packet.FL_TyreSlip = wheelData[0].slip
    packet.FR_TyreSlip = wheelData[1].slip
    packet.RL_TyreSlip = wheelData[2].slip
    packet.RR_TyreSlip = wheelData[3].slip
    -- packet.FL_TyreSlipAngle = wheelData[0].slipAngle
    -- packet.FR_TyreSlipAngle = wheelData[1].slipAngle
    -- packet.RL_TyreSlipAngle = wheelData[2].slipAngle
    -- packet.RR_TyreSlipAngle = wheelData[3].slipAngle
    packet.FL_ThermalState = wheelData[0].tyreCoreTemperature
    packet.FR_ThermalState = wheelData[1].tyreCoreTemperature
    packet.RL_ThermalState = wheelData[2].tyreCoreTemperature
    packet.RR_ThermalState = wheelData[3].tyreCoreTemperature
    packet.FL_DynamicPressure = wheelData[0].tyrePressure
    packet.FR_DynamicPressure = wheelData[1].tyrePressure
    packet.RL_DynamicPressure = wheelData[2].tyrePressure
    packet.RR_DynamicPressure = wheelData[3].tyrePressure
    packet.FL_TyreDirtyLevel = wheelData[0].tyreDirty
    packet.FR_TyreDirtyLevel = wheelData[1].tyreDirty
    packet.RL_TyreDirtyLevel = wheelData[2].tyreDirty
    packet.RR_TyreDirtyLevel = wheelData[3].tyreDirty
    return packet
end
