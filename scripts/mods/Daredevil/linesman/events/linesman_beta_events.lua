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
		composition_type = "event_large"
	},
	{
		"event_horde",
		spawner_id = "square_front",
		composition_type = "linesman_mixed_horde"
	},
	{
		"delay",
		duration = 15
	},
	{
		"event_horde",
		spawner_id = "hay_barn_bridge_invis",
		composition_type = "linesman_mixed_horde"
	},
	{
		"delay",
		duration = 10
	},
	{
		"event_horde",
		spawner_id = "square_center",
		composition_type = "event_small"
	},
	{
		"delay",
		duration = 10
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("chaos_marauder") < 25 and count_event_breed("skaven_slave") < 50
		end
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
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 35 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
		end
	},
	{
		"event_horde",
		spawner_id = "hay_barn_back",
		composition_type = "linesman_mixed_horde"
	},
	{
		"event_horde",
		spawner_id = "hay_barn_back",
		composition_type = "skaven_shields"
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
		duration = 40
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
		composition_type = "linesman_mixed_horde"
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
		enable = false
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
		duration = 35
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
		enable = false
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
		duration = 40,
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
		duration = 30,
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
		enable = false
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
		spawner_id = "sawmill_interior",
		composition_type = "dn_warpfire_spam"
	},
	{
		"event_horde",
		spawner_id = "sawmill_interior",
		composition_type = "banners"
	},
	{
		"event_horde",
		spawner_id = "sawmill_interior",
		composition_type = "banners"
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
		duration = 30,
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