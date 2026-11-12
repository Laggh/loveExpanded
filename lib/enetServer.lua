local server = {}
local enet = require "enet"

server.config = {
    tickRate = 20,
    timeout = 1000
}

server.clients = { count = 0 } -- Lista de clientes (peers)
server.shared = {}             -- Estado global autoritativo

local lastSharedState = {}     -- Para o diffing
local snapshotTimer = 0


function server.start(port)

    enet.host_create("*:" .. port,2) -- Cria com 2 canais
    -- TODO: 
    -- 1. Chamar server.load() (se existir)
    -- 2. Inicializar enet.host_create("*:port")
    -- 3. Loop infinito (while true) com controle de dt (Tick Accumulator)
    -- 4. Chamar server._syncState() no final de cada Tick
    -- 5. love.timer.sleep() para liberar CPU

    
end

function server.sendEvent(clientObj, eventName, data)
    -- TODO: Enviar evento específico para um cliente


end

function server.broadcastEvent(eventName, data)
    -- TODO: Enviar evento para todos os clientes conectados


end

-- Funções internas auxiliares sugeridas
function server._processConnection(peer)
    -- TODO: Gerar ID, salvar no server.clients, disparar server.onConnect


end

function server._processDisconnect(peer)
    -- TODO: Remover do server.clients, disparar server.onDisconnect


end

function server._syncState(dt)
    -- TODO: Lógica de calcular diff do server.shared, 
    -- mandar via Unreliable e mandar Full Snapshot periodicamente


end

--[[
function server.load() end
function server.tick(dt) end
function server.onConnect(client) end
function server.onDisconnect(client, reason) end
function server.onEvent(client, eventName, data) end
]]

return server