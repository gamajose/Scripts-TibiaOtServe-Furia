local file = nil
local itemStructureSize = 3
local itemsDbPath = "C:\\Users\\josel\\OneDrive\\Documentos\\ZeroBot\\Scripts" -- items_lua.db FULL PATH DIRECTORY

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

local lastWalk = 0
Timer("dead man walking...", function()
    local creature = Creature(Player.getId())
    local creaturePos = creature:getPosition()
    if not creaturePos then return end

    if creaturePos.x == 32359 and creaturePos.y == 32169 and creaturePos.z == 7 then
        return
    end

    local tileThings = Map.getThings(creaturePos.x, creaturePos.y, creaturePos.z)
    if not tileThings or #tileThings == 0 then return end
    
    local toTileThings = Map.getThings(creaturePos.x, creaturePos.y - 1, creaturePos.z)
    if not toTileThings or #toTileThings == 0 then return end

    for i, v in pairs(toTileThings) do
        if v.id then
            local itemInfo = getItemInfo(v.id)
            if itemInfo.unpassable then
                print("I can't walk.")
                return
            end
        end
    end

    local stepDuration = getStepDuration(creature, tileThings)

    if lastWalk == 0 or os.clock() - lastWalk >= stepDuration / 1000 then
        Game.walk(Enums.Directions.NORTH)
        lastWalk = os.clock()
        print("Walking again...")
    end
end, 5)