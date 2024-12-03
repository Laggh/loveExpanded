local thisState = {}

function thisState.load()
    thisState.randomVariable = 0
end

function thisState.update()
    thisState.randomVariable = thisState.randomVariable + 1
end

function thisState.draw()
    love.graphics.print("Hello World!", 400, 300)
end

function thisState.onMouseClick(_Input)
    
end

return thisState
