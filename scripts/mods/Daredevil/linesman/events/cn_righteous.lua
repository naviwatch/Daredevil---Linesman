local mod = get_mod("Daredevil")

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

HordeCompositions.ons_bile_troll = {
	{
		name = "troll",
		weight = 5,
		breeds = {
			"chaos_troll",
			{
				1,
				1
			}
		}
	}
}

	---------------------
	--Righteous Stand

	TerrorEventBlueprints.military.military_courtyard_event_01 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "courtyard_hidden",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 20 and count_event_breed("chaos_fanatic") < 26
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "courtyard",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 27 and count_event_breed("skaven_storm_vermin_commander") < 8 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard_hidden",
			composition_type = "onslaught_event_military_courtyard_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard_hidden",
			composition_type = "onslaught_event_military_courtyard_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "onslaught_courtyard_roof_middle",
			composition_type = "ons_bile_troll"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "courtyard",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "courtyard",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 10
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "courtyard_hidden",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "courtyard_hidden",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "courtyard",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 24 and count_event_breed("chaos_fanatic") < 32
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "courtyard",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 30 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_plague_monk") < 12
			end
		},
				{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "onslaught_event_military_courtyard_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 30 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_plague_monk") < 12
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "courtyard",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 30 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_plague_monk") < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_02 = TerrorEventBlueprints.military.military_courtyard_event_01

	TerrorEventBlueprints.military.military_courtyard_event_specials_01 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard_hidden",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard_hidden",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_specials_02 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard_hidden",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_specials_03 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_specials_04 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "onslaught_custom_specials_heavy_disabler"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_specials_05 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "onslaught_custom_specials_heavy_disabler"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	--01	Warriors & Plague Monks
	--02	Berzerkers & Stormvermins
	--03	Mixed Shielders
	--04	Extra Denial
	--05	Extra Disablers

	HordeCompositions.onslaught_military_mauler_assault = { -- Are you ok core
		{
			name = "plain",
			weight = 1,
			breeds = {
				"chaos_raider",
				{
				7, -- 15
				7  -- 17
				},
				"chaos_warrior",
				{
				5,
				6
				},
			}
		}
	}

	HordeCompositions.military_end_event_chaos_01 = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_raider",
				{
					10,
					13,
				},
				"chaos_marauder",
				{
					20,
					22
				},
				"chaos_fanatic",
				{
					20,
					22
				}
			}
		},
		{
			name = "mixed",
			weight = 3,
			breeds = {
				"chaos_raider",
				{
					10,
					13,
				},
				"chaos_marauder_with_shield",
				{
					10,
					12
				},
				"chaos_marauder",
				{
					8,
					9
				},
				"chaos_fanatic",
				{
					18,
					19
				}
			}
		}
	}

	HordeCompositions.military_end_event_berzerkers = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_berzerker",
				15, -- 15
				"chaos_marauder_with_shield",
				20
			}
		}
	}

	TerrorEventBlueprints.military.military_temple_guards = {
		{
			"disable_kick"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards02",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards05",
			breed_name = "chaos_marauder_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards06",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards07",
			breed_name = "chaos_marauder_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards09",
			breed_name = "chaos_warrior"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_temple_guard_assault",
			composition_type = "onslaught_military_mauler_assault"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_start = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"disable_kick"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "end_event_start",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_boss_troll"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 25 and count_event_breed("skaven_clan_rat_with_shield") < 24 and count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_start_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_01_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_01_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_01_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_01_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_02_left = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_02_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_02_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_02_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_02_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_02_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_02_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_02_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_03_left = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 25 and count_event_breed("skaven_slave") < 28 and count_event_breed("skaven_storm_vermin_commander") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_03_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_03_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 25 and count_event_breed("skaven_slave") < 28 and count_event_breed("skaven_storm_vermin_commander") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_03_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_03_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_middle",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 25 and count_event_breed("skaven_slave") < 28 and count_event_breed("skaven_storm_vermin_commander") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_03_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_03_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 15 and count_event_breed("skaven_slave") < 18 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_storm_vermin_with_shield") < 5 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_03_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_04_left = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_04_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_04_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_04_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_04_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_middle",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_04_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_04_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_04_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_05_left = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "end_event_left",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_clan_rat_with_shield") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_05_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_05_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "end_event_right",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_clan_rat_with_shield") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_05_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_05_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "end_event_middle",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_clan_rat_with_shield") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_05_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_05_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "end_event_back",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_clan_rat_with_shield") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_05_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_06_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 1 and count_event_breed("chaos_marauder") < 2 and count_event_breed("chaos_marauder_with_shield") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_06_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_06_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 1 and count_event_breed("chaos_marauder") < 2 and count_event_breed("chaos_marauder_with_shield") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_06_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_06_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 1 and count_event_breed("chaos_marauder") < 2 and count_event_breed("chaos_marauder_with_shield") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_06_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_01 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_02 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_03 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_04 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_05 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_06 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	--01 2x denial 1x skaven
	--02 2x denial 1x disabler
	--03 2x disabler 1x denial
	--04 2x disabler 1x skaven
	--05 Mass denial
	--06 3x skaven

	TerrorEventBlueprints.military.military_end_event_survival_escape = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"control_specials",
			enable = true
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_start",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_escape_done"
		}
	}