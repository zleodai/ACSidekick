---@diagnostic disable: duplicate-set-field

UIElements = require(".app/lua/ui_elements")
TelemetryCollector = require(".app/lua/telemetry_collector")
Util = require(".app/lua/util")

initalized = false
guiInitalized = false
collectingData = false
windowActive = false

time = 0
uploadPacketInterval = 1
uploadPacketStep = uploadPacketInterval

---@type UIElement[]
visibleElements = {}

---@type UIElement[]
clickableElements = {}

function script.onShowWindow()
  -- Window Opened
  windowActive = true

  if not initalized then
    -- Load configs/defaultValues

    ini = ac.getFolder(ac.FolderID.ContentTracks) .. '/' .. ac.getTrackFullID('/') .. '/data/map.ini'
    config = ac.INIConfig.load(ini):mapSection('PARAMETERS', { SCALE_FACTOR = 1, Z_OFFSET = 1, X_OFFSET = 1, WIDTH=500, HEIGHT=500, MARGIN=20, DRAWING_SIZE=10, MAX_SIZE=1000})
    config.OFFSETS = vec2(config.X_OFFSET, config.Z_OFFSET)

    uiState = ac.getUI()
    displaySize = uiState.windowSize


    -- UI Element Setup

    ---@type UIElement
    dataCollectionDisplay = UIElement:new()
    dataCollectionDisplay:setBackground(rgbm(0.1, 0.1, 0.1, 1))
    table.insert(visibleElements, dataCollectionDisplay)

    ---@type UIElement
    collectDataButton = UIElement:new()
    table.insert(visibleElements, collectDataButton)
    table.insert(clickableElements, collectDataButton)
    packetsSent = 0

    ---@type UIElement
    mapDisplay = UIElement:new()
    mapDisplay:setBackground(rgbm(0.1, 0.1, 0.1, 1))
    table.insert(visibleElements, mapDisplay)

    local map_mini = ac.getFolder(ac.FolderID.ContentTracks) .. '\\' .. ac.getTrackFullID('\\') .. '\\map_mini.png'
    local map = ac.getFolder(ac.FolderID.ContentTracks) .. '\\' .. ac.getTrackFullID('\\') .. '\\map.png'
    mapImageSrc = io.exists(map_mini) and map_mini or map
    mapImageOffset = vec2(0, 50)
    mapImagePadding = vec2(20, 20)
    mapImageSize = ui.imageSize(mapImageSrc)
    mapScale = 1

    playerCar = ac.getCar(0)


    -- TelemetryCollection

    dbPort = 8091

    ---@type DBLink
    dbLink = DBLink:new(dbPort)

    initalized = true
  end
end

function script.onHideWindow()
  -- Window Close
  windowActive = false
end

