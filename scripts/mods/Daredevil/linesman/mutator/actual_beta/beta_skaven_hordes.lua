local mod = get_mod("Daredevil")

local faction = "huge"

	local trash_scale = 1
	local shield_trash_scale = 1
	local elite_scale = 1
	local shield_elite_scale = 1
	local berzerker_scale = 1
	local super_armor_scale = 1

	local trash_entities = {"skaven_slave","skaven_clan_rat"}
	local shield_trash_entities = {"skaven_clan_rat_with_shield"}
	local elite_entities = {"skaven_storm_vermin_commander"}
	local shield_elite_entities = {"skaven_storm_vermin_with_shield"}
	local berzerker_entities = {"skaven_plague_monk"}
	local super_armor_entities = {"skaven_storm_vermin", "skaven_dummy_clan_rat", "skaven_dummy_slave"}

	local scaling_data = {
    {
        scale_factor = trash_scale,
        breeds = trash_entities,
    },
    {
        scale_factor = shield_trash_scale,
        breeds = shield_trash_entities,
    },
    {
        scale_factor = elite_scale * mod.gain,
        breeds = elite_entities,
    },
    {
        scale_factor = shield_elite_scale * mod.gain,
        breeds = shield_elite_entities,
    },
    {
        scale_factor = berzerker_scale * mod.gain,
        breeds = berzerker_entities,
    },
    {
        scale_factor = super_armor_scale * mod.gain,
        breeds = super_armor_entities,
    },
}
	
