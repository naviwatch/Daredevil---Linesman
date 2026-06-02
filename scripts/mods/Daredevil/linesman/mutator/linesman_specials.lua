local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict
local man = mod.difficulty_level == 3
local baby = mod.difficulty_level == 0
local boy = mod.difficulty_level == 1
local boomer = mod.difficulty_level == 4

-- Special Settings
local special_slots
local min_special_timer
local max_special_timer
local max_of_same
local coca
if mod:get("giga_specials") then
	special_slots = 6
	min_special_timer = 0
	max_special_timer = 7
	max_of_same = 3
	mod:chat_broadcast("Unending Specials ENABLED.")
elseif not lb then
	special_slots = 7
	min_special_timer = 30 -- 30
	max_special_timer = 45 
	max_of_same = 3
end

if lb then
	special_slots = 7
	min_special_timer = 35 -- 30
	max_special_timer = 47 
	max_of_same = 3
end
-- Timer overrides for difficulties
if boy or baby then -- baby
	min_special_timer = 37
	max_special_timer = 50
end

if not boomer or lb then 
	coca = 0.5
else
	coca = 0
end

-- n/120*(max+min) ~ specials per min
-- idk why the equation is like that osmium came up with it not me,
-- usually its 7-8 per minute in testing
SpecialsSettings.default.max_specials = special_slots
SpecialsSettings.default.spawn_method = "specials_by_slots"
SpecialsSettings.default.methods = {}
SpecialsSettings.default.methods.specials_by_slots = {
	max_of_same = max_of_same,
	coordinated_attack_cooldown_multiplier = 0.3,
	chance_of_coordinated_attack = coca,
	select_next_breed = "get_random_breed",
	after_safe_zone_delay = {
		20,
		45
	},
	spawn_cooldown = {
		min_special_timer, -- 32
		max_special_timer -- 60
	},
}

if boomer then
	SpecialsSettings.default.methods.specials_by_slots.after_safe_zone_delay = { 10, 15 }
end

SpecialsSettings.default.breeds = {
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_warpfire_thrower",
	"skaven_poison_wind_globadier",
	"chaos_corruptor_sorcerer",
	"skaven_gutter_runner",
--	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
}

--[[
if mod:get("beta") then
	SpecialsSettings.default.breeds = {
		"skaven_gutter_runner",
		"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"skaven_warpfire_thrower",
		"chaos_vortex_sorcerer",
		"chaos_corruptor_sorcerer",
		"beastmen_standard_bearer",
		"skaven_gutter_runner",
		"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_warpfire_thrower",
		"chaos_corruptor_sorcerer",
		"beastmen_standard_bearer",
	--	"skaven_gutter_runner",
	--	"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"skaven_warpfire_thrower",
		"chaos_vortex_sorcerer",
	--	"chaos_corruptor_sorcerer",
	}
end
]]

local default_override = table.clone(SpecialsSettings.default)
-- SpecialsSettings.default.difficulty_overrides.hard = default_override
-- SpecialsSettings.default.difficulty_overrides.harder = default_override
SpecialsSettings.default.difficulty_overrides.hardest = default_override
SpecialsSettings.default.difficulty_overrides.cataclysm = default_override
-- SpecialsSettings.default.difficulty_overrides.cataclysm_2 = default_override
SpecialsSettings.default.difficulty_overrides.cataclysm_3 = default_override
-- SpecialsSettings.default.difficulty_overrides.versus_base = default_override

table.merge_recursive(SpecialsSettings.default_light, SpecialsSettings.default)
table.merge_recursive(SpecialsSettings.skaven, SpecialsSettings.default)

SpecialsSettings.skaven.breeds = {
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_warpfire_thrower",
	"skaven_poison_wind_globadier",
	"skaven_gutter_runner",
--	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
}

