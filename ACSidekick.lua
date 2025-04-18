UIElements = require(".src/UIElements")
App = require(".src/App")

Active = false
UIState = ac.getUI()
WindowSize = UIState.windowSize
DefaultSize = WindowSize.y/3
DefaultTitleFontSize = DefaultSize/16

---@type UIElement[]
ActiveElements = {}

function script.onShowWindow()
  -- Window Opened
  ac.onSessionStart(OnSessionStart)
  Active = true

  ---@type UIElement[]
  ActiveElements = {}

  ---@type UIElement
  MapDisplay = UIElement:new(vec2(100, DefaultSize * 2 - 100), vec2(DefaultSize, DefaultSize))
  MapDisplay:addText("Map Display", DefaultTitleFontSize, vec2(0, 0), vec2(DefaultSize, 100))
  table.insert(ActiveElements, MapDisplay)

  ---@type UIElement
  AppDisplay = UIElement:new(vec2(100, 100), vec2(DefaultSize, DefaultSize))
  AppDisplay:addText("Telemetry Display", DefaultTitleFontSize, vec2(0, 0), vec2(DefaultSize, 100))
  table.insert(ActiveElements, AppDisplay)

  ---@type UIElement
  DataCollectionDisplay = UIElement:new(vec2(WindowSize.x - 100 - DefaultSize, 100), vec2(DefaultSize, DefaultSize * 3/2))
  DataCollectionDisplay:addText("Data Collection", DefaultTitleFontSize, vec2(0, 0), vec2(DefaultSize, 100))
  table.insert(ActiveElements, DataCollectionDisplay)
end

function script.onHideWindow()
  -- Window Close
  Active = false
end

function OnSessionStart(sessionIndex, restarted)
  ac.log(string.format("Session %d. Started: %s", sessionIndex, restarted))
end

function script.onWindowUpdate(dt)
  -- On Window Update
  AppDraw()
end

function script.update(dt)
  -- Universal Update
  AppUpdate(dt)
end

function script.scenePreRenderUpdate()
  -- Called before a scene has started rendering
end

function script.postGeometryRenderUpdate()
  -- Called when opaque geometry has finished rendering
end

function script.preRenderUIUpdate()
  -- Called before rendering ImGui apps to draw things on screen

  if Active then
    UIState = ac.getUI()
    ac.debug("Mouse Position", UIState.mousePos)

    ui.pushDWriteFont(ui.DWriteFont("Chakra Petch;Weight=Light;", "./data"))

    for _, element in pairs(ActiveElements) do
      element:draw()
    end
  end
end

function script.simulationUpdate()
  -- Called after a whole simulation update
end