mini_patrol = {
	{
		name = "few_clanrats",
		weight = 2,
		breeds = {
			"skaven_clan_rat_with_shield",
			{
				4,
				5
			},
			"skaven_storm_vermin_commander",
			{
				1,
				2
			},
			"skaven_plague_monk",
			{
				2,
				2
			}
		}
	},
	{
		name = "few_clanrats",
		weight = 2,
		breeds = {
			"skaven_clan_rat",
			{
				3,
				4
			},
			"skaven_plague_monk",
			{
				3,
				4
			}
		}
	},
	{
		name = "storm_clanrats",
		weight = 2,
		breeds = {
			"skaven_clan_rat",
			{
				2,
				3
			},
			"skaven_storm_vermin_commander",
			{
				3,
				4
			}
		}
	}
}
HordeCompositionsPacing.small = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				24,
				36
			},
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.medium = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				24,
				36
			},
			"skaven_clan_rat",
			{
				16,
				24
			},
			"skaven_clan_rat_with_shield",
			{
				2,
				8
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2
			},
			"skaven_storm_vermin_with_shield",
			{
				1,
				2
			},
			"skaven_plague_monk",
			{
				1,
				3
			},
			"skaven_ratling_gunner",
			{
				1,
				2
			},
			"skaven_poison_wind_globadier",
			{
				1,
				1
			},
			"skaven_gutter_runner",
			{
				1,
				1
			},
			"chaos_vortex_sorcerer",
			{
				1,
				1
			},
			"skaven_warpfire_thrower",
			{
				1,
				2
			},
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.large = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				22,
				28
			},
			"skaven_clan_rat",
			{
				20,
				30
			},
			"skaven_plague_monk",
			{
				9,
				9
			},
			"skaven_storm_vermin_commander",
			{
				6,
				6
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			},
			"skaven_poison_wind_globadier",
			{
				0,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				22,
				28
			},
			"skaven_clan_rat",
			{
				20,
				30
			},
			"skaven_clan_rat_with_shield",
			{
				16,
				25
			},
			"skaven_plague_monk",
			{
				6,
				9
			},
			"skaven_storm_vermin_commander",
			{
				6,
				6
			},
			"skaven_ratling_gunner",
			{
				0,
				1
			},
			"skaven_pack_master",
			{
				1,
				1
			}
		}
	},
	{
		name = "leader",
		weight = 6,
		breeds = {
			"skaven_slave",
			{
				22,
				28
			},
			"skaven_clan_rat",
			{
				20,
				30
			},
			"skaven_clan_rat_with_shield",
			{
				16,
				25
			},
			"skaven_plague_monk",
			{
				5,
				17
			},
			"skaven_storm_vermin_commander",
			{
				8,
				23
			},
			"skaven_ratling_gunner",
			{
				0,
				1
			},
			"skaven_pack_master",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders_heavy",
		weight = 2,
		breeds = {
			"skaven_slave",
			{
				60,
				60
			},
			"skaven_clan_rat",
			{
				50,
				50
			},
			"skaven_gutter_runner",
			{
				1,
				1
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			},
			"skaven_ratling_gunner",
			{
				1,
				1
			},
			"skaven_pack_master",
			{
				1,
				1
			},
			"chaos_corruptor_sorcerer",
			{
				1,
				1
			},
			"chaos_plague_sorcerer",
			{
				1,
				1
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.huge = {
	{
		name = "mixed",
		weight = 7,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				2,
				2,
			},
			"chaos_berzerker",
			{
				2,
				2,
			},
			"chaos_raider",
			{
				2,
				2,
			},
			"skaven_storm_vermin_commander",
			{
				2,
				3,
			},
		},
	},
	{
		name = "monks",
		weight = 5,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				4,
				4,
			},
			"chaos_berzerker",
			{
				2,
				2,
			},
			"chaos_raider",
			{
				1,
				1,
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2,
			},
		},
	},
	{
		name = "stormvermins",
		weight = 5,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				2,
				2,
			},
			"chaos_berzerker",
			{
				1,
				1,
			},
			"chaos_raider",
			{
				2,
				2,
			},
			"skaven_storm_vermin_commander",
			{
				4,
				4,
			},
		},
	},
	{
		name = "chaoszerkers",
		weight = 3,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				2,
				2,
			},
			"chaos_berzerker",
			{
				4,
				4,
			},
			"chaos_raider",
			{
				2,
				2,
			},
			"skaven_storm_vermin_commander",
			{
				1,
				1,
			},
		},
	},
	{
		name = "maulers",
		weight = 3,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				1,
				1,
			},
			"chaos_berzerker",
			{
				2,
				2,
			},
			"chaos_raider",
			{
				4,
				4,
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2,
			},
		},
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.huge_shields = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				20,
				22
			},
			"skaven_plague_monk",
			{
				3,
				3
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2
			},
			"skaven_dummy_slave",
			{
				1,
				1
			},
			"skaven_dummy_clan_rat",
			{
				1,
				1
			},
			"skaven_clan_rat",
			{
				30,
				34
			},
			"skaven_clan_rat_with_shield",
			{
				10,
				12
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2
			},
			"chaos_corruptor_sorcerer",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 7,
		breeds = {
			"skaven_storm_vermin_commander",
			{
				4,
				5
			},
			"skaven_slave",
			{
				20,
				22
			},
			"skaven_plague_monk",
			{
				2,
				2
			},
			"skaven_clan_rat",
			{
				26,
				28
			},
			"skaven_clan_rat_with_shield",
			{
				12,
				14
			},
			"skaven_dummy_slave",
			{
				1,
				1
			},
			"skaven_dummy_clan_rat",
			{
				1,
				1
			},
			"skaven_ratling_gunner",
			{
				1,
				1
			}
		}
	},
	{
		name = "leader",
		weight = 5,
		breeds = {
			"skaven_plague_monk",
			{
				4,
				4
			},
			"skaven_slave",
			{
				20,
				24
			},
			"skaven_clan_rat",
			{
				24,
				28
			},
			"skaven_storm_vermin_commander",
			{
				5,
				5
			},
			"skaven_clan_rat_with_shield",
			{
				6,
				8
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders_heavy",
		weight = 2,
		breeds = {
			"skaven_slave",
			{
				22,
				24
			},
			"skaven_clan_rat",
			{
				24,
				28
			},
			"skaven_clan_rat_with_shield",
			{
				18,
				20
			},
			"skaven_storm_vermin_commander",
			{
				6,
				7
			},
			"skaven_plague_monk",
			{
				2,
				2
			},
			"skaven_gutter_runner",
			{
				1,
				1
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.huge_armor = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				20,
				24
			},
			"skaven_storm_vermin_commander",
			{
				4,
				4
			},
			"skaven_dummy_slave",
			{
				2,
				2
			},
			"skaven_clan_rat",
			{
				12,
				24
			},
			"skaven_plague_monk",
			{
				3,
				3
			},
			"skaven_ratling_gunner",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 7,
		breeds = {
			"skaven_slave",
			{
				18,
				22
			},
			"skaven_storm_vermin",
			{
				2,
				2
			},
			"skaven_plague_monk",
			{
				2,
				2
			},
			"skaven_clan_rat",
			{
				24,
				26
			},
			"skaven_storm_vermin_commander",
			{
				2,
				3
			},
			"skaven_dummy_slave",
			{
				2,
				2
			},
			"skaven_clan_rat_with_shield",
			{
				7,
				9
			},
		}
	},
	{
		name = "leader",
		weight = 6,
		breeds = {
			"skaven_slave",
			{
				22,
				24
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_storm_vermin_commander",
			{
				7,
				7
			},
			"skaven_plague_monk",
			{
				2,
				2
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders_heavy",
		weight = 2,
		breeds = {
			"skaven_slave",
			{
				18,
				20
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_clan_rat_with_shield",
			{
				3,
				5
			},
			"skaven_storm_vermin_commander",
			{
				6,
				6
			},
			"skaven_plague_monk",
			{
				2,
				2
			},
			"chaos_warrior",
			{
				1,
				1
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.huge_berzerker = {
	{
		name = "plain",
		weight = 7,
		breeds = {
			"skaven_slave",
			{
				18,
				20
			},
			"skaven_dummy_slave",
			{
				2,
				2
			},
			"skaven_plague_monk",
			{
				1,
				1
			},
			"skaven_storm_vermin_commander",	
			{
				3,
				3
			},
			"skaven_clan_rat",
			{
				28,
				30
			},
			"skaven_plague_monk",
			{
				3,
				3
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				15,
				18
			},
			"skaven_clan_rat",
			{
				15,
				18
			},
			"skaven_plague_monk",
			{
				4,
				4	
			},
			"skaven_dummy_slave",
			{
				2,
				2
			},
			"skaven_clan_rat_with_shield",
			{
				10,
				12
			},
			"skaven_storm_vermin_commander",
			{
				3,
				3
			}
		}
	},
	{
		name = "leader",
		weight = 6,
		breeds = {
			"skaven_plague_monk",
			{
				5,
				5
			},
			"skaven_storm_vermin_commander",
			{
				4,
				4
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_slave",
			{
				15,
				18
			},
			"skaven_pack_master",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders_heavy",
		weight = 2,
		breeds = {
			"skaven_slave",
			{
				15,
				18
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_clan_rat_with_shield",
			{
				3,
				5
			},
			"chaos_warrior",
			{
				1,
				1
			},
			"skaven_plague_monk",
			{
				7,
				7
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}

scale_horde_composition(HordeCompositionsPacing, faction, scaling_data)

--[[
HordeCompositionsPacing.huge = {
	{
		name = "mixed",
		weight = 7,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				2,
				2,
			},
			"chaos_berzerker",
			{
				2,
				2,
			},
			"chaos_raider",
			{
				2,
				2,
			},
			"skaven_storm_vermin_commander",
			{
				2,
				3,
			},
		},
	},
	{
		name = "monks",
		weight = 5,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				4,
				4,
			},
			"chaos_berzerker",
			{
				2,
				2,
			},
			"chaos_raider",
			{
				1,
				1,
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2,
			},
		},
	},
	{
		name = "stormvermins",
		weight = 5,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				2,
				2,
			},
			"chaos_berzerker",
			{
				1,
				1,
			},
			"chaos_raider",
			{
				2,
				2,
			},
			"skaven_storm_vermin_commander",
			{
				4,
				4,
			},
		},
	},
	{
		name = "chaoszerkers",
		weight = 3,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				2,
				2,
			},
			"chaos_berzerker",
			{
				4,
				4,
			},
			"chaos_raider",
			{
				2,
				2,
			},
			"skaven_storm_vermin_commander",
			{
				1,
				1,
			},
		},
	},
	{
		name = "maulers",
		weight = 3,
		breeds = {
			"chaos_marauder",
			{
				9,
				9,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"skaven_plague_monk",
			{
				1,
				1,
			},
			"chaos_berzerker",
			{
				2,
				2,
			},
			"chaos_raider",
			{
				4,
				4,
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2,
			},
		},
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.huge_shields = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				20,
				22
			},
			"skaven_clan_rat",
			{
				30,
				34
			},
			"skaven_clan_rat_with_shield",
			{
				10,
				12
			},
			"skaven_storm_vermin_commander",
			{
				3,
				4
			},
			"skaven_plague_monk",
			{
				5,
				5
			},
			"chaos_corruptor_sorcerer",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 7,
		breeds = {
			"skaven_slave",
			{
				20,
				22
			},
			"skaven_clan_rat",
			{
				26,
				28
			},
			"skaven_clan_rat_with_shield",
			{
				12,
				14
			},
			"skaven_plague_monk",
			{
				5,
				5
			},
			"skaven_storm_vermin_commander",
			{
				4,
				5
			},
			"skaven_ratling_gunner",
			{
				1,
				1
			}
		}
	},
	{
		name = "leader",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				20,
				24
			},
			"skaven_clan_rat",
			{
				24,
				28
			},
			"skaven_storm_vermin_commander",
			{
				4,
				4
			},
			"skaven_clan_rat_with_shield",
			{
				6,
				8
			},
			"skaven_plague_monk",
			{
				5,
				6
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders_heavy",
		weight = 2,
		breeds = {
			"skaven_slave",
			{
				22,
				24
			},
			"skaven_clan_rat",
			{
				24,
				28
			},
			"skaven_clan_rat_with_shield",
			{
				18,
				20
			},
			"skaven_storm_vermin_commander",
			{
				6,
				7
			},
			"skaven_storm_vermin_with_shield",
			{
				2,
				2
			},
			"skaven_gutter_runner",
			{
				1,
				1
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.huge_armor = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				20,
				24
			},
			"skaven_clan_rat",
			{
				12,
				24
			},
			"skaven_storm_vermin_commander",
			{
				8,
				8
			},
			"skaven_plague_monk",
			{
				2,
				2
			},
			"skaven_ratling_gunner",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 7,
		breeds = {
			"skaven_slave",
			{
				18,
				22
			},
			"skaven_clan_rat",
			{
				24,
				26
			},
			"skaven_clan_rat_with_shield",
			{
				7,
				9
			},
			"skaven_storm_vermin_commander",
			{
				4,
				5
			},
			"skaven_storm_vermin",
			{
				3,
				3
			},
			"skaven_plague_monk",
			{
				2,
				2
			}
		}
	},
	{
		name = "leader",
		weight = 6,
		breeds = {
			"skaven_slave",
			{
				22,
				24
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_storm_vermin_commander",
			{
				7,
				8
			},
			"skaven_plague_monk",
			{
				2,
				2
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders_heavy",
		weight = 2,
		breeds = {
			"skaven_slave",
			{
				18,
				20
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_clan_rat_with_shield",
			{
				3,
				5
			},
			"skaven_storm_vermin_commander",
			{
				6,
				7	
			},
			"skaven_plague_monk",
			{
				2,
				2
			},
			"skaven_storm_vermin_with_shield",
			{
				2,
				2
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.huge_berzerker = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				18,
				20
			},
			"skaven_clan_rat",
			{
				28,
				30
			},
			"skaven_plague_monk",
			{
				7,
				7
			},
			"skaven_storm_vermin_commander",	
			{
				2,
				2
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 7,
		breeds = {
			"skaven_slave",
			{
				15,
				18
			},
			"skaven_clan_rat",
			{
				15,
				18
			},
			"skaven_clan_rat_with_shield",
			{
				10,
				12
			},
			"skaven_plague_monk",
			{
				7,
				7	
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2
			}
		}
	},
	{
		name = "leader",
		weight = 6,
		breeds = {
			"skaven_slave",
			{
				15,
				18
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2
			},
			"skaven_plague_monk",
			{
				9,
				10
			},
			"skaven_pack_master",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders_heavy",
		weight = 2,
		breeds = {
			"skaven_slave",
			{
				15,
				18
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_clan_rat_with_shield",
			{
				3,
				5
			},
			"skaven_storm_vermin_with_shield",
			{
				1,
				1
			},
			"skaven_plague_monk",
			{
				7,
				8
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.skaven
}
]]