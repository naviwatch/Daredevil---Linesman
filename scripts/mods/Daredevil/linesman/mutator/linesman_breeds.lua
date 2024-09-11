local mod = get_mod("Daredevil")

local stagger_types = require("scripts/utils/stagger_types")

-- White SV
Breeds.skaven_storm_vermin.bloodlust_health = BreedTweaks.bloodlust_health.beastmen_elite
Breeds.skaven_storm_vermin.primary_armor_category = 6
Breeds.skaven_storm_vermin.size_variation_range = { 1.2, 1.2 }
Breeds.skaven_storm_vermin.max_health = BreedTweaks.max_health.bestigor
Breeds.skaven_storm_vermin.hit_mass_counts = BreedTweaks.hit_mass_counts.bestigor
UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.min = 30
UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.max = 31
UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.min = 1
UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.max = 1

-- Big Ratling
mod.deepcopy = function(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[mod.deepcopy(orig_key, copies)] = mod.deepcopy(orig_value, copies)
            end
            setmetatable(copy, mod.deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

Breeds.skaven_dummy_clan_rat = mod.deepcopy(Breeds.skaven_ratling_gunner)
Breeds.skaven_dummy_clan_rat.size_variation_range = { 3, 3 }
Breeds.skaven_dummy_clan_rat.walk_speed = 12
Breeds.skaven_dummy_clan_rat.run_speed = 12
Breeds.skaven_dummy_clan_rat.boss = true -- No WHC/Shade cheese fight this big man fair and square
BreedActions.skaven_dummy_clan_rat.wind_up_ratling_gun = {
    wind_up_time = {
        0.5, -- 2
        0.7  -- 2
    }
}
BreedActions.skaven_dummy_clan_rat.shoot_ratling_gun = {
    fire_rate_at_end = 30, -- 25
    fire_rate_at_start = 15, -- 10
    attack_time = {
        10, -- 7
        12, -- 10
    },
}

GrudgeMarkedNames.skaven = { "Bob the Builder" }

Breeds.skaven_dummy_slave = mod.deepcopy(Breeds.chaos_troll)
Breeds.skaven_dummy_slave.height = 4.35
Breeds.skaven_dummy_slave.size_variation_range = { 1.45, 1.45 }
Breeds.skaven_dummy_slave.regen_pulse_interval = 10 -- 10s per regen
Breeds.skaven_dummy_slave.regen_taken_damage_pause_time = 20 -- 20s delay until regen kicks in
BreedActions.skaven_dummy_slave.vomit = {
    near_vomit_distance = 100
}

BreedActions.skaven_dummy_slave.attack_cleave = {
    attacks = {
        {
            height = 3.75, -- 2.5
            hit_multiple_targets = true,
            ignores_dodging = true,
            offset_forward = 1.1,
            offset_up = 0,
            player_push_speed = 8, -- 8
            player_push_speed_blocked = 8, -- 8
            range = 4.125, -- 2.75
            rotation_time = 1.7, -- 1.7
            width = 2.625, -- 1.75
        }
    },
    running_attacks = {
        {
            height = 3.75, -- 2.5
            range = 4.125,
            width = 2.625,
        },
    }
}
BreedActions.skaven_dummy_slave.attack_crouch_sweep = {
        attacks = {
        {
            height = 3,
            range = 3,
            rotation_time = 1,
            width = 0.6,
        },
    }
}

BreedActions.skaven_dummy_slave.melee_shove = {
    attacks = {
        {
            height = 1.2, -- 0.8
            hit_multiple_targets = true,
            hit_only_players = false,
            ignore_targets_behind = true,
            ignores_dodging = false,
            offset_forward = 0.5,
            offset_up = 0.5,
            range = 1.05, -- 0.7
            rotation_speed = 7,
            rotation_time = 0.6,
            width = 1.2, -- 0.8
            push_ai = {
                stagger_distance = 6,
                stagger_impact = {
                    stagger_types.explosion,
                    stagger_types.heavy,
                    stagger_types.none,
                    stagger_types.none,
                },
                stagger_duration = {
                    4.5,
                    1,
                    0,
                    0,
                },
            },
        },
    },
    running_attacks = {
        {
            height = 1.35, -- 0.9
            hit_multiple_targets = true,
            hit_only_players = false,
            ignore_targets_behind = true,
            ignores_dodging = false,
            offset_forward = 1.2,
            offset_up = 0.5,
            range = 1.05, -- 0.7
            rotation_speed = 7,
            rotation_time = 1,
            width = 1.65, -- 1.1
            push_ai = {
                stagger_distance = 6,
                stagger_impact = {
                    stagger_types.explosion,
                    stagger_types.heavy,
                    stagger_types.none,
                    stagger_types.none,
                },
                stagger_duration = {
                    4.5,
                    1,
                    0,
                    0,
                },
            },
            bot_threat_difficulty_data = default_bot_threat_difficulty_data,
            bot_threats = {
                {
                    collision_type = "cylinder",
                    duration = 0.9333333333333333,
                    height = 3.7,
                    offset_forward = 2,
                    offset_right = 0,
                    offset_up = 0,
                    radius = 3,
                    start_time = 0.16666666666666666,
                },
            },
        },
    },
}

BreedActions.skaven_dummy_slave.melee_sweep = {
    attacks = {
        {
            height = 1.2, -- 0.8
            hit_multiple_targets = true,
            hit_only_players = false,
            ignore_targets_behind = true,
            ignores_dodging = true,
            offset_forward = 1,
            offset_up = 0.5,
            range = 1.2, -- 0.8
            rotation_speed = 7,
            rotation_time = 0.6,
            width = 1.65, -- 1.1
            push_ai = {
                stagger_distance = 6,
                stagger_impact = {
                    stagger_types.explosion,
                    stagger_types.heavy,
                    stagger_types.none,
                    stagger_types.none,
                },
                stagger_duration = {
                    4.5,
                    1,
                    0,
                    0,
                },
            },
        },
    },
    running_attacks = {
        {
            height = 1.35, -- 0.9
            hit_multiple_targets = true,
            hit_only_players = false,
            ignore_targets_behind = true,
            ignores_dodging = false,
            offset_forward = 1.8,
            offset_up = 0.3,
            range = 1.5, -- 1
            rotation_speed = 12,
            rotation_time = 1,
            width = 2.1, -- 1.4
            push_ai = {
                stagger_distance = 3,
                stagger_impact = {
                    stagger_types.explosion,
                    stagger_types.heavy,
                    stagger_types.none,
                    stagger_types.none,
                },
                stagger_duration = {
                    4.5,
                    1,
                    0,
                    0,
                },
            },
        },
    },
}



BreedActions.skaven_dummy_slave.downed = {
    become_downed_hp_percent = 0, -- 0.4
    downed_duration = 1, -- 7
    min_downed_duration = 1, -- 3
    reduce_hp_permanently = true,
    reset_duration = 900,
    respawn_hp_max_percent = 0,
    respawn_hp_min_percent = 0,
    standup_anim_duration = 5,
}

Breeds.skaven_dummy_slave.size_variation_range = { 1.6, 1.6 }
