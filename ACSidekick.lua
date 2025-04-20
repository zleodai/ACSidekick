UIElements = require(".src/UIElements")
TelemetryCollector = require(".src/TelemetryCollector")

alreadyStart = false
windowActive = false
uiState = ac.getUI()

---@type UIElement[]
activeElements = {}

function script.onShowWindow()
  -- Window Opened
  windowActive = true

  if not alreadyStart then
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
    
    local mapP1 = vec2(mapImagePadding.x, mapImagePadding.y) + mapImageOffset
    local mapMaxX = windowSize.x - mapImagePadding.x
    local mapMaxY = windowSize.y/2 - mapImagePadding.y
    local mapMin = math.min(mapMaxX, mapMaxY)
    local xGreater = mapImageSize.x > mapImageSize.y
    local mapImageRatio = math.min(mapImageSize.x/mapImageSize.y, mapImageSize.y/mapImageSize.x)
    local mapP2 = not xGreater and vec2(mapMin * mapImageRatio, mapMin) or xGreater and vec2(mapMin, mapMin * mapImageRatio)
    local difference = vec2(mapMaxX, mapMaxY) - mapP2
    mapDisplay:addImage(mapImageSrc, mapP1 + difference/2, mapP2 - mapImagePadding + difference/2)
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

    ui.pushDWriteFont(ui.DWriteFont("Chakra Petch;Weight=Light;", "./data"))

    for _, element in pairs(activeElements) do
      element:draw()
    end
  end
end

function script.simulationUpdate()
  -- Called after a whole simulation update
end