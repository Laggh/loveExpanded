function loadFile(_File)
    local func = love.filesystem.load(_File) 
    return func()
end


function love.load()
    screen = loadFile("API_mobile.lua") --carrega o arquivo na variavel 
    love.window.setMode(800, 600,{resizable=true})
end

function love.update(dt)

end

function love.draw()
    screen.setScreen(200,200)
    love.graphics.rectangle("line",0,0,200,200)
    love.graphics.line(0,0,200,200)
    screen.createBorder()
end