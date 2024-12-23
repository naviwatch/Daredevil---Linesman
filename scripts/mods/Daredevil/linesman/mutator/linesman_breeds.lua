local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict

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

-- Bestigor changes
local stagger_types = require("scripts/utils/stagger_types")
Breeds.beastmen_bestigor.height = 1.5

-- Stamina shields
PlayerUnitStatusSettings.fatigue_point_costs.blocked_charge = 16         -- 28 wtf
PlayerUnitStatusSettings.fatigue_point_costs.shield_bestigor_charge = 6  -- 16

-- Charge stuff
BreedActions.beastmen_bestigor.charge_attack.action_weight = 8                -- 8
BreedActions.beastmen_bestigor.charge_attack.push_ai.stagger_distance = 1.25  -- 1.5
BreedActions.beastmen_bestigor.charge_attack.push_ai.stagger_impact = {
    stagger_types.medium,                                                     -- explosion
    stagger_types.medium,                                                     -- explosion
    stagger_types.none,
    stagger_types.none,
    stagger_types.medium, -- explosion
}
BreedActions.beastmen_bestigor.charge_attack.push_ai.stagger_duration = {
    0.5, -- 3
    0.5, -- 1
    0,
    0,
    0.5,                                                                      -- 4
}
BreedActions.beastmen_bestigor.charge_attack.player_push_speed = 7            -- 9.5
BreedActions.beastmen_bestigor.charge_attack.player_push_speed_blocked = 5.5  -- 10

-- Suicide rat
BreedActions.skaven_explosive_loot_rat.explosion_attack.radius = 0.45

mod:hook(DeathReactions.templates.explosive_loot_rat.unit, "start",
    function(func, self, unit, context, t, killng_blow, is_server)
        if mutator_plus.active then
            local chance_to_spawn_ammmo = 0

            if chance_to_spawn_ammmo >= math.random() then
                local pickup_name = "all_ammo_small"
                local pickup_settings = AllPickups[pickup_name]
                local extension_init_data = {
                    pickup_system = {
                        has_physics = false,
                        spawn_type = "loot",
                        pickup_name = pickup_name,
                    },
                }
                local unit_name = pickup_settings.unit_name
                local unit_template_name = pickup_settings.unit_template_name or "pickup_unit"
                local position = POSITION_LOOKUP[unit]
                local rotation = Quaternion.identity()

                Managers.state.unit_spawner:spawn_network_unit(unit_name, unit_template_name, extension_init_data,
                    position, rotation)
            end
            return func(self, unit, context, t, killing_blow, is_server)
        else
            return func(self, unit, context, t, killing_blow, is_server)
        end
    end)

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
    near_vomit_distance = 120
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

Breeds.skaven_dummy_slave.size_variation_range = { 1.8, 1.8 }

