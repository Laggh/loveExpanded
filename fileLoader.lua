local nImg = love.graphics.newImage
local nSfx = love.audio.newSource

local loadedFiles = {}


loadedFiles.img = {
    ant = {
        [1] = nImg("img/formiga-01.png"),
        [2] = nImg("img/formiga-02.png")
    }
}

loadedFiles.sfx = {

}

loadedFiles.font = {
    small = love.graphics.newFont(12),
    medium = love.graphics.newFont(24),
    big = love.graphics.newFont(48),
    monospace = {
        small = love.graphics.newFont("fonts/monospaced.ttf", 12),
        medium = love.graphics.newFont("fonts/monospaced.ttf", 24),
        big = love.graphics.newFont("fonts/monospaced.ttf", 48)
    }
}



return loadedFiles