local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict

-- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/1bd09637f5786e97fe47b1c7e2d37d35aecff6aa/scripts/unit_extensions/human/ai_player_unit/target_selection_utils.lua

local HEALTH_ALIVE = HEALTH_ALIVE
local unit_knocked_down = AiUtils.unit_knocked_down
local vector3_distance = Vector3.distance
local POSITION_LOOKUP = POSITION_LOOKUP
local AI_TARGET_UNITS = AI_TARGET_UNITS
local AI_UTILS = AI_UTILS
local ScriptUnit_extension = ScriptUnit.extension
local result_table = {}

-- Since no one uses this I cant be bothered to check if mutator is active
mod:hook_origin(PerceptionUtils, "healthy_players", function(unit, blackboard, breed)
    local best_score = -math.huge  
    local best_unit
    local side = blackboard.side
    local PLAYER_AND_BOT_UNITS = side.ENEMY_PLAYER_AND_BOT_UNITS

    for i = 1, #PLAYER_AND_BOT_UNITS do
        local player_unit = PLAYER_AND_BOT_UNITS[i]
        local score = 0
        if Unit.alive(player_unit) then
            local current_hp = ScriptUnit.extension(unit, "health_system"):current_health_percent()
            score = current_hp  -- Higher HP targets will have a higher score

            if score > best_score then
                best_unit = player_unit
                best_score = score
            end
        end
    end

    return best_unit
end)

PerceptionUtils.least_healthy_player = function (unit, blackboard, breed)
    local best_score = -math.huge  
    local best_unit
    local side = blackboard.side
    local PLAYER_AND_BOT_UNITS = side.ENEMY_PLAYER_AND_BOT_UNITS

    for i = 1, #PLAYER_AND_BOT_UNITS do
        local player_unit = PLAYER_AND_BOT_UNITS[i]
        local score = 0
        if Unit.alive(player_unit) then
            local current_hp = ScriptUnit.extension(unit, "health_system"):current_health_percent()
            score = 1 - current_hp  -- Opposite of healthy

            if score > best_score then
                best_unit = player_unit
                best_score = score
            end
        end
    end

    return best_unit
end

PerceptionUtils.furthest_player = function (unit, blackboard, breed)
    local best_score = -math.huge  
    local best_unit
    local side = blackboard.side
    local max_distance = 100
    local PLAYER_AND_BOT_UNITS = side.ENEMY_PLAYER_AND_BOT_UNITS
    local score

    for i = 1, #PLAYER_AND_BOT_UNITS do
        local player_unit = PLAYER_AND_BOT_UNITS[i]
        if Unit.alive(player_unit) then
            if dist < max_distance then
				local inv_radius = math.clamp(dist / max_distance, 0, 1)

				score = score + inv_radius * 5
			end

            if score > best_score then
                best_unit = player_unit
                best_score = score
            end
        end
    end

    return best_unit
end