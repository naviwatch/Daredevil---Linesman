local mod = get_mod("Daredevil")
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
	["intangible"] = true,
	["unstaggerable"] = true
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
			composition_type = "onslaught_custom_boss_ogre"
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
			"spawn_special",
			amount = 1,
			breed_name = "skaven_explosive_loot_rat"
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
			composition_type = "onslaught_custom_specials_heavy_denial"
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
			composition_type = "onslaught_custom_specials_heavy_denial"
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

	---------------------
	--Convocation of Decay

	TerrorEventBlueprints.catacombs.catacombs_puzzle_event_loop = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_puzzle_event_loop"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 30 and count_event_breed("skaven_slave") < 36 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 12
			end
		},
		{
			"delay",
			duration = 7
		},
		{
			"flow_event",
			flow_event_name = "catacombs_puzzle_event_loop_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_puzzle_event_a = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_puzzle_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"flow_event",
			flow_event_name = "catacombs_puzzle_event_a_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_puzzle_event_b = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_puzzle_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"flow_event",
			flow_event_name = "catacombs_puzzle_event_b_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_puzzle_event_c = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_puzzle_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "event_maulers_medium"
		},
		{
			"flow_event",
			flow_event_name = "catacombs_puzzle_event_c_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_special_event_a = {
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_storm_vermin_shields_small"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_special_event_b = {
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_02",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_02",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_special_event_c = {
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_01",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_02",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_03",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		},
	}

	--a shields & warriors
	--b maulers
	--c berzerkers

	--a special shielded storm
	--b special monk
	--c special mass warpfire

	--Because otherwise triple boss event is triggered early by respawning player..
	local function living_player_has_dropped()
		for i, player in pairs(Managers.player:players()) do
			if player.player_unit then
				local status_extension = ScriptUnit.has_extension(player.player_unit, "status_system")
				if status_extension and not status_extension.is_ready_for_assisted_respawn(status_extension) then
					if POSITION_LOOKUP[player.player_unit].z < -15 then
						return true
					end
				end
			end
		end
		return false
	end

	TerrorEventBlueprints.catacombs.catacombs_load_sorcerers = {
		{
			"force_load_breed_package",
			breed_name = "chaos_dummy_sorcerer"
		},
		{
			"continue_when",
			condition = function (t)
				return living_player_has_dropped()
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_pool_boss_1",
			breed_name = {
				"chaos_spawn",
				"beastmen_minotaur"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_pool_boss_3",
			breed_name = {
				"skaven_rat_ogre",
				"skaven_stormfiend"
			}
		},
		{
			"control_hordes",
			enable = true
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_01 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 6,
			spawner_id = "end_event",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_storm_vermin_commander") < 10 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 16 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_01_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_02 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 30 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 6,
			spawner_id = "end_event",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 16 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 6,
			spawner_id = "end_event",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},

		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 16 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 16 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_02_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_specials_01 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event_specials"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_specials_02 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event_specials"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_specials_03 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event_specials"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_specials_done"
		}
	}

	---------------------
	--Hunger in the Dark

	TerrorEventBlueprints.mines.mines_end_event_start = {
		{
			"disable_kick"
		},
		{
			"enable_bots_in_carry_event"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_first_wave = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0225
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0225
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0225
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0225
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 30 and count_event_breed("skaven_slave") < 30 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_first_wave_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_loop = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_3",
			breed_name = "chaos_troll",
			optional_data = {
				enhancements = better_bob,
				max_health_modifier = 0.0625
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 30
		},
		{
			"delay",
			duration = 5
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 25 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 10 and count_event_breed("chaos_raider") < 12
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0625
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 20 and count_event_breed("chaos_fanatic") < 25 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 12
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0625
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_loop_02_skaven = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_medium_chaos"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0625
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 20 and count_event_breed("chaos_fanatic") < 25 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0625
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 10
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_maulers_small"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll",
			optional_data = {
				max_health_modifier = 0.0625
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 20 and count_event_breed("chaos_fanatic") < 25 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 12 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 10 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 9
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_loop_02_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_loop_02_chaos = TerrorEventBlueprints.mines.mines_end_event_loop_02_skaven

	TerrorEventBlueprints.mines.mines_end_event_specials_01 = {
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") + count_event_breed("chaos_vortex_sorcerer")) < 8 and (count_event_breed("skaven_gutter_runner") + count_event_breed("skaven_pack_master") + count_event_breed("chaos_corruptor_sorcerer")) < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_specials_02 = {
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") + count_event_breed("chaos_vortex_sorcerer")) < 8 and (count_event_breed("skaven_gutter_runner") + count_event_breed("skaven_pack_master") + count_event_breed("chaos_corruptor_sorcerer")) < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_specials_03 = {
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") + count_event_breed("chaos_vortex_sorcerer")) < 8 and (count_event_breed("skaven_gutter_runner") + count_event_breed("skaven_pack_master") + count_event_breed("chaos_corruptor_sorcerer")) < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_stop = {
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_trolls = {
		{
			"force_load_breed_package",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_01",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_02",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_03",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_04",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_05",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_06",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_07",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_08",
			breed_name = "chaos_dummy_troll"
		},
		{
			"stop_event",
			stop_event_name = "mines_end_event_loop"
		},
		{
			"stop_event",
			stop_event_name = "mines_end_event_loop_02"
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_trolls_done"
		}
	}

	TerrorEventBlueprints.mines.mines_troll_boss = {
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_bell_boss",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_boss",
			breed_name = "skaven_dummy_slave",
			optional_data = {
				max_health_modifier = 0.2
			}
		},
		{
			"set_time_challenge",
			time_challenge_name = "mines_speed_event"
		},
		{
			"set_time_challenge",
			time_challenge_name = "mines_speed_event_cata"
		},
		{
			"continue_when",
			duration = 90,
			condition = function (t)
				return count_event_breed("chaos_troll") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_troll_boss_done"
		},
		{
			"has_completed_time_challenge",
			time_challenge_name = "mines_speed_event"
		},
		{
			"has_completed_time_challenge",
			time_challenge_name = "mines_speed_event_cata"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_escape = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "escape",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 15 and count_event_breed("chaos_berzerker") < 10
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "escape",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 12 and count_event_breed("skaven_slave") < 15 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_escape_done"
		}
	}

	---------------------
	--Halescourge

	TerrorEventBlueprints.ground_zero.gz_elevator_guards_a = {
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_1",
			breed_name = "skaven_storm_vermin_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_2",
			breed_name = "skaven_storm_vermin_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_3",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_4",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_5",
			breed_name = "skaven_storm_vermin_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_6",
			breed_name = "skaven_storm_vermin_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_1",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_2",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_3",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_4",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_5",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_6",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_7",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_8",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_1",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_2",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_3",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_4",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_5",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_6",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"delay",
			duration = 5
		}
	}

	local ACTIONS = BreedActions.chaos_exalted_sorcerer
	local restore_bubbledude = {
		"BTSpawnAllies",
		enter_hook = "sorcerer_spawn_horde",
		name = "sorcerer_spawn_horde",
		action_data = ACTIONS.spawn_allies_horde
	}

	table.insert(BreedBehaviors.chaos_exalted_sorcerer[7], 2, restore_bubbledude)

	TerrorEventBlueprints.ground_zero.gz_chaos_boss = {
		{
			"set_master_event_running",
			name = "gz_chaos_boss"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"spawn_at_raw",
			spawner_id = "warcamp_chaos_boss",
			breed_name = "chaos_exalted_sorcerer"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_sorcerer") == 1
			end
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_sorcerer") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "gz_chaos_boss_dead"
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	HordeCompositions.sorcerer_boss_event_defensive = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					10,
					14
				},
				"chaos_marauder",
				{
					16,
					18
				},
				"chaos_marauder_with_shield",
				{
					12,
					15
				},
				"chaos_raider",
				{
					5,
					6
				},
				"chaos_warrior",
				1,
				"chaos_corruptor_sorcerer",
				2
			}
		},
		{
			name = "wave_b",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					9,
					11
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_marauder_with_shield",
				{
					10,
					12
				},
				"chaos_berzerker",
				{
					5,
					6
				},
				"chaos_warrior",
				1,
				"chaos_corruptor_sorcerer",
				2
			}
		},
		{
			name = "wave_c",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					9,
					11
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_warrior",
				{
					2,
					3
				},
				"chaos_corruptor_sorcerer",
				2
			}
		},
		{
			name = "wave_d",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					12,
					15
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_raider",
				{
					6,
					7
				},
				"chaos_warrior",
				1,
				"chaos_corruptor_sorcerer",
				2
			}
		},
		{
			name = "wave_e",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					24,
					26
				},
				"chaos_berzerker",
				{
					6,
					7
				},
				"chaos_warrior",
				1,
				"chaos_corruptor_sorcerer",
				2
			}
		},
		start_time = 0
	}

	HordeCompositions.sorcerer_extra_spawn = HordeCompositions.sorcerer_boss_event_defensive

	---------------------
	--Athel Yenlui

	TerrorEventBlueprints.elven_ruins.elven_ruins_end_event = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_time_challenge",
			time_challenge_name = "elven_ruins_speed_event"
		},
		{
			"set_time_challenge",
			time_challenge_name = "elven_ruins_speed_event_cata"
		},
		{
			"set_master_event_running",
			name = "ruins_end_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"disable_kick"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = {
				4,
				5
			}
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 20, -- 10
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_small" 
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "athel_assassin_fire_combo"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = {
				18,
				20
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 10,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "athel_wdnmd"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = {
				2,
				3
			}
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = {
				2,
				3
			}
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_ratling_spam"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = {
				2,
				3
			}
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_ratling_spam"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = {
				2,
				3
			}
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_ratling_spam"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = {
				2,
				3
			}
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_ratling_spam"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = {
				2,
				3
			}
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "dn_ratling_spam"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_bottomtier",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = {
				5,
				7
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
			end
		},
	}
	
	TerrorEventBlueprints.elven_ruins.elven_ruins_end_event_flush = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"has_completed_time_challenge",
			time_challenge_name = "elven_ruins_speed_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "elven_ruins_toptier",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = {
				1,
				2
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_boss_ogre"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"event_horde",
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_custom_boss_stormfiend"
		},
		{
			"delay",
			duration = {
				3,
				4
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "elven_ruins_toptier",
			composition_type = "athel_wdnmd"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_custom_special_denial"
		},
	}
	
	TerrorEventBlueprints.elven_ruins.elven_ruins_end_event_device_fiddlers = {
		{
			"control_specials",
			enable = false
		},
		{
			"spawn_at_raw",
			spawner_id = "device_skaven_1",
			breed_name = "skaven_clan_rat"
		},
		{
			"spawn_at_raw",
			spawner_id = "device_skaven_2",
			breed_name = "skaven_clan_rat"
		},
		{
			"spawn_at_raw",
			spawner_id = "device_skaven_3",
			breed_name = "skaven_clan_rat"
		}
	}

	---------------------
	--Screaming Bell

	HordeCompositions.event_bell_monks = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"skaven_plague_monk",
				{
					7,
					7
				}
			}
		}
	}
	
	HordeCompositions.event_bell_monks_muertos = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"skaven_plague_monk",
				{
					33,
					33
				}
			}
		}
	}

	HordeCompositions.event_bell_warriors = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_warrior",
				10
			}
		}
	}

	TerrorEventBlueprints.bell.canyon_bell_event = {
		{
			"set_master_event_running",
			name = "canyon_bell_event"
		},
		{
			"set_time_challenge",
			time_challenge_name = "bell_speed_event"
		},
		{
			"set_time_challenge",
			time_challenge_name = "bell_speed_event_cata"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enabled = false
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"flow_event",
			flow_event_name = "canyon_bell_event_done"
		}
	}

	TerrorEventBlueprints.bell.canyon_ogre_boss = {
		{
			"spawn_at_raw",
			spawner_id = "canyon_ogre_boss",
			breed_name = "skaven_dummy_clan_rat",
			optional_data = {
				enhancements = bob,
				max_health_modifier = 15,
				target_selection = "least_healthy_player"
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_second_ogre",
			breed_name = "skaven_dummy_clan_rat",
			optional_data = {
				enhancements = shield_shatter,
				max_health_modifier = 15,
				target_selection = "least_healthy_player"
			}
		},
		{
			"delay",
			duration = 6
		},
	}

	TerrorEventBlueprints.bell.canyon_escape_event = {
		{
			"set_master_event_running",
			name = "canyon_escape_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "canyon_escape_event",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"delay",
			duration = 5
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_clan_rat_with_shield") < 8 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 3
			end
		}
	}

	---------------------
	--Fort Brachsenbr𣫥

	HordeCompositions.event_fort_pestilen = {
		{
			name = "mixed",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					17,
					19
				},
				"skaven_clan_rat",
				{
					15,
					15
				},
				"skaven_plague_monk",
				{
					4,
					5
				}
			}
		}
	}

	HordeCompositions.event_fort_savagery = {
		{
			name = "mixed",
			weight = 5,
			breeds = {
				"chaos_fanatic",
				{
					19,
					23
				},
				"chaos_marauder",
				{
					10,
					11
				},
				"chaos_berzerker",
				{
					4,
					5
				}
			}
		}
	}

	TerrorEventBlueprints.fort.fort_pacing_off = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.fort.fort_terror_event_climb = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "fort_terror_event_climb"
		},
		{
			"event_horde",
			spawner_id = "terror_event_climb",
			composition_type = "apocalypse_wave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 18 and count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_clan_rat_with_shield") < 10 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_terror_event_climb_done"
		}
	}

	TerrorEventBlueprints.fort.fort_terror_event_inner_yard_skaven = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "fort_terror_event_inner_yard"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_slave") < 24 and count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_clan_rat_with_shield") < 6 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_terror_event_inner_yard_done"
		}
	}

	TerrorEventBlueprints.fort.fort_terror_event_inner_yard_chaos = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "fort_terror_event_inner_yard"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_marauder") < 10 and count_event_breed("chaos_marauder_with_shield") < 7
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") and count_event_breed("chaos_marauder") < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_terror_event_inner_yard_done"
		}
	}

	TerrorEventBlueprints.fort.fort_horde_gate = {
		{
			"set_master_event_running",
			name = "fort_horde_gate"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = true
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
			spawner_id = "fort_horde_gate",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "fort_horde_gate",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_gate",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("skaven_storm_vermin") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_horde_gate_done"
		}
	}

	TerrorEventBlueprints.fort.fort_horde_cannon_skaven = {
		{
			"set_master_event_running",
			name = "fort_horde_cannon"
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
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_pestilen"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			},
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 6 and count_event_breed("skaven_poison_wind_globadier") < 10 and count_event_breed("skaven_warpfire_thrower") < 6 and count_event_breed("skaven_ratling_gunner") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_pestilen"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			},
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 6 and count_event_breed("skaven_poison_wind_globadier") < 10 and count_event_breed("skaven_warpfire_thrower") < 6 and count_event_breed("skaven_ratling_gunner") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_pestilen"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			},
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 6 and count_event_breed("skaven_poison_wind_globadier") < 10 and count_event_breed("skaven_warpfire_thrower") < 6 and count_event_breed("skaven_ratling_gunner") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_pestilen"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			},
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"flow_event",
			flow_event_name = "fort_horde_cannon_done"
		}
	}

	TerrorEventBlueprints.fort.fort_horde_cannon_chaos = {
		{
			"set_master_event_running",
			name = "fort_horde_cannon"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_savagery"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "event_medium_chaos"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 15 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 10 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_warrior") < 4 and count_event_breed("skaven_poison_wind_globadier") < 10 and count_event_breed("skaven_warpfire_thrower") < 6 and count_event_breed("chaos_vortex_sorcerer") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_savagery"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "event_medium_chaos"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 15 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 10 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_warrior") < 4 and count_event_breed("skaven_poison_wind_globadier") < 10 and count_event_breed("skaven_warpfire_thrower") < 6 and count_event_breed("chaos_vortex_sorcerer") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_savagery"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "event_medium_chaos"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 15 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 10 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_warrior") < 4 and count_event_breed("skaven_poison_wind_globadier") < 10 and count_event_breed("skaven_warpfire_thrower") < 6 and count_event_breed("chaos_vortex_sorcerer") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_savagery"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "event_medium_chaos"
		},
		{
			"flow_event",
			flow_event_name = "fort_horde_cannon_done"
		}
	}

	TerrorEventBlueprints.fort.fort_siegers = {
		{
			"set_master_event_running",
			name = "fort_siegers"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_3",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_4",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_5",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_6",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_3",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_4",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_5",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_6",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_3",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_4",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_5",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_3",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_4",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_5",
			breed_name = "chaos_bulwark"
		},
		{
			"continue_when",
			duration = 180,
			condition = function (t)
				return count_event_breed("chaos_bulwark") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "siege_broken"
		}
	}

	---------------------
	-- Into the Nest
	TerrorEventBlueprints.skaven_stronghold.stronghold_pacing_off = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.skaven_stronghold.stronghold_pacing_on = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.skaven_stronghold.stronghold_horde_water_wheels = {
		{
			"set_master_event_running",
			name = "stronghold_horde_water_wheels"
		},
		{
			"control_hordes",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
	--[[]
		{
			"event_horde",
			spawner_id = "stronghold_horde_water_wheels",
			composition_type = "skaven_shields"
		},
	]]
		{
			"event_horde",
			spawner_id = "stronghold_horde_water_wheels",
			composition_type = "onslaught_skaven_double_wave"
		},	
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_clan_rat_with_shield") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_storm_vermin") < 5 and count_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"control_specials",
			enable = true
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = "skaven_rat_ogre",
			optional_data = {
				max_health_modifier = 0.25
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"control_hordes",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "stronghold_horde_water_wheels_done"
		}
	}

	TerrorEventBlueprints.skaven_stronghold.stronghold_boss = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "stronghold_boss"
		},
		{
			"spawn_at_raw",
			spawner_id = "stronghold_boss",
			breed_name = "skaven_storm_vermin_warlord",
			optional_data = {
				max_health_modifier = 1.2
			}
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_warlord") == 1
			end
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_warlord") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "stronghold_boss_killed"
		},
		{
			"delay",
			duration = 8
		},

		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	HordeCompositions.stronghold_boss_event_defensive = {
		{
			name = "defensive",
			weight = 6,
			breeds = {
				"skaven_slave",
				{
					5,
					7
				},
				"skaven_clan_rat",
				{
					20,
					22
				},
				"skaven_clan_rat_with_shield",
				{
					10,
					12
				},
				"skaven_plague_monk",
				{
					3,
					4
				},
				"skaven_storm_vermin_commander",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.stronghold_boss_trickle = {
		{
			name = "plain",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					18,
					18
				},
				"skaven_warpfire_thrower",
				{
					2,
					2,
				},
				"skaven_gutter_runner",
				{
					1,
					1,
				},
				"skaven_plague_monk",
				{
					3,
					3,
				},
				"skaven_storm_vermin_commander",
				{
					2,
					2,
				},
			}
		},
		{
			name = "shit",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					18,
					18
				},
				"skaven_ratling_gunner",
				{
					2,
					2,
				},
				"skaven_pack_master",
				{
					1,
					1,
				},
				"skaven_plague_monk",
				{
					2,
					2,
				},
				"skaven_storm_vermin_commander",
				{
					3,
					3,
				},
			}
		}
	}

	HordeCompositions.stronghold_boss_initial_wave = {
		{
			name = "initial",
			weight = 6,
			breeds = {
				"skaven_storm_vermin",
				{
					3,
					3
				},
				"skaven_plague_monk",
				{
					3,
					3
				},
				"skaven_clan_rat",
				{
					15,
					17
				},
				"skaven_ratling_gunner",
				{
					1,
					1
				},
				"skaven_warpfire_thrower",
				{
					1,
					1
				},
				"skaven_pack_master",
				{
					1,
					1
				},
			}
		}
	}

	BreedActions.skaven_storm_vermin_warlord.spawn_allies.spawn_list = {
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_storm_vermin",
		"skaven_plague_monk",
		"skaven_plague_monk",
		"skaven_plague_monk",
		"skaven_plague_monk",
	}

	BreedActions.skaven_storm_vermin_warlord.spawn_sequence.considerations.time_since_last.max_value = 800

	--See hooks for boss behaviour changes.

	---------------------
	--Against the Grain

	TerrorEventBlueprints.farmlands.farmlands_rat_ogre = {
		{
			"set_master_event_running",
			name = "farmlands_boss_barn"
		},
		{
			"spawn_at_raw",
			spawner_id = "farmlands_rat_ogre",
			breed_name = "beastmen_minotaur",
			optional_data = {
				enhancements = grain
			}
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_minotaur") == 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_spawned"
		},
		{
			"delay",
			duration = 1
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("beastmen_minotaur") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_dead"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_storm_fiend = {
		{
			"set_master_event_running",
			name = "farmlands_boss_barn"
		},
		{
			"spawn_at_raw",
			spawner_id = "farmlands_rat_ogre",
			breed_name = "beastmen_minotaur",
			optional_data = {
				enhancements = grain
			}
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_minotaur") == 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_spawned"
		},
		{
			"delay",
			duration = 1
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("beastmen_minotaur") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_dead"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_chaos_troll = {
		{
			"set_master_event_running",
			name = "farmlands_boss_barn"
		},
		{
			"spawn_at_raw",
			spawner_id = "farmlands_rat_ogre",
			breed_name = "beastmen_minotaur",
			optional_data = {
				enhancements = grain
			}
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_minotaur") == 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_spawned"
		},
		{
			"delay",
			duration = 1
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("beastmen_minotaur") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_dead"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_chaos_spawn = {
		{
			"set_master_event_running",
			name = "farmlands_boss_barn"
		},
		{
			"spawn_at_raw",
			spawner_id = "farmlands_rat_ogre",
			breed_name = "beastmen_minotaur",
			optional_data = {
				enhancements = grain
			}
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_minotaur") == 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_spawned"
		},
		{
			"delay",
			duration = 1
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("beastmen_minotaur") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_dead"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_spawn_guards = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"spawn_at_raw",
			spawner_id = "wall_guard_01",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "wall_guard_02",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "wall_guard_03",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_wall_guard_extra_1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "windmill_guard",
			breed_name = "chaos_warrior"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_01 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"disable_kick"
		},
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
			name = "farmlands_prisoner_event_01"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "square_front",
			composition_type = "apocalypse_wave"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_raider") < 5 and count_event_breed("skaven_storm_vermin_commander") < 5
			end
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "linesman_mixed_horde"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 10 and count_event_breed("skaven_slave") < 20
			end
		},
		{
			"event_horde",
			spawner_id = "square_center",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 25 and count_event_breed("skaven_slave") < 20
			end
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 35 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			spawner_id = "hay_barn_back",
			composition_type = "apocalypse_wave"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_specials_heavy_disabler"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 35 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			spawner_id = "square_front",
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			spawner_id = "square_front",
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 25
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 35 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "apocalypse_wave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_hay_barn_bridge_guards = {
		{
			"spawn_at_raw",
			spawner_id = "hay_barn_bridge_guards",
			breed_name = "chaos_warrior",
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_1",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_2",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_3",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_4",
			breed_name = "chaos_bulwark"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_5",
			breed_name = "chaos_bulwark"
		},
		{
			"set_time_challenge",
			time_challenge_name = "farmlands_speed_event"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_hay_barn = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "farmlands_prisoner_event_hay_barn"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "hay_barn_guards",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "hay_barn_manual_spawns",
			breed_name = "chaos_marauder"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_cellar_invis",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 25
		},
		{
			"event_horde",
			spawner_id = "hay_barn_front_invis",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 40
		},
		{
			"event_horde",
			spawner_id = "hay_barn_interior",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 5
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 30 and count_event_breed("chaos_warrior") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_storm_vermin_commander") < 16
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 35,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 45 and count_event_breed("skaven_storm_vermin_commander") < 16 and count_event_breed("skaven_storm_vermin_with_shield") < 10
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_storm_vermin_commander") < 16
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_upper_square = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"disable_kick"
		},
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
			name = "farmlands_prisoner_event_upper_square"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "square_center",
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 30 and count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("chaos_marauder") < 30
			end
		},
		{
			"event_horde",
			spawner_id = "sawmill_creek",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "sawmill_creek",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_sawmill_door = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
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
			name = "farmlands_prisoner_event_sawmill_door"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "sawmill_interior",
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_sawmill = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "farmlands_prisoner_event_sawmill"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "sawmill_interior_invis",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_gate_open_event = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"has_completed_time_challenge",
			time_challenge_name = "farmlands_speed_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "linesman_mixed_horde"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	---------------------
	--Empire in Flames

	TerrorEventBlueprints.ussingen.ussingen_gate_guards = {
		{
			"spawn_at_raw",
			spawner_id = "onslaught_gate_spawner_1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_gate_spawner_2",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_gate_spawner_3",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 0.8
		},
		{
			"spawn_at_raw",
			spawner_id = "gate_spawner_1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 0.8
		},
		{
			"spawn_at_raw",
			spawner_id = "gate_spawner_2",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		}
	}

	TerrorEventBlueprints.ussingen.ussingen_payload_event_01 = {
		{
			"control_pacing",
			enable = false
		},
		{
			"disable_kick"
		},
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "ussingen_payload_event"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cart_guard_1",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cart_guard_2",
			breed_name = "chaos_warrior"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_start",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_start",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_start",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "ussingen_payload_start",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_start",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_start",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 12 and count_event_breed("chaos_raider") < 7 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 24 and count_event_breed("chaos_fanatic") < 26 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
			{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
			{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cart_guard_1",
			breed_name = "chaos_troll"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cart_guard_1",
			breed_name = "chaos_spawn"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cart_guard_2",
			breed_name = "chaos_troll"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 22 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_warrior") < 6
			end
		},
	}

	TerrorEventBlueprints.ussingen.ussingen_payload_event_loop_01 = {
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "event_small_chaos"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer",
				"skaven_poison_wind_globadier"
			},
			difficulty_requirement = HARDEST
		},
		{
			"delay",
			duration = 6,
			difficulty_requirement = HARDER
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "event_medium_chaos",
			difficulty_requirement = HARDER
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_raider") < 16 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_marauder_with_shield") < 16
			end
		},
		{
			"flow_event",
			flow_event_name = "ussingen_payload_event_loop_done"
		}
	}

	TerrorEventBlueprints.ussingen.ussingen_payload_event_loop_02 = {
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "event_chaos_extra_spice_small",
			difficulty_requirement = HARDER
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer",
				"skaven_poison_wind_globadier"
			},
			difficulty_requirement = HARDEST
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_raider") < 16 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_marauder_with_shield") < 16
			end
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_transit",
			composition_type = "event_maulers_medium"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_raider") < 16 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_marauder_with_shield") < 16
			end
		},
		{
			"flow_event",
			flow_event_name = "ussingen_payload_event_loop_done"
		}
	}

	TerrorEventBlueprints.ussingen.ussingen_payload_event_loop_03 = {
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_pack_master",
				"skaven_gutter_runner"
			},
			difficulty_requirement = HARDER
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_pack_master",
				"skaven_gutter_runner",
				"chaos_vortex_sorcerer"
			},
			difficulty_requirement = CATACLYSM
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_transit",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_raider") < 16 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_marauder_with_shield") < 16
			end
		},
		{
			"flow_event",
			flow_event_name = "ussingen_payload_event_loop_done"
		}
	}

	TerrorEventBlueprints.ussingen.ussingen_payload_event_loop_04 = {
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_transit",
			composition_type = "event_chaos_extra_spice_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"chaos_vortex_sorcerer",
				"skaven_pack_master",
				"skaven_ratling_gunner"
			},
			difficulty_requirement = HARDER
		},
		{
			"delay",
			duration = 10
		},
		{
			duration = 15,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_raider") < 16 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_marauder_with_shield") < 16
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			duration = 15,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_raider") < 16 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_marauder_with_shield") < 16
			end
		},
		{
			"flow_event",
			flow_event_name = "ussingen_payload_event_loop_done"
		}
	}

	TerrorEventBlueprints.ussingen.ussingen_payload_event_02 = {
		{
			"control_pacing",
			enable = false
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "ussingen_payload_event"
		},
		{
			"delay",
			duration = 4
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_square",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_square",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "ussingen_payload_transit",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "chaos_vortex_sorcerer"
		},
		{
			"delay",
			duration = 12
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.ussingen.ussingen_gate_open_event = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "ussingen_gate_open",
			composition_type = "event_ussingen_gate_group"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "ussingen_mansion_garden_payload",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "ussingen_mansion_garden_payload",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 8
		},
		{
			"control_specials",
			enable = true
		}
	}

	HordeCompositions.event_ussingen_gate_group = {
		{
			name = "storm_slaves",
			weight = 1,
			breeds = {
				"skaven_slave",
				57,
				"skaven_clan_rat_with_shield",
				14,
				"skaven_storm_vermin_commander",
				{
					7,
					8
				}
			}
		}
	}

	TerrorEventBlueprints.ussingen.ussingen_escape = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "ussingen_escape"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_escape_event",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_escape_event",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_escape_event",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_escape_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_raider") < 6 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 14
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "ussingen_escape_restart"
		}
	}

	---------------------
	--Festering Ground

	TerrorEventBlueprints.nurgle.nurgle_end_event01 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
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
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 6) and count_event_breed("skaven_slave") < 6 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 10  and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield") < 5) and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 5) and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 10 and count_event_breed("skaven_storm_vermin") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 10) and count_event_breed("skaven_slave") < 8 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_storm_vermin_with_shield") < 4 and count_event_breed("chaos_berzerker") < 5 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 7) and count_event_breed("skaven_slave") < 7 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
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
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield") < 10) and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_monk",
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
				return count_event_breed("skaven_plague_monk") < 10 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 7) and count_event_breed("skaven_slave") < 7 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event01_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_specials_01 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 7,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_specials_02 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 7,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_specials_03 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 7,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_specials_done"
		}
	}

	--01 2 Denial 1 random
	--02 1 Denial 1 disabler 1 random
	--03 1 Denial 2 random
	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_01 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_02 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_chaos_extra_spice_small"
		},
		{
			"spawn_at_raw",
			spawner_id = "Festering_loop_event_1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function,
				size_variation_range = {
				    1.2,
				    1.25
				}
			}
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_03 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "Festering_loop_event_1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function,
				size_variation_range = {
				    1.2,
				    1.25
				}
			}
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_04 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_05 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "Festering_loop_event_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function,
				size_variation_range = {
				    1.2,
				    1.25
				}
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_06 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_monk",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_monk",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_monk",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_escape = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "Festering_escape_event",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function,
				size_variation_range = {
				    1.2,
				    1.25
				}
			}
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_clan_rat_with_shield") < 15 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_escape_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_escape_02 = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_clan_rat_with_shield") < 15 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event02",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_clan_rat_with_shield") < 15 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_clan_rat_with_shield") < 15 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_escape_02_done"
		}
	}


	---------------------
	--Warcamp

	HordeCompositions.event_warcamp_elites = {
		{
			name = "zerker",
			weight = 3,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_berzerker",
				{
					4,
					5
				}
			}
		},
		{
			name = "mixed",
			weight = 2,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_raider",
				{
					2,
					3
				},
				"chaos_berzerker",
				{
					2,
					3
				}
			}
		},
		{
			name = "mauler",
			weight = 5,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_raider",
				{
					4,
					5
				}
			}
		},
	}

	TerrorEventBlueprints.warcamp.warcamp_payload = {
		{
			"set_master_event_running",
			name = "warcamp_payload"
		},
		{
			"control_pacing",
			enable = false
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
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 6
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "chaos_warriors"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"flow_event",
			flow_event_name = "warcamp_payload"
		}
	}

	-- TerrorEventBlueprints.warcamp.warcamp_door_guard = {
		-- {
			-- "disable_kick"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_shield_dude_1",
			-- breed_name = "chaos_warrior"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_shield_dude_2",
			-- breed_name = "chaos_warrior"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_sword_dude_1",
			-- breed_name = "chaos_berzerker"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_sword_dude_2",
			-- breed_name = "chaos_berzerker"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_2h_dude_1",
			-- breed_name = "chaos_warrior"
		-- }
	-- }

	TerrorEventBlueprints.warcamp.warcamp_camp = {
		{
			"set_master_event_running",
			name = "warcamp_camp"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "camp_event",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "camp_event",
			composition_type = "event_warcamp_elites"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "camp_event",
			composition_type = "event_warcamp_elites"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield") < 25) and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "warcamp_camp_restart"
		}
	}

	HordeCompositions.warcamp_boss_event_trickle = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_marauder",
				{
					6,
					8
				},
				"chaos_berzerker",
				{
					6,
					7
				}
			}
		},
		{
			name = "somevermin",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					6,
					8
				},
				"chaos_raider",
				{
					2,
					3
				},
				"chaos_berzerker",
				{
					5,
					6
				}
			}
		}
	}

	HordeCompositions.warcamp_boss_event_defensive = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_marauder",
				{
					9,
					12
				},
				"chaos_marauder_with_shield",
				{
					10,
					12
				},
				"chaos_berzerker",
				{
					5,
					6
				},
				"chaos_raider",
				{
					5,
					6
				},
				"chaos_warrior",
				{
					2,
					3
				}
			}
		},
		{
			name = "horde",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					25,
					31
				},
				"chaos_marauder",
				{
					10,
					11
				},
				"chaos_berzerker",
				{
					10,
					12
				}
			}
		},
		{
			name = "somevermin",
			weight = 2,
			breeds = {
				"chaos_warrior",
				{
					4,
					5
				},
				"chaos_berzerker",
				{
					6,
					7
				},
				"chaos_marauder_with_shield",
				{
					13,
					15
				}
			}
		}
	}

	TerrorEventBlueprints.warcamp.warcamp_chaos_boss = {
		{
			"set_master_event_running",
			name = "warcamp_chaos_boss"
		},
		{
			"spawn_at_raw",
			spawner_id = "warcamp_chaos_boss",
			breed_name = "chaos_exalted_champion_warcamp",
			optional_data = {
				max_health_modifier = 1.5,
				enhancements = enhancement_4
			}
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_warcamp") == 1
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_camp_boss_top",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_camp_boss_top_behind",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_camp_boss_top_left",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_camp_boss_top_right",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_warcamp") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "warcamp_chaos_boss_dead"
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	--See hooks for warcamp boss behaviour changes.

	---------------------
	--Skittergate

	TerrorEventBlueprints.skittergate.skittergate_spawn_guards = {
		{
			"spawn_at_raw",
			spawner_id = "gate_guard_01",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gate_guard_02",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_gate_guard",
			breed_name = "skaven_storm_vermin_commander"
		}
	}

	TerrorEventBlueprints.skittergate.skittergate_chaos_boss = {
		{
			"set_master_event_running",
			name = "skittergate_chaos_boss"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_1",
			composition_type = "onslaught_skittergate_warriors_one"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_3",
			composition_type = "onslaught_skittergate_warriors_three"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_2",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_2",
			composition_type = "onslaught_skittergate_warriors_two"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_1",
			composition_type = "onslaught_skittergate_warriors_one"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_3",
			composition_type = "onslaught_skittergate_warriors_three"
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "skittergate_chaos_boss",
			breed_name = "chaos_exalted_champion_norsca"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") == 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") < 1 or count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "onslaught_zerker_gatekeeper",
			composition_type = "onslaught_skittergate_warriors_three"
		},
		{
			"event_horde",
			spawner_id = "onslaught_zerker_gatekeeper",
			composition_type = "onslaught_skittergate_zerker"
		},
		{
			"event_horde",
			spawner_id = "onslaught_zerker_gatekeeper",
			composition_type = "onslaught_skittergate_zerker"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") < 1
			end
		},
		{
			"delay",
			duration = 2
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") < 1 and count_event_breed("chaos_spawn_exalted_champion_norsca") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "skittergate_chaos_boss_killed"
		}
	}

	HordeCompositions.onslaught_skittergate_warriors_one = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_warrior",
				1,
			}
		}
	}

	HordeCompositions.onslaught_skittergate_warriors_two = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_warrior",
				2,
			}
		}
	}

	HordeCompositions.onslaught_skittergate_warriors_three = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_warrior",
				3,
			}
		}
	}

	HordeCompositions.onslaught_skittergate_zerker = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_berzerker",
				{
					10,
					12
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_raider",
				{
					3,
					4
				}
			}
		}
	}

	TerrorEventBlueprints.skittergate.skittergate_gatekeeper_marauders = {
		{
			"spawn_at_raw",
			spawner_id = "skittergate_gatekeeper_marauder_01",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "skittergate_gatekeeper_marauder_02",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "skittergate_gatekeeper_marauder_03",
			breed_name = "chaos_marauder_with_shield"
		}
	}

	TerrorEventBlueprints.skittergate.skittergate_terror_event_02 = {
		{
			"set_master_event_running",
			name = "skittergate_terror_event_02"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "terror_event_02",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "terror_event_02",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "terror_event_02",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"control_specials",
			enable = true
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 15 and count_event_breed("skaven_slave") < 20 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "skittergate_terror_event_02_done"
		}
	}

	BreedActions.skaven_grey_seer.ground_combat.spawn_allies_cooldown = 18

	BreedActions.skaven_grey_seer.ground_combat.staggers_until_teleport = 1
	BreedActions.skaven_grey_seer.ground_combat.warp_lightning_spell_cooldown = {
			2,
			2,
			2,
			2
	}

	BreedActions.skaven_grey_seer.ground_combat.vermintide_spell_cooldown = {
			4,
			4,
			4,
			4
	}

	BreedActions.skaven_grey_seer.ground_combat.teleport_spell_cooldown = {
			1.5,
			1.5,
			1.5,
			1.5
	}

	HordeCompositions.skittergate_boss_event_defensive = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"skaven_storm_vermin",
				{
					14,
					16
				},
				"skaven_clan_rat",
				{
					10,
					12
				},
				"skaven_clan_rat_with_shield",
				{
					7,
					9
				},
				"skaven_storm_vermin_with_shield",
				{
					3,
					5
				}
			}
		},
		{
			name = "somevermin",
			weight = 3,
			breeds = {
				"skaven_slave",
				{
					25,
					30
				},
				"skaven_storm_vermin",
				{
					10,
					12
				},
				"skaven_storm_vermin_with_shield",
				{
					1,
					2
				},
				"skaven_plague_monk",
				{
					8,
					10
				}

			}
		},
		{
			name = "berzerkers",
			weight = 3,
			breeds = {
				"skaven_plague_monk",
				{
					16,
					18
				},
				"skaven_clan_rat_with_shield",
				{
					10,
					12
				},
				"skaven_storm_vermin_with_shield",
				1
			}
		},
		{
			name = "shield_vermins",
			weight = 8,
			breeds = {
				"skaven_storm_vermin_with_shield",
				{
					10,
					11
				},
				"skaven_clan_rat_with_shield",
				{
					10,
					12
				},
				"skaven_storm_vermin",
				6,
			}
		}
	}

	HordeCompositions.skittergate_grey_seer_trickle = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"skaven_slave",
				{
					16,
					20
				},
				"skaven_clan_rat",
				{
					9,
					10
				},
				"skaven_clan_rat_with_shield",
				{
					6,
					8
				},
				"skaven_storm_vermin_commander",
				{
					8,
					9
				},
				"skaven_plague_monk",
				{
					7,
					8
				},
				"skaven_storm_vermin_with_shield",
				1
			}
		}
	}

	--See hooks for boss logic.

	---------------------
	--The Pit

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_pacing_off = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_pacing_off = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	HordeCompositions.chaos_elites = {
		{
			name = "zerker",
			weight = 1,
			breeds = {
				"chaos_berzerker",
				{
					4,
					4
				}
			}
		},
		{
			name = "mauler",
			weight = 1,
			breeds = {
				"chaos_raider",
				{
					2,
					2
				}
			}
		}
	}

	HordeCompositions.slum_cw = {
		{
			name = "chaos_warrior",
			weight = 2,
			breeds = {
				"chaos_warrior",
					2
			}
		}
	}

	HordeCompositions.slum_specials = {
		{
			name = "leech",
			weight = 2,
			breeds = {
				"chaos_corruptor_sorcerer",
				2,
			}
		},
		{
			name = "warpfire",
			weight = 2,
			breeds = {
				"skaven_warpfire_thrower",
				2,
			}
		},
		{
			name = "mixed",
			weight = 3,
			breeds = {
				"chaos_corruptor_sorcerer",
				1,
				"skaven_warpfire_thrower",
				1,
			}
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_start = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_slum_event_start"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_specials",
			enable = true
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_mid_01",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_left_01",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_right_01",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_right_01",
			composition_type = "slum_cw"
		},
		{
			"delay",
			duration = 15
		},	
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_slum_event_start_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_loop = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_left_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_left_01",
			composition_type = "mass_trash_skaven"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_mid_01",
			composition_type = "mass_trash_chaos"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_right_01",
			composition_type = "slum_cw"
		},
		{
			"delay",
			duration = 48
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_slum_event_loop_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_spice_mid = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_mid_01",
			composition_type = "onslaught_chaos_double_wave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_mid_01",
			composition_type = "onslaught_custom_special_disabler"
		},
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_spice_left = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "event_small"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_spice_right = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "event_small"
		},
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_end_loop = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_roof_01",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_roof_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_roof_01",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_roof_01",
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
				return (count_event_breed("chaos_marauder_with_shield") + count_event_breed("chaos_marauder")) < 14
			end
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_slum_event_end_loop"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_gauntlet_part_01 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_slum_gauntlet_master"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_specials",
			enable = false
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_cutoff",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_cutoff",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_special",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 2
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_special",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_pack_master"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_behind",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_behind",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_behind",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_special",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			breed_name = "skaven_pack_master"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_gauntlet_wall = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_slum_gauntlet_master"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall_01",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall_01",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall_01",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall",
			composition_type = "onslaught_chaos_warriors"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_gauntlet_part_02 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_slum_gauntlet_master"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			composition_type = "dn_ratling_spam"
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			composition_type = "dn_ratling_spam"
		},
		{
			"spawn_special",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 3 and (count_event_breed("chaos_marauder_with_shield") + count_event_breed("chaos_marauder")) < 9 and count_event_breed("chaos_warrior") < 2 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 10 and count_event_breed("skaven_slave") < 14 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_slum_gauntlet_part_02_done"
		}
	}

	---------------------
	--Blightreaper

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_disable_pacing = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_start = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_sewer_start"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "event_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 18
			end
		},
		{
			"delay",
			duration = 20
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_start_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_spice = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_spice",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_spice",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_spice",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 18
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_spice_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_mid01 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_sewer_mid01"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "sewer_mid",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_large_chaos"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 25
			end
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			spawner_id = "sewer_rawspawner01",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_mid",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_mid",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_mid",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_mid",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "sewer_mid",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 8 and count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_slave") < 15
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_mid01_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_end = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_sewer_end"
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
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_end_chaos",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 20 and count_event_breed("chaos_marauder_with_shield") < 20
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_end_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "sewer_mid",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"control_specials",
			enable = true
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_end_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_escape = {
		{
			"set_master_event_running",
			name = "bogenhafenhafen_sewer_escape"
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
			limit_spawners = 2,
			spawner_id = "sewer_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_sewer_exit_gun_1",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_sewer_exit_gun_2",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_escape_done"
		}
	}

	HordeCompositions.onslaught_blightreaper_temple_easy = {
		{
			name = "skaven_offensive",
			weight = 1,
			breeds = {
				"skaven_storm_vermin_commander",
				{
					4,
					5
				},
				"skaven_plague_monk",
				{
					4,
					5
				}
			}
		},
		{
			name = "skaven_mixed",
			weight = 1,
			breeds = {
				"skaven_storm_vermin_with_shield",
				5,
				"skaven_plague_monk",
				{
					5,
					5
				}
			}
		},
		{
			name = "skaven_defensive",
			weight = 1,
			breeds = {
				"skaven_storm_vermin_with_shield",
				5,
				"skaven_storm_vermin_commander",
				{
					4,
					5
				}
			}
		},
		{
			name = "chaos_mixed",
			weight = 1,
			breeds = {
				"chaos_berzerker",
				{
					6,
					7
				},
				"chaos_marauder_with_shield",
				16,
			}
		},
		{
			name = "chaos_offensive",
			weight = 1,
			breeds = {
				"chaos_warrior",
				3,
				"chaos_raider",
				{
					5,
					6
				},
			}
		},
		{
			name = "chaos_zerg",
			weight = 1,
			breeds = {
				"chaos_warrior",
				3,
				"chaos_berzerker",
				{
					5,
					6
				},
			}
		},
		{
			name = "chaos_defensive",
			weight = 1,
			breeds = {
				"chaos_raider",
				{
					6,
					7
				},
				"chaos_marauder_with_shield",
				16,
			}
		},
		{
			name = "chaos_leader",
			weight = 1,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_raider",
				{
					3,
					4
				},
				"chaos_marauder_with_shield",
				{
					8,
					10
				},
				"chaos_berzerker",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.onslaught_blightreaper_temple_hard = {
		{
			name = "chaos_defensive",
			weight = 1,
			breeds = {
				"chaos_warrior",
				6,
				"chaos_marauder_with_shield",
				{
					10,
					12
				}
			}
		},
		{
			name = "chaos_offensive",
			weight = 1,
			breeds = {
				"chaos_warrior",
				4,
				"chaos_raider",
				{
					5,
					6
				}
			}
		},
		{
			name = "chaos_zerg",
			weight = 1,
			breeds = {
				"chaos_warrior",
				4,
				"chaos_berzerker",
				{
					6,
					7
				}
			}
		},
		{
			name = "chaos_leader",
			weight = 1,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_marauder_with_shield",
				{
					8,
					10
				},
				"chaos_raider",
				{
					4,
					6
				},
				"chaos_berzerker",
				{
					4,
					6
				}
			}
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_loop = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_loop"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_loop",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_plague_monk") < 5 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_warrior") < 3 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_gutter_runner") < 4 and count_event_breed("skaven_pack_master") < 4 and (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_ratling_gunner")) < 7
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_plague_monk") < 5 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_warrior") < 3 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_gutter_runner") < 4 and count_event_breed("skaven_pack_master") < 4 and (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_ratling_gunner")) < 7
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_plague_monk") < 5 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_warrior") < 3 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_gutter_runner") < 4 and count_event_breed("skaven_pack_master") < 4 and (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_ratling_gunner")) < 7
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_loop",
			composition_type = "linesman_mixed_horde"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_plague_monk") < 5 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_warrior") < 3 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_gutter_runner") < 4 and count_event_breed("skaven_pack_master") < 4 and (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_ratling_gunner")) < 7
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_loop_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_start = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_end_start"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"disable_kick"
		},
		{
			"control_specials",
			enable = true
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_start",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"event_horde",
			spawner_id = "temple_event_start",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_start_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button1 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button1"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button1",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_custom_specials_heavy_disabler"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "crackaddicts"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner01",
			breed_name = "skaven_dummy_clan_rat",
			optional_data = {
				max_health_modifier = 15,
			    enhancements = better_bob,
			}
		},
		{
			"delay",
			duration = 30
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button1_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button2 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button2"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "event_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner02",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner02",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button4",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window1",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front4",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin") < 8 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button2_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button3 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button3"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button3",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button3",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button3",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			amount = 5,
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"spawn_special",
			amount = 3,
			spawner_id = "temple_event_button3",
			breed_name = "chaos_corruptor_sorcerer"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window1",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front4",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button3",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button3_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button4 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button4"
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
			limit_spawners = 2,
			spawner_id = "temple_event_button4",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button4",
			composition_type = "highasf"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window2",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front2",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button4",
			composition_type = "onslaught_blightreaper_temple_hard"
		},
		{
			"delay",
			duration = 5
		},
				{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window2",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front2",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button4_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button5 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button5"
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
			"spawn_special",
			amount = 2,
			breed_name = "skaven_slave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "onslaught_blightreaper_temple_hard"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button5_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_escape = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_escape"
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
			spawner_id = "temple_event_escape",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
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
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
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
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
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
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
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
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button5_done"
		}
	}

	-------------------
	--Horn of Magnus

	HordeCompositions.onslaught_gutter_assistants = {
		{
			name = "monk",
			weight = 5,
			breeds = {
				"skaven_plague_monk",
				1
			}
		},
		{
			name = "shield",
			weight = 5,
			breeds = {
				"skaven_storm_vermin_with_shield",
				1				
			}
		},
		{
			name = "pack",
			weight = 5,
			breeds = {
				"skaven_pack_master",
				1
			}
		},
		{
			name = "warpfire",
			weight = 2,
			breeds = {
				"skaven_warpfire_thrower",
				1
			}
		}
	}
	
	TerrorEventBlueprints.magnus.magnus_gutter_runner_treasure = {
		{
			"spawn_special",
			breed_name = "skaven_gutter_runner",
			amount = {
				2,
				3
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_gutterrunner_stinger"
		},
		{
			"event_horde",
			composition_type = "onslaught_gutter_assistants"
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "gutter_runner_treasure_restart"
		}
	}
	
	TerrorEventBlueprints.magnus.magnus_door_a = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 12
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_magnus_boss_middle",
			breed_name = "skaven_rat_ogre",
			optional_data = {
				max_health_modifier = 0.375 -- 2400 hp
			}
		},
		{
			"delay",
			duration = 12
		},
		{
			"continue_when",
			duration = 10,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 12 and count_breed("chaos_fanatic") < 16 and count_breed("chaos_raider") < 6 and count_breed("chaos_berzerker") < 6
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"spawn_special",
			spawner_id = "magnus_door_event_specials",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_special",
			spawner_id = "magnus_door_event_specials",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			spawner_id = "magnus_door_event_specials",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			},
			amount = {
				1,
				2
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "skaven_poison_wind_globadier",
			spawner_id = "magnus_door_event_specials",
			amount = {
				1,
				2
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}
	
	TerrorEventBlueprints.magnus.magnus_door_b = TerrorEventBlueprints.magnus.magnus_door_a

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
				max_health_modifier = 0.1
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

	---------------------
	--Garden of Morr

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_1_a = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium",
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium",
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium",
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "cemetery_brew_event_specials",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_1_b = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_special",
			breed_name = "skaven_poison_wind_globadier",
			amount = 3
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_2_a = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"spawn_special",
			breed_name = "skaven_poison_wind_globadier",
			amount = 2
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "chaos_vortex_sorcerer",
			amount = 2
		},
		{
			"delay",
			duration = 5
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_2_b = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "chaos_vortex_sorcerer",
			amount = 2
		},
		{
			"delay",
			duration = 5
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_3_a = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "skaven_warpfire_thrower",
			amount = 3
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_3_b = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"spawn_special",
			breed_name = "skaven_ratling_gunner",
			amount = 3
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_4_a = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_4_b = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_exit_event = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_4",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_4",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_4",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_fanatic") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
			end
		}
	}

	---------------------
	--Engines of War

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_loop = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = {
				2,
				4
			}
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_loop_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_resistance_loop = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "forest_camp_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_camp_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = {
				4,
				9
			}
		},
		{
			"spawn_special",
			amount = 2,
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 10 and count_event_breed("skaven_slave") < 24 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 16 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 10
			end
		},
		{
			"delay",
			duration = {
				13,
				17
			}
		},
		{
			"event_horde",
			spawner_id = "forest_camp_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"spawn_special",
			amount = 2,
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = {
				4,
				9
			}
		},
		{
			"spawn_special",
			amount = 2,
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 10 and count_event_breed("skaven_slave") < 24 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 16 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 10
			end
		},
		{
			"delay",
			duration = {
				13,
				17
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_resistance_loop_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_a = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_commander") < 12
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_a_done"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_b = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 12
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_b_done"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_c = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "skaven_shields"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_with_shield") < 10
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "skaven_shields"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat_with_shield") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_c_done"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_finale = {
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"stop_event",
			stop_event_name = "forest_skaven_camp_resistance_loop"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_door_a",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_door_a",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_door_a",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_doomwheel_boss",
			breed_name = "skaven_rat_ogre",
			optional_data = {
			    enhancements = enhancement_5
			}
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_stormfiend") < 1
			end
		},
		{
			"stop_master_event"
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_finale_done"
		},
		{
			"disable_bots_in_carry_event"
		},
		{
			"control_pacing",
			enable = true
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_event_loop = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "forest_end_event",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_loop_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_event_a = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = {
				6,
				9
			}
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = {
				30,
				34
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_event_b = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = {
				40,
				45
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_event_c = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"delay",
			duration = 15
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_extra_spice_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = {
				38,
				42
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_finale = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_custom_boss_minotaur"
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("chaos_raider") < 5 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	---------------------
	--Dark Omens

	local horde_sound_settings = {
		skaven = {
			stinger_sound_event = "enemy_horde_stinger",
			music_states = {
				horde = "horde"
			}
		},
		chaos = {
			stinger_sound_event = "enemy_horde_chaos_stinger",
			music_states = {
				pre_ambush = "pre_ambush_chaos",
				horde = "horde_chaos"
			}
		},
		beastmen = {
			stinger_sound_event = "enemy_horde_beastmen_stinger",
			music_states = {
				pre_ambush = "pre_ambush_beastmen",
				horde = "horde_beastmen"
			}
		}
	}

	local function num_spawned_enemies()
		local spawned_enemies = Managers.state.conflict:spawned_units()

		return #spawned_enemies
	end

	local function num_alive_standards()
		local alive_standards = Managers.state.conflict:alive_standards()

		return #alive_standards
	end

	TerrorEventBlueprints.crater.crater_mid_event = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "crater_mid_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_beastmen_stinger"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		--[[
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_01",
			composition_type = "cheekspreader",
		},
		]]
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_01",
			composition_type = "dn_ratling_spam",
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_01",
			composition_type = "crackaddicts",
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_02",
			composition_type = "highasf",
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("beastmen_minotaur") < 1 and count_breed("beastmen_ungor_archer") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_01",
			composition_type = "event_medium_beastmen",
			sound_settings = horde_sound_settings.beastmen
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_02",
			composition_type = "event_medium_beastmen",
			sound_settings = horde_sound_settings.beastmen
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_warcamp") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_mid_event_enable_gate"
		},
		{
			"delay",
			duration = 1
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_beastmen_stinger"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "crater_mid_event_door_elite_02",
			composition_type = "crater_bestigor_medium",
			sound_settings = horde_sound_settings.beastmen
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_bestigor") < 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"control_specials",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "crater_mid_event_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_manual_spawns = {
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_01",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_02",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_03",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_04",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_05",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_06",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_07",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_08",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_10",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_11",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_12",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_13",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_14",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_15",
			breed_name = "beastmen_bestigor"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_intro_wave = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_intro_wave"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_beastmen_stinger"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event_intro_wave",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event_intro_wave",
			composition_type = "event_large_beastmen"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 55,
			condition = function (t)
				return count_event_breed("beastmen_gor") < 4 and count_breed("beastmen_ungor") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_intro_wave_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_wave_01 = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_wave_01"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 16
			end
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 10
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_medium_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_medium_beastmen"
		},
		{
			"continue_when",
			duration = 90,
			condition = function (t)
				return num_alive_standards() < 1 and count_event_breed("beastmen_gor") < 8 and count_event_breed("beastmen_ungor") < 8
			end
		},
		{
			"spawn_at_raw",
			breed_name = "beastmen_minotaur",
			spawner_id = "event_minotaur"
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_01_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_wave_02 = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_wave_02"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 14
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 20
			end
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 10
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"continue_when",
			duration = 180,
			condition = function (t)
				return num_alive_standards() < 1 and count_event_breed("beastmen_gor") < 8 and count_event_breed("beastmen_ungor") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_02_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_wave_03 = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_wave_03"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 20
			end
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 12
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "highasf"
		},
		{
			"continue_when",
			duration = 180,
			condition = function (t)
				return num_alive_standards() < 1 and count_event_breed("beastmen_gor") < 8 and count_event_breed("beastmen_ungor") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_03_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_wave_04 = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_wave_04"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 16
			end
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 12
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_04_repeat"
		},
		{
			"continue_when",
			duration = 180,
			condition = function (t)
				return num_alive_standards() < 1 and count_event_breed("beastmen_gor") < 5 and count_event_breed("beastmen_ungor") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_04_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_minotaur = {
		{
			"spawn_at_raw",
			breed_name = "skaven_clan_rat_tutorial",
			spawner_id = "event_minotaur",
			difficulty_requirement = HARD
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_minotaur") == 2
			end
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_minotaur") < 2
			end
		}
	}

	---------------------
	--Old Haunts

	TerrorEventBlueprints.dlc_portals.dlc_portals_control_pacing_disabled = {
		{
			"control_pacing",
			enable = false,
		},
		{
			"control_hordes",
			enable = false,
		},
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_temple_inside = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "dlc_portals_temple_inside"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_hordes",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside",
			composition_type = "dn_chaos_warriors"
		},
		{
			"delay",
			duration = 6
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_portals_temple_inside_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_temple_inside_specials = {
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_ladder_left1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_ladder_right1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_temple_yard = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_temple_yard"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_temple_yard",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_special",
			spawner_id = "portals_temple_yard",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"spawn_special",
			spawner_id = "portals_temple_yard",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			spawner_id = "portals_temple_yard_specials",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_yard_specials",
			composition_type = "chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "dn_skaven_elites"
		},
		{
			"delay",
			duration = 6
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 25 and count_event_breed("chaos_fanatic") < 30 and count_event_breed("chaos_raider") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_portals_temple_yard_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_temple_yard_exit = {
		{
			"spawn_at_raw",
			spawner_id = "portals_temple_yard_exit",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 18
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_hordes",
			enable = true
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_guards = {
		{
			"event_horde",
			spawner_id = "portals_end_event_guards",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_guards",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_guards",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_guards",
			composition_type = "chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_stairs1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_hordes",
			enable = false
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_a = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_event"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_special",
			breed_name = "skaven_pack_master",
			spawner_id = "portals_end_event_specials",
			amount = 1,
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 15
			end
		},
		{
			"flow_event",
			flow_event_name = "portals_end_event_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_b = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_event"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 7
		},
		{
			"spawn_special",
			spawner_id = "portals_end_event_specials",
			amount = 1,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_warpfire_thrower"
			}
		},
		{
			"spawn_special",
			spawner_id = "portals_end_event_specials",
			amount = 1,
			breed_name = {
				"skaven_ratling_gunner"
			},
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_basement",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			duration = 55,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 12 and count_event_breed("chaos_fanatic") < 14 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "portals_end_event_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_c = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_event"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "plague_monks_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_basement",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_special",
			spawner_id = "portals_end_event_specials",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			},
		},
		{
			"spawn_special",
			spawner_id = "portals_end_event_specials",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner"
			},
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 55,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "portals_end_event_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_d = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_event"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "plague_monks_medium",
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_stairs1",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 55,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 15 and count_event_breed("chaos_fanatic") < 15 and count_event_breed("chaos_raider") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "portals_end_event_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_escape_specials = {
		{
			"event_horde",
			spawner_id = "portals_end_escape_specials",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_specials",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_specials",
			composition_type = "plague_monks_medium"
		},
		{
			"spawn_special",
			spawner_id = "portals_end_escape_specials",
			amount = 3,
			breed_name = {
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 10
		},
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_escape_a = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_escape"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_special",
			spawner_id = "portals_end_escape_specials",
			amount = 4,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_ratling_gunner"
			}
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "plague_monks_medium"
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_special",
			breed_name = "skaven_warpfire_thrower",
			spawner_id = "portals_end_escape_specials",
			amount = 1,
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_plague_monk") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 6
			end
		},
		{
			"delay",
			duration = {
				1,
				4
			}
		},
		{
			"flow_event",
			flow_event_name = "portals_end_escape_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_escape_b = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_escape"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_maulers_medium"
		},
		{
			"spawn_special",
			spawner_id = "portals_end_escape_specials",
			amount = 2,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 12 and count_event_breed("chaos_fanatic") < 12
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"spawn_special",
			breed_name = "skaven_ratling_gunner",
			spawner_id = "portals_end_escape_specials",
			amount = 1,
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 15 and count_event_breed("chaos_fanatic") < 15 and count_event_breed("chaos_raider") < 6
			end
		},
		{
			"delay",
			duration = {
				1,
				4
			}
		},
		{
			"flow_event",
			flow_event_name = "portals_end_escape_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_escape_yard = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_escape_yard"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_portal",
			breed_name = "chaos_spawn",
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 12 and count_event_breed("chaos_fanatic") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_fanatic") < 3 and count_event_breed("chaos_raider") < 2
			end
		},
		{
			"delay",
			duration = {
				1,
				5
			}
		},
		{
			"flow_event",
			flow_event_name = "portals_end_escape_yard_done"
		}
	}

	-------------------
	--Blood in the Darkness

	TerrorEventBlueprints.dlc_bastion.bastion_gate_event = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "bastion_gate_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_hordes",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"delay",
			duration = 1
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 25 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_rat_ogre",
			spawner_id = "bastion_gate_event_special",
			optional_data = {
				enhancements = relentless
			}
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_ratling_gunner",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_ratling_gunner",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_poison_wind_globadier",
			spawner_id = "bastion_gate_event_special",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_large"
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_medium_shield"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_warpfire_thrower",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_warpfire_thrower",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_medium_shield"
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 14 and count_event_breed("chaos_warrior") < 10
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_stormfiend",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			breed_name = "chaos_spawn",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 20 and count_event_breed("chaos_fanatic") < 22 and count_event_breed("chaos_warrior") < 10
			end
		},
		{
			"spawn_at_raw",
			breed_name = "chaos_troll",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"spawn_at_raw",
			breed_name = "chaos_troll",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "chaos_warriors_small"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 7
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_fanatic") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_gate_event_done"
		}
	}

	TerrorEventBlueprints.dlc_bastion.bastion_finale_event = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "bastion_finale_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"delay",
			duration = 10
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 22 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "nngl_bastion_vo_sorcerer_taunt"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 22 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "nngl_bastion_vo_sorcerer_taunt"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_medium_shield"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 22 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_storm_vermin_with_shield") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 22 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 6 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "nngl_bastion_vo_sorcerer_taunt"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_medium_shield"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_pack_master",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_pack_master",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_pack_master",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_warpfire_thrower") < 3 and count_event_breed("skaven_warpfire_thrower") < 3 and count_event_breed("skaven_pack_master") < 3 and count_event_breed("skaven_poison_wind_globadier") < 3 and count_event_breed("skaven_gutter_runner") < 3
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_slave") < 28 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_storm_vermin_with_shield") < 6 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_vo_finale_tiring"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "nngl_bastion_vo_sorcerer_taunt"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "bastion_finale_event_boss"
		}
	}

	TerrorEventBlueprints.dlc_bastion.bastion_event_rat_ogre = {
		{
			"set_master_event_running",
			name = "bastion_event_boss"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_warrior") < 8 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_finale_event_escape"
		}
	}

	TerrorEventBlueprints.dlc_bastion.bastion_event_storm_fiend = {
		{
			"set_master_event_running",
			name = "bastion_event_boss"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_warrior") < 8 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_finale_event_escape"
		}
	}

	TerrorEventBlueprints.dlc_bastion.bastion_event_chaos_spawn = {
		{
			"set_master_event_running",
			name = "bastion_event_boss"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_warrior") < 8 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_finale_event_escape"
		}
	}

	TerrorEventBlueprints.dlc_bastion.bastion_finale_event_gauntlet = {
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"delay",
			duration = 7
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	-----------------
	--Enchanter's lair

	TerrorEventBlueprints.dlc_castle.castle_catacombs_welcome_committee = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "catacombs_special_welcome",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "catacombs_special_welcome",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "catacombs_special_welcome",
			composition_type = "onslaught_chaos_warriors"
		}
	}

	TerrorEventBlueprints.dlc_castle.castle_chaos_boss = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "castle_chaos_boss"
		},
		{
			"spawn_at_raw",
			spawner_id = "castle_chaos_boss",
			breed_name = "chaos_exalted_sorcerer_drachenfels"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_exalted_sorcerer_drachenfels") == 1
			end
		},
		{
			"flow_event",
			flow_event_name = "castle_chaos_boss_spawn"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_sorcerer_drachenfels") < 1
			end
		},
		{
			"control_specials",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "castle_chaos_boss_dead"
		}
	}

	TerrorEventBlueprints.dlc_castle.castle_catacombs_end_event_loop = {
		{
			"set_master_event_running",
			name = "escape_catacombs"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "escape_catacombs",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 18 and count_event_breed("skaven_slave") < 16
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "castle_catacombs_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.dlc_castle.castle_catacombs_end_event_loop_extra_spice = {
		{
			"set_master_event_running",
			name = "escape_catacombs"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape_spice",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape_spice",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape_spice",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "castle_catacombs_end_event_loop_extra_spice_done"
		}
	}

	HordeCompositions.chaos_event_defensive = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					45,
					51
				},
				"chaos_marauder",
				{
					21,
					23
				},
				"chaos_marauder_with_shield",
				{
					22,
					24
				},
				"chaos_berzerker",
				{
					6,
					7
				}
			}
		},
		{
			name = "wave_b",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_marauder_with_shield",
				{
					18,
					20
				},
				"chaos_raider",
				{
					4,
					5
				},
				"chaos_berzerker",
				{
					4,
					5
				},
				"chaos_warrior",
				2
			}
		},
		{
			name = "wave_c",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					22,
					23
				},
				"chaos_marauder_with_shield",
				{
					20,
					22
				},
				"chaos_raider",
				{
					23,
					25
				}
			}
		},
		{
			name = "wave_d",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					15,
					17
				},
				"chaos_marauder_with_shield",
				{
					18,
					20
				},
				"chaos_berzerker",
				{
					23,
					25
				}
			}
		},
		{
			name = "wave_e",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					18,
					20
				},
				"chaos_marauder",
				{
					22,
					23
				},
				"chaos_marauder_with_shield",
				{
					20,
					25
				},
				"chaos_warrior",
				10
			}
		},
		end_time = 9999,
		start_time = 0
	}

	HordeCompositions.chaos_event_defensive_intense = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					45,
					51
				},
				"chaos_marauder",
				{
					25,
					27
				},
				"chaos_marauder_with_shield",
				{
					30,
					31
				},
				"chaos_berzerker",
				{
					8,
					9
				}
			}
		},
		{
			name = "wave_b",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_marauder_with_shield",
				{
					30,
					32
				},
				"chaos_raider",
				{
					5,
					6
				},
				"chaos_berzerker",
				{
					5,
					6
				},
				"chaos_warrior",
				2
			}
		},
		{
			name = "wave_c",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					15,
					17
				},
				"chaos_marauder_with_shield",
				{
					20,
					22
				},
				"chaos_raider",
				{
					25,
					27
				}
			}
		},
		{
			name = "wave_d",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					20,
					22
				},
				"chaos_marauder_with_shield",
				{
					20,
					22
				},
				"chaos_berzerker",
				{
					25,
					27
				}
			}
		},
		{
			name = "wave_e",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					18,
					20
				},
				"chaos_marauder",
				{
					22,
					24
				},
				"chaos_marauder_with_shield",
				15,
				"chaos_warrior",
				10
			}
		},
		end_time = 9999,
		start_time = 0
	}

	HordeCompositions.chaos_event_offensive_small = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					10,
					12
				},
				"chaos_fanatic",
				{
					8,
					10
				},
				"chaos_raider",
				{
					2,
					3
				},
				"chaos_berzerker",
				{
					2,
					3
				},
				"chaos_warrior",
				1
			}
		},
		end_time = 9999,
		start_time = 0
	}

	HordeCompositions.chaos_event_offensive = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					25,
					30
				},
				"chaos_fanatic",
				{
					25,
					30
				},
				"chaos_berzerker",
				8
			}
		},
		{
			name = "wave_b",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					25,
					30
				},
				"chaos_fanatic",
				{
					25,
					30
				},
				"chaos_raider",
				7
			}
		},
		end_time = 9999,
		start_time = 0
	}
