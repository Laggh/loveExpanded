-- FUNCTIONS

-- Interpolates a string with the given arguments.
-- (String[],Arguments[]) -> String
function string.interpolate(_Str,_Args)
    return (_Str:gsub('($%b{})', function(w) return _Args[w:sub(3, -2)] or w end))
end

-- Clamps a value between a minimum and maximum value.
-- (Min,Value,Max)
function setLimits(_Min,_Value,_Max)
    if _Value < _Min then return _Min end
    if _Value > _Max then return _Max end
    return _Value
end

-- Checks if a value is within a specified range.
-- (Min,Value,Max) 
function inLimits(_Min,_Value,_Max)
    if _Value < _Min then return false end
    if _Value > _Max then return false end
    return true
end

-- Joins multiple values into a single string.
-- (Value1,Value2,...)
function strJoin(...)
    local args = {...}
    local str = ""
    for i,v in ipairs(args) do
        str = str .. tostring(v)
    end
    return str
end

-- Draws an image centered at the given coordinates.
-- (Draw,X,Y,R,Sx,Sy)
function drawCentered(_Draw, _X, _Y, _R, _Sx , _Sy)
    local width, height = _Draw:getDimensions()
    love.graphics.draw(_Draw, _X, _Y, _R, _Sx, _Sy ,width/2, height/2)
end

-- Isolates a color inside a function
-- (R,G,B,A,Function)
function withColor(_R,_G,_B,_A,_Function)
    local r,g,b,a = love.graphics.getColor()
    love.graphics.setColor(_R,_G,_B,_A)
    _Function()
    love.graphics.setColor(r,g,b,a)
end

-- Gets the angle difference of 2 points
-- (X1,Y1,X2,Y2)
function math.getAngle(_X1,_Y1,_X2,_Y2)
    _X2,_Y2 = _X2 or 0,_Y2 or 0
    return math.atan2(_Y2-_Y1,_X2-_X1)
end

-- Gets the distance between 2 points
-- (X1,Y1,X2,Y2)
function math.getDistance(_X1,_Y1,_X2,_Y2)
    return math.sqrt((_X2-_X1)^2 + (_Y2-_Y1)^2)
end

collision = {}
-- Checks if a point is inside a rectangle
-- (X1,Y1,X2,Y2,W,H)
function collision.pointRectangle(_X1,_Y1,_X2,_Y2,_W,_H)
    return _X1 > _X2 and _X1 < _X2 + _W and _Y1 > _Y2 and _Y1 < _Y2 + _H
end

-- Checks if a point is inside a circle
-- (X1,Y1,X2,Y2,R)
function collision.rectangleRectangle(_X1,_Y1,_W1,_H1,_X2,_Y2,_W2,_H2)
    return _X1 < _X2 + _W2 and
           _X2 < _X1 + _W1 and
           _Y1 < _Y2 + _H2 and
           _Y2 < _Y1 + _H1
end
-- Checks if a point is inside a circle
-- (X1,Y1,X2,Y2,R)
function collision.pointCircle(_X1,_Y1,_X2,_Y2,_R)
    return math.getDistance(_X1,_Y1,_X2,_Y2) < _R
end

-- Checks if a circle is inside a rectangle
-- (X1,Y1,R1,X2,Y2,W,H)
function collision.circleCircle(_X1,_Y1,_R1,_X2,_Y2,_R2)
    return math.getDistance(_X1,_Y1,_X2,_Y2) < _R1 + _R2
end
local function loadAllThings(_Path)
    local loaded = {}
    for i,v in pairs(love.filesystem.getDirectoryItems(_Path)) do
        -- if it is a directory
        if love.filesystem.getInfo(_Path.."/"..v, "directory") ~= nil then
            loaded[v] = {}
            for ii,vv in pairs(love.filesystem.getDirectoryItems(_Path .. "/" .. v)) do
                local imgName = string.sub(vv, 1, -5)
                loaded[v][imgName] = love.graphics.newImage(strJoin(_Path, "/", v, "/", vv))
            end
        else -- if it is a file
            local imgName = string.sub(v, 1, -5)
            loaded[imgName] = love.graphics.newImage(_Path .. "/" .. v)
        end
    end
    return loaded
end
--LOADING FILES

img = {}
img = loadAllThings("img")

sfx = {}
sfx = loadAllThings("sfx")

font = {}
font = {
    small = love.graphics.newFont(12),
    medium = love.graphics.newFont(24),
    big = love.graphics.newFont(48),
    monospace = {
        small = love.graphics.newFont("fonts/monospaced.ttf", 12),
        medium = love.graphics.newFont("fonts/monospaced.ttf", 24),
        big = love.graphics.newFont("fonts/monospaced.ttf", 48)
    }
}

print(json.encode(img))


