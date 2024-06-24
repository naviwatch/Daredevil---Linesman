SpecialsSettings = SpecialsSettings or {}

local director_specials = table.clone(SpecialsSettings.default)

director_specials.max_specials = 7	
director_specials.delay_specials_threat_value = nil
director_specials.methods.specials_by_slots = {
    max_of_same = 2,                                         
    coordinated_attack_cooldown_multiplier = 0.5,
    chance_of_coordinated_attack = 0.2,
    select_next_breed = "get_random_breed",
    after_safe_zone_delay = {
        5,
        20
    },
    spawn_cooldown = {
        20,													
        30													
    }
}

director_specials.breeds = {
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

director_specials.difficulty_overrides.hard = nil
director_specials.difficulty_overrides.harder = nil
director_specials.difficulty_overrides.hardest = nil
director_specials.difficulty_overrides.cataclysm = nil
director_specials.difficulty_overrides.cataclysm_2 = nil
director_specials.difficulty_overrides.cataclysm_3 = nil