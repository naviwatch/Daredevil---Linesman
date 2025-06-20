local mod = get_mod("Daredevil")

	
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
			"chaos_corruptor_sorcerer",
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
        weight = 15,
        breeds = {"chaos_marauder", {9, 9,}, "chaos_fanatic", {10, 12,}, "skaven_clan_rat", {10, 12,}, "skaven_slave", {17, 18,}, "skaven_plague_monk", {1, 1,}, "chaos_berzerker", {1, 1,}, "chaos_raider", {1, 1,}, "skaven_storm_vermin_commander", {1, 1,}, "chaos_warrior", {1, 1} },
    },
    {
        name = "shield_leader",	
        weight = 7, 
        breeds = {"skaven_plague_monk", {2, 2}, "skaven_clan_rat", {10, 12,}, "skaven_slave", {17, 18,}, "skaven_storm_vermin_commander", {2, 2}, "skaven_clan_rat_with_shield", {6, 8}, "skaven_warpfire_thrower", {1, 1}, "chaos_warrior", {1, 1} }
    },
    {
        name = "armored_leader",
        weight = 5,
        breeds = {"skaven_clan_rat", {10, 12,}, "skaven_slave", {17, 18,}, "skaven_storm_vermin_commander", {3, 3}, "skaven_plague_monk", {3, 3}, "skaven_warpfire_thrower", {1, 1}}
    },
    {
        name = "berserker_leader",
        weight = 5,
        breeds = {"skaven_plague_monk", {2, 2}, "skaven_storm_vermin_commander", {3, 3}, "skaven_clan_rat", {10, 12,}, "skaven_slave", {17, 18,}, "skaven_ratling_gunner", {1, 1}}
    },
    {
        name = "chaos_shield_leader",
        weight = 7,
		breeds = {"chaos_fanatic", {17, 20}, "chaos_marauder", {14, 16}, "chaos_raider", {3, 3}, "chaos_berzerker", {3, 3}, "chaos_marauder_with_shield", {6, 7}, "skaven_warpfire_thrower", {1, 1}}
    },
    {
        name = "chaos_berserker_leader",
        weight = 4,
        breeds = {"chaos_fanatic", {17, 20}, "chaos_marauder", {14, 16}, "chaos_raider", {2, 2}, "chaos_berzerker", {3, 3}, "skaven_ratling_gunner", {1, 1}, "chaos_warrior", 1}
    },
    {
        name = "chaos_armored_leader",
        weight = 4,
        breeds = {"chaos_fanatic", {17, 20}, "chaos_marauder", {14, 16}, "chaos_raider", {3, 3}, "chaos_berzerker", {2	, 2}, "skaven_ratling_gunner", {1, 1}, "chaos_warrior", 1}
    },
    sound_settings = HordeCompositionsSoundSettings.skaven
}
HordeCompositionsPacing.huge_shields = HordeCompositionsPacing.huge
HordeCompositionsPacing.huge_armor = HordeCompositionsPacing.huge
HordeCompositionsPacing.huge_berzerker = HordeCompositionsPacing.huge
HordeCompositionsPacing.chaos_huge = HordeCompositionsPacing.huge
HordeCompositionsPacing.chaos_huge_shields = HordeCompositionsPacing.huge
HordeCompositionsPacing.chaos_huge_armor = HordeCompositionsPacing.huge
HordeCompositionsPacing.chaos_huge_berzerker = HordeCompositionsPacing.huge

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