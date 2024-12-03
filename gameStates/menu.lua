local thisState = {}

function thisState.load()
    randomMenuVariable = "random menu value"
end

function thisState.update(_Dt)
    globalTime = globalTime + _Dt
    stateTime = stateTime + _Dt
end

function thisState.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Menu Screen: " .. randomMenuVariable, 10, 10)
end

function thisState.onInput(_Input)
    if wantToQuit then
        if _Input == "y" then
            love.event.quit()
        else
            wantToQuit = false
        end
    end

    if _Input == "p" then
        changeGameState("game")
    end

    if _Input == "c" then
        changeGameState("config")
    end

    if _Input == "q" then
        wantToQuit = true
    end

end

return thisState
