-- https://github.com/Laggh/loveButtons
-- If you like this please star the repository on github.

local API = {}
function API.setScreen(_Width,_Height)
    sizeX,sizeY = love.window.getMode()
    local aspectRatio = sizeX/sizeY
    local newAspectRatio = _Width/_Height

    if aspectRatio > newAspectRatio then -- largura original é maior
        scale = sizeY / _Height
    else -- largura original é menor
        scale = sizeX / _Width
    end
    
    newX = _Width * scale
    newY = _Height * scale
    offY = (sizeY - newY) / 2
    offX = (sizeX - newX) / 2

    
   love.graphics.origin()
    love.graphics.scale(scale)
    love.graphics.translate(offX/scale,offY/scale)
    API.sizeX = _Width
    API.sizeY = _Height
    API.offX = offX/scale
    API.offY = offY/scale
    API.scale = scale
end

function API.createBorder()
    local sizeX,sizeY = love.window.getMode()
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill",-API.offX,-API.offY,API.offX,sizeY/API.scale)
    love.graphics.rectangle("fill",API.sizeX,-API.offY,API.offX,sizeY/API.scale)
    love.graphics.rectangle("fill",-API.offX,-API.offY,sizeX/API.scale,API.offY)
    love.graphics.rectangle("fill",-API.offX,API.sizeY,sizeX/API.scale,API.offY)
    love.graphics.setColor(1, 1, 1, 1)
end

function API.checkOfsets(_Width,_Height)
    sizeX,sizeY = love.window.getMode()
    local aspectRatio = sizeX/sizeY
    local newAspectRatio = _Width/_Height
    local scale = 1

    if aspectRatio > newAspectRatio then -- largura original é maior
        scale = sizeY / _Height
    else -- largura original é menor
        scale = sizeX / _Width
    end
    
    newX = _Width * scale
    newY = _Height * scale
    offY = (sizeY - newY) / 2
    offX = (sizeX - newX) / 2
    API.sizeX = _Width
    API.sizeY = _Height
    API.offX = offX/scale
    API.offY = offY/scale
    API.scale = scale
end

function API.getMousePosition()
    local x,y = love.mouse.getPosition()
    x = (x/API.scale) - API.offX
    y = (y/API.scale) - API.offY
    return x,y
end

function API.toScreen(_X,_Y)
    return _X * API.scale + API.offX, _Y * API.scale + API.offY
end

function API.toGame(_X,_Y)
    return (_X - API.offX) / API.scale, (_Y - API.offY) / API.scale
end

return API