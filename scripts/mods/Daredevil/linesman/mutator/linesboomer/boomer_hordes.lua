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

	chaos_mini_patrol = {
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
					5,
					6
				},
				"skaven_storm_vermin_commander",
				{
					4,
					4
				},
				"skaven_warpfire_thrower",
				{
					1,
					1
				}
			--	"skaven_poison_wind_globadier",
			--	{
			--		1,
			--		1
			--	}
			}
		},
		{
			name = "shielders",
			weight = 7,
			breeds = {
				"skaven_slave",
				{
					12,
					16
				},
				"skaven_clan_rat",
				{
					20,
					25
				},
				"skaven_clan_rat_with_shield",
				{
					18,
					20
				},
				"skaven_storm_vermin_commander",
				{
					5,
					5
				},
				"skaven_plague_monk",
				{
					4,
					5
				},
				"skaven_warpfire_thrower",
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
					20,
					22
				},
				"skaven_clan_rat",
				{
					30,
					35
				},
				"skaven_storm_vermin_commander",
				{
					6,
					7
				},
				"skaven_storm_vermin",
				{
					2,
					2
				},
				"skaven_warpfire_thrower",
				{
					1,
					1
				}
			--	"skaven_pack_master",
			--	{
			--		1,
			--		1
			--	}
			}
		},
		{
			name = "shielders_heavy",
			weight = 2,
			breeds = {
				"skaven_slave",
				{
					22,
					28
				},
				"skaven_clan_rat",
				{
					20,
					22
				},
				"skaven_clan_rat_with_shield",
				{
					8,
					10
				},
				"skaven_storm_vermin_with_shield",
				{
					2,
					2
				},
				"skaven_plague_monk",
				{
					9,
					10
				}
			}
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
					8,
					9
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
					8	
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
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_fanatic",
				{
					18,
					20
				},
				"chaos_marauder",
				{
					24,
					26
				},
				"chaos_raider",
				{
					5,
					6
				},
				"chaos_berzerker",
				{
					4,
					5
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
			name = "zerker",
			weight = 7,
			breeds = {
				"chaos_fanatic",
				{
					14,
					16
				},
				"chaos_marauder",
				{
					24,
					26
				},
				"chaos_berzerker",
				{
					7,
					8
				},
				"chaos_raider",
				{
					2,
					2
				},
				"chaos_corruptor_sorcerer",
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
					20,
					22
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
					6,
					7	
				},
				"chaos_corruptor_sorcerer",
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
					20,
					22
				},
				"chaos_marauder",
				{
					14,
					16
				},
				"chaos_raider",
				{
					5,
					6
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
				1
			}
		},
		{
			name = "frenzy",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					45,
					50
				},
				"chaos_raider",
				{
					5,
					5
				},
				"chaos_berzerker",
				{
					30,
					30
				},
				"chaos_marauder_with_shield",
				{
					1,
					2
				},
			}
		},
		sound_settings = HordeCompositionsSoundSettings.chaos
	}
	HordeCompositionsPacing.chaos_huge = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_fanatic",
				{
					18,
					20
				},
				"chaos_marauder",
				{
					24,
					26
				},
				"chaos_raider",
				{
					4,
					5
				},
				"chaos_berzerker",
				{
					4,
					5
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
			name = "zerker",
			weight = 5,
			breeds = {
				"chaos_fanatic",
				{
					24,
					26
				},
				"chaos_marauder",
				{
					14,
					16
				},
				"chaos_berzerker",
				{
					8,
					8
				},
				"chaos_raider",
				{
					2,
					2
				},
				"chaos_warrior",
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
		{
			name = "shielders",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					10,
					12
				},
				"chaos_marauder",
				{
					8,
					10
				},
				"chaos_marauder_with_shield",
				{
					9,
					10
				},
				"chaos_raider",
				{
					5,
					6
				},
				"chaos_berzerker",
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
			name = "leader",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					12,
					14
				},
				"chaos_marauder",
				{
					18,
					20
				},
				"chaos_raider",
				{
					5,
					5
				},
				"skaven_pack_master",
				{
					1,
					1 
				},
				"skaven_gutter_runner",
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
					10,
					12
				},
				"chaos_marauder",
				{
					12,
					14
				},
				"chaos_raider",
				{
					3,
					4
				},
				"chaos_berzerker",
				{
					5,
					5
				},
				"chaos_marauder_with_shield",
				{
					8,
					10
				},
				"chaos_warrior",
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
		sound_settings = HordeCompositionsSoundSettings.chaos
	}
	HordeCompositionsPacing.chaos_huge_shields = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_fanatic",
				{
					20,
					22
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
					6,
					7	
				},
				"chaos_corruptor_sorcerer",
				{
					1,
					1
				},
				"chaos_warrior",
				1
			}
		},
		{
			name = "zerker",
			weight = 5,
			breeds = {
				"chaos_fanatic",
				{
					20,
					22
				},
				"chaos_marauder_with_shield",
				{
					8,
					10
				},
				"chaos_berzerker",
				{
					5,
					5
				},
				"chaos_raider",
				{
					3,
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
					20,
					22
				},
				"chaos_marauder_with_shield",
				{
					14,
					15
				},
				"chaos_raider",
				{
					6,
					7
				},
				"skaven_warpfire_thrower",
				{
					1,
					1
				},
				"chaos_warrior",
				{
					2,
					2
				}
			}
		},
		{
			name = "leader",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					12,
					14
				},
				"chaos_marauder",
				{
					14,
					16
				},
				"chaos_raider",
				{
					4,
					5
				},
				"chaos_berzerker",
				{
					4,
					4
				},
				"chaos_marauder_with_shield",
				{
					6,
					7
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
					16,
					16
				},
				"chaos_raider",
				{
					3,
					3
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
					5,
					5
				},
				"chaos_warrior",
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
					20,
					22
				},
				"chaos_marauder",
				{
					12,
					14
				},
				"chaos_raider",
				{
					8,
					9
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
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					20,
					22
				},
				"chaos_marauder",
				{
					10,
					12
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
				"chaos_berzerker",
				{
					4,
					6
				},
				"chaos_warrior",
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
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					20,
					22
				},
				"chaos_marauder",
				{
					14,
					16
				},
				"chaos_raider",
				{
					4,
					5
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
				1
			}
		},
		{
			name = "frenzy",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					12,
					14
				},
				"chaos_marauder",
				{
					18,
					20
				},
				"chaos_raider",
				{
					5,
					5
				},
				"chaos_berzerker",
				{
					5,
					5
				},
				"chaos_warrior",
				1
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
				"chaos_marauder",
				{
					24,
					26
				},
				"chaos_berzerker",
				{
					7,
					8
				},
				"chaos_raider",
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
			name = "zerker",
			weight = 5,
			breeds = {
				"chaos_fanatic",
				{
					10,
					12
				},
				"chaos_marauder",
				{
					18,
					20
				},
				"chaos_berzerker",
				{
					8,
					8
				},
				"chaos_raider",
				{
					2,
					2
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
					5,
					5
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
					14,
					16
				},
				"chaos_marauder",
				{
					18,
					20
				},
				"chaos_berzerker",
				{
					9,
					10
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
					14,
					16
				},
				"chaos_marauder",
				{
					16,
					18
				},
				"chaos_raider",
				{
					2,
					2
				},
				"chaos_berzerker",
				{
					7,
					8
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
		sound_settings = HordeCompositionsSoundSettings.chaos
	}