local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict

local function count_event_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
end

local function count_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed(breed_name)
end

local function spawned_during_event()
	return Managers.state.conflict:enemies_spawned_during_event()
end

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
	["crushing"] = true,
	["intangible"] = true,
}
local grain = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

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

    IntensitySettings.default.intensity_add_per_percent_dmg_taken = 0.2
    IntensitySettings.default.decay_delay = 4
    IntensitySettings.default.decay_per_second = 3
    IntensitySettings.default.intensity_add_knockdown = 20
    IntensitySettings.default.intensity_add_pounced_down = 4
    IntensitySettings.default.max_intensity = 100
    IntensitySettings.default.intensity_add_nearby_kill = -0.2

---------------

	-- HORDE SETTINGS
	HordeSettings.default.chance_of_vector = 0.6 -- 0.75
	HordeSettings.default.chance_of_vector_blob = 0.65
	HordeSettings.default.chance_of_vector_termite_1 = 0.9

	HordeSettings.chaos.chance_of_vector = 0.8 -- 0.9
	HordeSettings.chaos.chance_of_vector_blob = 0.9 -- 0.5
	HordeSettings.chaos.chance_of_vector_termite_1 = 0.9

----------------

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
            max_spawners = 12,
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

----------------
HordeCompositionsPacing.mini_patrol = {
	{
		name = "few_clanrats",
		weight = 2,
		breeds = {
			"skaven_clan_rat_with_shield",
			{
				4,
				5
			},
			"skaven_storm_vermin_commander",
			{
				1,
				2
			},
			"skaven_plague_monk",
			{
				2,
				2
			}
		}
	},
	{
		name = "few_clanrats",
		weight = 2,
		breeds = {
			"skaven_clan_rat",
			{
				3,
				4
			},
			"skaven_plague_monk",
			{
				3,
				4
			}
		}
	},
	{
		name = "storm_clanrats",
		weight = 2,
		breeds = {
			"skaven_clan_rat",
			{
				2,
				3
			},
			"skaven_storm_vermin_commander",
			{
				3,
				4
			}
		}
	}
}

HordeCompositionsPacing.chaos_mini_patrol = {
	{
		name = "few_marauders",
		weight = 10,
		breeds = {
			"chaos_marauder",
			{
				2,
				3
			},
			"chaos_raider",
			{
				1,
				1
			},
			"chaos_berzerker",
			{
				2,
				2
			}
		}
	},
	{
		name = "few_clanrats",
		weight = 2,
		breeds = {
			"chaos_marauder",
			{
				3,
				4
			},
			"chaos_berzerker",
			{
				3,
				4
			}
		}
	},
	{
		name = "storm_clanrats",
		weight = 2,
		breeds = {
			"chaos_marauder",
			{
				2,
				3
			},
			"chaos_raider",
			{
				3,
				4
			}
		}
	}
}
----------------