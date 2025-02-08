local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict
--[[

local ssms = 6
SpecialsSettings.default.max_specials = ssms
SpecialsSettings.default_light.max_specials = ssms
SpecialsSettings.skaven.max_specials = ssms
SpecialsSettings.skaven_light.max_specials = ssms
SpecialsSettings.chaos.max_specials = ssms
SpecialsSettings.chaos_light.max_specials = ssms
SpecialsSettings.beastmen.max_specials = ssms
SpecialsSettings.skaven_beastmen.max_specials = ssms
SpecialsSettings.chaos_beastmen.max_specials = ssms

PacingSettings.default.delay_specials_threat_value = nil
PacingSettings.chaos.delay_specials_threat_value = nil
PacingSettings.beastmen.delay_specials_threat_value = nil

Breeds.skaven_warpfire_thrower.threat_value = 2
Breeds.skaven_gutter_runner.threat_value = 4
--	Breeds.skaven_pack_master.threat_value = 2
--	Breeds.skaven_poison_wind_globadier.threat_value = 4
Breeds.skaven_ratling_gunner.threat_value = 2
Breeds.chaos_corruptor_sorcerer.threat_value = 2
-- Breeds.chaos_vortex_sorcerer.threat_value = 4

Managers.state.conflict:set_threat_value("skaven_warpfire_thrower", 2)
Managers.state.conflict:set_threat_value("skaven_gutter_runner", 4)
--	Managers.state.conflict:set_threat_value("skaven_pack_master", 2)
--	Managers.state.conflict:set_threat_value("skaven_poison_wind_globadier", 4)
Managers.state.conflict:set_threat_value("skaven_ratling_gunner", 2)
Managers.state.conflict:set_threat_value("chaos_corruptor_sorcerer", 2)
-- Managers.state.conflict:set_threat_value("chaos_vortex_sorcerer", 4)

SpecialsSettings.default.methods.specials_by_slots = {
	max_of_same = 2,
	coordinated_attack_cooldown_multiplier = 0.4,
	chance_of_coordinated_attack = 0.2,
	select_next_breed = "get_random_breed",
	after_safe_zone_delay = {
		5,
		20
	},
	spawn_cooldown = {
		30,
		45
	}
}

if mod:get("beta") then
	SpecialsSettings.default.methods.specials_by_slots = {
		max_of_same = 3,
		coordinated_attack_cooldown_multiplier = 0.4,
		chance_of_coordinated_attack = 0.2,
		select_next_breed = "get_random_breed",
		after_safe_zone_delay = {
			5,
			20
		},
		spawn_cooldown = {
			30,
			35
		}
	}
end

SpecialsSettings.default_light = SpecialsSettings.default
SpecialsSettings.skaven = SpecialsSettings.default
SpecialsSettings.skaven_light = SpecialsSettings.default
SpecialsSettings.chaos = SpecialsSettings.default
SpecialsSettings.chaos_light = SpecialsSettings.default
SpecialsSettings.beastmen = SpecialsSettings.default

SpecialsSettings.default.breeds = {
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_warpfire_thrower"
}

SpecialsSettings.chaos.breeds = SpecialsSettings.default.breeds

--[[
SpecialsSettings.chaos.breeds = {
	"skaven_gutter_runner",
	"skaven_gutter_runner",
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_pack_master",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_poison_wind_globadier",
	"chaos_vortex_sorcerer",
	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
	"chaos_corruptor_sorcerer",
	"skaven_warpfire_thrower",
}
]]
--[[
SpecialsSettings.default.difficulty_overrides = nil	
SpecialsSettings.default_light.difficulty_overrides = nil
SpecialsSettings.skaven.difficulty_overrides = nil
SpecialsSettings.skaven_light.difficulty_overrides = nil
SpecialsSettings.chaos.difficulty_overrides = nil
SpecialsSettings.chaos_light.difficulty_overrides = nil
SpecialsSettings.beastmen.difficulty_overrides = nil
SpecialsSettings.skaven_beastmen.difficulty_overrides = nil
SpecialsSettings.chaos_beastmen.difficulty_overrides = nil
--]]

-- Custom merge_recursive that should be more memory efficient
--[[
function table.merge_recursive(into, from)
    if type(into) ~= "table" or type(from) ~= "table" then
        mod:echo("Both arguments must be tables")
    end

    local stack = {{into, from}}
    local visited = {}  

    while #stack > 0 do
        local current = stack[#stack]  
        table.remove(stack)  

        local node1, node2 = current[1], current[2]

        for k, v in pairs(node2) do
            if type(v) == "table" then
                if not visited[v] then
                    visited[v] = true
                    if type(node1[k]) == "table" then
                        table.insert(stack, {node1[k], v}) 
                    else
                        node1[k] = {} 
                        table.insert(stack, {node1[k], v})
                    end
                end
            else
                node1[k] = v  
            end
        end
    end

    return into
end
]]

-- Special Settings
local special_slots
local min_special_timer
local max_special_timer
local max_of_same
if mod:get("giga_specials") then
	special_slots = 6
	min_special_timer = 0
	max_special_timer = 7
	max_of_same = 3
else
	special_slots = 7
	min_special_timer = 30
	max_special_timer = 43
	max_of_same = 3
end

-- Timer overrides for difficulties
if mod.difficulty_level == 1 then -- baby
	min_special_timer = 37
	max_special_timer = 47
end

-- n/120*(max+min) ~ specials per min
-- idk why the equation is like that osmium came up with it not me,
-- usually its 7-8 per minute in testing
SpecialsSettings.default.max_specials = special_slots
SpecialsSettings.default.spawn_method = "specials_by_slots"
SpecialsSettings.default.methods = {}
SpecialsSettings.default.methods.specials_by_slots = {
	max_of_same = max_of_same,
	coordinated_attack_cooldown_multiplier = 0.4,
	chance_of_coordinated_attack = 0.5,
	select_next_breed = "get_random_breed",
	after_safe_zone_delay = {
		10,
		35
	},
	spawn_cooldown = {
		min_special_timer, -- 32
		max_special_timer -- 60
	}
}

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
--	"chaos_vortex_sorcerer",
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

local new_slot_timers = { 10, 23 }

mod:hook_origin(SpecialsPacing, "specials_by_slots", function(self, t, specials_settings, method_data, slots, spawn_queue)
	local num_slots = #slots
	local waiting = 0
	local about_to_respawn = false

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
				slot.unit = nil
				spawn_queue[#spawn_queue + 1] = slot
				slot.state = method_data.always_coordinated and "coordinating" or "wants_to_spawn"
				slot.time = nil
				slot.dest = ""
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
			local breed = Breeds[breed_name]
			local time = use_fixed_cooldown and (t + ConflictUtils.random_interval(new_slot_timers)) or (t + ConflictUtils.random_interval(method_data.spawn_cooldown))
	
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
	
	if mutator_plus.active and not lb then
		-- Process first two slots with reduced cd
		for i = 1, 1 do
			process_slot(slots[i], t, method_data, spawn_queue, waiting, about_to_respawn, self, true)
		end
	
		-- Process remaining slots with random cooldown
		for i = 2, num_slots do
			process_slot(slots[i], t, method_data, spawn_queue, waiting, about_to_respawn, self, false)
		end
	else
		-- Process all slots with random cooldown
		for i = 1, num_slots do
			process_slot(slots[i], t, method_data, spawn_queue, waiting, about_to_respawn, self, false)
		end
	end

	if about_to_respawn and waiting == num_slots then
		local do_coordinated = Math.random() <= method_data.chance_of_coordinated_attack

		if do_coordinated then
			print("Coordinated attack!")

			local coordinated_time = t + 40
			local average_slot_time = 0
			local coordinated_attack_cooldown_multiplier = method_data.coordinated_attack_cooldown_multiplier or 0.5

			for i = 1, num_slots do
				local slot = slots[i]
				local slot_time = slot.time

				average_slot_time = average_slot_time + slot_time
			end

			if average_slot_time > 0 then
				average_slot_time = average_slot_time / num_slots
				coordinated_time = t + (average_slot_time - t) * coordinated_attack_cooldown_multiplier
			end

			local state_data = self._state_data

			for i = 1, num_slots do
				local slot = slots[i]
				local breed_name, health_modifier = SpecialsPacing.select_breed_functions[method_data.select_next_breed](slots, specials_settings, method_data, state_data, do_coordinated)
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
				slot.desc = "coordinated attack"
			end
		end
	end

	self._specials_timer = t + 1
end)


--[[

mod.deepcopy = function(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[mod.deepcopy(orig_key, copies)] = mod.deepcopy(orig_value, copies)
			end
			setmetatable(copy, mod.deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

mod:hook(SpecialsPacing, "specials_by_slots", function(func, self, t, specials_settings, method_data, ...)
	local new_method_data
	local spawn_cooldown_min = min_special_timer
	local spawn_cooldown_max = max_special_timer

	spawn_cooldown_max = math.max(spawn_cooldown_min, spawn_cooldown_max)
	new_method_data = mod.deepcopy(method_data)
	new_method_data.spawn_cooldown = {
		spawn_cooldown_min,
		spawn_cooldown_max
	}

	if not new_method_data then
		new_method_data = method_data
	end

	func(self, t, specials_settings, new_method_data, ...)
end)

mod:hook(SpecialsPacing.setup_functions, "specials_by_slots", function(func, t, slots, method_data, ...)
	local new_method_data = method_data

	local safe_zone_delay_min = 5
	local safe_zone_delay_max = 20
		safe_zone_delay_max = math.max(safe_zone_delay_min, safe_zone_delay_max)
		new_method_data = mod.deepcopy(method_data)
		new_method_data.after_safe_zone_delay = {
			safe_zone_delay_min,
			safe_zone_delay_max
		}

	local original_specials_settings = mod.deepcopy(CurrentSpecialsSettings)
	CurrentSpecialsSettings.max_specials = special_slots

	func(t, slots, new_method_data, ...)

	CurrentSpecialsSettings = original_specials_settings
end)

-- random shit
mod:hook(SpecialsPacing, "specials_by_slots", function(func, self, t, specials_settings, method_data, ...)
	local new_method_data
	local spawn_cooldown_min = mod:get(mod.SETTING_NAMES.SPAWN_COOLDOWN_MIN)
	local spawn_cooldown_max = mod:get(mod.SETTING_NAMES.SPAWN_COOLDOWN_MAX)
	if spawn_cooldown_min ~= mod.setting_defaults[mod.SETTING_NAMES.SPAWN_COOLDOWN_MIN]
	or spawn_cooldown_max ~= mod.setting_defaults[mod.SETTING_NAMES.SPAWN_COOLDOWN_MAX]
	then
		spawn_cooldown_max = math.max(spawn_cooldown_min, spawn_cooldown_max)
		new_method_data = mod.deepcopy(method_data)
		new_method_data.spawn_cooldown = {
			spawn_cooldown_min,
			spawn_cooldown_max
		}
	end

	if not new_method_data then
		new_method_data = method_data
	end
	func(self, t, specials_settings, new_method_data, ...)
end)
]]

-- Beta exclusive stuff
--[[
if mod:get("beta") then

	local plague_monk_spawn = function (context, data)
		local base_amount = 5
		local num_to_spawn = base_amount
		local spawn_list = {}

		for i = 1, num_to_spawn do
			spawn_list[i] = "skaven_plague_monk"
		end

		local side = Managers.state.side:get_side_from_name("dark_pact")

		data.side_id = side.side_id
	end

	mod:hook_origin(SpecialsPacing, "specials_by_slots", function (self, t, specials_settings, method_data, slots, spawn_queue)
		local num_slots = #slots
		local waiting = 0
		local about_to_respawn = false
	
		for i = 1, num_slots do
			local slot = slots[i]
	
			if slot.state == "alive" and not HEALTH_ALIVE[slot.unit] then
				local breed_name, health_modifier = SpecialsPacing.select_breed_functions[method_data.select_next_breed](slots, specials_settings, method_data, self._state_data)
				local breed = Breeds[breed_name]
				local time = t + ConflictUtils.random_interval(method_data.spawn_cooldown)
	
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

				plague_monk_spawn()

				local horde_spawner = Managers.state.conflict.horde_spawner
				local only_ahead = false
				local side_id = data.side_id
	
				horde_spawner:execute_custom_horde(spawn_list, only_ahead, side_id)
			end
		end
	
		return func(self, t, specials_settings, method_data, slots, spawn_queue)
	end)
	mod:echo("Test")
end
]]
