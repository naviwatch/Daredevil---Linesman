local mod = get_mod("Daredevil")

local co = 0.11
PackSpawningSettings.default.area_density_coefficient = co
PackSpawningSettings.skaven.area_density_coefficient = co
PackSpawningSettings.chaos.area_density_coefficient = co
PackSpawningSettings.beastmen.area_density_coefficient = co

-- Special Settings
local special_slots 
local min_special_timer
local max_special_timer
if mod:get("giga_specials") then
	special_slots = 5
	min_special_timer = 5
	max_special_timer = 10
else
	special_slots = 7
	min_special_timer = 10
	max_special_timer = 15
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
}

SpecialsSettings.default.difficulty_overrides.hard = table.clone(SpecialsSettings.default)
SpecialsSettings.default.difficulty_overrides.harder = table.clone(SpecialsSettings.default)
SpecialsSettings.default.difficulty_overrides.hardest = table.clone(SpecialsSettings.default)
SpecialsSettings.default.difficulty_overrides.cataclysm = table.clone(SpecialsSettings.default)
SpecialsSettings.default.difficulty_overrides.cataclysm_2 = table.clone(SpecialsSettings.default)
SpecialsSettings.default.difficulty_overrides.cataclysm_3 = table.clone(SpecialsSettings.default)
SpecialsSettings.default.difficulty_overrides.versus_base = table.clone(SpecialsSettings.default)

SpecialsSettings.skaven.max_specials = special_slots
SpecialsSettings.skaven.spawn_method = "specials_by_slots"
SpecialsSettings.skaven.methods = {}
SpecialsSettings.skaven.methods.specials_by_slots = {
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

SpecialsSettings.skaven.breeds = {
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
}

SpecialsSettings.skaven.difficulty_overrides.hard = table.clone(SpecialsSettings.skaven)
SpecialsSettings.skaven.difficulty_overrides.harder = table.clone(SpecialsSettings.skaven)
SpecialsSettings.skaven.difficulty_overrides.hardest = table.clone(SpecialsSettings.skaven)
SpecialsSettings.skaven.difficulty_overrides.cataclysm = table.clone(SpecialsSettings.skaven)
SpecialsSettings.skaven.difficulty_overrides.cataclysm_2 = table.clone(SpecialsSettings.skaven)
SpecialsSettings.skaven.difficulty_overrides.cataclysm_3 = table.clone(SpecialsSettings.skaven)
SpecialsSettings.skaven.difficulty_overrides.versus_base = table.clone(SpecialsSettings.skaven)

SpecialsSettings.skaven_light.max_specials = special_slots
SpecialsSettings.skaven_light.spawn_method = "specials_by_slots"
SpecialsSettings.skaven_light.methods = {}
SpecialsSettings.skaven_light.methods.specials_by_slots = {
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

SpecialsSettings.skaven_light.breeds = {
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
}

SpecialsSettings.skaven_light.difficulty_overrides.hard = table.clone(SpecialsSettings.skaven_light)
SpecialsSettings.skaven_light.difficulty_overrides.harder = table.clone(SpecialsSettings.skaven_light)
SpecialsSettings.skaven_light.difficulty_overrides.hardest = table.clone(SpecialsSettings.skaven_light)
SpecialsSettings.skaven_light.difficulty_overrides.cataclysm = table.clone(SpecialsSettings.skaven_light)
SpecialsSettings.skaven_light.difficulty_overrides.cataclysm_2 = table.clone(SpecialsSettings.skaven_light)
SpecialsSettings.skaven_light.difficulty_overrides.cataclysm_3 = table.clone(SpecialsSettings.skaven_light)
SpecialsSettings.skaven_light.difficulty_overrides.versus_base = table.clone(SpecialsSettings.skaven_light)

SpecialsSettings.chaos.max_specials = special_slots
SpecialsSettings.chaos.spawn_method = "specials_by_slots"
SpecialsSettings.chaos.methods = {}
SpecialsSettings.chaos.methods.specials_by_slots = {
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
}

SpecialsSettings.chaos.difficulty_overrides.hard = table.clone(SpecialsSettings.chaos)
SpecialsSettings.chaos.difficulty_overrides.harder = table.clone(SpecialsSettings.chaos)
SpecialsSettings.chaos.difficulty_overrides.hardest = table.clone(SpecialsSettings.chaos)
SpecialsSettings.chaos.difficulty_overrides.cataclysm = table.clone(SpecialsSettings.chaos)
SpecialsSettings.chaos.difficulty_overrides.cataclysm_2 = table.clone(SpecialsSettings.chaos)
SpecialsSettings.chaos.difficulty_overrides.cataclysm_3 = table.clone(SpecialsSettings.chaos)
SpecialsSettings.chaos.difficulty_overrides.versus_base = table.clone(SpecialsSettings.chaos)

SpecialsSettings.chaos_light.max_specials = special_slots
SpecialsSettings.chaos_light.spawn_method = "specials_by_slots"
SpecialsSettings.chaos_light.methods = {}
SpecialsSettings.chaos_light.methods.specials_by_slots = {
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

SpecialsSettings.chaos_light.breeds = {
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
}

SpecialsSettings.chaos_light.difficulty_overrides.hard = table.clone(SpecialsSettings.chaos_light)
SpecialsSettings.chaos_light.difficulty_overrides.harder = table.clone(SpecialsSettings.chaos_light)
SpecialsSettings.chaos_light.difficulty_overrides.hardest = table.clone(SpecialsSettings.chaos_light)
SpecialsSettings.chaos_light.difficulty_overrides.cataclysm = table.clone(SpecialsSettings.chaos_light)
SpecialsSettings.chaos_light.difficulty_overrides.cataclysm_2 = table.clone(SpecialsSettings.chaos_light)
SpecialsSettings.chaos_light.difficulty_overrides.cataclysm_3 = table.clone(SpecialsSettings.chaos_light)
SpecialsSettings.chaos_light.difficulty_overrides.versus_base = table.clone(SpecialsSettings.chaos_light)

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