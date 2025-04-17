import ac;

class Vector2:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __add__(self, a):
        if type(a) is Vector2:
            return Vector2(self.x + a.x, self.y + a.y)
        elif type(a) is int:
            return Vector2(self.x + a, self.y + a)
        elif type(a) is float:
            return Vector2(self.x + a, self.y + a)
    
    def __truediv__(self, a):
        if type(a) is int:
            return Vector2(self.x/a, self.y/a)
        elif type(a) is float:
            return Vector2(self.x/a, self.y/a)
        
    def __mul__(self, a):
        if type(a) is int:
            return Vector2(self.x*a, self.y*a)
        elif type(a) is float:
            return Vector2(self.x*a, self.y*a)

class DynamicUI:
    def __init__(self):
        self.time = 0

    def update(self, deltaT):
        self.time += deltaT

class UIElements:
    def __init__(self, appWindow, ref, position, size = None):
        self.appWindow = appWindow
        self.position = position
        self.size = size
        self.ref = ref
    
    def updatePosition(self):
        if (self.size != None):
            ac.setPosition(self.ref, self.position.x - self.size.x/2, self.position.y - self.size.y/2)
            ac.setSize(self.ref, self.size.x, self.size.y)
        else:
            ac.setPosition(self.ref, self.position.x, self.position.y)

class Image(UIElements, DynamicUI):
    def __init__(self, appWindow, position, size, imageSource):
        UIElements.__init__(self, appWindow, ac.addGraph(appWindow, ""), position, size)
        self.updatePosition()

        ac.setBackgroundTexture(self.ref, imageSource)

class Label(UIElements):
    def __init__(self, appWindow, position, text, fontSize):
        UIElements.__init__(self, appWindow, ac.addLabel(appWindow, text), position)
        self.updatePosition()

        ac.setFontSize(self.ref, fontSize)
        ac.setFontAlignment(self.ref, "center")

class Button(UIElements, DynamicUI):
    def __init__(self, appWindow, position, size, text, fontSize):
        UIElements.__init__(self, appWindow, ac.addButton(appWindow, ""), position, size)
        DynamicUI.__init__(self)
        self.defaultSize = size
        self.text = Label(appWindow, Vector2(self.position.x, self.position.y - self.defaultSize.y/2), text, fontSize)
        self.updatePosition()

        ac.setFontSize(self.ref, fontSize)
        ac.setFontAlignment(self.ref, "center")

        self.buttonPressed = False
        self.buttonClickEffectSizeChange = 5
        self.buttonClickEffectDuration = 0.1
        self.buttonClickEffectStep = self.time + self.buttonClickEffectDuration

    def updatePosition(self):
        ac.setPosition(self.ref, self.position.x - self.size.x/2, self.position.y - self.size.y/2)
        ac.setSize(self.ref, self.size.x, self.size.y)
        ac.setPosition(self.text.ref, self.position.x, self.position.y - self.defaultSize.y/2)

    def onClick(self):
        self.size = Vector2(self.size.x + self.buttonClickEffectSizeChange, self.size.y + self.buttonClickEffectSizeChange)
        self.updatePosition()

        self.buttonPressed = True
        self.buttonClickEffectStep = self.time + self.buttonClickEffectDuration

    def update(self, deltaT):
        self.time += deltaT

        if (self.buttonPressed and self.time > self.buttonClickEffectStep):
            self.buttonPressed = False
            self.size = self.defaultSize
            self.updatePosition()


class Utils:
    @staticmethod
    def log(x):
        ac.log(str(x))