local client = {}
local enet = require "enet"
local json = require("lib/json")
require("lib/loveExpanded")
-- ==========================================
-- VARIÁVEIS DE ESTADO (API Pública)
-- ==========================================

client.connectionState = "disconnected" -- disconnected, connecting, connected
client.id = nil
client.shared = {}       -- Somente leitura (verdade do servidor)
client.rawShared = {}    -- Verdade do servidor sem Interpolação (no momneto é IGUAL a .shared)
client.localState = {}   -- Previsão local do cliente
client._bufferedEvents = {} -- Eventos recebidos do servidor que ainda não foram processados

client.updateRate = nil
client._deltaSinceUpdate = 0





-- client.lua
function client.tryConnect(address)
  host = enet.host_create()
  server = host:connect(address)
end

function client._sendReliable(data)
  local jsonData = json.encode(data)
  server:send(jsonData, 0, "reliable") 
end
function client._sendUnreliable(data)
  local jsonData = json.encode(data)
  server:send(jsonData, 1, "unreliable") 
end

function client._handleReceive(event)
  print("Got message: ", event.data, event.peer)

  local functionMap = {
    ["innitial"] = client._handleInnitialMessage,
    ["event"] = client._handleEventMessage,
    ["snapshot"] = client._handleSnapshotMessage
  }
  local noFunction = function(event)
    print("No handler for message type: " .. event.type)
  end

  local data = json.decode(event.data)

  if client.connectionState ~= "connected" then
    print("Buffering event of type", event.data)
    table.insert(client._bufferedEvents, event)
    return
  end

  local functionToRun = functionMap[data.type] or noFunction
  functionToRun(data)
end

function client._handleConnect(event)
  client.connectionState = "waiting_for_innitial"
  print(event.peer, "connected.")
end

function client._handleDisconnect(event)
  client.connectionState = "disconnected"
  print(event.peer, "disconnected.")
end

-- Recebe evento e roteia para a função correta
function client._handleEvent(event)
  local functionMap = {
    ["receive"] = client._handleReceive,
    ["connect"] = client._handleConnect,
    ["disconnect"] = client._handleDisconnect
  }
  local function noFunction(event)
    print("No handler for event type: " .. event.type)
  end
  local functionToRun = functionMap[event.type] or noFunction
  functionToRun(event)
end

function client._handleInnitialMessage(event)
  client.connectionState = "connected"
  client.id = event.clientId
  client.updateRate = event.updateRate
  client.rawShared = event.shared
  client.shared = event.shared

  --Roda os eventos que estavam em buffer (antes de receber o innitial)
  for _, bufferedEvent in ipairs(client._bufferedEvents) do
    client._handleReceive(bufferedEvent)
  end

  if client.onConnect then
    client.onConnect(client.id, event.connectionParams)
  end

end

function client._handleEventMessage(event)
  runIfDefined(client.onEvent, event.eventName, event.data)
end

function client._handleSnapshotMessage(event)
  client._applySnapshot(event.shared)
  --runIfDefined(client.onOverride, event.shared)
end
  

function client.update(dt)
  --Lida com pacotes
  local event = host:service(0)

  while event do
    client._handleEvent(event)
    event = host:service()
  end
  --Para se não estiver conectado
  if client.connectionState ~= "connected" then return end

  --Lida com o Estado do Cliente
  client._deltaSinceUpdate = client._deltaSinceUpdate + dt
  if client._deltaSinceUpdate < client.updateRate then return end
  
  client._deltaSinceUpdate = 0

  client._applySnapshot(client.rawShared)
  client._sendLocalState()
  --No futuro isso vai mudar para poder ter apenas diffs, mas no moment é só snapshot (pq ta em json)
end

function client.sendEvent(eventName, data)
  if client.connectionState ~= "connected" then print("Cannot send event, client not connected") return end
  
  local dataToSent = {
    type = "event",
    eventName = eventName,
    data = data
  }

  local jsonData = json.encode(dataToSent)
  server:send(jsonData, 0, "reliable")
end

function client._sendLocalState()
  if client.connectionState ~= "connected" then print("Cannot send local state, client not connected") return end

  client._sendUnreliable({
    type = "localState",
    localState = client.localState
  })
end
  
-- Funções internas auxiliares sugeridas para organização
function client._applySnapshot(data)
  for k,v in pairs(data) do
    client.shared[k] = v
  end
end

function client._applyDiff(data)

end

-- ==========================================
-- CALLBACKS DO DEV (Fallbacks vazios)
-- ==========================================
-- O motor deve chamar essas funções, mas se o dev não 
-- defini-las no main.lua, o motor não quebra.

--[[
function client.onConnect(meuId, connectionParams) end
function client.onDisconnect(reason) end
function client.onOverride(data) end
function client.onEvent(eventName, data) end
]]

return client