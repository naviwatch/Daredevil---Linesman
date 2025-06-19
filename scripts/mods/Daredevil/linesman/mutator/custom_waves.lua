local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict
local horde_spawner = Managers.state.conflict.horde_spawner
local num_paced_hordes = horde_spawner.num_paced_hordes
local language_id = Managers.localizer:language_id()
local is_chinese = language_id == "zh"

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
local enhancement_list = {
    ["commander"] = true,
    ["unstaggerable"] = true
}
local bob_pacing = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local function count_event_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
end

local function count_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed(breed_name)
end

local function spawned_during_event()
	return Managers.state.conflict:enemies_spawned_during_event()
end

local function add_item(is_server, player_unit, pickup_type)
	local player_manager = Managers.player
	local player = player_manager:owner(player_unit)

	if player then
		local local_bot_or_human = not player.remote

		if local_bot_or_human then
			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
			local career_extension = ScriptUnit.extension(player_unit, "career_system")
			local pickup_settings = AllPickups[pickup_type]
			local slot_name = pickup_settings.slot_name
			local item_name = pickup_settings.item_name
			local slot_data = inventory_extension:get_slot_data(slot_name)
			local can_store_additional_item = inventory_extension:can_store_additional_item(slot_name)
			local has_additional_items = inventory_extension:has_additional_items(slot_name)

			if slot_data and not can_store_additional_item then
				local item_data = slot_data.item_data
				local item_template = BackendUtils.get_item_template(item_data)
				local pickup_item_to_spawn

				if item_template.name == "wpn_side_objective_tome_01" then
					pickup_item_to_spawn = "tome"
				elseif item_template.name == "wpn_grimoire_01" then
					pickup_item_to_spawn = "grimoire"
				end

				if pickup_item_to_spawn then
					local pickup_spawn_type = "dropped"
					local pickup_name_id = NetworkLookup.pickup_names[pickup_item_to_spawn]
					local pickup_spawn_type_id = NetworkLookup.pickup_spawn_types[pickup_spawn_type]
					local position = POSITION_LOOKUP[player_unit]
					local rotation = Unit.local_rotation(player_unit, 0)

					network_transmit:send_rpc_server("rpc_spawn_pickup", pickup_name_id, position, rotation, pickup_spawn_type_id)
				end
			end

			local item_data = ItemMasterList[item_name]
			local unit_template
			local extra_extension_init_data = {}

			if can_store_additional_item and slot_data then
				inventory_extension:store_additional_item(slot_name, item_data)
			elseif has_additional_items and slot_data then
				local has_droppable, is_stored, drop_item_data = inventory_extension:has_droppable_item(slot_name)

				if is_stored then
					inventory_extension:remove_additional_item(slot_name, drop_item_data)
					inventory_extension:store_additional_item(slot_name, item_data)
				else
					inventory_extension:destroy_slot(slot_name)
					inventory_extension:add_equipment(slot_name, item_data, unit_template, extra_extension_init_data)
				end
			else
				inventory_extension:destroy_slot(slot_name)
				inventory_extension:add_equipment(slot_name, item_data, unit_template, extra_extension_init_data)
			end

			local go_id = Managers.state.unit_storage:go_id(player_unit)
			local slot_id = NetworkLookup.equipment_slots[slot_name]
			local item_id = NetworkLookup.item_names[item_name]
			local weapon_skin_id = NetworkLookup.weapon_skins["n/a"]

			if is_server then
				network_transmit:send_rpc_clients("rpc_add_equipment", go_id, slot_id, item_id, weapon_skin_id)
			else
				network_transmit:send_rpc_server("rpc_add_equipment", go_id, slot_id, item_id, weapon_skin_id)
			end

			local wielded_slot_name = inventory_extension:get_wielded_slot_name()

			if wielded_slot_name == slot_name then
				CharacterStateHelper.stop_weapon_actions(inventory_extension, "picked_up_object")
				CharacterStateHelper.stop_career_abilities(career_extension, "picked_up_object")
				inventory_extension:wield(slot_name)
			end
		end
	end