-- SpecialsSettings.skaven.difficulty_overrides.hard.breeds = SpecialsSettings.skaven.breeds
-- SpecialsSettings.skaven.difficulty_overrides.harder = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.hardest.breeds = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.cataclysm.breeds = SpecialsSettings.skaven.breeds
-- SpecialsSettings.skaven.difficulty_overrides.cataclysm_2 = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.cataclysm_3.breeds = SpecialsSettings.skaven.breeds
-- SpecialsSettings.skaven.difficulty_overrides.versus_base = SpecialsSettings.skaven.breeds
table.merge_recursive(SpecialsSettings.skaven_light, SpecialsSettings.skaven)

table.merge_recursive(SpecialsSettings.chaos, SpecialsSettings.default)
table.merge_recursive(SpecialsSettings.chaos_light, SpecialsSettings.default)
table.merge_recursive(SpecialsSettings.beastmen, SpecialsSettings.default)

SpecialsSettings.chaos.breeds = {
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_warpfire_thrower",
	"skaven_poison_wind_globadier",
	"chaos_corruptor_sorcerer",
	"skaven_gutter_runner",
--	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
--	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
}

SpecialsSettings.beastmen.breeds = {
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_warpfire_thrower",
	"skaven_poison_wind_globadier",
	"chaos_corruptor_sorcerer",
	"skaven_gutter_runner",
--	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
--	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
}

SpecialsSettings.skaven_beastmen = SpecialsSettings.beastmen
SpecialsSettings.chaos_beastmen = SpecialsSettings.beastmen

-------------------------------------------------------------
-- === SPECIALS ===
-- Custom fast timer
local new_slot_timers
if not baby then
	new_slot_timers = { 10, 25 } -- gaslighting time
else
	new_slot_timers = { 20, 25 }
end

-- New surge stuff
local surge_timer_range = {0, 10}          -- Range for special respawn timers during surge (seconds)
local surge_duration = 30                  -- How long the surge lasts (seconds)
local chance_of_surge = lb and 0.3 or 0                 -- Probability of surge triggering during coordinated attack
local surge_coordinated_multiplier = 0.2   -- Multiplier to speed up initial burst
local surge_cooldown_range = {60, 90}      -- Cooldown range for surge (seconds)

-- Same breed spawning code
local max_same_breed_slots = 3             -- Maximum number of same-breed slots to spawn together
local same_breed_chance = 0.3              -- Chance for same-breed slots to spawn together
local stagger_time = 5                     -- Stagger time between same-breed spawns (seconds)

-- Horde-spawning specials
local horde_spawn_specials = 0           -- Probability of a slot being turned into a "horde special", ie spawned using horde mechanics

local level_name = Managers.level_transition_handler:get_current_level_key()

local spawn_custom_horde = function(slot)
	if level_name == "mines" and slot.breed ~= "chaos_vortex_sorcerer" then
		local num_to_spawn = math.random(1, 1) -- Customizable number for the future 
		local spawn_list = {}
		for i = 1, num_to_spawn do
			table.insert(spawn_list, slot.breed) 
		end
		local side = Managers.state.conflict.default_enemy_side_id
		Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, false, side)
	end
end