-- Beastmen armor changes
Breeds.beastmen_standard_bearer.hitzone_primary_armor_categories = { head = 3, neck = 3 }

    -- Beastmen banner ranged killable
    mod:hook_origin(BeastmenStandardHealthExtension, "add_damage", function (self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
        if mutator_plus.active then
            if damage_source_name == "suicide" then
                BeastmenStandardHealthExtension.super.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
            else
                BeastmenStandardHealthExtension.super.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)

                local standard_extension = ScriptUnit.has_extension(self._unit, "ai_supplementary_system")
                local standard_template = standard_extension.standard_template

                if standard_template then
                    local sfx_taking_damage = standard_template.sfx_taking_damage

                    WwiseUtils.trigger_unit_event(standard_extension.world, sfx_taking_damage, self._unit, 0)
                end
            end
        else
            if damage_source_name == "suicide" then
                BeastmenStandardHealthExtension.super.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
            else
                local can_damage_banner = false
        
                can_damage_banner = attack_type and (attack_type == "heavy_attack" or attack_type == "light_attack") or white_listed_damage_sources[damage_source_name]
        
                if can_damage_banner then
                    BeastmenStandardHealthExtension.super.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, hit_position, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike, added_dot, first_hit, total_hits, attack_type)
        
                    local standard_extension = ScriptUnit.has_extension(self._unit, "ai_supplementary_system")
                    local standard_template = standard_extension.standard_template
        
                    if standard_template then
                        local sfx_taking_damage = standard_template.sfx_taking_damage
        
                        WwiseUtils.trigger_unit_event(standard_extension.world, sfx_taking_damage, self._unit, 0)
                    end
                end
            end
        end
    end)

    -- Banner no explosion
    mod:hook(BeastmenStandardExtension, "on_death", function(func, self, killer_unit)
        if Unit.alive(killer_unit) and killer_unit ~= self.unit then
            Unit.flow_event(self.unit, "destroy")

            if self.is_server then
                Managers.state.entity:system("surrounding_aware_system"):add_system_event(self.unit, "standard_bearer_buff_deactivated", DialogueSettings.special_proximity_distance_heard)
            end
        else
            local vfx_picked_up_standard = self.standard_template.vfx_picked_up_standard

            World.create_particles(self.world, vfx_picked_up_standard, self.self_position_boxed:unbox())
            Unit.flow_event(self.unit, "picked_up")
        end

        return func(self, killer)
    end)

    DamageProfileTemplates.standard_bearer_explosion_lines = {
		charge_value = "grenade",
		is_explosion = true,
		no_damage = true,
		stagger_duration_modifier = 0.1,
		armor_modifier = {
			attack = {
				1,
				0.5,
				1,
				1,
				1,
			},
			impact = {
				1,
				0.5,
				100,
				1,
				1,
			},
		},
		default_target = {
			attack_template = "basic_sweep_push",
			damage_type = "push",
			power_distribution = {
				attack = 0,
				impact = 0,
			},
		},
	}

    ExplosionTemplates.standard_bearer_explosion.explosion.damage_profile = "standard_bearer_explosion_lines"
    ExplosionTemplates.standard_bearer_explosion.explosion.catapult_players = false
    ExplosionTemplates.standard_bearer_explosion.explosion.player_push_speed = 4.25

    -- Some stuff for spawning

    local cm = Managers.state.conflict
    local director = tostring(cm.current_conflict_settings)

        local spawn_trash_wave = function()
            local num_to_spawn_enhanced = 8
            local num_to_spawn = 5
            local spawn_list = {}

            -- PRD_trash, trash = PseudoRandomDistribution.flip_coin(trash, 0.5) -- Flip 50%
                for i = 1, num_to_spawn_enhanced do
                    table.insert(spawn_list, "skaven_clan_rat")
                end
        
                for i = 1, num_to_spawn do
                    table.insert(spawn_list, "skaven_slave")
                end

                for i = 1, 4 do
                    table.insert(spawn_list, "skaven_storm_vermin")
                    table.insert(spawn_list, "skaven_plague_monk")
                    table.insert(spawn_list, "chaos_raider")
                    table.insert(spawn_list, "chaos_berzerker")
                end

                for i = 1, num_to_spawn_enhanced do
                    table.insert(spawn_list, "chaos_marauder")
                end
        
                for i = 1, num_to_spawn do
                    table.insert(spawn_list, "chaos_fanatic")
                end

            local side = Managers.state.conflict.default_enemy_side_id
            local side_id = side

            Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, true, side_id)
        end

    local spawn_skaven_elites = function()
        local spawn_list = {
            "skaven_plague_monk",
            "skaven_storm_vermin",
            "skaven_plague_monk",
            "skaven_storm_vermin",
            "skaven_plague_monk",
            "skaven_storm_vermin"
        }
        local side = Managers.state.conflict.default_enemy_side_id
        local side_id = side

        Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, true, side_id)
    end

    local spawn_chaos_elites = function()
        local spawn_list = {
            "chaos_raider",
            "chaos_warrior",
            "chaos_berzerker",
            "chaos_raider",
            "chaos_warrior",
            "chaos_berzerker",
        }
        local side = Managers.state.conflict.default_enemy_side_id
        local side_id = side

        Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, true, side_id)
    end


    local spawn_trash_wave = function()
        local num_to_spawn_enhanced = 8
        local num_to_spawn = 5
        local elite 
        local spawn_list = {}

        -- PRD_trash, trash = PseudoRandomDistribution.flip_coin(trash, 0.5) -- Flip 50%
            for i = 1, num_to_spawn_enhanced do
                table.insert(spawn_list, "skaven_clan_rat")
                table.insert(spawn_list, "chaos_marauder")
            end
    
            for i = 1, num_to_spawn do
                table.insert(spawn_list, "skaven_slave")
                table.insert(spawn_list, "chaos_fanatic")
            end 

            if not lb then 
                elite = 2
            else
                elite = 3
            end

            for i = 1, elite do
                table.insert(spawn_list, "skaven_storm_vermin")
                table.insert(spawn_list, "skaven_plague_monk")
                table.insert(spawn_list, "chaos_raider")
                table.insert(spawn_list, "chaos_berzerker")
            end

        local side = Managers.state.conflict.default_enemy_side_id
        local side_id = side

        Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, true, side_id)
    end

    -- Spawn wave
    mod:hook(BeastmenStandardExtension, "update", function(func, self, unit, input, dt, context, t)
        if self.dead then
            return
        end

        local standard_template = self.standard_template

        if self.is_server and standard_template.apply_buff_to_ai and t >= self.next_apply_buff_t then

            spawn_trash_wave()

            self.next_apply_buff_t = t + math.huge
        end
    end)

    -- Banner buddies
    BreedTweaks.standard_bearer_spawn_list = {
        easy = {

        },
        normal = {

        },
        hard = {

        },
        harder = {

        },
        hardest = {

        },
        cataclysm = {

        },
        cataclysm_2 = {

        },
        cataclysm_3 = {

        },
        versus_base = {
        }
    }
    BreedTweaks.standard_bearer_spawn_list_replacements = {
    }

    -- Banner range to plant 
    UtilityConsiderations.beastmen_place_standard_lines = {
        has_line_of_sight = {
            blackboard_input = "has_line_of_sight",
            is_condition = true,
        },
        distance_to_target = {
            blackboard_input = "target_dist",
            max_value = 6.5,
            spline = {
                0,
                0,
                0.2,
                1,
                0.5,
                1,
                0.7,
                0,
            },
        },
        has_not_placed_standard = {
            blackboard_input = "has_placed_standard",
            invert = true,
            is_condition = true,
        },
        has_valid_astar_path = {
            blackboard_input = "has_valid_astar_path",
            is_condition = true,
        },
    }
    BreedActions.beastmen_standard_bearer.place_standard.considerations = UtilityConsiderations.beastmen_place_standard_lines
    BeastmenStandardTemplates.healing_standard.radius = 3