end

local give_strength_pot_man = function()
    local side = blackboard.side
    local PLAYER_AND_BOT_UNITS = side.ENEMY_PLAYER_AND_BOT_UNITS

    for i = 1, #PLAYER_AND_BOT_UNITS do
        local player_unit = PLAYER_AND_BOT_UNITS[i]
        if Unit.alive(player_unit) then
            add_item(is_server, unit, "damage_boost_potion")
        end
    end
end

-- ========================
-- Set up events
-- ========================

GenericTerrorEvents.special_coordinated = {
    {
        "play_stinger",
        stinger_name = "Play_curse_egg_of_tzeentch_alert_high"
    },
}

GenericTerrorEvents.grunt_rush = {
    {
        "play_stinger",
        stinger_name = "Play_blessing_challenge_of_grimnir_activate"
    }
}

GenericTerrorEvents.split_wave = {
    {
        "play_stinger",
        stinger_name = "morris_bolt_of_change_laughter"
    },
}

GenericTerrorEvents.mini_boss_warning = {
    {
        "play_stinger",
        stinger_name = "Play_curse_egg_of_tzeentch_alert_egg_destroyed"
    }
}

GenericTerrorEvents.darktide = {
    {
        "play_stinger",
        stinger_name = "enemy_horde_stinger"
    }
}

GenericTerrorEvents.skaven_denial = {
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_poison_wind_globadier",
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = "skaven_warpfire_thrower",
        optional_data = {
            target_selection = "least_healthy_player"
        }
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
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "furthest_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_pack_master",
        optional_data = {
            target_selection = "pick_solitary_target"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer"
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
        amount = 2,
        breed_name = "chaos_corruptor_sorcerer"
    },
}
GenericTerrorEvents.skaven_spam = {
    {
        "spawn_special",
        amount = 2,
        breed_name = "skaven_warpfire_thrower",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "furthest_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_pack_master",
        optional_data = {
            target_selection = "pick_solitary_target"
        }
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "furthest_player"
        }
    }
}
GenericTerrorEvents.skaven_gas = {
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_poison_wind_globadier"
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_vortex_sorcerer"
    },
}

-- Spam waves
GenericTerrorEvents.spam_ratling = {
    {
        "spawn_special",
        amount = 2,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "delay",
        duration = 10
    },
    {
        "spawn_special",
        amount = 4,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "delay",
        duration = 20
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "furthest_player"
        }
    },
    {
        "delay",
        duration = 2
    },
}

GenericTerrorEvents.spam_warpfire = {
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_warpfire_thrower",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "delay",
        duration = 10
    },
    {
        "spawn_special",
        amount = 4,
        breed_name = "skaven_warpfire_thrower",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "delay",
        duration = 15
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_warpfire_thrower",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "delay",
        duration = 2
    },
}

GenericTerrorEvents.spam_leech = { -- 3 rotations
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "pick_solitary_target"
        }
    },
    {
        "delay",
        duration = 25
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "pick_solitary_target"
        }
    },
    {
        "delay",
        duration = 25
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_corruptor_sorcerer",
        optional_data = {
            target_selection = "pick_solitary_target"
        }
    },
    {
        "delay",
        duration = 5
    },
}

GenericTerrorEvents.spam_assassin = { -- 3 rotations
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "pick_solitary_target"
        }
    },
    {
        "delay",
        duration = 25
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "pick_solitary_target"
        }
    },
    {
        "delay",
        duration = 30
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "pick_solitary_target"
        }
    },
}

