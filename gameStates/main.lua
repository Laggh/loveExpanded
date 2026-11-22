local thisState = {}

local points

function thisState.load()
    points = 0
    changeGameState("netClientExample2")
end 

function thisState.draw()
    love.graphics.print("Pontos: " .. points, 10, 10)
end


function thisState.mousepressed()
    points = points + 1
end

return thisState
