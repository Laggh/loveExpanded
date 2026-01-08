local thisState = {}

local points

function thisState.load()
    points = 0
end 

function thisState.draw()
    love.graphics.print("Mouse Clicks: "..points,100,100)
end


function thisState.mousepressed()
    points = points + 1
end

return thisState
