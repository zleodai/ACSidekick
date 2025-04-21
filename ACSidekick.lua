UIElements = require(".src/UIElements")
TelemetryCollector = require(".src/TelemetryCollector")

alreadyStart = false
windowActive = false
uiState = ac.getUI()

---@type UIElement[]
activeElements = {}

direction = {
  n = vec2(0, 1),
  ne = vec2(math.sqrt(0.5), math.sqrt(0.5)),
  e = vec2(1, 0),
  se = vec2(math.sqrt(0.5), -math.sqrt(0.5)),
  s = vec2(0, -1),
  sw = vec2(-math.sqrt(0.5), -math.sqrt(0.5)),
  w = vec2(-1, 0),
  nw = vec2(-math.sqrt(0.5), math.sqrt(0.5))
}

function script.onShowWindow()
  -- Window Opened
  windowActive = true

  if not alreadyStart then
    -- load configs
    ini = ac.getFolder(ac.FolderID.ContentTracks) .. '/' .. ac.getTrackFullID('/') .. '/data/map.ini'
    config = ac.INIConfig.load(ini):mapSection('PARAMETERS', { SCALE_FACTOR = 1, Z_OFFSET = 1, X_OFFSET = 1, WIDTH=500, HEIGHT=500, MARGIN=20, DRAWING_SIZE=10, MAX_SIZE=1000})
    config.OFFSETS = vec2(config.X_OFFSET, config.Z_OFFSET)

    displaySize = uiState.windowSize

    ---@type UIElement[]
    activeElements = {}

    ---@type UIElement
    dataCollectionDisplay = UIElement:new()
    table.insert(activeElements, dataCollectionDisplay)

    ---@type UIElement
    mapDisplay = UIElement:new()
    table.insert(activeElements, mapDisplay)

    local map_mini = ac.getFolder(ac.FolderID.ContentTracks) .. '\\' .. ac.getTrackFullID('\\') .. '\\map_mini.png'
    local map = ac.getFolder(ac.FolderID.ContentTracks) .. '\\' .. ac.getTrackFullID('\\') .. '\\map.png'
    mapImageSrc = io.exists(map_mini) and map_mini or map
    mapImageOffset = vec2(0, 50)
    mapImagePadding = vec2(20, 20)
    mapImageSize = ui.imageSize(mapImageSrc)
    mapScale = 1

    playerCar = ac.getCar(0)

    alreadyStart = true
  end
end

function script.onHideWindow()
  -- Window Close
  windowActive = false
end

function script.onWindowUpdate(dt)
  if not alreadyStart then return end
  local windows = ac.getAppWindows()
  for _, window in pairs(windows) do
    if window.title == "ACSidekick" then
      AppInfo = window
    end
  end
  ac.debug("windowInfo", AppInfo)

  windowSize = AppInfo.size
  defaultTitleFontSize = (windowSize.x + windowSize.y)/48

  if (dataCollectionDisplay ~= nil and mapDisplay ~= nil) then
    dataCollectionDisplay.pos = AppInfo.position
    dataCollectionDisplay.size = vec2(windowSize.x, windowSize.y * 0.5)
    dataCollectionDisplay:clearElements()

    dataCollectionDisplay:addText("Sector Timing", defaultTitleFontSize, vec2(0, 0), vec2(windowSize.x, 50))

    mapDisplay.pos = AppInfo.position + vec2(0, dataCollectionDisplay.size.y)
    mapDisplay.size = vec2(windowSize.x, windowSize.y - dataCollectionDisplay.size.y)
    mapDisplay:clearElements()
    
    mapDisplay:addText("Map Display", defaultTitleFontSize, vec2(0, 0), vec2(windowSize.x, 50))
    

    -- Map positioning
    local mapSizeFactor = math.pow(1.15, mapScale)
    local mapOffset = (vec2(playerCar.position.x, playerCar.position.z) + config.OFFSETS) * (mapSizeFactor/config.SCALE_FACTOR) - mapDisplay.size/2
    rotationangle = 270 - math.deg(math.atan2(playerCar.look.x, playerCar.look.z))
    local p1 = -mapOffset
    local p2 = -mapOffset + (mapSizeFactor * mapImageSize)
    mapDisplay:addImage(mapImageSrc, p1, p2, rotationangle, mapDisplay.size/2)
    mapDisplay:addImage("./data/Arrow.png", mapDisplay.size/2 - vec2(25, 25), mapDisplay.size/2 + vec2(25, 25), 90, mapDisplay.size/2)
  end
  -- On Window Update
end

function script.update(dt)
  -- Universal Update
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
    ac.debug("Mouse Position", uiState.mousePos)
    ac.debug("Mouse Scroll", uiState.mouseWheel)

    if uiState.mouseWheel ~= 0 then
      if (uiState.mousePos.x > AppInfo.position.x and uiState.mousePos.y > AppInfo.position.y and uiState.mousePos.x < (AppInfo.position + AppInfo.size).x and uiState.mousePos.y < (AppInfo.position + AppInfo.size).y) then
        mapScale = mapScale + uiState.mouseWheel
      end
    end

    ui.pushDWriteFont(ui.DWriteFont("Chakra Petch;Weight=Light;", "./data"))

    for _, element in pairs(activeElements) do
      element:draw()
    end
  end
end

function script.simulationUpdate()
  -- Called after a whole simulation update
end