local thisState = {}

local menuButtons = {}


local function startGame()
    changeGameState("game")
end

local function closeGame()
    local Tittle = "Erro"
    local Message = "Você quer mesmo sair"
    local Options = {"Não","Sim"}
    local Type = "warning"
    local pressedButton = love.window.showMessageBox(Tittle, Message, Options, Type, true)

    if pressedButton == 2 then
        love.event.quit()
    end

end

function thisState.load()
    menuButtons = {
        {text = "Start Game", action = startGame},
        {text = "Close Game", action = closeGame}
    }
end

function thisState.update()

end

function thisState.draw()
    for i,v in pairs(menuButtons) do
        local x = 100
        local y = 100 + i * 50
        love.graphics.rectangle("line", x, y, 200, 50)
        love.graphics.print(v.text, x, y)
    end
end 

function thisState.mousepressed(x, y, button, istouch, presses)
    for i,v in ipairs(menuButtons) do
        local bx = 100
        local by = 100 + i * 50
        if collision.pointRectangle(x, y, bx, by, 200, 50) then
            v.action()
        end
    end
end


return thisState
