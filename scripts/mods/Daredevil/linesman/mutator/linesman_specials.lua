local mod = get_mod("Daredevil")

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

-- n/120*(max+min) ~ specials per min

SpecialsSettings.default.max_specials = special_slots
SpecialsSettings.default.spawn_method = "specials_by_slots"
SpecialsSettings.default.methods = {}
SpecialsSettings.default.methods.specials_by_slots = {
	max_of_same = max_of_same,
	coordinated_attack_cooldown_multiplier = 0.4,
	chance_of_coordinated_attack = 0.2,
	select_next_breed = "get_random_breed",
	after_safe_zone_delay = {
		5,
		20
	},
	spawn_cooldown = {
		min_special_timer, -- 32
		max_special_timer -- 60
	}
}

if mod:get("beta") then
	SpecialsSettings.default.methods.specials_by_slots.chance_of_coordinated_attack = 0
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
	"chaos_corruptor_sorcerer",
--	"skaven_gutter_runner",
--	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
	"chaos_vortex_sorcerer",
--	"chaos_corruptor_sorcerer",
}

if mod:get("beta") then
	SpecialsSettings.default.methods.specials_by_slots.chance_of_coordinated_attack = 0

	SpecialsSettings.default.breeds = {
		"skaven_gutter_runner",
		"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"skaven_warpfire_thrower",
		"chaos_vortex_sorcerer",
		"chaos_corruptor_sorcerer",
	--	"skaven_gutter_runner",
	--	"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_warpfire_thrower",
	--	"chaos_corruptor_sorcerer",
	--	"skaven_gutter_runner",
	--	"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"skaven_warpfire_thrower",
	--	"chaos_vortex_sorcerer",
	--	"chaos_corruptor_sorcerer",
	}

	SpecialsSettings.chaos.breeds = {
		"skaven_gutter_runner",
		"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"skaven_warpfire_thrower",
		"chaos_vortex_sorcerer",
		"chaos_corruptor_sorcerer",
	--	"skaven_gutter_runner",
	--	"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_warpfire_thrower",
	--	"chaos_corruptor_sorcerer",
	--	"skaven_gutter_runner",
	--	"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"skaven_warpfire_thrower",
		"chaos_vortex_sorcerer",
	--	"chaos_corruptor_sorcerer",
	}
end

local default_override = table.clone(SpecialsSettings.default)
SpecialsSettings.default.difficulty_overrides.hard = default_override
SpecialsSettings.default.difficulty_overrides.harder = default_override
SpecialsSettings.default.difficulty_overrides.hardest = default_override
SpecialsSettings.default.difficulty_overrides.cataclysm = default_override
SpecialsSettings.default.difficulty_overrides.cataclysm_2 = default_override
SpecialsSettings.default.difficulty_overrides.cataclysm_3 = default_override
SpecialsSettings.default.difficulty_overrides.versus_base = default_override

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
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
--	"skaven_gutter_runner",
--	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_warpfire_thrower",
}

SpecialsSettings.skaven.difficulty_overrides.hard.breeds = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.harder = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.hardest = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.cataclysm = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.cataclysm_2 = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.cataclysm_3 = SpecialsSettings.skaven.breeds
SpecialsSettings.skaven.difficulty_overrides.versus_base = SpecialsSettings.skaven.breeds
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
	"chaos_corruptor_sorcerer",
--	"skaven_gutter_runner",
--	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
	"chaos_vortex_sorcerer",
--	"chaos_corruptor_sorcerer",
}

SpecialsSettings.beastmen.breeds = {
	"beastmen_standard_bearer",
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"chaos_vortex_sorcerer",
	"chaos_corruptor_sorcerer",
	"skaven_gutter_runner",
	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"chaos_vortex_sorcerer",
	"skaven_warpfire_thrower"
}

SpecialsSettings.skaven_beastmen = SpecialsSettings.beastmen
SpecialsSettings.chaos_beastmen = SpecialsSettings.beastmen

--[[
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