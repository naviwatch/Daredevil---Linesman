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
if mod:get("giga_specials") then
	special_slots = 6
	min_special_timer = 0
	max_special_timer = 10
else
	special_slots = 7
	min_special_timer = 30
	max_special_timer = 43
end
-- n/120*(max+min) ~ specials per min

SpecialsSettings.default.max_specials = special_slots
SpecialsSettings.default.spawn_method = "specials_by_slots"
SpecialsSettings.default.methods = {}
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
	"chaos_corruptor_sorcerer",
--	"skaven_gutter_runner",
--	"skaven_pack_master",
	"skaven_ratling_gunner",
	"skaven_poison_wind_globadier",
	"skaven_warpfire_thrower",
	"chaos_vortex_sorcerer",
--	"chaos_corruptor_sorcerer",
}

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