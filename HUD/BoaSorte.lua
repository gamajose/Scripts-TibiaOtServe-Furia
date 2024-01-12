local file = nil
local itemStructureSize = 3
local itemsDbPath = "C:\\Users\\josel\\OneDrive\\Documentos\\ZeroBot\\Scripts\\items_lua.db" -- items_lua.db FULL PATH DIRECTORY
local destinations = {
    {x = 33754, y = 30901, z = 9},
    {x = 33754, y = 30904, z = 9},
    {x = 33754, y = 30907, z = 9},
    {x = 33754, y = 30910, z = 9},

}


Bit = {}
Bit.U16ToBytes = function(value)
	local target = {}
	target[0] = value % 256;
	target[1] = math.floor((value / 256) % 256)
	return target
end
Bit.U32ToBytes = function(value)
	local target = {}
	target[0] = value % 256;
	target[1] = math.floor((value / 256) % 256)
	target[2] = math.floor((value / 65536) % 256)
	target[3] = math.floor((value / 16777216) % 256)
	return target
end
Bit.U64ToBytes = function(value)
	local target = {}
	target[0] = value % 256;
	target[1] = math.floor((value / 256) % 256)
	target[2] = math.floor((value / 65536) % 256)
	target[3] = math.floor((value / 16777216) % 256)
	target[4] = math.floor((value / 4294967296) % 256)
	target[5] = math.floor((value / 1099511627776) % 256)
	target[6] = math.floor((value / 281474976710656) % 256)
	target[7] = math.floor((value / 72057594037927936) % 256)
	return target
end
Bit.BytesToU16 = function(target, index)
	return target[index + 0] + target[index + 1] * 256;
end
Bit.BytesToU32 = function(target, index)
	return target[index + 0] + target[index + 1] * 256 + target[index + 2] * 65536 + target[index + 3] * 16777216;
end
Bit.BytesToU64 = function(target, index)
	return target[index + 0] + target[index + 1] * 256 + target[index + 2] * 65536 +
		target[index + 3] * 16777216 +
		target[index + 4] * 4294967296 +
		target[index + 5] * 1099511627776 +
		target[index + 6] * 281474976710656 +
		target[index + 7] * 72057594037927936;
end

local speedA = 857.36
local speedB = 261.29
local speedC = -4795.01

function getStepDuration(creature, tileThings)
	local creaturePos = creature:getPosition()
	local stepSpeed = creature:getSpeed()
	local calculatedStepSpeed = math.max(math.floor((speedA * math.log(stepSpeed + speedB) + speedC) + 0.5), 1)
	calculatedStepSpeed = (stepSpeed > -speedB) and calculatedStepSpeed or 1

	local groundSpeed = 150
    local groundId = tileThings[1].id
    local itemInfo = getItemInfo(groundId)
    groundSpeed = itemInfo.groundSpeed > 0 and itemInfo.groundSpeed or groundSpeed

	local duration = math.floor(1000 * groundSpeed / calculatedStepSpeed)
	local stepDuration = math.ceil(duration / 50) * 50

	return stepDuration
end

function getItemInfo(id)
    if not file then
        file = io.open(itemsDbPath, "rb")
    end

    id = id - 100
    if not file then return {unpassable = true, groundSpeed = 0} end
    file:seek("set", id * itemStructureSize)
    local tmpBuffer = {}
    local read = file:read(itemStructureSize)

    for c in (read or ''):gmatch '.' do
        tmpBuffer[#tmpBuffer + 1] = c:byte()
    end

    if #tmpBuffer ~= itemStructureSize then
        return {unpassable = true, groundSpeed = 0}
    end

    local unpassable = tmpBuffer[1] == 1
    local groundSpeed = Bit.BytesToU16(tmpBuffer, 2)

    return {unpassable = unpassable, groundSpeed = groundSpeed}
end



local currentDestinationIndex = 1
local lastWalk = 0
local matrix = {}

local function distance(pos1, pos2)
    return math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y)