mod:hook_origin(SpecialsPacing, "specials_by_slots", function(self, t, specials_settings, method_data, slots, spawn_queue)
    local num_slots = #slots
    local waiting = 0
    local about_to_respawn = false
    local slots_to_spawn = {} -- Track slots ready to spawn for breed grouping

    -- Initialize surge state if not already set
    self._surge_active = self._surge_active or false
    self._surge_end_time = self._surge_end_time or 0
    self._last_surge_end_time = self._last_surge_end_time or 0
    self._surge_cooldown_duration = self._surge_cooldown_duration or 0

    -- Check if surge has ended
    if self._surge_active and t >= self._surge_end_time then
        self._surge_active = false
        self._last_surge_end_time = t
        self._surge_cooldown_duration = math.random(surge_cooldown_range[1], surge_cooldown_range[2])
    end

    if method_data.always_coordinated then
        local state_data = self._state_data
        if t > state_data.coordinated_timer then
            self:set_next_coordinated_attack(t, specials_settings, method_data, slots, spawn_queue)
        end
        self._specials_timer = t + 1
        return
    end

    local function process_slot(slot, t, method_data, spawn_queue, waiting, about_to_respawn, self, use_fixed_cooldown)
        if slot.state == "waiting" then
            if t > slot.time then
                if mutator_plus.active and not use_fixed_cooldown and math.random() <= horde_spawn_specials then -- 30% chance for non-fixed cooldown slots
                    spawn_custom_horde(slot)
                    local cooldown_range = (mutator_plus.active and self._surge_active) and surge_timer_range or method_data.spawn_cooldown
                    slot.time = t + ConflictUtils.random_interval(cooldown_range) + 10 -- Reset timer with 10 extra seconds
                else
                    -- Normal spawning logic, but delay actual spawning for breed grouping
                    slot.unit = nil
                    slot.state = method_data.always_coordinated and "coordinating" or "wants_to_spawn"
                    slot.time = nil
                    slot.desc = ""
                    slots_to_spawn[#slots_to_spawn + 1] = slot -- Track for breed grouping
                end
            else
                waiting = waiting + 1
            end

            if slot.special_spawn_stinger and t > slot.special_spawn_stinger_at_t then
                self:_play_stinger(slot.special_spawn_stinger, slot)
                slot.special_spawn_stinger = nil
                slot.special_spawn_stinger_at_t = nil
            end
        end

        if slot.state == "alive" and not HEALTH_ALIVE[slot.unit] then
            local breed_name, health_modifier = SpecialsPacing.select_breed_functions[method_data.select_next_breed](slots, specials_settings, method_data, self._state_data)
			-- replace blights on hunger
            if level_name == "mines" and breed_name == "chaos_vortex_sorcerer" then
                local replacement_breeds = {"skaven_gutter_runner", "skaven_poison_wind_globadier", "skaven_pack_master", "chaos_corruptor_sorcerer"}
                breed_name = replacement_breeds[math.random(1, #replacement_breeds)]
            end
            local breed = Breeds[breed_name]
            local cooldown_range = (mutator_plus.active and self._surge_active) and surge_timer_range or method_data.spawn_cooldown
            local time = use_fixed_cooldown and (t + ConflictUtils.random_interval(new_slot_timers)) or (t + ConflictUtils.random_interval(cooldown_range))

            if breed.special_spawn_stinger then
                slot.special_spawn_stinger = breed.special_spawn_stinger
                slot.special_spawn_stinger_at_t = time - (breed.special_spawn_stinger_time or 6)
            else
                slot.special_spawn_stinger = nil
                slot.special_spawn_stinger_at_t = nil
            end

            slot.time = time
            slot.breed = breed_name
            slot.unit = nil
            slot.state = "waiting"
            slot.desc = ""
            slot.health_modifier = health_modifier
            about_to_respawn = true
            waiting = waiting + 1
        end
    end

    -- Process slots
    if mutator_plus.active then
        if level_name == "dlc_termite_3" then 
            for i = 1, 2 do
                process_slot(slots[i], t, method_data, spawn_queue, waiting, about_to_respawn, self, true)
            end
            for i = 3, num_slots do
                process_slot(slots[i], t, method_data, spawn_queue, waiting, about_to_respawn, self, false)
            end
        else
            for i = 1, 1 do
                process_slot(slots[i], t, method_data, spawn_queue, waiting, about_to_respawn, self, true)
            end
            for i = 2, num_slots do
                process_slot(slots[i], t, method_data, spawn_queue, waiting, about_to_respawn, self, false)
            end
        end
    else
        for i = 1, num_slots do
            process_slot(slots[i], t, method_data, spawn_queue, waiting, about_to_respawn, self, false)
        end
    end

    -- Handle same-breed slot grouping only when man is active
    if mutator_plus.active and #slots_to_spawn > 0 then
        -- Group slots by breed
        local breed_groups = {}
        for _, slot in ipairs(slots_to_spawn) do
            local breed = slot.breed
            breed_groups[breed] = breed_groups[breed] or {}
            table.insert(breed_groups[breed], slot)
        end

        -- Process each breed group
        for breed, group in pairs(breed_groups) do
            if #group > 1 and math.random() <= same_breed_chance then -- 30% chance to group
                local num_to_group = math.min(#group, max_same_breed_slots)
                local base_time = t + 10 -- Base spawn time for the group
                for i = 1, num_to_group do
                    local slot = group[i]
                    slot.time = base_time + (i - 1) * stagger_time -- Staggered spawn
                    slot.state = "waiting"
                    -- Remove from spawn queue to prevent immediate spawning
                    for j, queued_slot in ipairs(spawn_queue) do
                        if queued_slot == slot then
                            table.remove(spawn_queue, j)
                            break
                        end
                    end
                end
                -- Remaining slots in group (if any) proceed normally
                for i = num_to_group + 1, #group do
                    local slot = group[i]
                    spawn_queue[#spawn_queue + 1] = slot
                end
            else
                -- No grouping, all slots proceed normally
                for _, slot in ipairs(group) do
                    spawn_queue[#spawn_queue + 1] = slot
                end
            end
        end
    else
        -- Add all slots to spawn queue if man is inactive
        for _, slot in ipairs(slots_to_spawn) do
            spawn_queue[#spawn_queue + 1] = slot
        end
    end

    if about_to_respawn and waiting == num_slots then
        local do_coordinated = math.random() <= method_data.chance_of_coordinated_attack
        if do_coordinated then
            print("Coordinated attack!")
            local coordinated_attack_cooldown_multiplier

            if mutator_plus.active then
                local surge_cooldown_expired = t > self._last_surge_end_time + self._surge_cooldown_duration
                local do_surge = surge_cooldown_expired and math.random() <= chance_of_surge
                if do_surge then
                    self._surge_active = true
                    self._surge_end_time = t + surge_duration
                    coordinated_attack_cooldown_multiplier = surge_coordinated_multiplier
                    mod:chat_broadcast("Surge activated!")
                else
                    coordinated_attack_cooldown_multiplier = method_data.coordinated_attack_cooldown_multiplier or 0.5
                end
            else
                coordinated_attack_cooldown_multiplier = method_data.coordinated_attack_cooldown_multiplier or 0.5
            end

            local coordinated_time
            local average_slot_time = 0
            for i = 1, num_slots do
                local slot = slots[i]
                average_slot_time = average_slot_time + (slot.time or 0)
            end

            if average_slot_time > 0 then
                average_slot_time = average_slot_time / num_slots
                coordinated_time = t + (average_slot_time - t) * coordinated_attack_cooldown_multiplier
            else
                coordinated_time = t + 20 -- Fallback
            end

            local state_data = self._state_data
            for i = 1, num_slots do
                local slot = slots[i]
                local breed_name, health_modifier = SpecialsPacing.select_breed_functions[method_data.select_next_breed](slots, specials_settings, method_data, state_data, do_coordinated)
				if level_name == "mines" and breed_name == "chaos_vortex_sorcerer" then
					local replacement_breeds = { "skaven_gutter_runner", "skaven_poison_wind_globadier", "skaven_pack_master", "chaos_corruptor_sorcerer" }
					breed_name = replacement_breeds[math.random(1, #replacement_breeds)]
				end
                local breed = Breeds[breed_name]
                local time = coordinated_time + (method_data.coordinated_trickle_time and i * method_data.coordinated_trickle_time or i * 2)
                
                if breed.special_spawn_stinger then
                    slot.special_spawn_stinger = breed.special_spawn_stinger
                    slot.special_spawn_stinger_at_t = time - (breed.special_spawn_stinger_time or 6)
                else
                    slot.special_spawn_stinger = nil
                    slot.special_spawn_stinger_at_t = nil
                end

                slot.time = time
                slot.breed = breed_name
                slot.unit = nil
                slot.state = "waiting"
                slot.health_modifier = health_modifier
                about_to_respawn = true
                slot.desc = (mutator_plus.active and self._surge_active) and "surge attack" or "coordinated attack"
            end
        end
    end

    self._specials_timer = t + 1
end)