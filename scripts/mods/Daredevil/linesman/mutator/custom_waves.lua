local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict
local horde_spawner = Managers.state.conflict.horde_spawner
local num_paced_hordes = horde_spawner.num_paced_hordes

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

GenericTerrorEvents.skaven_denial = {
    {
        "spawn_special",
        amount = 2,
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
        amount = 2,
        breed_name = "skaven_ratling_gunner",
        optional_data = {
            target_selection = "healthy_players"
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
        duration = 2
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
        duration = 2
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
        duration = 2
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
        duration = 2
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
            max_health_modifier = 6
        }
    }
}

GenericTerrorEvents.bob_the_builder = {
    {
        "spawn_special",
        breed_name = "skaven_dummy_clan_rat",
        optional_data = {
            max_health_modifier = 9,
            size_variation_range = { 2, 2 },
        --    spawned_func = AiUtils.magic_entrance_optional_spawned_func,
            enhancements = bob_pacing,
            target_selection = "least_healthy_player"
        }
    }
}

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

-- Special wave 1: Skaven denial-focused (gas/ratling/fire)
-- Special wave 2: Skaven mix (gas/ratling/assassin or hook)
-- Special wave 3: Chaos denial-focused (blight/ratling)
-- Spooky wave

--[[ Code explained for those who don't know how to read it
  The first coin flip simulates a 10% chance.
  a/ If the first event (PRD_special_attack) occurs, it triggers the coordinated strike:
    - Starts the SFX for warning
    - Broadcasts "Coordinated Attack!"
    - Then, based on another 50% coin flip (PRD_mix), it spawns different comps (three atm)
        a/ If PRD_mix is true, it starts a terror event named "skaven_mix".
        b/ If PRD_mix is false, it further flips a 50% coin for PRD_denial.
            a/ If PRD_denial is true, it starts a terror event named "skaven_denial".
            b/ If PRD_denial is false, it starts a terror event named "chaos_denial".
  b/ If the first event doesn't occur, simply end the function.

All of this is to make sure that all three waves are evenly distributed and spawned, fuck me
]]

local sa_chances = 0.1

local special_attack = function()
    PRD_special_attack, state = PseudoRandomDistribution.flip_coin(state, sa_chances)
    if PRD_special_attack then
        conflict_director:start_terror_event("special_coordinated")

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
                    conflict_director:start_terror_event("skaven_mix")
                end

            else
                PRD_die, die = PseudoRandomDistribution.flip_coin(die, 0.5)

                if PRD_die then
                    conflict_director:start_terror_event("skaven_spam")
                else
                    PRD_denial, denial = PseudoRandomDistribution.flip_coin(denial, 0.5) -- Flip 50%

                    if PRD_denial then
                        conflict_director:start_terror_event("skaven_denial")
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
    local chances = 0.05

    PRD_mini_boss, pmb = PseudoRandomDistribution.flip_coin(pmb, chances)

    if PRD_mini_boss then
        
        Managers.state.conflict:start_terror_event("mini_boss_warning")

        PRD_bob_or_ogre, boo = PseudoRandomDistribution.flip_coin(boo, 1)

        if PRD_bob_or_ogre then 
            mod:chat_broadcast("The air tingles with a looming sense of dread.")

            Managers.state.conflict:start_terror_event("bob_the_builder")
        end
    end
end

-- Spooky special wave
-- This shit is ran every wave i only realized after i did this
mod:hook(HordeSpawner, "horde", function(func, self, horde_type, extra_data, side_id, no_fallback)
    print("horde requested: ", horde_type)

    local horde_spawner = Managers.state.conflict.horde_spawner
    local num_paced_hordes = horde_spawner.num_paced_hordes

    if mutator_plus.active and num_paced_hordes ~= nil then
        if num_paced_hordes >= 3 then  
            special_attack()
            custom_wave_c3()
        end

        if num_paced_hordes >= 6 then 
            mini_boss()
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
    prd_direction = 0.15
elseif mod.difficulty_level == 1 then 
    prd_direction = 0.05
else
    prd_direction = 0.1
end

-- Both directions, from Spawn Tweaks
mod:hook(HordeSpawner, "find_good_vector_horde_pos", function(func, self, main_target_pos, distance, check_reachable)
    local horde_spawner = Managers.state.conflict.horde_spawner
    local num_paced_hordes = horde_spawner.num_paced_hordes

    PRD_sandwich, sandwhich = PseudoRandomDistribution.flip_coin(sandwhich, prd_direction) -- Flip 15%, every 3rd vector horde or 6th vector wave
    if PRD_sandwich and num_paced_hordes ~= nil then
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
    else
        return func(self, main_target_pos, distance, check_reachable)
    end

    return success, o_horde_spawners, o_found_cover_points, epicenter_pos
end)