function script.onWindowUpdate(dt)
  -- On Window Update

  if not initalized then return end

  local windows = ac.getAppWindows()
  for _, window in pairs(windows) do
    if window.title == "ACSidekick" then
      AppInfo = window
    end
  end

  windowSize = AppInfo.size
  defaultTitleFontSize = (windowSize.x * 0.1 + windowSize.y * 0.9)/32
  
  -- Handle onClicks
  if collectDataButton.onClick then
    collectingData = not collectingData
  end

  -- Update GUI
  if (dataCollectionDisplay ~= nil and mapDisplay ~= nil) then
    dataCollectionDisplay.pos = AppInfo.position
    dataCollectionDisplay.size = vec2(windowSize.x, windowSize.y * 0.5)
    dataCollectionDisplay:clearElements()

    dataCollectionDisplay:addText("Timing", defaultTitleFontSize, vec2(0, 0), vec2(windowSize.x, 50))
    dataCollectionDisplay:addText("Packets Sent: " .. packetsSent, defaultTitleFontSize/1.5, vec2(0, dataCollectionDisplay.size.y * 0.9), dataCollectionDisplay.size)

    collectDataButton.size = vec2(dataCollectionDisplay.size.x/3, dataCollectionDisplay.size.y/8)
    collectDataButton.pos = AppInfo.position + dataCollectionDisplay.size/2 - collectDataButton.size/2 + vec2(0, windowSize.y*0.175)
    collectDataButton:clearElements()

    if collectingData then 
      collectDataButton:addText("Unlink DB", defaultTitleFontSize/1.5, vec2(0, 0), collectDataButton.size)
      collectDataButton:setBackground(rgbm(0.3, 0, 0, 1))
    else
      collectDataButton:addText("Link DB", defaultTitleFontSize/1.5, vec2(0, 0), collectDataButton.size)
      collectDataButton:setBackground(rgbm(0, 0.3, 0, 1))
    end

    mapDisplay.pos = AppInfo.position + vec2(0, dataCollectionDisplay.size.y)
    mapDisplay.size = vec2(windowSize.x, windowSize.y - dataCollectionDisplay.size.y)
    mapDisplay:clearElements()

    -- Map positioning
    local mapSizeFactor = math.pow(1.15, mapScale)
    local mapOffset = (vec2(playerCar.position.x, playerCar.position.z) + config.OFFSETS) * (mapSizeFactor/config.SCALE_FACTOR) - mapDisplay.size/2
    rotationangle = 270 - math.deg(math.atan2(playerCar.look.x, playerCar.look.z))
    local p1 = -mapOffset
    local p2 = -mapOffset + (mapSizeFactor * mapImageSize)
    mapDisplay:addImage(mapImageSrc, p1, p2, rotationangle, mapDisplay.size/2)
    mapDisplay:addImage("./data/Arrow.png", mapDisplay.size/2 - vec2(25, 25), mapDisplay.size/2 + vec2(25, 25), 90, mapDisplay.size/2)

    guiInitalized = true
  end

  time = time + dt
end

function script.update(dt)
  -- On Script Update 

  if not initalized then return end

  if collectingData then
    if time > uploadPacketStep then
      playerCar = ac.getCar(0)
      if not playerCar then return end

      packet = CreatePacket(0, 0, 0, os.date("%m/%d/%Y %X", os.time()) .. string.format(":%d", (time - math.floor(time))*1000), playerCar)

      uploadPacketStep = time + uploadPacketInterval
      dbLink:uploadPacket(packet)
    end
  end

  -- Write up your own backend with golang to store the telemetry data with SQLite
  
end

function script.scenePreRenderUpdate()
  -- Called before a scene has started rendering
end

function script.postGeometryRenderUpdate()
  -- Called when opaque geometry has finished rendering
end

function script.preRenderUIUpdate()
  -- Called before rendering ImGui apps to draw things on screen

  if windowActive then
    uiState = ac.getUI()

    if guiInitalized then
      -- map scaling update
      if uiState.mouseWheel ~= 0 then
        if (uiState.mousePos.x > AppInfo.position.x and uiState.mousePos.y > AppInfo.position.y and uiState.mousePos.x < (AppInfo.position + AppInfo.size).x and uiState.mousePos.y < (AppInfo.position + AppInfo.size).y) then
          mapScale = mapScale + uiState.mouseWheel
        end
      end
      
      ui.pushDWriteFont(ui.DWriteFont("Chakra Petch;Weight=Light;", "./data"))

      for _, element in pairs(visibleElements) do
        element:draw()
      end

      for _, element in pairs(clickableElements) do
        if (uiState.isMouseLeftKeyClicked) then
          if (uiState.mousePos.x > element.pos.x and uiState.mousePos.y > element.pos.y and uiState.mousePos.x < (element.pos + element.size).x and uiState.mousePos.y < (element.pos + element.size).y) then
            element.onClick = true
          else
            element.onClick = false
          end
        else
          element.onClick = false
        end
      end
    end
  end
end

function script.simulationUpdate()
  -- Called after a whole simulation update
end