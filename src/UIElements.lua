---@class UIElement
---@field pos vec2
---@field size vec2
---@field padding vec2
---@field internalElements table[]
UIElement = {}
UIElement.__index = UIElement

function UIElement:new(pos, size, padding)
    local uiElement = {}
    setmetatable(uiElement, UIElement)
    uiElement.pos = pos
    uiElement.size = size
    uiElement.padding = padding
    uiElement.internalElements = {}
    return uiElement
end

function UIElement:addText(text, size, p1, p2)
    local textElement = {
        type = "textElement",
        text = text,
        fontSize = size,
        p1 = p1,
        p2 = p2
    }
    table.insert(self.internalElements, textElement)
end

function UIElement:draw()
    ui.transparentWindow("Element", self.pos, self.size, function()
        ui.drawRectFilled(vec2(0, 0), self.size, rgbm(0.1, 0.1, 0.1, 1))
        for _, element in pairs(self.internalElements) do
            if element.type == "textElement" then
                ui.dwriteDrawTextClipped(element.text, element.fontSize, element.p1, element.p2, ui.Alignment.Center, ui.Alignment.Center)
            end
        end
    end)
end