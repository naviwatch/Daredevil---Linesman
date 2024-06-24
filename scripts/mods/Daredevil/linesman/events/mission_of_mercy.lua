local mod = get_mod("Daredevil")

local function count_event_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
end

local function num_spawned_enemies()
	local spawned_enemies = Managers.state.conflict:spawned_enemies()

	return #spawned_enemies
end

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_disable_pacing = {
		{
			"control_pacing",
			enable = true
		},
		{
			"control_hordes",
			enable = false
		},
		{
			"control_specials",
			enable = true
		}
	}
	
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_enable_pacing = {
		{
			"control_pacing",
			enable = true
		},
		{
			"control_hordes",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_bell_alert_02 = {
		{
			"set_master_event_running",
			name = "dwarf_interior_bell_alert"
		},
		{
			"delay",
			duration = 4
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower",
				"skaven_pack_master",
				"skaven_ratling_gunner"
			}
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower",
				"skaven_pack_master",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_bell_alert_done"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_bell_alert_01 = TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_bell_alert_02
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_bell_alert_03 = TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_bell_alert_02

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_bell_alert_04_dummy = {
		{
			"set_master_event_running",
			name = "dwarf_interior_bell_alert"
		},
		{
			"delay",
			duration = 10
		}
	}

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_bell_alert_05_construction = {
		{
			"set_master_event_running",
			name = "dwarf_interior_bell_alert"
		},
		{
			"delay",
			duration = 10
		}
	}

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_bell_alert_06_chasm = {
		{
			"set_master_event_running",
			name = "dwarf_interior_bell_alert"
		},
		{
			"spawn_at_raw",
			spawner_id = "bell_event_chasm_boss",
			amount = 1,
			breed_name = {
				"skaven_rat_ogre",
				"skaven_stormfiend",
				"chaos_spawn",
				"chaos_troll",
				"beastmen_minotaur"
			}
		},
		{
			"delay",
			duration = 10
		}
	}

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_01 = {
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_static_guard_spawner_01",
			breed_name = "skaven_storm_vermin"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_static_guard_spawner_02",
			breed_name = "chaos_warrior"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_static_guard_spawner_03",
			breed_name = "skaven_storm_vermin"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_02 = TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_01
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_03 = TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_01

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_04 = {
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_static_guard_spawner_04",
			breed_name = "chaos_warrior"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_static_guard_spawner_05",
			breed_name = "skaven_storm_vermin"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_static_guard_spawner_06",
			breed_name = "chaos_warrior"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_05 = TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_04

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_04_boss = {
		{
			"spawn_at_raw",
			"skaven_stormfiend",
			spawner_id = "static_guards_04_boss_spawner",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 10
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_static_guards_dummy = {
		{
			"set_master_event_running",
			name = "dwarf_interior_static_guards_dummy"
		},
		{
			"delay",
			duration = 10
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_start = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"control_hordes",
			enable = false
		}
	}

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_a = table.clone(TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_loop)
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_b = table.clone(TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_loop)
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_c = table.clone(TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_loop)

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_hard_a = table.clone(TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_loop)
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_hard_b = table.clone(TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_loop)
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_hard_c = table.clone(TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_loop)
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_hard_d = table.clone(TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_loop)

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_pre_pause = {
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_hard_start"
		}
	}

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_post_pause = {
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_restart"
		}
	}

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_finale = {
		{
			"set_master_event_running",
			name = "brewery_event"
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
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event_finale",
			composition_type = "plague_monks_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_04",
			amount = 3,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower",
				"skaven_gutter_runner"
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event_finale",
			composition_type = "dn_skaven_elites"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 90,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave", "skaven_storm_vermin_commander") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_finale_end"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_loop = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 1,
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_01",
			amount = 2,
			breed_name = {
				"skaven_ratling_gunner",
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "dwarf_interior_brewery_specials_02",
			amount = 1,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "brewery_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_loop_restart"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_stop = {
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_a"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_b"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_c"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_hard_a"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_hard_b"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_hard_c"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_hard_d"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_loop"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_finale"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_pre_pause"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_post_pause"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_brewery_stop_chunk = {
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_a"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_b"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_brewery_c"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_great_hall_tunnels = {
		{
			"set_master_event_running",
			name = "great_hall_spawn"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"enable_bots_in_carry_event"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "tunnel_spawn",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "downstairs_tunnel_gutter_loop",
			amount = 2,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "back_tunnel_spawn_special",
			amount = 3,
			breed_name = {
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "tunnel_spawn",
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
				return count_event_breed("skaven_clan_rat", "skaven_clan_rat_with_shield", "skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_gutter_runner", "skaven_ratling_gunner") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "tunnel_spawn",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "tunnel_spawn",
			composition_type = "plague_monks_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "downstairs_tunnel_special_loop",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_pack_master"
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
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_storm_vermin_commander", "skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_great_hall_done"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_great_hall_extra_spice_event = {
		{
			"set_master_event_running",
			name = "great_hall_spawn"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"enable_bots_in_carry_event"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "great_hall_air_vent_spawners",
			composition_type = "event_extra_spice_small"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "great_hall_air_vent_spawners",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "great_hall_air_vent_spawners",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			amount = 3,
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_pack_master"
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
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_storm_vermin_commander") < 3
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_great_hall_extra_spice_done"
		}
	}
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_great_hall_tunnel_A_extra = {
		{
			"set_master_event_running",
			name = "great_hall_spawn"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"enable_bots_in_carry_event"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "tunnel_A_extra_spawn",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "tunnel_A_extra_spawn",
			composition_type = "event_small"
		},
		{
			"spawn_special",
			amount = 4,
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
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_great_hall_upstairs_tunnel_extra_done"
		}
	}
	
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_great_hall_tunnel_B_extra = TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_great_hall_tunnel_A_extra
	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_great_hall_tunnel_C_extra = TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_great_hall_tunnel_A_extra

	TerrorEventBlueprints.dlc_dwarf_interior.dwarf_interior_great_hall_stop = {
		{
			"delay",
			duration = 5
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_great_hall_tunnels"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_great_hall_extra_spice_event"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_great_hall_tunnel_A_extra"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_great_hall_tunnel_B_extra"
		},
		{
			"stop_event",
			stop_event_name = "dwarf_interior_great_hall_tunnel_C_extra"
		},
		{
			"disable_bots_in_carry_event"
		},
		{
			"delay",
			duration = 10
		}
	}

