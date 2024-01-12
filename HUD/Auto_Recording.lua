NameHunt = 'Hunt'
PcName = 'josel'
isOnRecording = false
pathHUD = nil
local enabled = false

function pathToggle()
    isOnRecording = not isOnRecording
    if isOnRecording then
        enabled = true
        Client.showMessage("Recording (ON)")
    else
        enabled = false
        Client.showMessage("Recording (OFF)")
    end
    updatePathHUD() -- Atualiza o estado da HUD do Oberon Say
end

function updatePathHUD()
    if isOnRecording then
        pathHUD.name:setText("Recording (ON)")
        pathHUD.name:setColor(127, 255, 0)
    else
        pathHUD.name:setText("Recording (OFF)")
        pathHUD.name:setColor(255, 0, 0)
    end
end

local lastPosition = nil
local threshold = 3 -- Ajuste este valor conforme necessário

local function isSamePosition(pos1, pos2, threshold)
    -- Verifica se as coordenadas são iguais ou se a mudança é menor que o threshold
    return (pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z) or
           (math.abs(pos1.x - pos2.x) <= threshold and
            math.abs(pos1.y - pos2.y) <= threshold and
            math.abs(pos1.z - pos2.z) <= threshold)
end

function AddCoordenada()
    local player = Creature(Player.getId())
    if player then
        local playerPos = player:getPosition()

        if not lastPosition or not isSamePosition(playerPos, lastPosition, threshold) then
            local file = assert(io.open(CoordenadasPath, "a+"))
            local coordenada = "{x = " .. playerPos.x .. ", y = " .. playerPos.y .. ", z = " .. playerPos.z .. "}, \n"
			Client.showMessage("    Adicionado a coordenada \n"..coordenada.."     em "..NameHunt..".txt")
            if file then
                file:write(coordenada)
                file:flush()
                file:close()
                lastPosition = playerPos
            end
        end
    end
end

Timer("AdicionarSQMs", function()
    if enabled then
        dofile('HUD\\huntName.lua')
        NameHunt = huntName
        CoordenadasPath = 'C:\\Users\\' ..PcName.. '\\OneDrive\\Documentos\\ZeroBot\\Scripts\\Hunts\\' ..NameHunt..'.txt'
        AddCoordenada()
    end
end, 50)
