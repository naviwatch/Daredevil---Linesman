local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict
local bl = get_mod("Beastmen Loader")

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

local function respawn_check()
	for i, player in pairs(Managers.player:players()) do
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
	mutator_plus.OriginalBreeds = table.clone(Breeds)
	--mutator_plus.OriginalCurrentSpecialsSettings = table.clone(CurrentSpecialsSettings)

	-- Load custom breeds
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_breeds")
	-- Perceptions
	mod:dofile("scripts/mods/Daredevil/linesman/functions/perceptions")
	-- Functions
	mod:dofile("scripts/mods/Daredevil/linesman/functions/man_functions")

	-- OST
--	Wwise.load_bank("backstab")

	-- Specials HP
	--[[
	if mod:get("beta") then
		mod:dofile("scripts/mods/Daredevil/linesman/mutator/actual_beta/beta_specials_stuff")
	end
	]]

	--Non-event settings and compositions
	RecycleSettings = {
		ai_stuck_check_start_time = 5,
		destroy_los_distance_squared = 8100,
		destroy_no_path_found_time = 5,
		destroy_no_path_only_behind = true,
		destroy_stuck_distance_squared = 400, --20 squared
		max_grunts = 160,
		push_horde_if_num_alive_grunts_above = 300,
		push_horde_in_time = true,
	}

	-- Ambient density multiplied by 125% instead of 200
	mod:hook(SpawnZoneBaker, "spawn_amount_rats", function(func, self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
		local total_intensity = Managers.state.conflict.pacing:get_pacing_intensity()
		local level_name = Managers.level_transition_handler:get_current_level_key()
		local num_wanted_percentage

		if mod.difficulty_level == 1 then
			num_wanted_percentage = 1
		else
			num_wanted_percentage = 1.3
		end

		-- Map overrides
		if level_name == "dlc_termite_1" then 
			num_wanted_percentage = 0.65
		end

		num_wanted_rats = math.round(num_wanted_rats * num_wanted_percentage)

		if mod:get("lonk") then
			num_wanted_rats = math.round(num_wanted_rats * 200/100)
		end

		return func(self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
	end)

	mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
		-- This all could be better but idc
		local level_name = Managers.level_transition_handler:get_current_level_key()
		local nocw
		local nochaos
		local pit 
		if breed.name == "skaven_clan_rat_with_shield" then
			nocw = {Breeds["skaven_clan_rat"]} -- To not piss people off
		elseif breed.name == "chaos_marauder_with_shield" then
			nochaos = {Breeds["chaos_marauder"]}
		elseif level_name == "skaven_stronghold" and breed.name == "skaven_storm_vermin_commander" then 
			pit = {Breeds["skaven_plague_monk"]}
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
		co = 0.08
	elseif mod.difficulty_level == 2 then
		co = 0.11
	elseif mod.difficulty_level == 3 then
		co = 0.134 -- 0.1335
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

	PackSpawningSettings.default.area_density_coefficient = co
	PackSpawningSettings.skaven.area_density_coefficient = co
	PackSpawningSettings.chaos.area_density_coefficient = co
	PackSpawningSettings.beastmen.area_density_coefficient = co

	-- PACING
	PacingSettings.default.peak_fade_threshold = 5000
	PacingSettings.default.peak_intensity_threshold = 5000
	PacingSettings.default.sustain_peak_duration = { 5, 10 }
	PacingSettings.default.relax_duration = { 7, 10 }                     -- 10/13
	PacingSettings.default.horde_frequency = { 35, 50 }
	PacingSettings.default.multiple_horde_frequency = { 4, 5 }            -- 7/8, 6/7
	PacingSettings.default.max_delay_until_next_horde = { 74, 76 }        -- 70/75 
	PacingSettings.default.horde_startup_time = { 12, 15 }
	PacingSettings.default.multiple_hordes = 3							  -- Came from Dense 

	PacingSettings.default.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.default.mini_patrol.only_spawn_below_intensity = 900
	PacingSettings.default.mini_patrol.frequency = { 0, 1 }

	PacingSettings.default.difficulty_overrides = nil
	PacingSettings.default.delay_specials_threat_value = nil

	PacingSettings.chaos.peak_fade_threshold = 5000
	PacingSettings.chaos.peak_intensity_threshold = 5000
	PacingSettings.chaos.sustain_peak_duration = { 5, 10 }
	PacingSettings.chaos.relax_duration = { 10, 13 }					  -- 13/15
	PacingSettings.chaos.horde_frequency = { 35, 50 } 					  -- Base 30/45
	PacingSettings.chaos.multiple_horde_frequency = { 6, 7 } 			  -- Base 7/10
	PacingSettings.chaos.max_delay_until_next_horde = { 77, 79 }		  -- 74/78
	PacingSettings.chaos.horde_startup_time = { 13, 15 }
	PacingSettings.chaos.multiple_hordes = 3

	PacingSettings.chaos.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.chaos.mini_patrol.only_spawn_below_intensity = 900
	PacingSettings.chaos.mini_patrol.frequency = { 0, 1 }

	PacingSettings.chaos.difficulty_overrides = nil
	PacingSettings.chaos.delay_specials_threat_value = nil

	PacingSettings.beastmen.peak_fade_threshold = 5000					  -- I'm not touching beastmen they suck
	PacingSettings.beastmen.peak_intensity_threshold = 5000
	PacingSettings.beastmen.sustain_peak_duration = { 5, 10 }
	PacingSettings.beastmen.relax_duration = { 10, 15 }
	PacingSettings.beastmen.horde_frequency = { 30, 50 }
	PacingSettings.beastmen.multiple_horde_frequency = { 6, 7 }
	PacingSettings.beastmen.max_delay_until_next_horde = { 77, 79 }
	PacingSettings.beastmen.horde_startup_time = { 10, 20 }
	PacingSettings.beastmen.multiple_hordes = math.huge -- 无限

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
	HordeSettings.default.chance_of_vector = 0.7 -- 0.75
	HordeSettings.default.chance_of_vector_blob = 0.65	
	HordeSettings.default.chance_of_vector_termite_1 = 0.9

	HordeSettings.chaos.chance_of_vector = 0.7 -- 0.9
	HordeSettings.chaos.chance_of_vector_blob = 0.65 -- 0.5
	HordeSettings.chaos.chance_of_vector_termite_1 = 0.9

	HordeSettingsBasics = {
		ambush = {
			max_spawners = math.huge,
			max_size,
			max_hidden_spawner_dist = 30, -- 40
			max_horde_spawner_dist = 20, -- 35
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
			max_spawners = 13,
			min_hidden_spawner_dist = 5,
			min_horde_spawner_dist = 5,
			raw_dist_from_players = 13,
			start_delay = 4.5,
		},
		vector_blob = {
			max_size,
			main_path_chance_spawning_ahead = 0.67,
			main_path_dist_from_players = 60,
			raw_dist_from_players = 13,
			start_delay = 1,
		},
	}

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
		PacingSettings.default.multiple_horde_frequency = math.huge
		PacingSettings.chaos.multiple_horde_frequency = math.huge
		PacingSettings.default.multiple_hordes = { 20, 25 }
		PacingSettings.chaos.multiple_hordes = { 20, 25 }
		mod:dofile("scripts/mods/Daredevil/linesman/mutator/nonstop/nonstop_hordes")
		mod:dofile("scripts/mods/Daredevil/linesman/mutator/nonstop/nonstop_breed_pack")

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

	-- Beastmen mixed faction waves since i didnt make them just for dark omens
	HordeSettings.beastmen.difficulty_overrides = {
		cataclysm = {
			ambush_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
			vector_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
			vector_blob_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
		},
		cataclysm_2 = {
			ambush_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
			vector_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
			vector_blob_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
		},
		cataclysm_3 = {
			ambush_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
			vector_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
			vector_blob_composition = {"chaos_huge", "chaos_huge_shields", "chaos_huge_armor", "chaos_huge_berzerker", "huge", "huge_armor", "huge_shields", "huge_berzerker"},
		},
	}

	-- Custom waves
	mod:dofile("scripts/mods/Daredevil/linesman/mutator/custom_waves")
	-- Events
	mod:dofile("scripts/mods/Daredevil/linesman/events/all_events")
	-- Mission of Mercy
	mod:dofile("scripts/mods/Daredevil/linesman/events/mission_of_mercy")
	-- Parting of the Waves or whatever
	mod:dofile("scripts/mods/Daredevil/linesman/events/dwarf_whaling")
	-- Set Warcamp to strictly chaos
	LevelSettings.ground_zero.conflict_settings = "chaos"
	-- Dwarf 3rd map ambience override
	mod:dofile("scripts/mods/Daredevil/linesman/events/dwarf_beacons")
	-- Grudge Served cold
	mod:dofile("scripts/mods/Daredevil/linesman/events/grudge_served_hot")
	-- Trail
	mod:dofile("scripts/mods/Daredevil/linesman/events/trail")
	-- Forsaken Temple
	mod:dofile("scripts/mods/Daredevil/linesman/events/the_freaky_temple")

	-- Override if Beta
	if mod:get("beta") then
		mod:dofile("scripts/mods/Daredevil/linesman/events/linesman_beta_events")
	end

	-- CN specific events 
	if lb then
		mod:dofile("scripts/mods/Daredevil/linesman/events/cn_righteous")
		mod:dofile("scripts/mods/Daredevil/linesman/mutator/lb_override_temp")
	end

	-- Linesman specific events
	if mod.difficulty_level == 1 then 
	end

	mod.difficulty_level = mod:get("difficulty_level")
	--[[
	mod:hook_safe(StateLoadingRunning, "on_enter", function(self, params)
		local level_name = Managers.level_transition_handler:get_current_level_key()
		if mutator_plus.active then
			-- Reapply all stuff
			if level_name == "dlc_dwarf_beacons" then 
			--	mod:dofile("scripts/mods/Daredevil/linesman/map_modifiers/dwarf_beacons")
			elseif level_name == "dlc_termite_1" then
				mod:dofile("scripts/mods/Daredevil/linesman/map_modifiers/freaky_temple")
			end

			mod:dofile("scripts/mods/Daredevil/linesman/mutator/linesman_triggers")
		end
	end)
	]]

	--[[
	mod:hook(MissionSystem, "_update_level_progress", function(func, self, dt)
		local level_name = Managers.level_transition_handler:get_current_level_key()
		if level_name == "catacombs" then
			-- Break then reapply 
			stop_progress_event()
			local conflict_director = Managers.state.conflict
			local level_analysis = conflict_director.level_analysis
			local main_path_data = level_analysis.main_path_data
			while true do	
				local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
				local total_travel_dist = main_path_data.total_dist
				local travel_percentage = ahead_travel_dist / total_travel_dist * 100
				if 58 <= travel_percentage then
					conflict_director:start_terror_event("convo_mid_event_pacing")
					mod:echo("STARTING EVENT STARTING EVENT STARTING EVENT")
					break
				end 
			end
		end

		return func(self, dt)
	end)
	
	mod.on_game_state_changed = function(status, state_name)
		local level_name = Managers.level_transition_handler:get_current_level_key()
		if status == "enter" and state_name == "StateLoading" then -- if loading into level
			stop_progress_event()      -- just break for safety
		end
	end
	]]

	--- Disable patrols.
	--[[
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
	]]

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
	}

	-- Custom Director
	--mod:dofile("scripts/mods/Daredevil/Custom-Director")

	-- Sync up stuff
	mod:network_send("rpc_enable_white_sv", "all", true)
	mod:network_send("bob_name_enable", "all", true)
	mod:network_send("giant_so_true", "all", true)
	mod:network_send("c3dwlines", "others", true)
	mod:network_send("breed_loading_in", "all", true)
--	mod:network_send("linesman_ost", "all", true)

	-- Just override the shit set by beastmen loader
	-- Load breeds

	
	EnemyPackageLoaderSettings.max_loaded_breed_cap = 50

	create_weights()

	mod:enable_all_hooks()

	mutator_plus.active = true