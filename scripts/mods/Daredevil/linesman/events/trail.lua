local mod = get_mod("Daredevil")

local function count_event_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
end

local function num_spawned_enemies()
	local spawned_enemies = Managers.state.conflict:spawned_enemies()

	return #spawned_enemies
end

local function spawned_during_event()
	return Managers.state.conflict:enemies_spawned_during_event()
end
	-----------------
	--Trail of Treachery
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_disable_pacing_mid = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.dlc_wizards_trail.trail_disable_pacing_light = {
		{
			"control_specials",
			enable = true
		},
		{
			"control_pacing",
			enable = true
		}
	}
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_drawbridge_wallbreaker = {
	{
		"spawn_at_raw",
		spawner_id = "drawbridge_wall_breaker_01",
		amount = 1,
		breed_name = {
			"skaven_ratling_gunner",
			"skaven_warpfire_thrower",
			"skaven_poison_wind_globadier"
		}
	},
	{
		"spawn_at_raw",
		spawner_id = "drawbridge_wall_breaker_01",
		amount = 3,
		breed_name = {
			"skaven_ratling_gunner"
		}
	},
	{
		"event_horde",
		spawner_id = "drawbridge_wall_breaker_01",
		composition_type = "dn_skaven_pursuit"
	},
	{
		"delay",
		duration = 3
	},
	{
		"spawn_at_raw",
		spawner_id = "drawbridge_wall_breaker_02",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_warpfire_thrower",
			"skaven_pack_master"
		}
	},
	{
		"spawn_at_raw",
		spawner_id = "drawbridge_wall_breaker_02",
		amount = 3,
		breed_name = {
			"skaven_ratling_gunner"
		}
	},
	{
		"event_horde",
		spawner_id = "drawbridge_wall_breaker_02",
		composition_type = "event_small"
	}
}

