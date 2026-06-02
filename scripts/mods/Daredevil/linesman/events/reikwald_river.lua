local mod = get_mod("Daredevil")
local language_id = Managers.localizer:language_id()
local is_chinese = language_id == "zh"

local function count_event_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
end

local function count_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed(breed_name)
end

local function num_spawned_enemies()
	local spawned_enemies = Managers.state.conflict:spawned_enemies()

	return #spawned_enemies
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

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_pacing_off = {
	{
		"control_pacing",
		enable = false,
	},
	{
		"control_specials",
		enable = false,
	},
	{
		"control_hordes",
		enable = true,
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_pacing_on = {
	{
		"control_pacing",
		enable = true,
	},
	{
		"control_specials",
		enable = true,
	},
	{
		"control_hordes",
		enable = true,
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_enable_special_pacing = {
	{
		"control_specials",
		enable = true,
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_disable_special_pacing = {
	{
		"control_specials",
		enable = false,
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_enable_hordes_pacing = {
	{
		"control_hordes",
		enable = true,
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_disable_hordes_pacing = {
	{
		"control_hordes",
		enable = false,
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_plaza_01 = {
	{
		"delay",
		duration = 5,
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_troll = {
	{
		"set_master_event_running",
		name = "river_troll",
	},
	{
		"control_specials",
		enable = true,
	},
	{
		"spawn_at_raw",
		breed_name = "chaos_troll",
		spawner_id = "troll_boss",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		condition = function (t)
			return count_breed("chaos_troll") < 1
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_troll_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_troll_flush = {
	{
		"set_master_event_running",
		name = "river_troll_flush",
	},
	{
		"control_specials",
		enable = true,
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "troll_cave_flush",
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_troll_flush_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_barrel_ambush_01 = {
	{
		"set_master_event_running",
		name = "barrel_ambush",
	},
	{
		"control_specials",
		enable = true,
	},
	{
		"event_horde",
		composition_type = "dn_chaos_zerkers_heavy",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"event_horde",
		composition_type = "dn_chaos_warriors",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"delay",
		duration = 15,
	},
	{
		"continue_when",
		duration = 15,
		condition = function (t)
			return count_event_breed("chaos_warrior") < 2 and count_event_breed("skaven_slave") < 10 and count_event_breed("skaven_clan_rat") < 15
		end,
	},
	{
		"event_horde",
		composition_type = "dn_chaos_zerkers_heavy",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"event_horde",
		composition_type = "dn_chaos_warriors",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"delay",
		duration = 15,
	},
	{
		"flow_event",
		flow_event_name = "barrel_ambush_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sw_reikwald_river_swamp = {
	{
		"set_master_event_running",
		name = "warcamp_swamp",
	},
	{
		"control_pacing",
		enable = false,
	},
	{
		"control_specials",
		enable = false,
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"event_horde",
		composition_type = "event_medium_chaos",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_l",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"event_horde",
		composition_type = "chaos_shields",
		limit_spawners = 1,
		spawner_id = "warcamp_swamp_event_l",
	},
	{
		"spawn_special",
		amount = 3,
		breed_name = {
			"chaos_corruptor_sorcerer",
			"chaos_vortex_sorcerer",
		},
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 3 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
		end,
	},
	{
		"event_horde",
		composition_type = "chaos_berzerkers_small",
		limit_spawners = 1,
		spawner_id = "warcamp_swamp_event_r",
	},
	{
		"delay",
		duration = 10,
		difficulty_requirement = HARDER,
	},
	{
		"spawn_special",
		amount = 3,
		breed_name = {
			"chaos_corruptor_sorcerer",
			"chaos_vortex_sorcerer",
			"skaven_gutter_runner",
		},
		difficulty_requirement = HARDEST,
	},
	{
		"event_horde",
		composition_type = "event_chaos_extra_spice_small",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_l",
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_pack_master",
			"skaven_ratling_gunner",
			"skaven_poison_wind_globadier",
		},
		difficulty_requirement = HARDER,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"chaos_corruptor_sorcerer",
			"chaos_vortex_sorcerer",
			"skaven_gutter_runner",
		},
		difficulty_requirement = HARDEST,
	},
	{
		"continue_when",
		duration = 35,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
		end,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"event_horde",
		composition_type = "event_small_chaos",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_l",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"spawn_special",
		amount = 2,
		breed_name = {
			"skaven_pack_master",
			"skaven_gutter_runner",
		},
		difficulty_requirement = HARDEST,
	},
	{
		"event_horde",
		composition_type = "event_chaos_extra_spice_small",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_l",
		difficulty_requirement = HARDER,
	},
	{
		"event_horde",
		composition_type = "event_small_chaos",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_r",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"spawn_special",
		amount = 3,
		breed_name = "skaven_poison_wind_globadier",
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"chaos_corruptor_sorcerer",
			"chaos_vortex_sorcerer",
			"skaven_gutter_runner",
		},
		difficulty_requirement = HARDEST,
	},
	{
		"continue_when",
		duration = 40,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 3 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
		end,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"event_horde",
		composition_type = "event_large_chaos",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_l",
	},
	{
		"event_horde",
		composition_type = "event_chaos_extra_spice_small",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_r",
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 20,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 3 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
		end,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"event_horde",
		composition_type = "event_small_chaos",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_r",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"event_horde",
		composition_type = "chaos_shields",
		limit_spawners = 1,
		spawner_id = "warcamp_swamp_event_r",
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 3 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
		end,
	},
	{
		"event_horde",
		composition_type = "event_small_chaos",
		limit_spawners = 2,
		spawner_id = "warcamp_swamp_event_r",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"event_horde",
		composition_type = "chaos_shields",
		limit_spawners = 1,
		spawner_id = "warcamp_swamp_event_l",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 40,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 3 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_swamp_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_chaos_01 = {
	{
		"set_master_event_running",
		name = "chaos_ship_1",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"spawn_at_raw",
		breed_name = "chaos_warrior",
		spawner_id = "chaos_ship_01",
		difficulty_requirement = HARDEST,
	},
	{
		"event_horde",
		composition_type = "dn_chaos_warriors",
		spawner_id = "chaos_ship_01",
	},
	{
		"event_horde",
		composition_type = "mass_trash_chaos",
		spawner_id = "chaos_ship_01",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 15,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 3 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2 and count_event_breed("chaos_fanatic") < 4
		end,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_sea_battle_chaos_01_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_landside_01 = {
	{
		"control_pacing",
		enable = false,
	},
	{
		"control_specials",
		enable = false,
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "sea_battle_landside_raw_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "sea_battle_landside_raw_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_poison_wind_globadier",
		spawner_id = "sea_battle_landside_raw_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_poison_wind_globadier",
		spawner_id = "sea_battle_landside_raw_01",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_right_01 = {
	{
		"event_horde",
		composition_type = "mass_trash_skaven",
		spawner_id = "sea_battle_right_01",
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "sea_battle_right_01",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 15,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 10
		end,
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "sea_battle_right_01",
	},
	{
		"event_horde",
		composition_type = "plague_monks_medium",
		spawner_id = "sea_battle_right_01",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 10
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_sea_battle_right_01_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_left_01 = {
	{
		"event_horde",
		composition_type = "mass_trash_skaven",
		spawner_id = "sea_battle_left_01",
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "sea_battle_left_01",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 15,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 10
		end,
	},
	{
		"event_horde",
		composition_type = "dn_chaos_warriors_heavy",
		spawner_id = "sea_battle_left_01",
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "sea_battle_left_01",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 10
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_sea_battle_right_01_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_right_02 = {
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "sea_battle_right_02",
	},
	{
		"event_horde",
		composition_type = "dn_plague_monks",
		spawner_id = "sea_battle_right_02",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 20,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 5
		end,
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "sea_battle_right_02",
	},
	{
		"event_horde",
		composition_type = "dn_white_stormvermin",
		spawner_id = "sea_battle_right_02",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 20,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 5
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_sea_battle_right_02_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_left_02 = {
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "sea_battle_left_02",
	},
	{
		"delay",
		duration = 15,
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "sea_battle_left_02",
	},
	{
		"delay",
		duration = 15,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_sea_battle_left_02_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_right_03 = {
	{
		"event_horde",
		composition_type = "linesman_skaven_horde",
		spawner_id = "sea_battle_right_03",
	},
	{
		"delay",
		duration = 25,
	},
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "sea_battle_right_03",
	},
	{
		"continue_when",
		duration = 20,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 3
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "sea_battle_right_03",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 20,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_sea_battle_right_03_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_left_03 = {
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "sea_battle_left_03",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "sea_battle_left_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_warpfire_thrower",
		spawner_id = "raw_skaven_ship_left_03_clan_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_pack_master",
		spawner_id = "raw_skaven_ship_left_03_clan_03",
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "sea_battle_left_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_warpfire_thrower",
		spawner_id = "raw_skaven_ship_left_03_clan_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_pack_master",
		spawner_id = "raw_skaven_ship_left_03_clan_03",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_sea_battle_left_03_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_front_03 = {
	{
		"event_horde",
		composition_type = "event_medium",
		spawner_id = "sea_battle_front_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_pack_master",
		spawner_id = "right_ship_ambush_corner",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 2 and count_event_breed("skaven_slave") < 2
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "sea_battle_front_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "right_ship_ambush_corner",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "right_ship_ambush_corner",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_sea_battle_front_03_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_replace_left_01 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_left_01_clan_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_gutter_runner",
		spawner_id = "raw_skaven_ship_left_01_clan_02",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_gutter_runner",
		spawner_id = "raw_skaven_ship_left_01_clan_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_left_01_clan_04",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_storm_vermin_commander",
		spawner_id = "raw_skaven_ship_left_01_captain",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_replace_right_01 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_01_clan_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_01_clan_02",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_01_clan_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_01_clan_04",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_storm_vermin_commander",
		spawner_id = "raw_skaven_ship_right_01_captain",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_replace_left_02 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_left_02_clan_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_gutter_runner",
		spawner_id = "raw_skaven_ship_left_02_clan_02",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_gutter_runner",
		spawner_id = "raw_skaven_ship_left_02_clan_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_gutter_runner",
		spawner_id = "raw_skaven_ship_left_02_clan_04",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_storm_vermin_commander",
		spawner_id = "raw_skaven_ship_left_02_captain",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_replace_right_02 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_02_clan_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_02_clan_02",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_02_clan_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_02_clan_04",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_02_captain",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_replace_left_03 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_left_03_clan_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_left_03_clan_02",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_left_03_clan_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_left_03_clan_04",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_left_03_captain",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_sea_battle_replace_right_03 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_03_clan_01",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_03_clan_02",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_03_clan_03",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_03_clan_04",
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_ratling_gunner",
		spawner_id = "raw_skaven_ship_right_03_captain",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_chaos_sword_01 = {
	{
		"set_master_event_running",
		name = "chaos_sword",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"control_specials",
		enable = false,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"event_horde",
		composition_type = "linesman_chaos_horde",
		spawner_id = "chaos_sword",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 50,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 3 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2 and count_event_breed("chaos_fanatic") < 4
		end,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_chaos_sword_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_shore_crash_01 = {
	{
		"set_master_event_running",
		name = "survive_beach_end_event",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"event_horde",
		composition_type = "linesman_skaven_horde",
		spawner_id = "shore_crash_01",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_gauntlet_01 = {
	{
		"set_master_event_running",
		name = "survive_beach_end_event",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "gauntlet_01_front",
	},
	{
		"event_horde",
		composition_type = "event_medium",
		spawner_id = "gauntlet_01",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "gauntlet_01",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_gauntlet_02 = {
	{
		"set_master_event_running",
		name = "survive_beach_end_event",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"delay",
		duration = 1,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "gauntlet_02",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"event_horde",
		composition_type = "event_medium",
		spawner_id = "gauntlet_02",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_gauntlet_03 = {
	{
		"set_master_event_running",
		name = "survive_beach_end_event",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"delay",
		duration = 1,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "gauntlet_03",
	},
	{
		"event_horde",
		composition_type = "event_medium",
		spawner_id = "gauntlet_03",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "gauntlet_03",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_survive_beach_01 = {
	{
		"control_pacing",
		enable = false,
	},
	{
		"control_specials",
		enable = true,
	},
	{
		"set_master_event_running",
		name = "survive_beach_end_event",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"flow_event",
		flow_event_name = "survive_beach_crescendo_starting",
	},
	{
		"event_horde",
		composition_type = "linesman_chaos_horde",
		limit_spawners = 2,
		spawner_id = "survive_beach_01",
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger",
	},
	{
		"spawn_special",
		amount = 3,
		breed_name = {
			"skaven_ratling_gunner",
			"skaven_warpfire_thrower",
		},
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 4
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_large",
		limit_spawners = 4,
		spawner_id = "survive_beach_01",
	},
	{
		"disable_kick",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"spawn_special",
		amount = 3,
		breed_name = {
			"skaven_ratling_gunner",
			"skaven_warpfire_thrower",
		},
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 4
		end,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"event_horde",
		composition_type = "linesman_mixed_horde",
		spawner_id = "survive_beach_01",
	},
	{
		"spawn_special",
		amount = 3,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_ratling_gunner",
		},
		difficulty_requirement = HARDEST,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 20,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 4
		end,
	},	
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger",
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_large",
		limit_spawners = 4,
		spawner_id = "survive_beach_01",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"event_horde",
		composition_type = "plague_monks_medium",
		limit_spawners = 1,
		spawner_id = "survive_beach_01",
		difficulty_requirement = HARDEST,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 20,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 4
		end,
	},
	{
		"spawn_special",
		breed_name = {
			"skaven_gutter_runner",
			"skaven_pack_master",
		},
		difficulty_requirement = HARDER,
	},
	{
		"spawn_special",
		breed_name = {
			"skaven_gutter_runner",
			"skaven_pack_master",
		},
		difficulty_requirement = HARDEST,
	},
	{
		"event_horde",
		composition_type = "apocalypse_wave",
		limit_spawners = 4,
		spawner_id = "survive_beach_01",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 60,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 7 and count_event_breed("skaven_storm_vermin_commander") < 4
		end,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"event_horde",
		composition_type = "apocalypse_wave",
		limit_spawners = 4,
		spawner_id = "survive_beach_01",
	},
	{
		"spawn_special",
		breed_name = {
			"skaven_ratling_gunner",
			"skaven_poison_wind_globadier",
		},
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 60,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 4 and count_event_breed("skaven_plague_monk") < 2
		end,
	},
	{
		"flow_event",
		flow_event_name = "survive_beach_event_done",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"control_specials",
		enable = true,
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_survive_chaos_01 = {
	{
		"set_master_event_running",
		name = "chaos_beach_1",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"event_horde",
		composition_type = "linesman_chaos_horde",
		spawner_id = "beach_chaos",
	},
	{
		"delay",
		duration = 3,
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 3 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2 and count_event_breed("chaos_fanatic") < 4
		end,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"event_horde",
		composition_type = "mass_trash_chaos",
		spawner_id = "beach_chaos",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_beach_chaos_01_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_survive_chaos_spice_01 = {
	{
		"set_master_event_running",
		name = "chaos_beach_spice_1",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger",
	},
	{
		"event_horde",
		composition_type = "apocalypse_wave",
		spawner_id = "beach_chaos",
	},
	{
		"delay",
		duration = 20,
	},
	{
		"continue_when",
		duration = 35,
		condition = function(t)
			if (count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 10 and count_event_breed("chaos_warrior") < 5) then
				-- Give purple pot buff + healing
				local players = Managers.player:human_and_bot_players()

				for _, player in pairs(players) do
					local unit = player.player_unit
	
					if Unit.alive(unit) then
						local buff_system = Managers.state.entity:system("buff_system")
						local server_controlled = false
	
						buff_system:add_buff(unit, "twitch_cooldown_reduction_boost", unit, server_controlled)
						buff_system:add_buff(unit, "twitch_damage_boost", unit, server_controlled)
						buff_system:add_buff(unit, "twitch_health_regen", unit, server_controlled)
					end
				end

				return true
			end
		end,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"event_horde",
		composition_type = "dn_chaos_warriors",
		spawner_id = "survive_beach_01",
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("chaos_warrior") < 2
		end,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_beach_chaos_spice_01_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_survive_ambush_01 = {
	{
		"set_master_event_running",
		name = "survive_ambush",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "rescue_ship_ambush",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"delay",
		duration = 10,
	},
	{
		"flow_event",
		flow_event_name = "survive_ambush_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_doombringer_01 = {
	{
		"set_master_event_running",
		name = "reikwald_river_doombringer_01",
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "finale_floor",
	},
	{
		"event_horde",
		composition_type = "event_medium",
		spawner_id = "finale_floor",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "doombringer_wreck",
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "finale_floor",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_doombringer_01_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_doombringer_02 = {
	{
		"set_master_event_running",
		name = "reikwald_river_doombringer_02",
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "finale_floor",
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "finale_floor",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "doombringer_wreck",
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "finale_floor",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 10
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_doombringer_02_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_doombringer_03 = {
	{
		"set_master_event_running",
		name = "reikwald_river_doombringer_03",
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "finale_floor",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 2 and count_event_breed("skaven_slave") < 2
		end,
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "doombringer_wreck",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_doombringer_03_done",
	},
}

TerrorEventBlueprints.dlc_reikwald_river.reikwald_river_hooks = {
	{
		"set_master_event_running",
		name = "reikwald_river_hooks",
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "ship_sides",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 2 and count_event_breed("skaven_slave") < 2
		end,
	},
	{
		"event_horde",
		composition_type = "event_large",
		spawner_id = "ship_sides",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"event_horde",
		composition_type = "crater_detour",
		spawner_id = "doombringer_specials",
	},
	{
		"delay",
		duration = 10,
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
		end,
	},
	{
		"flow_event",
		flow_event_name = "reikwald_river_hooks_done",
	},
}