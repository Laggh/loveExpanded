local thisState = {}

function thisState.load()
    points = 0
end

function thisState.update(_Dt)
    points = points + points * 0.001 * _Dt
end

function thisState.draw()
    love.graphics.print("Click the screen", 100, 100)
    love.graphics.print(string.interpolate("Current points: ${points}",{points = points}), 100, 150)
end

function thisState.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        changeGameState("menu")
    end
end

function thisState.mousepressed(x, y, button, istouch, presses)
    points = points + 1
end



return thisState
