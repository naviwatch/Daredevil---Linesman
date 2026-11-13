local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict
local bl = get_mod("Beastmen Loader")

-- ============================================================================
-- ENHANCEMENT DEFINITIONS
-- ============================================================================
local enhancement_list = {
	["regenerating"] = true,
	["unstaggerable"] = true
}
local enhancement_1 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
	["unstaggerable"] = true
}
local relentless = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
	["intangible"] = true
}
local enhancement_3 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
	["ranged_immune"] = true
}
local enhancement_4 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["commander"] = true,
}
local enhancement_5 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
	["regenerating"] = true
}
local enhancement_6 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["warping"] = true,
	["crushing"] = true
}
local enhancement_7 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["crushing"] = true
}
local shield_shatter = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["crushing"] = true,
--	["intangible"] = true,
	["unstaggerable"] = true
}
local bob = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["crushing"] = true,
	["intangible"] = true,
	["unstaggerable"] = true
}
local better_bob = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["commander"] = true,
	["unstaggerable"] = true
}
local warchief = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["intangible"] = true,
	["unstaggerable"] = true
}
local grain = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

local function respawn_check()
        for _, player in pairs(Managers.player:players()) do
                if player.player_unit then
                        local status_extension = ScriptUnit.has_extension(player.player_unit, "status_system")
                        if status_extension and not status_extension.is_ready_for_assisted_respawn(status_extension) then
                                return true
                        end
                end
        end
        return false
end

local function stop_progress_event()
        return true
end

local function progress_event(required_progress, terror_event_name)
        local level_analysis = conflict_director.level_analysis
        local main_path_data = level_analysis.main_path_data
        local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
        local total_travel_dist = main_path_data.total_dist
        local travel_percentage = ahead_travel_dist / total_travel_dist * 100

        while true do
                if required_progress <= travel_percentage then
                        conflict_director:start_terror_event(terror_event_name)
                        mod:echo("STARTING EVENT STARTING EVENT STARTING EVENT")
                        break
                end

                if stop_progress_event() then
                        break
                end
        end
end