GenericTerrorEvents.fuck_you = {
    {
        "spawn_special",
        amount = 2,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "delay",
        duration = 15,
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_pack_master"
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_poison_wind_globadier",
        optional_data = {
            target_selection = "furthest_player"
        }
    },
    {
        "delay",
        duration = 30,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "delay",
        duration = 15,
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_pack_master"
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_poison_wind_globadier",
        optional_data = {
            target_selection = "furthest_player"
        }
    },
    {
        "delay",
        duration = 35,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = "skaven_gutter_runner",
        optional_data = {
            target_selection = "healthy_players"
        }
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "least_healthy_player"
        }
    },
    {
        "delay",
        duration = 15,
    },
    {
        "spawn_special",
        amount = 1,
        breed_name = "skaven_pack_master"
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_poison_wind_globadier",
        optional_data = {
            target_selection = "furthest_player"
        }
    },
}

GenericTerrorEvents.mini_ogre = {
    {
        "spawn_special",
        breed_name = "skaven_clan_rat",
        optional_data = {
            enhancements = enhancement_5,
            perception = "perception_all_seeing",
            detection_radius = math.huge,
            target_selection = "pick_closest_target_infinte_range",
            size_variation_range = { 2, 2 },
            max_health_modifier = 4
        }
    }
}

GenericTerrorEvents.bob_the_builder = {
    {
        "spawn_special",
        breed_name = "skaven_dummy_clan_rat",
        optional_data = {
            max_health_modifier = 7,
        --    spawned_func = AiUtils.magic_entrance_optional_spawned_func,
            enhancements = bob_pacing,
            target_selection = "least_healthy_player",
            size_variation_range = { 2, 2 },
            force_boss_health_ui = true,
        }
    }
}

-- ========================
-- Wave functions
-- ========================

local spawn_trash_wave = function()
    local num_to_spawn_enhanced = 0
    local num_to_spawn = 1
    local spawn_list = {}

    -- PRD_trash, trash = PseudoRandomDistribution.flip_coin(trash, 0.5) -- Flip 50%
    for i = 1, num_to_spawn_enhanced do
        table.insert(spawn_list, "skaven_clan_rat")
        table.insert(spawn_list, "chaos_marauder")
    end

    for i = 1, num_to_spawn do
        table.insert(spawn_list, "beastmen_standard_bearer")
    end

    local side = Managers.state.conflict.default_enemy_side_id
    local side_id = side

    Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, true, side_id)
end

local sa_chances = 0.1

local special_attack = function()
    PRD_special_attack, state = PseudoRandomDistribution.flip_coin(state, sa_chances)
    if PRD_special_attack then
        conflict_director:start_terror_event("special_coordinated")

        if is_chinese then 
            mod:chat_broadcast("特感波!")
        else
            mod:chat_broadcast("SPECIAL WAVE!")
        end

        PRD_well_thought_out_waves, wtow = PseudoRandomDistribution.flip_coin(wtow, 0.5)

        if PRD_well_thought_out_waves then 
            if mod:get("debug") then
                mod:chat_broadcast("Spawning wave of specials")
            end

            PRD_mix, mix = PseudoRandomDistribution.flip_coin(mix, 0.5) -- Flip 50%

            if PRD_mix then
                PRD_gas, gas = PseudoRandomDistribution.flip_coin(gas, 0.5)

                if gas then 
                    conflict_director:start_terror_event("skaven_gas")
                else
                    PRD_wejofi, wejofi = PseudoRandomDistribution.flip_coin(wejofi, 0.5)

                    if PRD_wejofi then 
                        conflict_director:start_terror_event("fuck_you")
                    else
                        conflict_director:start_terror_event("skaven_mix")
                    end
                end

            else
                PRD_die, die = PseudoRandomDistribution.flip_coin(die, 0.5)

                if PRD_die then
                    conflict_director:start_terror_event("skaven_spam")
                else
                    PRD_denial, denial = PseudoRandomDistribution.flip_coin(denial, 0.5) -- Flip 50%

                    if PRD_denial then
                        conflict_director:start_terror_event("fuck_you")
                    else
                        conflict_director:start_terror_event("chaos_denial")
                    end
                end

            end
        else
            PRD_scrambler, scram = PseudoRandomDistribution.flip_coin(scram, 0.5)

            if PRD_scrambler then 
                abcdefg, an242 = PseudoRandomDistribution.flip_coin(an242, 0.5)

                if abcdefg then 
                    conflict_director:start_terror_event("spam_ratling")
                else
                    conflict_director:start_terror_event("spam_warpfire")
                end
            else
                which_disabler, wdwegnwe = PseudoRandomDistribution.flip_coin(wdwegnwe, 0.5)

                if which_disabler then 
                    conflict_director:start_terror_event("spam_assassin")
                else
                    conflict_director:start_terror_event("spam_leech")
                end
            end
        end
    end
