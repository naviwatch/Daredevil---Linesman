local mod = get_mod("Daredevil")

-- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/master/scripts/settings/terror_events/terror_events_dlc_dwarf_whaling.lua

-- First event, 30s speedrun one
TerrorEventBlueprints.dlc_dwarf_whaling.dwarf_disable_pacing = {
    {
        "control_pacing",
        enable = true,
    },
    {
        "control_specials",
        enable = true,
    }
}

--[[
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_burn = {
    {
        "set_master_event_running",
        name = "whaling_whaling",
    },
    {
        "control_pacing",
        enable = false,
    },
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "event_horde",
        composition_type = "mass_trash_chaos",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = {
            "skaven_ratling_gunner",
        },
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_poison_wind_globadier",
            "skaven_gutter_runner",
        },
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
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_whaling",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_chaos_boss_01 = {
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "spawner_manual_shielded_warrior_001",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_chaos_boss_02 = {
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "spawner_manual_shielded_warrior_002",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_chaos_boss_03 = {
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "spawner_manual_shielded_warrior_003",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_mid_fanatics = {
    {
        "enable_bots_in_carry_event",
    },
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "set_master_event_running",
        name = "whaling_mid_fanatics",
    },
    {
        "disable_kick",
    },
    {
        "control_pacing",
        enable = false,
    },
    {
        "event_horde",
        composition_type = "mass_trash_chaos",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = {
            "skaven_ratling_gunner",
        },
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_poison_wind_globadier",
            "skaven_gutter_runner",
        },
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
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_mid_fanatics_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_mid_event_fanatics = {
    {
        "enable_bots_in_carry_event",
    },
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "set_master_event_running",
        name = "whaling_mid_event_fanatics",
    },
    {
        "control_pacing",
        enable = false,
    },
    {
        "event_horde",
        composition_type = "mass_trash_chaos",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = {
            "skaven_ratling_gunner",
        },
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "dn_chaos_elites",
        limit_spawners = 2,
        spawner_id = "whaletoilet",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_poison_wind_globadier",
            "skaven_gutter_runner",
        },
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
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "event_horde",
        composition_type = "dn_chaos_zerkers",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "event_horde",
        composition_type = "dn_ratling_spam",
        limit_spawners = 1,
        spawner_id = "whaling_event_r",
    },
    {
        "delay",
        duration = 10,
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
        composition_type = "event_extra_spice_medium",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
        difficulty_requirement = HARDER,
    },
    {
        "delay",
        duration = 5,
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 1,
        spawner_id = "behindhut",
    },
    {
        "event_horde",
        composition_type = "onslaught_custom_specials_heavy_denial",
        limit_spawners = 2,
        spawner_id = "whaling_event_l",
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 3 and count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_mid_event_fanatics_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_mid_event_specials = {
    {
        "set_master_event_running",
        name = "whaling_mid_event_fanatics",
    },
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "delay",
        duration = 15,
    },
    {
        "flow_event",
        flow_event_name = "whaling_mid_event_specials_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_mid_event_spice_01 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_burn
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_mid_event_spice_02 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_mid_event_spice_01
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_mid_event_spice_03 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_mid_event_spice_01
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_trickle = {
    {
        "enable_bots_in_carry_event",
    },
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "set_master_event_running",
        name = "whaling_end_event",
    },
    {
        "control_pacing",
        enable = false,
    },
    {
        "event_horde",
        composition_type = "event_extra_spice_medium",
        limit_spawners = 8,
        spawner_id = "lighthouse_event",
    },
    {
        "delay",
        duration = 8,
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("chaos_fanatic") < 3 and count_event_breed("chaos_marauder") < 5 and count_event_breed("chaos_raider") < 1 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_end_event_trickle_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_01 = {
    {
        "set_master_event_running",
        name = "whaling_end_event",
    },
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "event_horde",
        composition_type = "event_extra_spice_large",
        spawner_id = "lighthouse_event",
    },
    {
        "continue_when",
        duration = 90,
        condition = function (t)
            return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_end_event_loop_done",
    },
}
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_02 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_01
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_03 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_01
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_04 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_01
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_05 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_01
TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_06 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_loop_01

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_specials_01 = {
    {
        "set_master_event_running",
        name = "whaling_end_event_specials",
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = {
            "skaven_poison_wind_globadier",
            "skaven_warpfire_thrower",
        },
    },
    {
        "delay",
        duration = 5,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_poison_wind_globadier",
            "skaven_ratling_gunner",
        },
        difficulty_requirement = HARDER,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_gutter_runner",
            "skaven_warpfire_thrower",
        },
        difficulty_requirement = CATACLYSM,
    },
    {
        "delay",
        duration = 60,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_poison_wind_globadier",
            "skaven_ratling_gunner",
        },
        difficulty_requirement = HARDER,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_gutter_runner",
            "skaven_warpfire_thrower",
        },
        difficulty_requirement = CATACLYSM,
    },
    {
        "delay",
        duration = 60,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_poison_wind_globadier",
            "skaven_ratling_gunner",
        },
        difficulty_requirement = HARDER,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_gutter_runner",
            "skaven_warpfire_thrower",
        },
        difficulty_requirement = CATACLYSM,
    },
    {
        "delay",
        duration = 60,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_poison_wind_globadier",
            "skaven_ratling_gunner",
        },
        difficulty_requirement = HARDER,
    },
    {
        "spawn_special",
        amount = 2,
        breed_name = {
            "skaven_gutter_runner",
            "skaven_warpfire_thrower",
        },
        difficulty_requirement = CATACLYSM,
    },
    {
        "continue_when",
        duration = 40,
        condition = function (t)
            return count_event_breed("skaven_poison_wind_globadier") < 1 and count_event_breed("skaven_gutter_runner") < 1 and count_event_breed("skaven_ratling_gunner") < 1 and count_event_breed("skaven_warpfire_thrower") < 1
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_end_event_specials_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_specials_02 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_specials_01

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_specials_03 = TerrorEventBlueprints.dlc_dwarf_whaling.whaling_end_event_specials_01

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_lighthouse = {
    {
        "set_master_event_running",
        name = "whaling_end_event",
    },
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "event_horde",
        composition_type = "event_small_chaos",
        limit_spawners = 2,
        spawner_id = "lighthouse_event",
    },
    {
        "delay",
        duration = 10,
    },
    {
        "continue_when",
        duration = 30,
        condition = function (t)
            return count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_lighthouse_restart",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_bulwark_house = {
    {
        "spawn_at_raw",
        breed_name = "chaos_spawn",
        spawner_id = "end_event_house",
        optional_data = {
            max_health_modifier = 0.375
        }
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_burning_window = {
    {
        "enable_bots_in_carry_event",
    },
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "set_master_event_running",
        name = "whaling_burning_windows",
    },
    {
        "disable_kick",
    },
    {
        "control_pacing",
        enable = false,
    },
    {
        "event_horde",
        composition_type = "event_small",
        limit_spawners = 6,
        spawner_id = "burning_window",
    },
    {
        "delay",
        duration = 5,
    },
    {
        "continue_when",
        duration = 20,
        condition = function (t)
            return count_event_breed("skaven_slave") < 6
        end,
    },
    {
        "delay",
        duration = 7,
    },
    {
        "flow_event",
        flow_event_name = "whaling_burning_windows_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_door_guard = {
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "whaling_shield_dude_1",
    },
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "whaling_shield_dude_2",
    },
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "whaling_sword_dude_1",
    },
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "whaling_sword_dude_2",
    },
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "whaling_2h_dude_1",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_sewer_event_a = {
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "set_master_event_running",
        name = "whaling_sewer_event",
    },
    {
        "play_stinger",
        stinger_name = "enemy_horde_chaos_stinger",
    },
    {
        "event_horde",
        composition_type = "chaos_shields",
        limit_spawners = 2,
        spawner_id = "sewer_spawn",
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_event_a_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_sewer_event_b = {
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "set_master_event_running",
        name = "whaling_sewer_event",
    },
    {
        "play_stinger",
        stinger_name = "enemy_horde_chaos_stinger",
    },
    {
        "event_horde",
        composition_type = "event_small_chaos",
        limit_spawners = 2,
        spawner_id = "sewer_spawn",
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_event_b_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_sewer_event_c = {
    {
        "set_freeze_condition",
        max_active_enemies = 100,
    },
    {
        "set_master_event_running",
        name = "whaling_sewer_event",
    },
    {
        "play_stinger",
        stinger_name = "enemy_horde_chaos_stinger",
    },
    {
        "event_horde",
        composition_type = "chaos_berzerkers_small",
        limit_spawners = 2,
        spawner_id = "sewer_spawn",
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_event_c_done",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_rat_ogre = {
    {
        "set_master_event_running",
        name = "whaling_boss_sewer",
    },
    {
        "spawn_at_raw",
        spawner_id = "whaling_boss_spawn_sewer",
        breed_name = {
            "skaven_rat_ogre",
            "skaven_stormfiend",
            "chaos_troll",
            "chaos_spawn",
        },
    },
    {
        "delay",
        duration = 1,
    },
    {
        "continue_when",
        condition = function (t)
            return count_event_breed("skaven_rat_ogre") == 1 or count_event_breed("skaven_stormfiend") == 1 or count_event_breed("chaos_troll") == 1 or count_event_breed("chaos_spawn") == 1
        end,
    },
    {
        "delay",
        duration = 1,
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_boss_spawned",
    },
    {
        "continue_when",
        condition = function (t)
            return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_stormfiend") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_boss_dead",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_storm_fiend = {
    {
        "set_master_event_running",
        name = "whaling_boss_sewer",
    },
    {
        "spawn_at_raw",
        breed_name = "skaven_stormfiend",
        spawner_id = "whaling_boss_spawn_sewer",
    },
    {
        "delay",
        duration = 1,
    },
    {
        "continue_when",
        condition = function (t)
            return count_event_breed("skaven_stormfiend") == 1
        end,
    },
    {
        "delay",
        duration = 1,
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_boss_spawned",
    },
    {
        "continue_when",
        condition = function (t)
            return count_event_breed("skaven_stormfiend") < 1
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_boss_dead",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_chaos_troll = {
    {
        "set_master_event_running",
        name = "whaling_boss_sewer",
    },
    {
        "spawn_at_raw",
        breed_name = "chaos_troll",
        spawner_id = "whaling_boss_spawn_sewer",
    },
    {
        "delay",
        duration = 1,
    },
    {
        "continue_when",
        condition = function (t)
            return count_event_breed("chaos_troll") == 1
        end,
    },
    {
        "delay",
        duration = 1,
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_boss_spawned",
    },
    {
        "continue_when",
        condition = function (t)
            return count_event_breed("chaos_troll") < 1
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_boss_dead",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_chaos_spawn = {
    {
        "set_master_event_running",
        name = "whaling_boss_sewer",
    },
    {
        "spawn_at_raw",
        breed_name = "chaos_spawn",
        spawner_id = "whaling_boss_spawn_sewer",
    },
    {
        "delay",
        duration = 1,
    },
    {
        "continue_when",
        condition = function (t)
            return count_event_breed("chaos_spawn") == 1
        end,
    },
    {
        "delay",
        duration = 1,
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_boss_spawned",
    },
    {
        "continue_when",
        condition = function (t)
            return count_event_breed("chaos_spawn") < 1
        end,
    },
    {
        "flow_event",
        flow_event_name = "whaling_sewer_boss_dead",
    },
}

TerrorEventBlueprints.dlc_dwarf_whaling.whaling_bulwark_endslope = {
    {
        "spawn_at_raw",
        breed_name = "chaos_spawn",
        spawner_id = "bulwark_end_1",
        optional_data = {
            max_health_modifier = 0.125
        }
    },
    {
        "spawn_at_raw",
        breed_name = "chaos_troll",
        spawner_id = "bulwark_end_2",
        optional_data = {
            max_health_modifier = 0.125
        }
    },
    {
        "spawn_at_raw",
        breed_name = "chaos_warrior",
        spawner_id = "bulwark_end_3",
        optional_data = {
            max_health_modifier = 0.125
        }
    },
}

]]