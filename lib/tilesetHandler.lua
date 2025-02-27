-- Made by Laggh
-- Dependencies: json.lua (stored in the variable 'json')

local API = {}

-- Transform a tileset into an array of tile images
-- (Tileset, tileWidth, tileHeight) -> [img1, img2, img3, ...]
function API.tilesetToArray(tileset, tileWidth, tileHeight)
    local tileArray = {}

    local tilesetWidth = tileset:getWidth()
    local tilesetHeight = tileset:getHeight()
    
    local tilesetWidth = tilesetWidth / tileWidth
    local tilesetHeight = tilesetHeight / tileHeight

    local tileCount = 1
    for y = 0, tilesetHeight - 1 do
        for x = 0, tilesetWidth - 1 do
            local newCanvas = love.graphics.newCanvas(tileWidth, tileHeight)
            love.graphics.setCanvas(newCanvas)
            love.graphics.draw(tileset, -x * tileWidth, -y * tileHeight)
            love.graphics.setCanvas()
            tileArray[tileCount] = newCanvas
            tileCount = tileCount + 1
        end
    end
    return tileArray
end

-- Transform an array of tile images into a tileset
-- (tileArray[], tileWidth, tileHeight) -> tileset (canvas)
function API.ArrayToTileset(tileArray, tileWidth, tileHeight)
    local tileset = love.graphics.newCanvas(tileWidth * #tileArray, tileHeight)
    love.graphics.setCanvas(tileset)
    for i = 1, #tileArray do
        love.graphics.draw(tileArray[i], (i - 1) * tileWidth, 0)
    end
    love.graphics.setCanvas()
    return tileset
end

-- Transform a .tmj file into a and creates a table with the data called 'data2', the data is in the format 'data[y][x]'
-- (file) -> table
function API.tiledToTable(file)
    if not json then
        error("json library not fount, please require it or put it in the variable 'json'")
    end
    if not love.filesystem.getInfo(file) then
        error("File not found")
    end

    local file = love.filesystem.read(file)
    local table = json.decode(file)

    for i,v in ipairs(table.layers) do
        for ii,vv in pairs(v.data) do
            --v.data[ii] = v.data[ii] + 1
        end

        v.data2 = {} --data but in a 2d table instead of a 1d table
        for i = 1, #v.data do
            if not v.data2[math.ceil(i / v.width)] then
                v.data2[math.ceil(i / v.width)] = {}
            end
            v.data2[math.ceil(i / v.width)][i % v.width == 0 and v.width or i % v.width] = v.data[i]
        end
    end
    return table
end

return API