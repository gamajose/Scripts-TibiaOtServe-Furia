-- Table to hold player-related functions
Player = {}

--- Get the player's unique ID.
-- This function is a wrapper around the external function playerGetId.
-- @return The player's unique ID, or 0 if isn't in-game.
function Player.getId()
	return playerGetId()
end

--- Get the player's name.
-- This function is a wrapper around the external function playerGetName.
-- @return The player's name, or nil if isn't in-game.
function Player.getName()
	return playerGetName()
end

--- Get the player's current health.
-- This function is a wrapper around the external function playerGetHealth.
-- @return The player's current health, or last value if isn't in-game.
function Player.getHealth()
	return playerGetHealth()
end

--- Get the player's current mana.
-- This function is a wrapper around the external function playerGetMana.
-- @return The player's current mana, or last value if isn't in-game.
function Player.getMana()
	return playerGetMana()
end

--- Get the player's current health as a percentage.
-- This function is a wrapper around the external function playerGetHealthPercent.
-- @return The player's current health as a percentage, or last value if isn't in-game.
function Player.getHealthPercent()
	return playerGetHealthPercent()
end

--- Get the player's current mana as a percentage.
-- This function is a wrapper around the external function playerGetManaPercent.
-- @return The player's current mana as a percentage, or last value if isn't in-game.
function Player.getManaPercent()
	return playerGetManaPercent()
end

--- Get the player's current capacity.
-- This function is a wrapper around the external function playerGetCapacity.
-- @return The player's current capacity, or last value if isn't in-game.
function Player.getCapacity()
	return playerGetCapacity()
end

--- Get the player's current soul points.
-- This function is a wrapper around the external function playerGetSoulPoints.
-- @return The player's current soul points, or last value if isn't in-game.
function Player.getSoulPoints()
	return playerGetSoulPoints()
end

--- Return if player is hungry.
-- This function is a wrapper around the external function playerIsHungry.
-- @return The player's hungry state, or last value if isn't in-game.
function Player.isHungry()
	return playerIsHungry()
end

--- Get the player's skills.
-- This function is a wrapper around the external function playerGetSkills.
-- This information will be available if you logged in with bot injected, so it can gather skills informations
-- @return The player's current skills by level and percentage as table, or last value if isn't in-game.
-- Example output:
-- {
--     "lifeLeechDamage": 2500,
--     "manaLeechChance": 0,
--     "manaLeechDamage": 0,
--     "fist": 10,
--     "club": 10,
--     "sword": 10,
--     "distance": 10,
--     "shield": 10,
--     "fishing": 10,
--     "fistPercent": 0,
--     "clubPercent": 0,
--     "swordPercent": 0,
--     "distancePercent": 0,
--     "shieldPercent": 0,
--     "fishingPercent": 0,
--     "criticalChance": 0,
--     "criticalDamage": 0,
--     "lifeLeechChance": 0
-- }
function Player.getSkills()
	return playerGetSkills()
end

--- Get the ID of the player's current target.
-- This function is a wrapper around the external function playerGetTargetId.
-- @return The ID of the player's current target, or last value if isn't in-game.
function Player.getTargetId()
	return playerGetTargetId()
end

--- Get the ID of the player's current follow target.
-- This function is a wrapper around the external function playerGetFollowId.
-- @return The ID of the player's current follow target, or last value if isn't in-game.
function Player.getFollowId()
	return playerGetFollowId()
end

--- Get the item information of specific player's inventory slot.
-- This function is a wrapper around the external function playerGetInventorySlot.
-- @param slot (number) - The inventory slot to get item information, refer the parameter value as Enums.InventorySlot
-- @return The item information of specific the player's inventory slot, or nil if there's no item. Table format: {id=0,count=0,tier=0,holdingCount=0}
function Player.getInventorySlot(slot)
	return playerGetInventorySlot(slot)
end

--- Get the status of specified state index of player.
-- This function is a wrapper around the external function playerGetState.
-- @param index (number) - The state index to check if is active, refer the parameter value as Enums.States
-- @return The state status if is active on player or not, or nil if there's no state from specified param index
function Player.getState(index)
	return playerGetState(index)
end

--- Get the player opened containers.
-- This function get the player opened containers.
-- @return A table containing all open container indexes, or nil if there's no container opened
function Player.getContainers()
	return playerGetContainers()
end