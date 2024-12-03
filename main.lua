screenLib = require("lib/screen")
json = require("lib/json")
require("lib/loveExpanded")

gameStates = {}
currentGameState = {}

for i,v in pairs(love.filesystem.getDirectoryItems("gameStates")) do
    if string.sub(v,-4) == ".lua" then
        local stateName = string.sub(v,1,-5)
        gameStates[stateName] = require("gameStates/"..stateName)
    end
end

function changeGameState(_State,_Arg)
    currentGameState = gameStates[_State]
    if currentGameState.load then
        currentGameState.load(_Arg)
    end
    love.window.setTitle(_State)
end

function love.load()
    changeGameState("main")
end

function love.update(dt)
    currentGameState.update(dt)
end

function love.draw()
    currentGameState.draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    if currentGameState.onMouseClick then
        currentGameState.onMouseClick(x, y, button, istouch, presses)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if currentGameState.onKeyPress then
        currentGameState.onKeyPress(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    if currentGameState.onKeyRelease then
        currentGameState.onKeyRelease(key, scancode)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if currentGameState.onMouseMove then
        currentGameState.onMouseMove(x, y, dx, dy, istouch)
    end
end

function love.quit()
    if currentGameState.onQuit then
        currentGameState.onQuit()
    end
end

function love.focus(f)
    if currentGameState.onFocus then
        currentGameState.onFocus(f)
    end
end

function love.resize(w, h)
    if currentGameState.onResize then
        currentGameState.onResize(w, h)
    end
end

function love.textinput(t)
    if currentGameState.onTextInput then
        currentGameState.onTextInput(t)
    end
end
