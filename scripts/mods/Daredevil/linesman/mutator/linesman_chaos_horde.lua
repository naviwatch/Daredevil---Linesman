local mod = get_mod("Daredevil")

local faction = "chaos"

local trash_scale = 1
local shield_trash_scale = 1
local elite_scale = 1
local shield_elite_scale = 1
local berzerker_scale = 1
local super_armor_scale = 1

local trash_entities = { "skaven_slave", "chaos_fanatic" }
local elite_trash_entities = { "skaven_clan_rat", "chaos_marauder" }
local shield_trash_entities = { "skaven_clan_rat_with_shield", "chaos_marauder_with_shield" }
local elite_entities = { "skaven_storm_vermin_commander", "chaos_raider", "beastmen_bestigor" }
local shield_elite_entities = { "skaven_storm_vermin_with_shield" }
local berzerker_entities = { "skaven_plague_monk", "chaos_berzerker" }
local super_armor_entities = { "skaven_storm_vermin", "chaos_warrior" }

local scaling_data = {
	{
		scale_factor = trash_scale,
		breeds = trash_entities,
	},
	{
		scale_factor = trash_scale,
		breeds = elite_trash_entities,
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


HordeCompositionsPacing.chaos_mini_patrol = {
	{
		name = "few_marauders",
		weight = 10,
		breeds = {
			"chaos_marauder",
			{
				2,
				3
			},
			"chaos_raider",
			{
				1,
				1
			},
			"chaos_berzerker",
			{
				1,
				1
			}
		}
	},
	{
		name = "few_clanrats",
		weight = 2,
		breeds = {
			"chaos_marauder",
			{
				3,
				4
			},
			"chaos_berzerker",
			{
				2,
				2
			}
		}
	},
	{
		name = "storm_clanrats",
		weight = 2,
		breeds = {
			"chaos_marauder",
			{
				2,
				3
			},
			"chaos_raider",
			{
				2,
				2
			}
		}
	}
}

HordeCompositionsPacing.chaos_medium = {
	{
		name = "plain",
		weight = 7,
		breeds = {
			"chaos_marauder",
			{
				3,
				4
			},
			"chaos_fanatic",
			{
				15,
				20
			}
		}
	},
	{
		name = "zerkers",
		weight = 5,
		breeds = {
			"chaos_fanatic",
			{
				15,
				20
			},
			"chaos_berzerker",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 2,
		breeds = {
			"chaos_fanatic",
			{
				15,
				20
			},
			"chaos_marauder_with_shield",
			{
				1,
				3
			}
		}
	},
	{
		name = "leader",
		weight = 4,
		breeds = {
			"chaos_fanatic",
			{
				15,
				20
			},
			"chaos_raider",
			{
				1,
				1
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.chaos
}
HordeCompositionsPacing.chaos_large = {
	{
		name = "mixed",
		weight = 7,
		breeds = {
			"chaos_marauder",
			{
				12,
				12,
			},
			"chaos_fanatic",
			{
				16,
				18,
			},
			"skaven_clan_rat",
			{
				7,
				9,
			},
			"skaven_slave",
			{
				11,
				12,
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
		weight = 3,
		breeds = {
			"chaos_marauder",
			{
				12,
				12,
			},
			"chaos_fanatic",
			{
				16,
				18,
			},
			"skaven_clan_rat",
			{
				7,
				9,
			},
			"skaven_slave",
			{
				11,
				12,
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
		weight = 3,
		breeds = {
			"chaos_marauder",
			{
				12,
				12,
			},
			"chaos_fanatic",
			{
				16,
				18,
			},
			"skaven_clan_rat",
			{
				7,
				9,
			},
			"skaven_slave",
			{
				11,
				12,
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
		weight = 5,
		breeds = {
			"chaos_marauder",
			{
				12,
				12,
			},
			"chaos_fanatic",
			{
				16,
				18,
			},
			"skaven_clan_rat",
			{
				7,
				9,
			},
			"skaven_slave",
			{
				11,
				12,
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
	sound_settings = HordeCompositionsSoundSettings.chaos
}
HordeCompositionsPacing.chaos_huge = {
	{
		name = "mixed",
		weight = 7,
		breeds = {
			"chaos_marauder",
			{
				12,
				12,
			},
			"chaos_raider",
			{
				2,
				2,
			},
			"chaos_fanatic",
			{
				16,
				18,
			},
			"skaven_clan_rat",
			{
				7,
				9,
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
			"skaven_slave",
			{
				11,
				12,
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
		weight = 3,
		breeds = {
			"chaos_marauder",
			{
				12,
				12,
			},
			"chaos_fanatic",
			{
				16,
				18,
			},
			"skaven_clan_rat",
			{
				7,
				9,
			},
			"skaven_slave",
			{
				11,
				12,
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
		weight = 3,
		breeds = {
			"chaos_fanatic",
			{
				16,
				18,
			},
			"skaven_clan_rat",
			{
				7,
				9,
			},
			"chaos_raider",
			{
				2,
				2,
			},
			"skaven_slave",
			{
				11,
				12,
			},
			"chaos_berzerker",
			{
				1,
				1,
			},
			"skaven_plague_monk",
			{
				2,
				2,
			},
			"skaven_storm_vermin_commander",
			{
				4,
				4,
			},
			"chaos_marauder",
			{
				12,
				12,
			},
		}
	},
	{
		name = "chaoszerkers",
		weight = 5,
		breeds = {
			"chaos_marauder",
			{
				12,
				12,
			},
			"chaos_fanatic",
			{
				16,
				18,
			},
			"skaven_clan_rat",
			{
				7,
				9,
			},
			"skaven_slave",
			{
				11,
				12,
			},
			"skaven_plague_monk",
			{
				2,
				2,
			},
			"chaos_berzerker",
			{
				3,
				3,
			},
			"beastmen_bestigor",
			{
				1,
				1
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
		weight = 5,
		breeds = {
			"skaven_plague_monk",
			{
				1,
				1,
			},
			"chaos_raider",
			{
				4,
				4,
			},
			"skaven_clan_rat",
			{
				10,
				12,
			},
			"chaos_marauder",
			{
				9,
				9,
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2,
			},
			"chaos_fanatic",
			{
				10,
				12,
			},
			"skaven_slave",
			{
				17,
				18,
			},
			"chaos_berzerker",
			{
				2,
				2,
			},
		}
	},
	sound_settings = HordeCompositionsSoundSettings.chaos
}
HordeCompositionsPacing.chaos_huge_shields = {
	{
		name = "plain",
		weight = 7,
		breeds = {
			"beastmen_bestigor",
			{
				3,
				4
			},
			"chaos_fanatic",
			{
				23,
				24
			},
			"chaos_marauder",
			{
				15,
				16
			},
			"chaos_marauder_with_shield",
			{
				10,
				12
			},
			"chaos_berzerker",
			{
				4,
				4	
			},
			"chaos_warrior",
			1
		}
	},
	{
		name = "zerker",
		weight = 5,
		breeds = {
			"chaos_raider",
			{
				3,
				4
			},
			"chaos_fanatic",
			{
				24,
				25
			},
			"chaos_marauder",
			{
				8,
				10
			},
			"beastmen_bestigor",
			{
				4,
				4
			},
			"skaven_ratling_gunner",
			{
				1,
				1
			},
			"chaos_warrior",
			{
				1,
				1
			}
		}
	},
	{
		name = "shielders",
		weight = 2,
		breeds = {
			"chaos_fanatic",
			{
				24,
				25
			},
			"chaos_marauder",
			{
				14,
				15
			},
			"chaos_raider",
			{
				3,
				3
			},
			"chaos_berzerker",
			{
				4,
				4
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			},
			"chaos_warrior",
			{
				1,
				1
			}
		}
	},
	{
		name = "leader",
		weight = 4,
		breeds = {
			"chaos_fanatic",
			{
				23,
				24
			},
			"chaos_marauder",
			{
				15,
				16
			},
			"chaos_raider",
			{
				2,
				2
			},
			"chaos_berzerker",
			{
				3,
				3
			},
			"chaos_marauder_with_shield",
			{
				6,
				7
			},
			"beastmen_bestigor",
			{
				4,
				4
			}
		}
	},
	{
		name = "frenzy",
		weight = 5,
		breeds = {
			"chaos_fanatic",
			{
				23,
				24
			},
			"chaos_marauder",
			{
				15,
				16
			},
			"chaos_raider",
			{
				1,
				1
			},
			"beastmen_bestigor",
			{
				2,
				2
			},
			"chaos_berzerker",
			{
				6,
				7
			},
			"chaos_marauder_with_shield",
			{
				6,
				7
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.chaos
}
HordeCompositionsPacing.chaos_huge_armor = {
	{
		name = "plain",
		weight = 7,
		breeds = {
			"beastmen_bestigor",
			{
				2,
				2
			},
			"chaos_fanatic",
			{
				20,
				22
			},
			"chaos_marauder",
			{
				20,
				22
			},
			"chaos_raider",
			{
				4,
				4
			},
			"chaos_berzerker",
			{
				2,
				2
			},
			"chaos_warrior",
			{
				1,
				1
			},
		}
	},
	{
		name = "zerker",
		weight = 5,
		breeds = {
			"chaos_raider",
			{
				5,
				6
			},
			"chaos_fanatic",
			{
				20,
				22
			},
			"chaos_marauder",
			{
				20,
				22
			},
			"beastmen_bestigor",
			{
				3,
				3
			},
			"skaven_ratling_gunner",
			{
				1,
				1
			},
			"chaos_warrior",
			1
		}
	},
	{
		name = "shielders",
		weight = 4,
		breeds = {
			"chaos_warrior",
			{
				1,
				1
			},
			"chaos_fanatic",
			{
				23,
				24
			},
			"chaos_berzerker",
			{
				3,
				3
			},
			"chaos_marauder",
			{
				15,
				16
			},
			"chaos_marauder_with_shield",
			{
				9,
				10
			},
			"chaos_raider",
			{
				4,
				4
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
		weight = 2,
		breeds = {
			"chaos_fanatic",
			{
				23,
				24
			},
			"chaos_marauder",
			{
				15,
				16
			},
			"chaos_raider",
			{
				1,
				1
			},
			"chaos_berzerker",
			{
				4,
				4
			},
			"chaos_warrior",
			3
		}
	},
	{
		name = "frenzy",
		weight = 2,
		breeds = {
			"chaos_fanatic",
			{
				18,
				20
			},
			"chaos_marauder",
			{
				18,
				20
			},
			"chaos_raider",
			{
				3,
				3
			},
			"beastmen_bestigor",
			{
				3,
				3
			},
			"chaos_berzerker",
			{
				5,
				5
			}
		}
	},
	{
		name = "guh",
		weight = 2,
		breeds = {
			"chaos_fanatic",
			{
				18,
				20
			},
			"chaos_marauder",
			{
				20,
				30
			},
			"chaos_berzerker",
			{
				10,
				10
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.chaos
}
HordeCompositionsPacing.chaos_huge_berzerker = {
	{
		name = "plain",
		weight = 7,
		breeds = {
			"chaos_fanatic",
			{
				14,
				16
			},
			"beastmen_bestigor",
			{
				2,
				2
			},
			"chaos_marauder",
			{
				24,
				26
			},
			"chaos_berzerker",
			{
				6,
				7
			},
			"chaos_corruptor_sorcerer",
			{
				1,
				1
			}
		}
	},
	{
		name = "zerker",
		weight = 5,
		breeds = {
			"chaos_fanatic",
			{
				23,
				24
			},
			"chaos_marauder",
			{
				15,
				16
			},
			"chaos_berzerker",
			{
				4,
				4
			},
			"beastmen_bestigor",
			{
				4,
				4
			},
			"chaos_warrior",
			1
		}
	},
	{
		name = "shielders",
		weight = 2,
		breeds = {
			"chaos_fanatic",
			{
				16,
				18
			},
			"chaos_marauder",
			{
				16,
				18
			},
			"chaos_marauder_with_shield",
			{
				8,
				10
			},
			"chaos_berzerker",
			{
				4,
				4
			},
			"chaos_raider",
			{
				3,
				4
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			},
			"chaos_warrior",
			1
		}
	},
	{
		name = "leader",
		weight = 4,
		breeds = {
			"chaos_fanatic",
			{
				23,
				24
			},
			"chaos_marauder",
			{
				15,
				16
			},
			"chaos_berzerker",
			{
				5,
				6
			},
			"chaos_raider",
			{
				2,
				2
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			},
			"chaos_warrior",
			{
				1,
				1
			}
		}
	},
	{
		name = "frenzy",
		weight = 2,
		breeds = {
			"chaos_fanatic",
			{
				23,
				24
			},
			"chaos_marauder",
			{
				15,
				16
			},
			"chaos_raider",
			{
				2,
				2
			},
			"beastmen_bestigor",
			{
				3,
				3
			},
			"chaos_berzerker",
			{
				4,
				4
			},
			"chaos_marauder_with_shield",
			{
				3,
				4
			},
			"chaos_warrior",
			1
		}
	},
	{
		name = "guh",
		weight = 2,
		breeds = {
			"chaos_fanatic",
			{
				18,
				20
			},
			"chaos_marauder",
			{
				20,
				30
			},
			"chaos_raider",
			{
				10,
				10
			}
		}
	},
	sound_settings = HordeCompositionsSoundSettings.chaos
}

scale_horde_composition(HordeCompositionsPacing, faction, scaling_data)