local function create_weights()
        local crash = nil

        for id, setting in pairs(PackSpawningSettings) do
                setting.name = id

                if not setting.disabled then
                        roaming_set = setting.roaming_set
                        roaming_set.name = id
                        local weights = {}
                        local breed_packs_override = roaming_set.breed_packs_override

                        if breed_packs_override then
                                for i = 1, #breed_packs_override, 1 do
                                        weights[i] = breed_packs_override[i][2]
                                end

                                roaming_set.breed_packs_override_loaded_dice = {
                                        LoadedDice.create(weights)
                                }
                        end
                end
        end

        -- Adjustment for the new difficulty system of horde compositions from 1.4 - I am not copypasting each composition 3 times. Or 4, doesn't matter.
        for event, composition in pairs(HordeCompositions) do
                if not composition[1][1] then
                        local temp_table = table.clone(composition)
                        table.clear_array(composition, #composition)
                        composition[1] = temp_table
                        composition[2] = temp_table
                        composition[3] = temp_table
                        composition[4] = temp_table
                        composition[5] = temp_table
                        composition[6] = temp_table
                        composition[7] = temp_table
                elseif not composition[6] then
                        composition[6] = composition[5]
                        composition[7] = composition[5]
                end
        end

        local weights = {}
        local crash = nil

        for key, setting in pairs(HordeSettings) do
        setting.name = key

        if setting.compositions then
            for name, composition in pairs(setting.compositions) do
                for i = 1, #composition, 1 do
                    table.clear_array(weights, #weights)

                    local compositions = composition[i]

                    for j, variant in ipairs(compositions) do
                        weights[j] = variant.weight
                        local breeds = variant.breeds

                        if breeds then
                            for k = 1, #breeds, 2 do
                                local breed_name = breeds[k]
                                local breed = Breeds[breed_name]

                                if not breed then
                                    print(string.format("Bad or non-existing breed in HordeCompositions table %s : '%s' defined in HordeCompositions.", name, tostring(breed_name)))

                                    crash = true
                                elseif not breed.can_use_horde_spawners then
                                    variant.must_use_hidden_spawners = true
                                end
                            end
                        end
                    end

                    compositions.loaded_probs = {
                        LoadedDice.create(weights)
                    }

                    fassert(not crash, "Found errors in HordeComposition table %s - see above. ", name)
                    fassert(compositions.loaded_probs, "Could not create horde composition probablitity table, make sure the table '%s' in HordeCompositions is correctly structured and has an entry for each difficulty.", name)
                end
            end
        end

                if setting.compositions_pacing then
                        for name, composition in pairs(setting.compositions_pacing) do
                                table.clear_array(weights, #weights)

                                for i, variant in ipairs(composition) do
                                        weights[i] = variant.weight
                                        local breeds = variant.breeds

                                        for j = 1, #breeds, 2 do
                                                local breed_name = breeds[j]
                                                local breed = Breeds[breed_name]

                                                if not breed then
                                                        print(string.format("Bad or non-existing breed in HordeCompositionsPacing table %s : '%s' defined in HordeCompositionsPacing.", name, tostring(breed_name)))

                                                        crash = true
                                                elseif not breed.can_use_horde_spawners then
                                                        variant.must_use_hidden_spawners = true
                                                end
                                        end
                                end

                                composition.loaded_probs = {
                                        LoadedDice.create(weights)
                                }

                                fassert(not crash, "Found errors in HordeCompositionsPacing table %s - see above. ", name)
                                fassert(composition.loaded_probs, "Could not create horde composition probablitity table, make sure the table '%s' in HordeCompositionsPacing is correctly structured.", name)
                        end
                end
        end
end


-- ============================================================================
-- DIFFICULTY CONFIGS
-- ============================================================================

local DIFFICULTY = {
        BABY = 0,
        BOY = 1,
        MAN = 3,
        BOOMER = 4,
}

mod.difficulty_level = mod:get("difficulty_level")

local current_difficulty = mod.difficulty_level
local is_baby = current_difficulty == DIFFICULTY.BABY
local is_boy = current_difficulty == DIFFICULTY.BOY
local is_man = current_difficulty == DIFFICULTY.MAN
local is_boomer = current_difficulty == DIFFICULTY.BOOMER

-- Multiplier used on hordes 
local GAIN_MULTIPLIERS = {
        [DIFFICULTY.BABY] = 0.5,
        [DIFFICULTY.BOY] = 0.6,
        [DIFFICULTY.MAN] = 1.0,
        [DIFFICULTY.BOOMER] = 1.0,
}
mod.gain = GAIN_MULTIPLIERS[mod.difficulty_level] or 1.0

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- This really doesnt fucking matter much but we'll still do it to be safe
mutator_plus.OriginalBreeds = table.clone(Breeds)

mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_breeds")
mod:dofile("scripts/mods/Daredevil/linesman/functions/perceptions")
mod:dofile("scripts/mods/Daredevil/linesman/functions/man_functions")

RecycleSettings = {
        ai_stuck_check_start_time = 10,
        destroy_los_distance_squared = 8100,
        destroy_no_path_found_time = 5,
        destroy_no_path_only_behind = true,
        destroy_stuck_distance_squared = 400, --20 squared
        max_grunts = 160,
        push_horde_if_num_alive_grunts_above = 300,
        push_horde_in_time = true,
}

-- ============================================================================
-- SPAWN HOOKS
-- ============================================================================

-- Difficulty multipliers for ambient density
local DIFFICULTY_MULTIPLIERS = {
        [DIFFICULTY.BABY] = 1.0,
        [DIFFICULTY.BOY] = 1.0,
        [DIFFICULTY.MAN] = 1.15,
        [DIFFICULTY.BOOMER] = 1.25,
}

-- Map-specific multipliers
local MAP_MULTIPLIERS = {
        dlc_termite_1 = 0.65,
        dlc_termite_3 = 2.0,
        dlc_bastion = 0.8,
        dlc_reikwald_river = 1.0,
        skittergate = 2,
}

-- Breed replacement mappings by level
local BREED_REPLACEMENTS = {
        skaven_stronghold = {
                chaos_raider = "skaven_storm_vermin_commander",
                chaos_berzerker = "skaven_plague_monk",
                chaos_warrior = "skaven_storm_vermin",
                chaos_marauder = "skaven_clan_rat",
                chaos_marauder_with_shield = "skaven_clan_rat_with_shield",
                chaos_fanatic = "skaven_slave"
        },
        dlc_termite_3 = {
                chaos_raider = "skaven_storm_vermin_commander",
                chaos_berzerker = "skaven_plague_monk",
                chaos_warrior = "skaven_storm_vermin",
                chaos_marauder = "skaven_clan_rat",
                chaos_marauder_with_shield = "skaven_clan_rat_with_shield",
                chaos_fanatic = "skaven_slave"
        },
        warcamp = {
                skaven_storm_vermin_commander = "chaos_raider",
                skaven_plague_monk = "chaos_berzerker",
                skaven_storm_vermin = "chaos_warrior",
                skaven_clan_rat = "chaos_marauder",
                skaven_clan_rat_with_shield = "chaos_marauder_with_shield",
                skaven_slave = "chaos_fanatic"
        },
        crater = {
                beastmen_gor = "chaos_fanatic",
                beastmen_ungor = "skaven_clan_rat",
        },
}

-- Random breed replacements
local RANDOM_REPLACEMENTS = {
        skaven_clan_rat_with_shield = { "skaven_clan_rat" },
        chaos_marauder_with_shield = { "chaos_marauder" },
        skaven_storm_vermin_with_shield = { "skaven_plague_monk", "skaven_storm_vermin_commander" }
}

mod:hook(SpawnZoneBaker, "spawn_amount_rats", function(func, self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
        local level_transition = Managers.level_transition_handler
        local level_name = level_transition:get_current_level_key()

        local multiplier = DIFFICULTY_MULTIPLIERS[mod.difficulty_level] or 1.25

        if lb or mod:get("ubercharge") then
            multiplier = 1.4
        end

        multiplier = MAP_MULTIPLIERS[level_name] or multiplier

        num_wanted_rats = math.round(num_wanted_rats * multiplier)

        return func(self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
end)

mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
        -- Ensure breed is valid before processing
        if not breed or not breed.name then
                return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
        end

        local level_name = Managers.level_transition_handler:get_current_level_key()
        local new_breed = breed

        local random_options = RANDOM_REPLACEMENTS[breed.name]
        if random_options then
                if level_name == "dlc_termite_3" and breed.name == "skaven_storm_vermin_with_shield" then
                        new_breed = Breeds[random_options[math.random(1, #random_options)]]
                elseif math.random() <= 0.6 then
                        new_breed = Breeds[random_options[math.random(1, #random_options)]]
                end
        end

        local level_replacements = BREED_REPLACEMENTS[level_name]
        if level_replacements and level_replacements[breed.name] then
                new_breed = Breeds[level_replacements[breed.name]]
        end

        return func(self, new_breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
end)

-- ============================================================================
-- PACK DISTRIBUTIONS
-- ============================================================================

local SPAWN_MEAN = 1.1
local SPAWN_RANGE = 0.01

PackDistributions = {
        periodical = {
                max_low_density = SPAWN_MEAN,
                min_low_density = SPAWN_MEAN - SPAWN_RANGE,
                min_hi_density = SPAWN_MEAN,
                max_hi_density = SPAWN_MEAN + SPAWN_RANGE,
                random_distribution = false,
                zero_density_below = 0,
                max_hi_dist = 3,
                min_hi_dist = 2,
                max_low_dist = 10,
                min_low_dist = 7,
                zero_clamp_max_dist = 5
        },
        random = {},
        linesman = {
                min_density = 0.5,
                max_density = 0.8,
                goal_density = 0.6
        }
}

PackSpawningDistribution = {
        standard = {
                goal_density = SPAWN_MEAN,
                clamp_main_path_zone_area = 100,
                length_density_coefficient = 0,
                spawn_cycle_length = 350,
                clamp_outer_zones_used = 1,
                distribution_method = "periodical",
                calculate_nearby_islands = false
        },
}

-- Load Dense's breedpacks
mod:dofile("scripts/mods/Daredevil/linesman/mutator/breed_pack_linesman")

-- ============================================================================
-- MORE AMBIENT SETTINGS
-- ============================================================================

-- Area density coefficient based on difficulty
local DENSITY_COEFFICIENTS = {
        [DIFFICULTY.BABY] = 0.09,
        [DIFFICULTY.BOY] = 0.11,
        [DIFFICULTY.MAN] = 0.125,
        [DIFFICULTY.BOOMER] = 0.1338,
}
local co = DENSITY_COEFFICIENTS[mod.difficulty_level] or 0.1338

PackSpawningSettings.default.roaming_set = {
	breed_packs = "dense_standard",
	breed_packs_peeks_overide_chance = {
		0.3,
		0.4
	},
	breed_packs_override = {
		{
			"skaven",
			4,
			0.035
		},
		{
			"plague_monks",
			2,
			0.035
		},
		{
			"marauders",
			4,
			0.03
		},
		{
			"marauders_elites",
			2,
			0.03
		}
	}
}

PackSpawningSettings.skaven.roaming_set = {
	breed_packs = "dense_skaven",
	breed_packs_peeks_overide_chance = {
		0.3,
		0.4
	},
	breed_packs_override = {
		{
			"skaven",
			4,
			0.035
		},
		{
			"shield_rats",
			2,
			0.035
		},
		{
			"plague_monks",
			2,
			0.035
		}
	}
}

PackSpawningSettings.chaos.roaming_set = {
	breed_packs = "dense_chaos",
	breed_packs_peeks_overide_chance = {
		0.3,
		0.4
	},
	breed_packs_override = {
		{
			"marauders_and_warriors",
			4,
			0.03
		},
		{
			"marauders_shields",
			2,
			0.03
		},
		{
			"marauders_elites",
			2,
			0.03
		},
		{
			"marauders_berzerkers",
			2,
			0.03
		}
	}
}

PackSpawningSettings.beastmen.roaming_set = {
	breed_packs = "dense_beastmen",
	breed_packs_peeks_overide_chance = {
		0.3,
		0.4
	},
	breed_packs_override = {
		{
			"marauders_and_warriors",
			4,
			0.03
		},
		{
			"marauders_shields",
			2,
			0.03
		},
		{
			"marauders_elites",
			2,
			0.03
		},
		{
			"marauders_berzerkers",
			2,
			0.03
		}
	}
}

-- ============================================================================
-- DIFFICULTY OVERRIDES
-- ============================================================================

-- Make light variations disappear 
PackSpawningSettings.default_light = PackSpawningSettings.default
PackSpawningSettings.skaven_light = PackSpawningSettings.skaven
PackSpawningSettings.chaos_light = PackSpawningSettings.chaos
PackSpawningSettings.beastmen_light = PackSpawningSettings.beastmen

-- Clear difficulty overrides
PackSpawningSettings.default.difficulty_overrides = nil
PackSpawningSettings.skaven.difficulty_overrides = nil
PackSpawningSettings.skaven_light.difficulty_overrides = nil
PackSpawningSettings.chaos.difficulty_overrides = nil
PackSpawningSettings.beastmen.difficulty_overrides = nil
PackSpawningSettings.skaven_beastmen.difficulty_overrides = nil
PackSpawningSettings.chaos_beastmen.difficulty_overrides = nil

-- Apply area density coefficients
PackSpawningSettings.default.area_density_coefficient = co
PackSpawningSettings.skaven.area_density_coefficient = co
PackSpawningSettings.chaos.area_density_coefficient = co
PackSpawningSettings.beastmen.area_density_coefficient = co


-- PACING
PacingSettings.default.peak_fade_threshold = 5000
PacingSettings.default.peak_intensity_threshold = 5000
PacingSettings.default.sustain_peak_duration = { 5, 10 }
PacingSettings.default.relax_duration = { 7, 10 }                      -- 10/13
PacingSettings.default.horde_frequency = { 30, 45 }
PacingSettings.default.multiple_horde_frequency = { 4, 5 }             -- 7/8, 6/7
PacingSettings.default.max_delay_until_next_horde = { 74, 76 }         -- 70/75
PacingSettings.default.horde_startup_time = { 12, 15 }
PacingSettings.default.multiple_hordes = 3                             -- Came from Dense

PacingSettings.default.mini_patrol.only_spawn_above_intensity = 0
PacingSettings.default.mini_patrol.only_spawn_below_intensity = 900
PacingSettings.default.mini_patrol.frequency = { 15, 20 }

PacingSettings.default.difficulty_overrides = nil
PacingSettings.default.delay_specials_threat_value = nil

PacingSettings.chaos.peak_fade_threshold = 5000
PacingSettings.chaos.peak_intensity_threshold = 5000
PacingSettings.chaos.sustain_peak_duration = { 5, 10 }
PacingSettings.chaos.relax_duration = { 10, 13 }                     -- 13/15
PacingSettings.chaos.horde_frequency = { 30, 45 }                 -- Base 30/45
PacingSettings.chaos.multiple_horde_frequency = { 6, 7 }             -- Base 7/10
PacingSettings.chaos.max_delay_until_next_horde = { 77, 79 }         -- 74/78
PacingSettings.chaos.horde_startup_time = { 13, 15 }
PacingSettings.chaos.multiple_hordes = 3

PacingSettings.chaos.mini_patrol.only_spawn_above_intensity = 0
PacingSettings.chaos.mini_patrol.only_spawn_below_intensity = 900
PacingSettings.chaos.mini_patrol.frequency = { 15, 20 }

PacingSettings.chaos.difficulty_overrides = nil
PacingSettings.chaos.delay_specials_threat_value = nil

PacingSettings.beastmen.peak_fade_threshold = 5000         -- I'm not touching beastmen they suck
PacingSettings.beastmen.peak_intensity_threshold = 5000
PacingSettings.beastmen.sustain_peak_duration = { 5, 10 }
PacingSettings.beastmen.relax_duration = { 10, 15 }
PacingSettings.beastmen.horde_frequency = { 30, 45 }
PacingSettings.beastmen.multiple_horde_frequency = { 6, 7 }
PacingSettings.beastmen.max_delay_until_next_horde = { 77, 79 }
PacingSettings.beastmen.horde_startup_time = { 10, 20 }
PacingSettings.beastmen.multiple_hordes = math.huge         -- infinite

PacingSettings.beastmen.mini_patrol.only_spawn_above_intensity = 0
PacingSettings.beastmen.mini_patrol.only_spawn_below_intensity = 900
PacingSettings.beastmen.mini_patrol.frequency = { 0, 1 }

PacingSettings.beastmen.difficulty_overrides = nil
PacingSettings.beastmen.delay_specials_threat_value = nil

-- INTENSITY
IntensitySettings.default.intensity_add_per_percent_dmg_taken = 0.2
IntensitySettings.default.decay_delay = 4
IntensitySettings.default.decay_per_second = 3
IntensitySettings.default.intensity_add_knockdown = 50
IntensitySettings.default.intensity_add_pounced_down = 25
IntensitySettings.default.max_intensity = 100
IntensitySettings.default.intensity_add_nearby_kill = -0.2

IntensitySettings.default.difficulty_overrides = nil

-- HORDE SETTINGS
HordeSettings.default.chance_of_vector = 0.8         -- 0.75
HordeSettings.default.chance_of_vector_blob = 0.65
HordeSettings.default.chance_of_vector_termite_1 = 0.9

HordeSettings.chaos.chance_of_vector = 0.8               -- 0.9
HordeSettings.chaos.chance_of_vector_blob = 0.65         -- 0.5
HordeSettings.chaos.chance_of_vector_termite_1 = 0.9

HordeSettingsBasics = {
	ambush = {
		max_spawners = math.huge,
		max_size,
		max_hidden_spawner_dist = 30,                 -- 40
		max_horde_spawner_dist = 20,                  -- 35
		min_hidden_spawner_dist = 5,
		min_horde_spawner_dist = 1,
		min_spawners = math.huge,
		start_delay = 5,                 -- 3.45
	},
	vector = {
		max_size,
		main_path_chance_spawning_ahead = 0.67,
		main_path_dist_from_players = 30,
		max_hidden_spawner_dist = 30,
		max_horde_spawner_dist = 20,
		max_spawners = 9,                 -- 13/6
		min_hidden_spawner_dist = 5,
		min_horde_spawner_dist = 5,
		raw_dist_from_players = 13,
		start_delay = 5.5,
	},
	vector_blob = {
		max_size,
		main_path_chance_spawning_ahead = 0.67,
		main_path_dist_from_players = 60,
		raw_dist_from_players = 13,
		start_delay = 1,
	},
}

mod:echo("Intensity System DISABLED.")

-- THREAT SETTINGS
PacingSettings.beastmen.delay_horde_threat_value = {
	cataclysm = 85,               -- 80
	cataclysm_2 = 85,             -- 100
	cataclysm_3 = 90,             -- 100
	easy = 40,
	hard = 50,
	harder = 60,
	hardest = 60,
	normal = 40,
	versus_base = 60,
}
PacingSettings.chaos.delay_horde_threat_value = PacingSettings.beastmen.delay_horde_threat_value
PacingSettings.default.delay_horde_threat_value = PacingSettings.beastmen.delay_horde_threat_value

-- Manual no beastmen
DefaultConflictDirectorSet = {
	"skaven",
	"chaos",
	"default"
}

HordeWaveCompositions = {
	skaven_huge = { "huge", },
	skaven_huge_shields = { "huge", "huge_shields", },
	skaven_huge_armor = { "huge_armor", },
	skaven_huge_berzerker = { "huge", "huge_berzerker", },
	chaos_huge = { "chaos_huge", },
	chaos_huge_shields = { "chaos_huge", "chaos_huge_shields", },
	chaos_huge_armor = { "chaos_huge_armor", },
	chaos_huge_berzerker = { "chaos_huge", "chaos_huge_berzerker", },
}

CoordinatedHordeStrikeChance = 0.5

CoordinatedHordeStrikeSettings = {
	spread_ambush = {
		weight = 1,
		total_num_allowed = { 9, 9 },
		conditions = {},
                start_together = true,
                time_to_first_wave = { 13, 15 },
		horde_setup = {
                        {
                                horde_type = "vector_blob",
                                prefered_direction = "ahead",
                                num_waves = { 3, 3 },
                                time_between_waves = { 6, 8 },
                                composition = { "chaos_ambush" }
                        },
			{
				horde_type = "ambush",
				num_waves = { 3, 3 },
				time_between_waves = { 6, 8 },
                                composition = { "rat_ambush" }
			},
		},
	},
        blockade = {
                weight = 1,
                total_num_allowed = { 9, 9 },
                conditions = {},
                start_together = true,
                time_to_first_wave = { 13, 15 },
                horde_setup = {
                        {
                                horde_type = "vector_blob",
                                prefered_direction = "ahead",
                                num_waves = { 3, 3 },
                                time_between_waves = { 6, 8 },
                                composition = { "rat_front" }
                        },
                        {
                                horde_type = "vector_blob",
                                prefered_direction = "behind",
                                num_waves = { 3, 3 },
                                time_between_waves = { 6, 8 },
                                composition = { "rat_back" }
                        },
                }
        },
        coordinated_strike = {
                weight = 1,
                total_num_allowed = { 9, 9 },
                conditions = {},
                start_together = true,
                time_to_first_wave = { 13, 15 },
                horde_setup = {
                        {
                                horde_type = "vector",
                                prefered_direction = "ahead",
                                num_waves = { 3, 3 },
                                time_between_waves = { 6, 8 },
                                composition = { "huge", "huge_shields", "huge_armor", "huge_berzerker" }
                        },
                        {
                                horde_type = "vector_blob",
                                prefered_direction = "behind",
                                num_waves = { 3, 3 },
                                time_between_waves = { 6, 8 },
                                composition = { "coordinated_rats" }
                        },
                }
        },
        mega_wave = {
                weight = 1,
                total_num_allowed = { 1, 2 },
                conditions = {},
                start_together = true,
                time_to_first_wave = { 13, 15 },
                horde_setup = {
                        {
                                horde_type = "vector",
                                prefered_direction = "ahead",
                                num_waves = { 3, 3 },
                                time_between_waves = { 6, 8 },
                                composition = { "apocalypse_wave" }
                        },
                }
        },
}

-- Multiple hordes thing
if mod:get("testers") then
	PacingSettings.default.multiple_hordes = math.huge
	PacingSettings.chaos.multiple_hordes = math.huge
	PacingSettings.default.multiple_horde_frequency = { 20, 25 }
	PacingSettings.chaos.multiple_horde_frequency = { 20, 25 }
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/nonstop/nonstop_hordes")
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/nonstop/nonstop_breed_pack")

	HordeSettings.default.chance_of_vector = 1
	HordeSettings.default.chance_of_vector_blob = 1

	HordeSettings.chaos.chance_of_vector = 1
	HordeSettings.chaos.chance_of_vector_blob = 1

	mod:chat_broadcast("Unending Hordes ENABLED.")
end

-- Beastmen mixed faction waves since i didnt make them just for dark omens
HordeSettings.beastmen.difficulty_overrides = {
	cataclysm = {
		ambush_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
		vector_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
		vector_blob_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
	},
	cataclysm_2 = {
		ambush_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
		vector_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
		vector_blob_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
	},
	cataclysm_3 = {
		ambush_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
		vector_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
		vector_blob_composition = { "chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker" },
	},
}

mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_skaven_horde")
mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_chaos_horde")
mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_specials")
mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_triggers")
mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_event_comp")

-- Custom waves
mod:dofile("scripts/mods/Daredevil/linesman/mutator/custom_waves")
-- Events
mod:dofile("scripts/mods/Daredevil/linesman/events/all_events")
-- Mission of Mercy
mod:dofile("scripts/mods/Daredevil/linesman/events/mission_of_mercy")
-- Parting of the Waves or whatever
mod:dofile("scripts/mods/Daredevil/linesman/events/dwarf_whaling")
-- Set Warcamp to strictly chaos although I think this doesnt work
LevelSettings.ground_zero.conflict_settings = "chaos"
-- Dwarf 3rd map ambience override
mod:dofile("scripts/mods/Daredevil/linesman/events/dwarf_beacons")
-- Grudge Served cold
mod:dofile("scripts/mods/Daredevil/linesman/events/grudge_served_hot")
-- Trail
mod:dofile("scripts/mods/Daredevil/linesman/events/trail")
-- Forsaken Temple
mod:dofile("scripts/mods/Daredevil/linesman/events/the_freaky_temple")
-- Well of Dreams
mod:dofile("scripts/mods/Daredevil/linesman/events/well_of_dreams")
-- Reikland River
mod:dofile("scripts/mods/Daredevil/linesman/events/reikwald_river")

-- ============================================================================
-- OVERRIDES
-- ============================================================================

if is_baby and not lb then
        mod:dofile("scripts/mods/Daredevil/linesman/events/onslaught_events")
end

if mod:get("beta") then
        mod:dofile("scripts/mods/Daredevil/linesman/events/linesman_beta_events")
end

-- CN specific events
if lb then
        mod:dofile("scripts/mods/Daredevil/linesman/events/cn_righteous")
        mod:dofile("scripts/mods/Daredevil/linesman/mutator/lb_specific/lb_override_temp")
end

-- Linesboomer override
if mod.difficulty_level == 4 then
        mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesboomer/boomer_hordes")
        mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesboomer/boomer_pacing")
end
-- Sync up stuff
mod:network_send("rpc_enable_white_sv", "all", true)
mod:network_send("bob_name_enable", "all", true)
mod:network_send("giant_so_true", "all", true)
mod:network_send("c3dwlines", "others", true)
-- mod:network_send("breed_loading_in", "all", true)
-- mod:network_send("linesman_ost", "all", true)

create_weights()

mod:enable_all_hooks()

mutator_plus.active = true
