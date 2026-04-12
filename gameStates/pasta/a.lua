
local thisState = {}

function thisState.load()
    texto = require("gameStates/teste/texto")
end 

function thisState.draw()
    love.graphics.print(texto)
end


return thisState