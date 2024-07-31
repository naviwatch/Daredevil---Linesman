local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")

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
	["commander"] = true
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

	mod.difficulty_level = mod:get("difficulty_level")
	mod.gain = 1
	if mod.difficulty_level == 1 then
		mod.gain = 0.5
	elseif mod.difficulty_level == 2 then
		mod.gain = 0.77
	elseif mod.difficulty_level == 3 then
		mod.gain = 1
	end


	-- Pacing
	-- mutator_plus.OriginalBreedPacks = table.clone(BreedPacks)
	mutator_plus.OriginalConflictDirectors = table.clone(ConflictDirectors)
	mutator_plus.OriginalDifficultySettings = table.clone(DifficultySettings)
	mutator_plus.OriginalBreeds = table.clone(Breeds)
	mutator_plus.OriginalBreedPacks = table.clone(BreedPacks)
	mutator_plus.OriginalBreedActions = table.clone(BreedActions)
	mutator_plus.OriginalBreedPacksBySize = table.clone(BreedPacksBySize)
	mutator_plus.OriginalPackSpawningSettings = table.clone(PackSpawningSettings)
	mutator_plus.OriginalPacingSettings = table.clone(PacingSettings)
	mutator_plus.OriginalRecycleSettings  = table.clone(RecycleSettings)
	mutator_plus.OriginalHordeCompositions = table.clone(HordeCompositions)
	mutator_plus.OriginalHordeCompositionsPacing = table.clone(HordeCompositionsPacing)
	mutator_plus.OriginalSpecialsSettings = table.clone(SpecialsSettings)
	--mutator_plus.OriginalCurrentSpecialsSettings = table.clone(CurrentSpecialsSettings)

	-- Events and Triggers
	mutator_plus.OriginalGenericTerrorEvents = table.clone(GenericTerrorEvents)
	mutator_plus.OriginalTerrorEventBlueprints = table.clone(TerrorEventBlueprints)
	mutator_plus.OriginalBossSettings = table.clone(BossSettings)
	mutator_plus.OriginalPatrolFormationSettings = table.clone(PatrolFormationSettings)
	mutator_plus.OriginalBob = table.clone(Breeds.skaven_dummy_clan_rat)

	mutator_plus.OriginalThreatValue = {}
	for name, breed in pairs(Breeds) do
		if breed.threat_value then
			mutator_plus.OriginalThreatValue[name] = breed.threat_value
		end
	end


	-- White SV
	Breeds.skaven_storm_vermin.bloodlust_health = BreedTweaks.bloodlust_health.beastmen_elite
	Breeds.skaven_storm_vermin.primary_armor_category = 6
	Breeds.skaven_storm_vermin.size_variation_range = { 1.2, 1.2 }
	Breeds.skaven_storm_vermin.max_health = BreedTweaks.max_health.bestigor
	Breeds.skaven_storm_vermin.hit_mass_counts = BreedTweaks.hit_mass_counts.bestigor
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.min = 30
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.max = 31
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.min = 1
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.max = 1

	-- Big Ratling
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

	Breeds.skaven_dummy_clan_rat = mod.deepcopy(Breeds.skaven_ratling_gunner)
	Breeds.skaven_dummy_clan_rat.size_variation_range = { 3, 3 }
	Breeds.skaven_dummy_clan_rat.walk_speed = 12
	Breeds.skaven_dummy_clan_rat.run_speed = 12
	Breeds.skaven_dummy_clan_rat.boss = true -- No WHC/Shade cheese fight this big man fair and square
	GrudgeMarkedNames.skaven = { "Bob the Builder" }

	-- Specials HP
	--[[
	if mod:get("beta") then
		mod:dofile("scripts/mods/Daredevil/linesman/mutator/actual_beta/beta_specials_stuff")
	end
	]]

	-- Stop spawner from spawning one extra enemy in horde
	local spawn_list_a = {}
	local spawn_list_b = {}

	local function D(...)
		if script_data.debug_hordes then
			printf(...)
		end
	end

	local function copy_array(source, index_a, index_b, dest)
		local j = 1

		for i = index_a, index_b do
			dest[j] = source[i]
			j = j + 1
		end
	end

	local spawn_list = {
		"skaven_slave",
		"skaven_clan_rat",
		"skaven_slave",
		"skaven_clan_rat",
		"skaven_slave",
		"skaven_clan_rat",
		"skaven_slave",
		"skaven_clan_rat",
		"skaven_slave",
		"skaven_clan_rat"
	}

	local spawn_list = {}
	local spawn_list_hidden = {}
	local copy_list = {}

	local ok_spawner_breeds = {
		skaven_clan_rat = true,
		skaven_slave = true
	}

	mod:hook_origin(HordeSpawner, "compose_blob_horde_spawn_list", function (self, composition_type)
		--mod:echo("Blob Horde Spawning")
		local composition = CurrentHordeSettings.compositions_pacing[composition_type]
		local index = LoadedDice.roll_easy(composition.loaded_probs)
		local variant = composition[index]
		local i = 1
		local spawn_list = spawn_list_a

		table.clear_array(spawn_list_a, #spawn_list_a)

		local breeds = variant.breeds

		for i = 1, #breeds, 2 do
			local breed_name = breeds[i]
			local amount = breeds[i + 1]
			local num_to_spawn = ConflictUtils.random_interval(amount)
			local start = #spawn_list + 1

			for j = start, start + num_to_spawn - 1 do -- Subtracted 1 from num to spawn
				spawn_list[j] = breed_name
			end
		end

		table.shuffle(spawn_list)
		return spawn_list, #spawn_list

	end)

	-- Bestigor changes
	local stagger_types = require("scripts/utils/stagger_types")
	Breeds.beastmen_bestigor.height = 1.5

	-- Stamina shields
	PlayerUnitStatusSettings.fatigue_point_costs.blocked_charge = 16          -- 28 wtf
	PlayerUnitStatusSettings.fatigue_point_costs.shield_bestigor_charge = 6   -- 16

	-- Charge stuff
	BreedActions.beastmen_bestigor.charge_attack.action_weight = 8                 -- 8
	BreedActions.beastmen_bestigor.charge_attack.push_ai.stagger_distance = 1.25   -- 1.5
	BreedActions.beastmen_bestigor.charge_attack.push_ai.stagger_impact = {
		stagger_types.medium,                                                      -- explosion
		stagger_types.medium,                                                      -- explosion
		stagger_types.none,
		stagger_types.none,
		stagger_types.medium, -- explosion
	}
	BreedActions.beastmen_bestigor.charge_attack.push_ai.stagger_duration = {
		0.5, -- 3
		0.5, -- 1
		0,
		0,
		0.5,                                                                     -- 4
	}
	BreedActions.beastmen_bestigor.charge_attack.player_push_speed = 5.5         -- 9.5
	BreedActions.beastmen_bestigor.charge_attack.player_push_speed_blocked = 7   -- 10

	-- Suicide rat
	BreedActions.skaven_explosive_loot_rat.explosion_attack.radius = 0.45
	
	mod:hook(DeathReactions.templates.explosive_loot_rat.unit, "start", function(func, self, unit, context, t, killng_blow, is_server)
		local chance_to_spawn_ammmo = 0

		if chance_to_spawn_ammmo >= math.random() then
			local pickup_name = "all_ammo_small"
			local pickup_settings = AllPickups[pickup_name]
			local extension_init_data = {
				pickup_system = {
					has_physics = false,
					spawn_type = "loot",
					pickup_name = pickup_name,
				},
			}
			local unit_name = pickup_settings.unit_name
			local unit_template_name = pickup_settings.unit_template_name or "pickup_unit"
			local position = POSITION_LOOKUP[unit]
			local rotation = Quaternion.identity()

			Managers.state.unit_spawner:spawn_network_unit(unit_name, unit_template_name, extension_init_data, position, rotation)
		end

		return func(self, unit, context, t, killing_blow, is_server)
	end)


	--Non-event settings and compositions
	RecycleSettings = {
		ai_stuck_check_start_time = 5,
		destroy_los_distance_squared = 8100,
		destroy_no_path_found_time = 5,
		destroy_no_path_only_behind = true,
		destroy_stuck_distance_squared = 400, --20 squared
		max_grunts = 170,
		push_horde_if_num_alive_grunts_above = 200,
		push_horde_in_time = true,
	}

	-- Ambient density multiplied by 125% instead of 200
	mod:hook(SpawnZoneBaker, "spawn_amount_rats", function(func, self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)

		if mod:get("lonk") then
			num_wanted_rats = math.round(num_wanted_rats * 250/100)
		else
			num_wanted_rats = math.round(num_wanted_rats *125/100)
		end

		return func(self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
	end)

	mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)

		local nocw
		local nochaos
		if breed.name == "skaven_clan_rat_with_shield" then
			nocw = {Breeds["skaven_clan_rat"]} -- To not piss people off
		elseif breed.name == "chaos_marauder_with_shield" then
			nochaos = {Breeds["chaos_marauder"]}
		end

		if nocw then
			if math.random() <= 0.6 then
				breed = nocw[math.random(1, #nocw)]
			end
		elseif nochaos then
			if math.random() <= 0.6 then
				breed = nochaos[math.random(1, #nochaos)]
			end
		end

		return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
	end)

local mean = 1.1
local range = 0.01

	PackDistributions = {
		periodical = {
			max_low_density = mean,
			min_low_density = mean - range,
			min_hi_density = mean,
			max_hi_density = mean + range,
			random_distribution = false,
			zero_density_below = 0,
			max_hi_dist = 3,
			min_hi_dist = 2,
			max_low_dist = 10,
			min_low_dist = 7,
			zero_clamp_max_dist = 5
		},
		random = {}
	}

	PackSpawningDistribution = {
		standard = {
			goal_density = mean,
			clamp_main_path_zone_area = 100,
			length_density_coefficient = 0,
			spawn_cycle_length = 350,
			clamp_outer_zones_used = 1,
			distribution_method = "periodical",
			calculate_nearby_islands = false
		}
	}

	-- Dense's breedpacks 
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/breed_pack_linesman")

	--[[
	mod.difficulty_level = mod:get("difficulty_level")
	local co = 0 
	if mod.difficulty_level == 1 then 
		co = 0.09
	elseif mod.difficulty_level == 2 then 
		co = 0.124
	elseif mod.difficulty_level == 3 then 
		co = 0.1335
	end 

	PackSpawningSettings.default.area_density_coefficient = co
	PackSpawningSettings.skaven.area_density_coefficient = co
	PackSpawningSettings.chaos.area_density_coefficient = co
	PackSpawningSettings.beastmen.area_density_coefficient = co
	]]

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

	-- Make light variations disappear
	PackSpawningSettings.default_light = PackSpawningSettings.default
	PackSpawningSettings.skaven_light = PackSpawningSettings.skaven
	PackSpawningSettings.chaos_light = PackSpawningSettings.chaos
	PackSpawningSettings.beastmen_light = PackSpawningSettings.beastmen

	PackSpawningSettings.default.difficulty_overrides = nil
	PackSpawningSettings.skaven.difficulty_overrides = nil
	PackSpawningSettings.skaven_light.difficulty_overrides = nil
	PackSpawningSettings.chaos.difficulty_overrides = nil
	PackSpawningSettings.beastmen.difficulty_overrides = nil
	PackSpawningSettings.skaven_beastmen.difficulty_overrides = nil
	PackSpawningSettings.chaos_beastmen.difficulty_overrides = nil

	-- PACING
	PacingSettings.default.peak_fade_threshold = 110
	PacingSettings.default.peak_intensity_threshold = 120
	PacingSettings.default.sustain_peak_duration = { 5, 10 }
	PacingSettings.default.relax_duration = { 7, 10 }                     -- 10/13
	PacingSettings.default.horde_frequency = { 30, 45 }
	PacingSettings.default.multiple_horde_frequency = { 6, 7 }            -- 7/8
	PacingSettings.default.max_delay_until_next_horde = { 74, 76 }        -- 70/75 
	PacingSettings.default.horde_startup_time = { 12, 15 }
	PacingSettings.default.multiple_hordes = 3							  -- Came from Dense 

	PacingSettings.default.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.default.mini_patrol.only_spawn_below_intensity = 900
	PacingSettings.default.mini_patrol.frequency = { 0, 1 }

	PacingSettings.default.difficulty_overrides = nil
	PacingSettings.default.delay_specials_threat_value = nil

	PacingSettings.chaos.peak_fade_threshold = 110
	PacingSettings.chaos.peak_intensity_threshold = 120
	PacingSettings.chaos.sustain_peak_duration = { 5, 10 }
	PacingSettings.chaos.relax_duration = { 10, 13 }					  -- 13/15
	PacingSettings.chaos.horde_frequency = { 30, 45 } 					  -- Base 30/45
	PacingSettings.chaos.multiple_horde_frequency = { 7, 10 } 			  -- Base 7/10
	PacingSettings.chaos.max_delay_until_next_horde = { 77, 79 }		  -- 74/78
	PacingSettings.chaos.horde_startup_time = { 13, 15 }
	PacingSettings.chaos.multiple_hordes = 3

	PacingSettings.chaos.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.chaos.mini_patrol.only_spawn_below_intensity = 900
	PacingSettings.chaos.mini_patrol.frequency = { 0, 1 }

	PacingSettings.chaos.difficulty_overrides = nil
	PacingSettings.chaos.delay_specials_threat_value = nil

	PacingSettings.beastmen.peak_fade_threshold = 110					  -- I'm not touching beastmen they suck
	PacingSettings.beastmen.peak_intensity_threshold = 120
	PacingSettings.beastmen.sustain_peak_duration = { 5, 10 }
	PacingSettings.beastmen.relax_duration = { 10, 15 }
	PacingSettings.beastmen.horde_frequency = { 30, 45 }
	PacingSettings.beastmen.multiple_horde_frequency = { 20, 23 }
	PacingSettings.beastmen.max_delay_until_next_horde = { 75, 95 }
	PacingSettings.beastmen.horde_startup_time = { 10, 20 }
	PacingSettings.beastmen.multiple_hordes = math.huge

	PacingSettings.beastmen.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.beastmen.mini_patrol.only_spawn_below_intensity = 900
	PacingSettings.beastmen.mini_patrol.frequency = { 0, 1 }

	PacingSettings.beastmen.difficulty_overrides = nil
	PacingSettings.beastmen.delay_specials_threat_value = nil

	-- INTENSITY
	IntensitySettings.default.intensity_added_per_percent_damage_taken = 0
	IntensitySettings.default.decay_delay = 1
	IntensitySettings.default.decay_per_second = 6
	IntensitySettings.default.intensity_added_knockdown = 50
	IntensitySettings.default.intensity_added_pounced_down = 25
	IntensitySettings.default.max_intensity = 100
	IntensitySettings.default.intensity_added_nearby_kill = 2

	IntensitySettings.default.difficulty_overrides = nil

	-- HORDE SETTINGS
	HordeSettings.default.chance_of_vector = 0.75
	HordeSettings.default.chance_of_vector_blob = 0.65

	HordeSettings.chaos.chance_of_vector = 0.9
	HordeSettings.chaos.chance_of_vector_blob = 0.5

	-- Override if the chinese are playing
	if mod:get("lb") then
		HordeSettings.default.chance_of_vector = 0.6
		HordeSettings.default.chance_of_vector_blob = 0.65

		HordeSettings.chaos.chance_of_vector = 0.65
		HordeSettings.chaos.chance_of_vector_blob = 0.9
	end

	HordeSettingsBasics = {
		ambush = {
			max_spawners = math.huge,
			max_size,
			max_hidden_spawner_dist = 40,
			max_horde_spawner_dist = 35,
			min_hidden_spawner_dist = 5,
			min_horde_spawner_dist = 1,
			min_spawners = math.huge,
			start_delay = 3.45,
		},
		vector = {
			max_size,
			main_path_chance_spawning_ahead = 0.67,
			main_path_dist_from_players = 30,
			max_hidden_spawner_dist = 30,
			max_horde_spawner_dist = 20,
			max_spawners = 14,
			min_hidden_spawner_dist = 0,
			min_horde_spawner_dist = 0,
			raw_dist_from_players = 13,
			start_delay = 4,
		},
		vector_blob = {
			max_size,
			main_path_chance_spawning_ahead = 0.67,
			main_path_dist_from_players = 60,
			raw_dist_from_players = 13,
			start_delay = 1,
		},
	}

	if mod:get("beta") then
		-- HordeSettingsBasics.vector.max_spawners = math.huge
	end

	-- THREAT SETTINGS
	PacingSettings.beastmen.delay_horde_threat_value = {
		cataclysm = 85, -- 80
		cataclysm_2 = 85, -- 100
		cataclysm_3 = 85, -- 100
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
		skaven_huge = {"huge",},
		skaven_huge_shields = {"huge", "huge_shields",},
		skaven_huge_armor = {"huge_armor",},
		skaven_huge_berzerker = {"huge", "huge_berzerker",},
		chaos_huge = {"chaos_huge",},
		chaos_huge_shields = {"chaos_huge", "chaos_huge_shields",},
		chaos_huge_armor = {"chaos_huge_armor",},
		chaos_huge_berzerker = {"chaos_huge", "chaos_huge_berzerker",},
	}

	mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_skaven_horde")
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_chaos_horde")
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_specials")
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_triggers")
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_event_comp")

	-- Custom conflict directors for levels
	--[[
	mod:dofile("scripts/mods/Daredevil/linesman/directors/directors_init")

	mod:set("dlc_bogenhafen_slum", "helloWorld")
	
	mod:hook(LevelAnalysis, "_setup_level_data", function(func, self, level_name, level_seed)
		
		local result = func(self, level_name, level_seed)
		
			for k,v in pairs(self.spawn_zone_data.zones) do
				if v.roaming_set and mutator_plus.active == true then
					mod:echo(mod:get(level_name))
					self.spawn_zone_data.zones[k].roaming_set = mod:get(level_name) or "default"
				end
			end
	
		return result 
	end)
	]]

	-- Multiple hordes thing 
	if mod:get("testers") then
		PacingSettings.default.multiple_horde_frequency = PacingSettings.beastmen.multiple_horde_frequency
		PacingSettings.chaos.multiple_horde_frequency = PacingSettings.beastmen.multiple_horde_frequency
		PacingSettings.default.multiple_hordes = PacingSettings.beastmen.multiple_hordes
		PacingSettings.chaos.multiple_hordes = PacingSettings.beastmen.multiple_hordes
		mod:dofile("scripts/mods/Daredevil/linesman/mutator/nonstop/nonstop_hordes")
		mod:dofile("scripts/mods/Daredevil/linesman/mutator/nonstop/nonstop_breed_pack")

		PacingSettings.beastmen.delay_horde_threat_value = {
			cataclysm = 65, -- 80
			cataclysm_2 = 65, -- 100
			cataclysm_3 = 65, -- 100
			easy = 40,
			hard = 50,
			harder = 60,
			hardest = 60,
			normal = 40,
			versus_base = 60,
		}
		PacingSettings.chaos.delay_horde_threat_value = PacingSettings.beastmen.delay_horde_threat_value
		PacingSettings.default.delay_horde_threat_value = PacingSettings.beastmen.delay_horde_threat_value

		HordeSettings.default.chance_of_vector = 1
		HordeSettings.default.chance_of_vector_blob = 1

		HordeSettings.chaos.chance_of_vector = 1
		HordeSettings.chaos.chance_of_vector_blob = 1

		mod:hook(SpawnZoneBaker, "spawn_amount_rats", function(func, self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
			num_wanted_rats = math.round(num_wanted_rats *135/100) -- Normal C3
			return func(self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
		end)

		mod:chat_broadcast("Unending Hordes ENABLED.")
	end

	-- Events
	mod:dofile("scripts/mods/Daredevil/linesman/events/all_events")
	-- Mission of Mercy
	mod:dofile("scripts/mods/Daredevil/linesman/events/mission_of_mercy")
	-- Parting of the Waves or whatever
	mod:dofile("scripts/mods/Daredevil/linesman/events/dwarf_whaling")
	-- Set Warcamp to strictly chaos
	LevelSettings.ground_zero.conflict_settings = "chaos"
	-- Set Dark Omens to Skaven because fuck beastmen
	LevelSettings.crater.conflict_settings = "skaven"
	-- Dwarf 3rd map ambience override
	mod:dofile("scripts/mods/Daredevil/linesman/events/dwarf_beacons")
	-- Grudge Served cold
	mod:dofile("scripts/mods/Daredevil/linesman/events/grudge_served_hot")
	-- Trail
	mod:dofile("scripts/mods/Daredevil/linesman/events/trail")

	-- Stuff to change for specific maps
	local co
	local new_co

	--[[
	if mod:get("scaling") then
		local players = Managers.player:human_and_bot_players()
	   
	   if mod.difficulty_level == 1 then 
		   co = 0.05
	   elseif mod.difficulty_level == 2 then 
		   co = 0.084
	   elseif mod.difficulty_level == 3 then 
		   co = 0.094
	   elseif mod.difficulty_level == 3 and lb then
		   co = 0.0938
	   end

	   new_co = co 

	   for _, player in pairs(players) do
		   new_co = new_co + 0.01
	   end
   end
   ]]

	if mod.difficulty_level == 1 then
		co = 0.09
	elseif mod.difficulty_level == 2 then
		co = 0.124
	elseif mod.difficulty_level == 3 then
		co = 0.1335 -- 0.135
	elseif mod.difficulty_level == 3 and lb then
		co = 0.134
	end

	if mod:get("lonk") then
		co = 0.134

		HordeSettings.default.chance_of_vector = 0.1
		HordeSettings.default.chance_of_vector_blob = 0.65

		HordeSettings.chaos.chance_of_vector = 0.1
		HordeSettings.chaos.chance_of_vector_blob = 0.65

		HordeWaveCompositions = {
			skaven_huge = {"huge",},
			skaven_huge_shields = {"huge", "huge_shields",},
			skaven_huge_armor = {"huge", "huge_armor",},
			skaven_huge_berzerker = {"huge", "huge_berzerker",},
			chaos_huge = {"chaos_huge",},
			chaos_huge_shields = {"chaos_huge", "chaos_huge_shields",},
			chaos_huge_armor = {"chaos_huge", "chaos_huge_armor",},
			chaos_huge_berzerker = {"chaos_huge", "chaos_huge_berzerker",},
		}

		HordeSettingsBasics = {
			ambush = {
				max_spawners = math.huge,
				max_size,
				max_hidden_spawner_dist = 40,
				max_horde_spawner_dist = 35,
				min_hidden_spawner_dist = 5,
				min_horde_spawner_dist = 1,
				min_spawners = math.huge,
				start_delay = 3.45,
			},
			vector = {
				max_size,
				main_path_chance_spawning_ahead = 0.67,
				main_path_dist_from_players = 30,
				max_hidden_spawner_dist = 30,
				max_horde_spawner_dist = 20,
				max_spawners = math.huge,
				min_hidden_spawner_dist = 0,
				min_horde_spawner_dist = 0,
				raw_dist_from_players = 13,
				start_delay = 4,
			},
			vector_blob = {
				max_size,
				main_path_chance_spawning_ahead = 0.67,
				main_path_dist_from_players = 60,
				raw_dist_from_players = 13,
				start_delay = 1,
			},
		}
	end

	GenericTerrorEvents.special_coordinated = {
		{
			"play_stinger",
			stinger_name = "Play_curse_egg_of_tzeentch_alert_high"
		},
	}

	GenericTerrorEvents.split_wave = {
		{
			"play_stinger",
			stinger_name = "Play_enemy_beastmen_standar_chanting_loop"
		},
		{
			"delay",
			duration = 4.5
		},
		{
			"play_stinger",
			stinger_name = "Stop_enemy_beastmen_standar_chanting_loop"
		},
	}
	
	GenericTerrorEvents.skaven_denial = {
		{
			"spawn_special",
			amount = 2,
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		}
	}
	GenericTerrorEvents.skaven_mix = {
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_pack_master"
		},
	}
	GenericTerrorEvents.chaos_denial = {
		{
			"spawn_special",
			amount = 1,
			breed_name = "chaos_vortex_sorcerer"
		},
		{
			"spawn_special",
			amount = 3,
			breed_name = "skaven_ratling_gunner"
		},
	}

	-- Special wave 1: Skaven denial-focused (gas/ratling/fire)
	-- Special wave 2: Skaven mix (gas/ratling/assassin or hook)
	-- Special wave 3: Chaos denial-focused (blight/ratling)

	--[[ Code explained for those who don't know how to read it
	  The first coin flip simulates a 15% chance.
	  a/ If the first event (PRD_special_attack) occurs, it triggers the coordinated strike:
		- Starts the SFX for warning
		- Broadcasts "Coordinated Attack!"
		- Then, based on another 50% coin flip (PRD_mix), it spawns different comps (three atm)
			a/ If PRD_mix is true, it starts a terror event named "skaven_mix".
			b/ If PRD_mix is false, it further flips a 50% coin for PRD_denial.
				a/ If PRD_denial is true, it starts a terror event named "skaven_denial".
				b/ If PRD_denial is false, it starts a terror event named "chaos_denial".
	  b/ If the first event doesn't occur, simply end the function. (or 4.5% to troll you)

	All of this is to make sure that all three waves are evenly distributed and spawned, fuck me
	]]

	local conflict_director = Managers.state.conflict
	local sa_chances

	if lb then -- If host is using linesman balance (which im presuming clients are too)
		sa_chances = 0.15
	else
		sa_chances = 0.1
	end

	local special_attack = function()
		PRD_special_attack, state = PseudoRandomDistribution.flip_coin(state, sa_chances) -- Flip 10%, every 4th horde or 10th wave
		if PRD_special_attack then
			conflict_director:start_terror_event("special_coordinated")
		--	mod:chat_broadcast("Coordinated Attack!")
			PRD_mix, mix = PseudoRandomDistribution.flip_coin(mix, 0.5) -- Flip 50%
			if PRD_mix then
				conflict_director:start_terror_event("skaven_mix")
			else
				PRD_denial, denial = PseudoRandomDistribution.flip_coin(denial, 0.5) -- Flip 50%
				if PRD_denial then
					conflict_director:start_terror_event("skaven_denial")
				else
					conflict_director:start_terror_event("chaos_denial")
				end
			end
		else
			if lb then
				EXPLOSION, die = PseudoRandomDistribution.flip_coin(die, 0.05) -- Flip 5%
				if EXPLOSION then
					conflict_director:spawn_one(Breeds.skaven_explosive_loot_rat, nil, nil)
				else
				end
			end
		end
	end

	-- Both directions, from Spawn Tweaks
	mod:hook(HordeSpawner, "find_good_vector_horde_pos", function(func, self, main_target_pos, distance, check_reachable)
		local prd_direction = 0.1
		PRD_sandwich, sandwhich = PseudoRandomDistribution.flip_coin(sandwhich, prd_direction) -- Flip 10%, every 4th horde or 10th wave
		if PRD_sandwich then
			conflict_director:start_terror_event("split_wave")
			local success, horde_spawners, found_cover_points, epicenter_pos = func(self, main_target_pos, distance,
				check_reachable)

			local o_horde_spawners = nil
			local o_found_cover_points = nil

			if success then
				o_horde_spawners = table.clone(horde_spawners)
				o_found_cover_points = table.clone(found_cover_points)

				local new_epicenter_pos = self:get_point_on_main_path(main_target_pos, -distance, check_reachable)
				if new_epicenter_pos then
					local new_success, new_horde_spawners, new_found_cover_points = self:find_vector_horde_spawners(
					new_epicenter_pos, main_target_pos)

					if new_success then
						for _, horde_spawner in ipairs(new_horde_spawners) do
							table.insert(o_horde_spawners, horde_spawner)
						end
						for _, cover_point in ipairs(new_found_cover_points) do
							table.insert(o_found_cover_points, cover_point)
						end
					end
				end
			end
		elseif not PRD_sandwich then
			return func(self, main_target_pos, distance, check_reachable)
		end

		return success, o_horde_spawners, o_found_cover_points, epicenter_pos
	end)

	-- Spooky special wave
	-- This shit is ran every wave i only realized after i did this
	mod:hook(HordeSpawner, "horde", function(func, self, horde_type, extra_data, side_id, no_fallback)
		print("horde requested: ", horde_type)

		if horde_type == "vector" then
			self:execute_vector_horde(extra_data, side_id, no_fallback)
			special_attack()
		elseif horde_type == "vector_blob" then
			self:execute_vector_blob_horde(extra_data, side_id, no_fallback)
			special_attack()
		else
			self:execute_ambush_horde(extra_data, side_id, no_fallback)
			special_attack()
		end
	end)

	PackSpawningSettings.default.area_density_coefficient = co
	PackSpawningSettings.skaven.area_density_coefficient = co
	PackSpawningSettings.chaos.area_density_coefficient = co
	PackSpawningSettings.beastmen.area_density_coefficient = co

	mod.difficulty_level = mod:get("difficulty_level")
	mod:hook_safe(StateLoadingRunning, "on_enter", function(self, params)
		local level_name = Managers.level_transition_handler:get_current_level_key()
		if mutator_plus.active == true then
			if level_name == "dlc_dwarf_beacons" then
				mod:dofile("scripts/mods/Daredevil/linesman/map_modifiers/dwarf_beacons")
			end
			mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_triggers")
		end
	end)

	--- Disable patrols.
	mod:hook(TerrorEventMixer.run_functions, "spawn_patrol", function (func, ...)
		local level_name = Managers.level_transition_handler:get_current_level_key()
		if mutator_plus.active == true then
			if level_name == "dlc_dwarf_beacons" then
				conflict_director:spawn_one(Breeds.skaven_gutter_runner, nil, nil)
				conflict_director:spawn_one(Breeds.skaven_pack_master, nil, nil)
				conflict_director:spawn_one(Breeds.chaos_corruptor_sorcerer, nil, nil)
				conflict_director:spawn_one(Breeds.skaven_dummy_clan_rat, nil, nil, {
					enhancements = bob,
					max_health_modifier = 3.5,
				})
				conflict_director:spawn_one(Breeds.skaven_poison_wind_globadier, nil, nil)
				conflict_director:spawn_one(Breeds.skaven_ratling_gunner, nil, nil)
				conflict_director:spawn_one(Breeds.skaven_poison_wind_globadier, nil, nil)
				conflict_director:spawn_one(Breeds.skaven_ratling_gunner, nil, nil)
				conflict_director:spawn_one(Breeds.skaven_ratling_gunner, nil, nil)
				conflict_director:spawn_one(Breeds.skaven_loot_rat, nil, nil)
				conflict_director:spawn_one(Breeds.skaven_loot_rat, nil, nil)
				mod:chat_broadcast("Specials be upon thee")
				return true
			end
		end

		return func(...)
	end)

	GenericTerrorEvents.fuck_you = {
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_special",
			amount = 3,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 5,
		},
		{
			"spawn_special",
			amount = 4,
			breed_name = "skaven_explosive_loot_rat"
		},
	}

	-- Custom Director
	--mod:dofile("scripts/mods/Daredevil/Custom-Director")

	-- Sync up stuff
	mod:network_send("rpc_enable_white_sv", "all", true)
	mod:network_send("bob_name_enable", "all", true)

	create_weights()

	mod:enable_all_hooks()

	mutator_plus.active = true

