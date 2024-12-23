screenLib = require("lib/screen")
json = require("lib/json")
require("lib/loveExpanded")


love.window.updateMode(nil,nil,{vSync = false, resizable = true, msaa = 4})

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
    if not currentGameState then
        error(string.interpolate("State \"${state}\" does not exist",
        {state = _State}))
    end

    if currentGameState.load then
        currentGameState.load(_Arg)
    else
        error(string.interpolate("State \"${state}\" does not have a load function",
        {state = _State}))
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
    if currentGameState.mousepressed then
        currentGameState.mousepressed(x, y, button, istouch, presses)
    end
end
function love.keypressed(key, scancode, isrepeat)
    if currentGameState.keypressed then
        currentGameState.keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    if currentGameState.keyreleased then
        currentGameState.keyreleased(key, scancode)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if currentGameState.mousemoved then
        currentGameState.mousemoved(x, y, dx, dy, istouch)
    end
end

function love.quit()
    if currentGameState.quit then
        currentGameState.quit()
    end
end

function love.focus(f)
    if currentGameState.focus then
        currentGameState.focus(f)
    end
end

function love.resize(w, h)
    if currentGameState.resize then
        currentGameState.resize(w, h)
    end
end

function love.textinput(t)
    if currentGameState.textinput then
        currentGameState.textinput(t)
    end
end