end

local function tableFind(tbl, elem)
    for index, value in ipairs(tbl) do
        if value.x == elem.x and value.y == elem.y then
            return index
        end
    end
    return nil
end

local function isSamePosition(pos1, pos2)
    return pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z
end


local function isMonsterAtPosition(pos)
    local creatures = Map.getCreatureIds(true, false) or {}
    for i = 1, #creatures do
        local cid = creatures[i]
        local creature = Creature(cid)
        if creature ~= nil and creature:getType() == Enums.CreatureTypes.CREATURETYPE_MONSTER then
            local creaturePos = creature:getPosition()
            if creaturePos and creaturePos.x == pos.x and creaturePos.y == pos.y and creaturePos.z == pos.z then
                return true
            end
        end
    end
    return false
end

local function fillMatrix()
    local playerPos = Creature(Player.getId()):getPosition()
    for x = -8, 7 do
        matrix[x + 8] = {}
        for y = -6, 5 do
            local position = { x = playerPos.x + x, y = playerPos.y + y, z = playerPos.z }
            local toTileThings = Map.getThings(position.x, position.y, position.z)
            local isUnpassable = false
            if toTileThings and #toTileThings > 0 then
                for _, item in ipairs(toTileThings) do
                    if item.id and getItemInfo(item.id).unpassable then
                        isUnpassable = true
                        break
                    end
                end
            end
            matrix[x + 8][y + 6] = isUnpassable or isMonsterAtPosition(position)
        end
    end
end 





local function findPath(start, goal)

    local openSet = {start}
    local cameFrom = {}
    local gScore = {}
    gScore[start] = 0

    local function isValidPosition(x, y)
        local matrixX = x + 8
        local matrixY = y + 6
    
        if matrixX >= 1 and matrixX <= 16 and matrixY >= 1 and matrixY <= 12 then
            -- Se a posição na matriz é nil, trata como impassável (true)
            -- Caso contrário, usa o valor existente na matriz
            local isUnpassable = matrix[matrixX] and matrix[matrixX][matrixY]
            return not isUnpassable
        end
    
        return false
    end

    while #openSet > 0 do
        local current, currentIndex
        local lowestFScore = math.huge

        for index, position in ipairs(openSet) do
            local fScore = gScore[position] + distance(position, goal)
            if fScore < lowestFScore then
                lowestFScore = fScore
                current = position
                currentIndex = index
            end
        end

        if current.x == goal.x and current.y == goal.y then
            local path = {}
            while current do
                table.insert(path, 1, current)
                current = cameFrom[current]
            end
            return path
        end

        table.remove(openSet, currentIndex)
        
        local neighbors = {
            { x = current.x + 1, y = current.y },
            { x = current.x - 1, y = current.y },
            { x = current.x, y = current.y + 1 },
            { x = current.x, y = current.y - 1 },
            { x = current.x + 1, y = current.y + 1 }, -- diagonal inferior direita
            { x = current.x - 1, y = current.y - 1 }, -- diagonal superior esquerda
            { x = current.x + 1, y = current.y - 1 }, -- diagonal superior direita
            { x = current.x - 1, y = current.y + 1 }  -- diagonal inferior esquerda
        }
        fillMatrix()
        for _, neighbor in ipairs(neighbors) do

            local tentativeGScore = gScore[current] + 1
            if isValidPosition(neighbor.x - start.x, neighbor.y - start.y) then
                if not gScore[neighbor] or tentativeGScore < gScore[neighbor] then
                    cameFrom[neighbor] = current
                    gScore[neighbor] = tentativeGScore
                    if not tableFind(openSet, neighbor) then
                        table.insert(openSet, neighbor)
                    end
                end
            end
        end
    end

    return nil
end

local function resetWaypoints()
    currentDestinationIndex = 1
end


