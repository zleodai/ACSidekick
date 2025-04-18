Time = 0

function AppDraw()
    local windowInfo = ac.getAppWindows()
    local appWindow
    for _, window in pairs(windowInfo) do
        if window.title == "Sidekick" then
            appWindow = window
        end
    end
    ac.debug("App Window Size", appWindow.size)
    ac.debug("App Window Pos", appWindow.position)
    ui.pushDWriteFont(ui.DWriteFont("Chakra Petch;Weight=Light;", "./data"))

    ui.dwriteDrawTextClipped(string.format("%.2f", Time), 24, vec2(0, 0), appWindow.size, ui.Alignment.Center, ui.Alignment.Center)
end

function AppUpdate(dt)
    Time = Time + dt
end