TerrorEventBlueprints.dlc_wizards_trail.trail_mid_event_01 = {
	{
		"set_master_event_running",
		name = "trail_mid_event_01"
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
		"control_pacing",
		enable = false
	},
	{
		"event_horde",
		spawner_id = "trail_mid_event_spawn_01",
		composition_type = "event_extra_spice_medium"
	},
	{
		"spawn_special",
		amount = 3,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_ratling_gunner",
			"skaven_warpfire_thrower"
		}
	},
	{
		"delay",
		duration = 5
	},
	{
		"spawn_special",
		amount = 2,
		breed_name = {
			"skaven_ratling_gunner",
			"skaven_gutter_runner"
		}
	},
	{
		"delay",
		duration = 5
	},
	{
		"spawn_at_raw",
		spawner_id = "trail_mid_event_04_boss",
		breed_name = "skaven_dummy_clan_rat",
		optional_data = {
			enhancements = enhancement_7,
			max_health_modifier = 15
		}
	},
	{
		"delay",
		duration = 3
	},
	{
		"spawn_at_raw",
		spawner_id = "trail_mid_event_02",
		breed_name = "skaven_rat_ogre",
		optional_data = {
			max_health_modifier = 0.5
		}
	},
	{
		"continue_when",
		duration = 45,
		condition = function (t)
			return num_spawned_enemies() < 15
		end
	},
	{
		"event_horde",
		limit_spawners = 6,
		spawner_id = "trail_mid_event_spawn_02",
		composition_type = "event_extra_spice_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		breed_name = {
			"chaos_corruptor_sorcerer",
			"chaos_vortex_sorcerer",
			"skaven_gutter_runner"
		}
	},
	{
		"delay",
		duration = 15
	},
	{
		"event_horde",
		spawner_id = "trail_mid_event_spawn_02",
		composition_type = "plague_monks_medium"
	},
	{
		"spawn_special",
		amount = 3,
		breed_name = {
			"skaven_pack_master",
			"skaven_gutter_runner",
			"skaven_warpfire_thrower",
			"skaven_ratling_gunner"
		}
	},
	{
		"event_horde",
		limit_spawners = 6,
		spawner_id = "trail_mid_event_spawn_02",
		composition_type = "plague_monks_medium"
	},
	{
		"delay",
		duration = 5
	},
	{
		"spawn_at_raw",
		spawner_id = "trail_mid_event_02",
		breed_name = {
			"skaven_ratling_gunner",
			"skaven_poison_wind_globadier",
			"skaven_warpfire_thrower",
			"skaven_pack_master"
		},
		difficulty_amount = {
			hardest = 2,
			hard = 2,
			harder = 2,
			cataclysm = 2,
			normal = 2
		}
	},
	{
		"event_horde",
		spawner_id = "trail_mid_event_spawn_02",
		composition_type = "plague_monks_medium"
	},
	{
		"spawn_at_raw",
		spawner_id = "trail_mid_event_02",
		breed_name = "onslaught_custom_boss_random",
		optional_data = {
			max_health_modifier = 0.5
		}
	},
	{
		"delay",
		duration = 50
	},
	{
		"spawn_at_raw",
		spawner_id = "trail_mid_event_02",
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"event_horde",
		limit_spawners = 4,
		spawner_id = "trail_mid_event_spawn_roof",
		composition_type = "event_small"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 2,
		breed_name = {
			"skaven_pack_master",
			"skaven_gutter_runner",
			"skaven_warpfire_thrower",
			"skaven_ratling_gunner"
		}
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_pack_master",
			"skaven_poison_wind_globadier"
		}
	},
	{
		"spawn_special",
		amount = 2,
		breed_name = {
			"chaos_corruptor_sorcerer",
			"chaos_vortex_sorcerer",
			"skaven_pack_master",
			"skaven_gutter_runner"
		}
	},
	{
		"delay",
		duration = 10
	},
	{
		"disable_bots_in_carry_event"
	},
	{
		"continue_when",
		duration = 40,
		condition = function (t)
			return num_spawned_enemies() < 8
		end
	},
	{
		"control_pacing",
		enable = true
	},
	{
		"flow_event",
		flow_event_name = "trail_mid_event_01_done"
	}
}
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_mid_event_04 = table.clone(TerrorEventBlueprints.dlc_wizards_trail.trail_mid_event_01)
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_intro_disable_pacing_end = {
		{
			"control_hordes",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"control_pacing",
			enable = true
		}
	}
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_end_event_first_wave = {
		{
			"set_master_event_running",
			name = "trail_end_event_first_wave"
		},
		{
			"disable_kick"
		},
		{
			"enable_bots_in_carry_event"
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
			"control_specials",
			enable = true
		},
		{
			"control_hordes",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "trail_end_event_first_wave",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_first_wave",
			composition_type = "dn_chaos_elites"
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_first_wave",
			composition_type = "dn_chaos_elites"
		},
		{
			"delay",
			duration = 40
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_first_wave",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"chaos_vortex_sorcerer",
			}
		},
		{
			"spawn_special",
			amount = 3,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"continue_when",
			duration = 35,
			condition = function (t)
				return num_spawned_enemies() < 20
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "trail_end_event_first_wave",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 21
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "trail_end_event_first_wave",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 180
		},
		{
			"spawn_at_raw",
			spawner_id = "trail_end_event_boss",
			breed_name = {
				"skaven_rat_ogre"
			},
			optional_data = {
				max_health_modifier = 5/64
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "trail_end_event_boss",
			breed_name = {
				"chaos_spawn"
			},
			optional_data = {
				max_health_modifier = 5/64
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "trail_end_event_boss",
			breed_name = {
				"beastmen_minotaur"
			},
			optional_data = {
				max_health_modifier = 5/64
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "trail_end_event_boss",
			breed_name = {
				"skaven_stormfiend"
			},
			optional_data = {
				max_health_modifier = 0.25
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "trail_end_event_boss",
			breed_name = {
				"chaos_troll"
			},
			optional_data = {
				max_health_modifier = 5/64
			}
		},
		{
			"continue_when",
			condition = function (t)
				return num_spawned_enemies() < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "trail_end_event_first_wave_done"
		}
	}
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_end_event_constant = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 30
		},
		{
			"set_master_event_running",
			name = "trail_end_event_constant"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "trail_end_event_spawner_under_water",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = {
				"chaos_vortex_sorcerer",
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_pack_master"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "trail_end_event_constant_done"
		}
	}
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_end_event_torch_hunter = {
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"chaos_vortex_sorcerer",
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer",
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		}
	}
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_end_event_01 = {
		{
			"set_master_event_running",
			name = "trail_end_event_01"
		},
		{
			"disable_kick"
		},
		{
			"enable_bots_in_carry_event"
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
			spawner_id = "trail_end_event_spawner_1",
			composition_type = "chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_4",
			composition_type = "chaos_berzerkers_medium"
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = {
				"chaos_corruptor_sorcerer",
			}
		},
		{
			"delay",
			duration = 15
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_2",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_2",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 18
			end
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"chaos_vortex_sorcerer",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_under_water",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 18
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "trail_end_event_spawner_under_water",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "trail_end_event_spawner_under_water",
			composition_type = "chaos_berzerkers_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_4",
			composition_type = "chaos_berzerkers_small"
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_4",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 18 and count_event_breed("chaos_warrior") < 3
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_1",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_2",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_4",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_1",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_2",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_4",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_1",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_2",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "trail_end_event_spawner_4",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 30 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "trail_end_event_01_done"
		}
	}
	
	TerrorEventBlueprints.dlc_wizards_trail.trail_end_event_03 = table.clone(TerrorEventBlueprints.dlc_wizards_trail.trail_end_event_01)