end

local custom_wave_c3 = function()
    local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
    local base_difficulty_name = difficulty_settings.display_name
    local chances = 0.08

    PRD_custom_wave, w = PseudoRandomDistribution.flip_coin(w, chances)

    if PRD_custom_wave then 
        Managers.state.conflict:start_terror_event("grunt_rush")

        trash, eot = PseudoRandomDistribution.flip_coin(eot, 1) -- ripped from apocalypse

        if trash then
            spawn_trash_wave()
            if mod:get("debug") then
                mod:chat_broadcast("Spawning banner")
            end
        end 
    end
end

local mini_boss = function()
    local chances = 0.04
    local english_messages = {
        "The air tingles with a looming sense of dread.",
        "Sand seeps into your winds, seeking to tear you asunder.",
        "Bob is here to fix your HP!",
        "A wave of heat washes over you as the wind grows thick with soot."
    }
    local chinese_messages = {
        "空气中震颤着迫近的恐惧感。",
        "流沙渗入伤口，似要将你彻底撕裂。",
        "热浪翻涌而至，狂风裹挟着煤灰扑面而来。"
    }

    -- Check game language
    local language_id = Managers.localizer:language_id()
    local is_chinese = language_id == "zh"
    local message_table = is_chinese and chinese_messages or english_messages

    PRD_mini_boss, pmb = PseudoRandomDistribution.flip_coin(pmb, chances)

    if PRD_mini_boss then
        Managers.state.conflict:start_terror_event("mini_boss_warning")

        -- Randomly select and broadcast message
        local random_message = message_table[math.random(#message_table)]
        mod:chat_broadcast(random_message)

        Managers.state.conflict:start_terror_event("bob_the_builder")
    end
end

-- Spooky special wave
-- This shit is ran every wave i only realized after i did this
mod:hook(HordeSpawner, "horde", function(func, self, horde_type, extra_data, side_id, no_fallback)
    print("horde requested: ", horde_type)

    local level_name = Managers.level_transition_handler:get_current_level_key()
    local persistent_data = mod:persistent_table("horde_spawner")
    persistent_data.bob_counter = persistent_data.bob_counter or 0

    if mutator_plus.active and self.num_paced_hordes then
        if self.num_paced_hordes == 1 then
            persistent_data.bob_counter = 0
        end

        if self.num_paced_hordes >= 4 then  
            special_attack()
            custom_wave_c3()
        end

        if self.num_paced_hordes >= 6 and persistent_data.bob_counter <= 2 then 
            mini_boss()
            persistent_data.bob_counter = persistent_data.bob_counter + 1
        end

        local restricted_levels = {
            mines = true,
            catacombs = true,
            skaven_stronghold = true,
            ground_zero = true,
            dlc_castle = true,
            dlc_bastion = true,
            dlc_termite_3 = true
        }

        if self.num_paced_hordes == 30 then 
            mod:chat_broadcast("2 hordes away from doom.")
        elseif self.num_paced_hordes == 31 then 
            mod:chat_broadcast("Time is ticking.")
        elseif self.num_paced_hordes == 32 and not restricted_levels[level_name] then
            Managers.state.conflict:start_terror_event("eee")
            Managers.state.conflict:start_terror_event("eee_trash")
            self.num_paced_hordes = self.num_paced_hordes + 1
        end
    end
 
    if horde_type == "vector" then
        self:execute_vector_horde(extra_data, side_id, no_fallback)
    elseif horde_type == "vector_blob" then
        self:execute_vector_blob_horde(extra_data, side_id, no_fallback)
    else
        self:execute_ambush_horde(extra_data, side_id, no_fallback)
    end
end)

local prd_direction
if not lb then 
    prd_direction = 0.1
elseif mod.difficulty_level == 1 then 
    prd_direction = 0.05
else
    prd_direction = 0.15
end

-- Both directions, from Spawn Tweaks
mod:hook(HordeSpawner, "find_good_vector_horde_pos", function(func, self, main_target_pos, distance, check_reachable)
    local horde_spawner = Managers.state.conflict.horde_spawner
    local num_paced_hordes = horde_spawner.num_paced_hordes

    PRD_sandwich, sandwhich = PseudoRandomDistribution.flip_coin(sandwhich, prd_direction) -- Flip 15%, every 3rd vector horde or 6th vector wave
    if PRD_sandwich and num_paced_hordes ~= nil then
        conflict_director:start_terror_event("split_wave")

        if is_chinese then 
            mod:chat_broadcast("巨浪裂空而至，欲将你撕成两半。")
        else
            mod:chat_broadcast("The waves part to tear you in two.")
        end

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
    else
        return func(self, main_target_pos, distance, check_reachable)
    end

    return success, o_horde_spawners, o_found_cover_points, epicenter_pos
end)


-- Custom Wave
-------------------------------------------------------------------------
local haz_40 = function(num_to_sv, num_to_white_sv, num_to_monk, num_to_mauler, num_to_bers, num_to_cw, num_to_bestigor) -- sv/monk/mauler/bers/cw/bestigor
    -- so i can be lazy
    local num_to_sv = num_to_sv or 0
    local num_to_white_sv = num_to_white_sv or 0
    local num_to_monk = num_to_monk or 0
    local num_to_mauler = num_to_mauler or 0
    local num_to_bers = num_to_bers or 0
    local num_to_cw = num_to_cw or 0
    local num_to_bestigor = num_to_bestigor or 0

    local spawn_list = {}

    for i = 1, num_to_sv do
        table.insert(spawn_list, "skaven_storm_vermin_commander")
    end

    for i = 1, num_to_white_sv do 
        table.isnert(spawn_list, "skaven_storm_vermin")
    end

    for i = 1, num_to_monk do
        table.insert(spawn_list, "skaven_plague_monk")
    end

    for i = 1, num_to_mauler do
        table.insert(spawn_list, "chaos_raider")
    end

    for i = 1, num_to_bers do
        table.insert(spawn_list, "chaos_berzerker")
    end

    for i = 1, num_to_cw do
        table.insert(spawn_list, "chaos_warrior")
    end

    for i = 1, num_to_bestigor do
        table.insert(spawn_list, "beastmen_bestigor")
    end

    local side = Managers.state.conflict.default_enemy_side_id
    local side_id = side

    Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, true, side_id) -- only spawn front so force players to push back and to avoid speedrunning
end

local haz_40_trash = function(num_to_spawn_enhanced, num_to_spawn) -- trash are x2
    -- so i can be lazy
    local num_to_spawn_enhanced = num_to_spawn_enhanced or 0
    local num_to_spawn = num_to_spawn or 0

    local spawn_list = {}

    for i = 1, num_to_spawn_enhanced do
        table.insert(spawn_list, "skaven_clan_rat")
        table.insert(spawn_list, "chaos_marauder")
    end

    for i = 1, num_to_spawn do
        table.insert(spawn_list, "skaven_slave")
        table.insert(spawn_list, "chaos_fanatic")
    end

    local side = Managers.state.conflict.default_enemy_side_id
    local side_id = side

    Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, true, side_id) -- only spawn front so force players to push back and to avoid speedrunning
end
-------------------------------------------------------------------------