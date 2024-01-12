isOnCavebot = false
cavebotHUD = nil
local isLoopEnabled = false -- Variable to track the loop status

-- User-Editable Variables
local PcName = 'josel'          -- Your PC name
local NameHunt = 'Glooths'      -- Name for the hunt
local monsterCountThreshold = 4 -- Threshold for monster count to move to the next area
local monsterCheckArea = 7      -- Area to check for monsters

-- Wait time in seconds (user-editable)
local WaitTimeInSeconds = 1

-- Key trigger to toggle the loop
local CAVEBOT_KEYSWITCH_START = "p"

function CavebotToggle()
    isOnCavebot = not isOnCavebot
    if isOnCavebot then
        dofile('HUD\\huntName.lua')
        -- Dynamic filename based on PC name and hunt name
        CoordenadasPath = 'C:\\Users\\' .. PcName .. '\\OneDrive\\Documentos\\ZeroBot\\Scripts\\Hunts\\' .. huntName .. '.txt'
        sequenciaDePosicoes = readPositionsFromFile(CoordenadasPath)
        isLoopEnabled = true
        Client.showMessage("Cavebot (ON)")
        wait(1000)
        Client.showMessage(huntName)
    else
        isLoopEnabled = false
        Client.showMessage("Cavebot (OFF)")
    end
    updateCavebotHUD() -- Atualiza o estado da HUD do Oberon Say
end

function updateCavebotHUD()
    if isOnCavebot then
        cavebotHUD.name:setText("Cavebot (ON)")
        cavebotHUD.name:setColor(127, 255, 0)
    else
        cavebotHUD.name:setText("Cavebot (OFF)")
        cavebotHUD.name:setColor(255, 0, 0)
    end
end

-- Function to move to a position
function moverParaPosicao(posicao)
    if posicao then
        Map.goTo(posicao.x, posicao.y, posicao.z)
        -- Add any additional logic after reaching the position, if necessary
    else
        print("Error: Attempt to access a null position.")
    end
end

function GetMonstersCountInsideArea(area)
    local count = 0
    local creatures = Map.getCreatureIds(true, false)
    local playerPos = Creature(Player.getId()):getPosition()

    if playerPos then
        for i = 1, #creatures do
            local creature = Creature(creatures[i])

            if creature and creature:getType() == Enums.CreatureTypes.CREATURETYPE_MONSTER then
                local creaturePos = creature:getPosition()

                if creaturePos then
                    if math.abs(playerPos.x - creaturePos.x) <= area and math.abs(playerPos.y - creaturePos.y) <= area then
                        count = count + 1
                    end
                end
            end
        end
    end

    return count
end

-- Function to read positions from a file with UTF-8 support
function readPositionsFromFile(filename)
    local file = io.open(filename, "r", "utf-8")
    if not file then
        error("Unable to open file: " .. filename)
    end

    local positions = {}
    for line in file:lines() do
        local x, y, z = line:match("{%s*x%s*=%s*(%d+),%s*y%s*=%s*(%d+),%s*z%s*=%s*(%d+)%s*}")
        if x and y and z then
            table.insert(positions, { x = tonumber(x), y = tonumber(y), z = tonumber(z) })
        end
    end

    file:close()
    return positions
end

-- Convert wait time to milliseconds
local WaitTimeInMilliseconds = WaitTimeInSeconds * 1000

-- Main Loop
--local sequenciaDePosicoes = readPositionsFromFile(CoordenadasPath)
local currentPositionIndex = 1



Timer("Cavebot", function()
    if isLoopEnabled then
        -- Move to the current position
        local targetPos = sequenciaDePosicoes[currentPositionIndex]

        -- Wait for the specified time
        --wait(WaitTimeInMilliseconds)

        -- Check monster count in the area
        local monsterCount = GetMonstersCountInsideArea(monsterCheckArea)

        -- Decide whpether to move to the next position or wait
        if monsterCount < monsterCountThreshold then
            --Client.showMessage("Monster count is less than " .. monsterCountThreshold .. ". Moving to the next area.")
            --Client.showMessage("Next desired position: " .. (currentPositionIndex + 1))
            wait(WaitTimeInMilliseconds)

            currentPositionIndex = (currentPositionIndex % #sequenciaDePosicoes) + 1
            moverParaPosicao(targetPos)
        end
    else
        wait(100) -- Pause the loop when it is disabled
    end
end, 200)



local _, _, CAVEBOT_KEY_START = HotkeyManager.parseKeyCombination(CAVEBOT_KEYSWITCH_START)
function OnKeyPressed(key, modifier)
    if key == CAVEBOT_KEY_START then
        isLoopEnabled = not isLoopEnabled -- Toggle the loop status
        print("Cavebot loop is ")
        Client.showMessage("Cavebot loop is " .. (isLoopEnabled and "enabled" or "disabled"))
    end
end

Game.registerEvent(Game.Events.HOTKEY_SHORTCUT_PRESS, OnKeyPressed)
