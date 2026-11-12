local server = require("lib/enetServer")

-- Configurações iniciais
function server.load()
    server.config.tickRate = 20
    server.config.timeout = 1000
end

function server.tick(dt)
    
end

-- Eventos customizados (RPCs)
function server.onEvent(client, eventName, data)
    if eventName == "player_jump" then
        --Faz nada
    end
end

function server.onConnect(client) 
    print("Cliente conectado! ID: " .. client.id)
    print("Ping médio: " .. client.ping)
    
    if server.clients.count > 10 then
        client:disconnect("Lobby cheio")
    end
end

function server.onDisconnect(client, reason)
    print("Cliente " .. client.id .. " saiu. Motivo: " .. reason)
end

server.start(6789)