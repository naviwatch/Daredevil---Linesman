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

TerrorEventBlueprints.dlc_termite_1.termite_01_pacing_off = {
	{
		"control_pacing",
		enable = false,
	},
	{
		"control_specials",
		enable = false,
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_pacing_on = {
	{
		"control_pacing",
		enable = true,
	},
	{
		"control_specials",
		enable = true,
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_detour = {
	{
		"set_master_event_running",
		name = "termite_01_detour",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 50,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_medium",
		spawner_id = "detour_spawner",
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_gutter_runner",
			"skaven_ratling_gunner",
		},
	},
	{
		"delay",
		duration = 1,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_gutter_runner",
			"skaven_ratling_gunner",
		},
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 1,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_gutter_runner",
			"skaven_ratling_gunner",
		},
		difficulty_requirement = CATACLYSM,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 120,
		condition = function(t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"flow_event",
		flow_event_name = "termite_01_detour_done",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_01 = {
	{
		"set_master_event_running",
		name = "termite_01_end_event_01",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"control_hordes",
		enable = false
	},
	{
		"control_specials",
		enable = true,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_large",
		spawner_id = "end_event_01",
	},
	{
		"event_horde",
		composition_type = "plague_monks_medium",
		spawner_id = "end_event_01_plagues",
	},
	{
		"event_horde",
		composition_type = "dn_warpfire_spam",
		spawner_id = "end_event_trickle",
	},
	{
		"event_horde",
		composition_type = "crackaddicts",
		spawner_id = "end_event_trickle",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 60,
		condition = function(t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and
			count_event_breed("skaven_plague_monk") < 1
		end,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_large",
		spawner_id = "end_event_01",
	},
	{
		"event_horde",
		composition_type = "plague_monks_medium",
		spawner_id = "end_event_01_plagues",
	},
	{
		"event_horde",
		composition_type = "dn_ratling_spam",
		spawner_id = "end_event_trickle",
	},
	{
		"continue_when",
		duration = 60,
		condition = function(t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and
			count_event_breed("skaven_plague_monk") < 1
		end,
	},
	{
		"flow_event",
		flow_event_name = "termite_01_end_event_01_done",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_trickle = {
	{
		"set_master_event_running",
		name = "termite_01_end_event_trickle",
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100,
	},
	{
		"control_hordes",
		enable = false,
	},
	{
		"control_specials",
		enable = true,
	},
	{
		"delay",
		duration = 5,
	},
	{
		"event_horde",
		composition_type = "mass_trash_skaven_mini",
		spawner_id = "end_event_trickle",
	},
	{
		"event_horde",
		composition_type = "plague_monks_medium",
		spawner_id = "end_event_trickle",
	},
	{
		"event_horde",
		composition_type = "dn_warpfire_spam",
		spawner_id = "end_event_trickle",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 80,
		condition = function(t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_plague_monk") < 2 and count_event_breed("skaven_stormvermin") < 1
		end,
	},
	{
		"event_horde",
		composition_type = "mass_trash_skaven_mini",
		spawner_id = "end_event_trickle",
	},
	{
		"event_horde",
		composition_type = "plague_monks_medium",
		spawner_id = "end_event_trickle",
	},
	{
		"event_horde",
		composition_type = "dn_warpfire_spam",
		spawner_id = "end_event_trickle",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"continue_when",
		duration = 80,
		condition = function(t)
			return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 10 and count_event_breed("skaven_plague_monk") < 2 and count_event_breed("skaven_stormvermin") < 2
		end,
	},
	{
		"flow_event",
		flow_event_name = "termite_01_end_event_trickle_done",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_left = {
	{
		"event_horde",
		composition_type = "dn_skaven_pursuit",
		spawner_id = "end_event_left",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_ratling_gunner",
		},
		difficulty_requirement = HARD,
	},
	{
		"delay",
		duration = 2,
	},
	{
		"event_horde",
		composition_type = "storm_vermin_medium",
		spawner_id = "end_event_left_extras",
		difficulty_requirement = HARDEST,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_ratling_gunner",
		},
		difficulty_requirement = HARDER,
	},
	{
		"delay",
		duration = 3,
	},
	{
		"continue_when",
		duration = 80,
		condition = function(t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"flow_event",
		flow_event_name = "termite_01_end_event_left_done",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_left_extras = {}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_right = {
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "end_event_right",
	},
	{
		"delay",
		duration = 5,
	},
	{
		"event_horde",
		composition_type = "event_extra_spice_small",
		spawner_id = "end_event_right_extras",
		difficulty_requirement = NORMAL,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_ratling_gunner",
		},
		difficulty_requirement = HARD,
	},
	{
		"delay",
		duration = 2,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_ratling_gunner",
		},
		difficulty_requirement = HARDEST,
	},
	{
		"delay",
		duration = 3,
	},
	{
		"event_horde",
		composition_type = "storm_vermin_small",
		spawner_id = "end_event_right_extras",
		difficulty_requirement = CATACLYSM,
	},
	{
		"delay",
		duration = 3,
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = {
			"skaven_poison_wind_globadier",
			"skaven_ratling_gunner",
		},
		difficulty_requirement = HARDER,
	},
	{
		"continue_when",
		duration = 120,
		condition = function(t)
			return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
		end,
	},
	{
		"flow_event",
		flow_event_name = "termite_01_end_event_right_done",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_right_extras = {}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_center = {
	{
		"event_horde",
		composition_type = "mass_trash_skaven",
		spawner_id = "end_event_center",
	},
	{
		"event_horde",
		composition_type = "dn_warpfire_spam",
		spawner_id = "end_event_center",
	},
	{
		"event_horde",
		composition_type = "dn_ratling_spam",
		spawner_id = "end_event_center",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_center_extras = TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_center
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_manual_01 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_poison_wind_globadier",
		spawner_id = "end_event_manual_01",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_manual_ratling_01 = {
	{
		"spawn_at_raw",
		breed_name = "chaos_exalted_champion_warcamp",
		spawner_id = "end_event_manual_ratling_01",
		optional_data = {
			max_health_modifier = 0.01
		}
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_manual_02 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_poison_wind_globadier",
		spawner_id = "end_event_manual_02",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_manual_03 = {
	{
		"spawn_at_raw",
		breed_name = "skaven_poison_wind_globadier",
		spawner_id = "end_event_manual_03",
	},
}
TerrorEventBlueprints.dlc_termite_1.termite_01_end_event_stormfiend = {
	{
		"spawn_at_raw",
		breed_name = "skaven_stormfiend",
		spawner_id = "end_event_stormfiend",
		optional_data = {
			max_health_modifier = 0.1
		}
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_stormfiend",
		spawner_id = "end_event_stormfiend",
		optional_data = {
			max_health_modifier = 0.1
		}
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_stormfiend",
		spawner_id = "end_event_stormfiend",
		optional_data = {
			max_health_modifier = 0.1
		}
	},
	{
		"spawn_at_raw",
		breed_name = "skaven_stormfiend",
		spawner_id = "end_event_stormfiend",
		optional_data = {
			max_health_modifier = 0.1
		}
	},
	{
		"event_horde",
		composition_type = "dn_warpfire_spam",
		spawner_id = "end_event_stormfiend",
	},
}
