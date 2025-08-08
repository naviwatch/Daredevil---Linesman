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
	--[[
	HordeSettings.default.chance_of_vector = 0.6 -- 0.75
	HordeSettings.default.chance_of_vector_blob = 0.65
	HordeSettings.default.chance_of_vector_termite_1 = 0.9

	HordeSettings.chaos.chance_of_vector = 0.8 -- 0.9
	HordeSettings.chaos.chance_of_vector_blob = 0.9 -- 0.5
	HordeSettings.chaos.chance_of_vector_termite_1 = 0.9
	]]

----------------

PacingSettings.default.mini_patrol.frequency = { 20, 30 }

PacingSettings.chaos.mini_patrol.frequency = { 20, 30 }

PacingSettings.beastmen.mini_patrol.frequency = { 20, 30 }
----------------
----------------
	TerrorEventBlueprints.magnus.magnus_end_event = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "magnus_end_event"
		},
		{
			"flow_event",
			flow_event_name = "magnus_horn_crescendo_starting"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn_first",
			composition_type = "event_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "magnus_end_event_first_wave_killed"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"disable_kick"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "skaven_dummy_clan_rat",
			amount = {
				3,
				3
			},
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"spawn_special",
			breed_name = "skaven_stormfiend",
			amount = {
				2,
				2
			},
			optional_data = {
				size_variation_range = { 1.45, 1.45 },
				max_health_modifier = 0.5
			}
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_chaos",
			composition_type = "dn_warpfire_spam"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"delay",
			duration = 30
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 10 and count_event_breed("chaos_fanatic") < 18 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_warrior") < 3
			end
		},
		{
			"delay",
			duration = 4
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_special",
			breed_name = "skaven_ratling_gunner",
			amount = 4,
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"spawn_special",
			breed_name = "skaven_gutter_runner",
			amount = 2,
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"control_specials",
			enable = true
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_special",
			breed_name = "skaven_poison_wind_globadier",
			amount = 3,
		},
		{
			"spawn_special",
			breed_name = "skaven_ratling_gunner",
			amount = 1,
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_chaos",
			composition_type = "apocalypse_wave"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 10 and count_event_breed("chaos_fanatic") < 18 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_warrior") < 3
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_horn",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "magnus_horn_event_done"
		},
		{
			"delay",
			duration = 5
		},
		{
			"control_pacing",
			enable = true
		}
	}
----