local function countMonstersAroundAndTotal(playerPos)
    local adjacentCount = 0
    local totalMonsters = 0
    local creatures = Map.getCreatureIds(true, false) or {}

    for _, cid in ipairs(creatures) do
        local creature = Creature(cid)
        if creature and creature:getType() == Enums.CreatureTypes.CREATURETYPE_MONSTER then
            totalMonsters = totalMonsters + 1
            local creaturePos = creature:getPosition()
            if creaturePos then
                local dx = math.abs(creaturePos.x - playerPos.x)
                local dy = math.abs(creaturePos.y - playerPos.y)
                local dz = creaturePos.z - playerPos.z
                if (dx <= 1 and dy <= 1 and dz == 0) and not (dx == 0 and dy == 0) then
                    adjacentCount = adjacentCount + 1
                end
            end
        end
    end
    return adjacentCount, totalMonsters
end


local function findNearestWaypoint(playerPosition, waypoints)
    local nearestIndex = 1
    local nearestDistance = math.huge

    for i, waypoint in ipairs(waypoints) do
        local distance = math.sqrt((playerPosition.x - waypoint.x)^2 + (playerPosition.y - waypoint.y)^2)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestIndex = i
        end
    end

    return nearestIndex
end

local creature = Creature(Player.getId())
local creaturePos = creature:getPosition()
if creaturePos then
    currentDestinationIndex = findNearestWaypoint(creaturePos, destinations)
end

Timer("finding path...", function()
    local creature = Creature(Player.getId())
    local creaturePos = creature:getPosition()
    if not creaturePos then return end

    adjacentCount, totalMonsters = countMonstersAroundAndTotal(creaturePos)



    local adjacentMonsters, totalMonsters = countMonstersAroundAndTotal(creaturePos)

    local destination = destinations[currentDestinationIndex]
    -- Condições para mover o personagem

    if isSamePosition(creaturePos, destination) then
        currentDestinationIndex = currentDestinationIndex + 1
        if currentDestinationIndex > #destinations then
            resetWaypoints()

        end
        destination = destinations[currentDestinationIndex] -- Atualiza o destino para o próximo waypoint
    end

        local path = findPath({x = creaturePos.x, y = creaturePos.y}, destination)

        if path and #path > 1 then
            local nextPos = path[2]
            local dx = nextPos.x - creaturePos.x
            local dy = nextPos.y - creaturePos.y
            print("position", creaturePos.x, creaturePos.y)
            print("Next step: ", nextPos.x, nextPos.y)

            local direction = nil

            if dx > 0 and dy > 0 then
                direction = Enums.Directions.SOUTHEAST
            elseif dx < 0 and dy < 0 then
                direction = Enums.Directions.NORTHWEST
            elseif dx > 0 and dy < 0 then
                direction = Enums.Directions.NORTHEAST
            elseif dx < 0 and dy > 0 then
                direction = Enums.Directions.SOUTHWEST
            elseif dx > 0 then
                direction = Enums.Directions.EAST
            elseif dx < 0 then
                direction = Enums.Directions.WEST
            elseif dy > 0 then
                direction = Enums.Directions.SOUTH
            elseif dy < 0 then
                direction = Enums.Directions.NORTH
            end

            local stepDuration = getStepDuration(creature, Map.getThings(nextPos.x, nextPos.y, creaturePos.z))

            if lastWalk == 0 or os.clock() - lastWalk >= stepDuration / 2000 then
                Game.walk(direction)
                lastWalk = os.clock()
                print("Walking...")
            end
        else
            print("No path found or path is too short.")
        end
end, 50)


-- local isScriptRunning = false
-- function onStartStopScript ()
--     if (isScriptRunning) then
--         isScriptRunning = false
--         print("Script stopped")
--     else 
--         isScriptRunning = true
--         print("Script started")
--         startScript()
--     end
-- end

-- function startScript()
        
-- end