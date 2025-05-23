local mod = get_mod("Daredevil")

	---------------------
	--Generic event spawnsets
	HordeCompositions.event_smaller = {
		{
			name = "plain",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					5,
					7
				},
				"skaven_clan_rat",
				{
					7,
					9
				}
			}
		},
		{
			name = "mixed",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					4,
					6
				},
				"skaven_clan_rat",
				{
					6,
					7
				},
				"skaven_clan_rat_with_shield",
				{
					1,
					2
				}
			}
		},
		{
			name = "leader",
			weight = 3,
			breeds = {
				"skaven_slave",
				{
					7,
					9
				},
				"skaven_storm_vermin_commander",
				{
					1,
					2
				}
			}
		}
	}

	HordeCompositions.event_small = {
		{
			name = "plain",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					8,
					10
				},
				"skaven_clan_rat",
				{
					13,
					15
				}
			}
		},
		{
			name = "mixed",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					9,
					10
				},
				"skaven_clan_rat",
				{
					8,
					9
				},
				"skaven_clan_rat_with_shield",
				{
					3,
					4
				}
			}
		},
		{
			name = "leader",
			weight = 3,
			breeds = {
				"skaven_slave",
				{
					13,
					15
				},
				"skaven_clan_rat_with_shield",
				{
					1,
					2
				},
				"skaven_storm_vermin_commander",
				{
					1,
					1
				}
			}
		}
	}

	HordeCompositions.event_medium = {
		{
			name = "plain",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					12,
					13
				},
				"skaven_clan_rat",
				{
					28,
					31
				}
			}
		},
		{
			name = "mixed",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					16,
					18
				},
				"skaven_clan_rat",
				{
					15,
					16
				},
				"skaven_clan_rat_with_shield",
				{
					5,
					6
				}
			}
		},
		{
			name = "leader",
			weight = 3,
			breeds = {
				"skaven_slave",
				{
					14,
					17
				},
				"skaven_clan_rat",
				{
					14,
					18
				},
				"skaven_clan_rat_with_shield",
				{
					5,
					6
				},
				"skaven_storm_vermin_commander",
				{
					2,
					3
				}
			}
		}
	}

	HordeCompositions.event_large = {
		{
			name = "plain",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					22,
					26
				},
				"skaven_clan_rat",
				{
					34,
					38
				},
				"skaven_plague_monk",
				{
					3,
					4
				}
			}
		},
		{
			name = "mixed",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					14,
					17
				},
				"skaven_clan_rat",
				{
					30,
					35
				},
				"skaven_clan_rat_with_shield",
				{
					8,
					13
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
			weight = 3,
			breeds = {
				"skaven_slave",
				{
					12,
					14
				},
				"skaven_clan_rat",
				{
					20,
					22
				},
				"skaven_clan_rat_with_shield",
				{
					7,
					11
				},
				"skaven_storm_vermin_commander",
				{
					3,
					4
				}
			}
		},
		{
			name = "shielders",
			weight = 3,
			breeds = {
				"skaven_slave",
				{
					14,
					16
				},
				"skaven_clan_rat",
				{
					20,
					21
				},
				"skaven_clan_rat_with_shield",
				{
					10,
					14
				},
				"skaven_storm_vermin_with_shield",
				{
					2,
					2
				}
			}
		}
	}

	HordeCompositions.event_small_chaos = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_marauder",
				{
					10,
					13
				}
			}
		},
		{
			name = "shielders",
			weight = 3,
			breeds = {
				"chaos_marauder_with_shield",
				{
					5,
					7
				},
				"chaos_marauder",
				{
					4,
					5
				}
			}
		}
	}

	HordeCompositions.event_medium_chaos = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_marauder",
				{
					14,
					16
				},
				"chaos_fanatic",
				{
					20,
					25
				}
			}
		},
		{
			name = "shielders",
			weight = 3,
			breeds = {
				"chaos_marauder_with_shield",
				{
					5,
					6
				},
				"chaos_marauder",
				{
					4,
					5
				},
				"chaos_fanatic",
				{
					20,
					25
				}
			}
		},
		{
			name = "leader",
			weight = 5,
			breeds = {
				"chaos_marauder",
				{
					4,
					5
				},
				"chaos_fanatic",
				{
					20,
					25
				},
				"chaos_raider",
				{
					2,
					2
				}
			}
		},
		{
			name = "zerker",
			weight = 3,
			breeds = {
				"chaos_marauder",
				{
					5,
					6
				},
				"chaos_fanatic",
				{
					20,
					25
				},
				"chaos_berzerker",
				{
					1,
					2
				}
			}
		}
	}

	HordeCompositions.event_large_chaos = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_marauder",
				{
					22,
					26
				},
				"chaos_fanatic",
				{
					22,
					26
				}
			}
		},
		{
			name = "shielders",
			weight = 3,
			breeds = {
				"chaos_marauder_with_shield",
				{
					9,
					13
				},
				"chaos_marauder",
				{
					8,
					11
				},
				"chaos_fanatic",
				{
					22,
					26
				}
			}
		},
		{
			name = "leader",
			weight = 5,
			breeds = {
				"chaos_marauder",
				{
					8,
					11
				},
				"chaos_fanatic",
				{
					22,
					26
				},
				"chaos_raider",
				{
					3,
					4
				}
			}
		},
		{
			name = "zerker",
			weight = 3,
			breeds = {
				"chaos_marauder",
				{
					8,
					11
				},
				"chaos_fanatic",
				{
					22,
					26
				},
				"chaos_berzerker",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.event_extra_spice_small = {
		{
			name = "few_clanrats",
			weight = 20,
			breeds = {
				"skaven_clan_rat",
				{
					4,
					5
				},
				"skaven_clan_rat_with_shield",
				{
					6,
					7
				},
				"skaven_storm_vermin_commander",
				1
			}
		},
		{
			name = "storm_clanrats",
			weight = 2,
			breeds = {
				"skaven_clan_rat",
				{
					6,
					7
				},
				"skaven_clan_rat_with_shield",
				{
					4,
					5
				},
				"skaven_storm_vermin_with_shield",
				1
			}
		}
	}

	HordeCompositions.event_extra_spice_medium = {
		{
			name = "few_clanrats",
			weight = 10,
			breeds = {
				"skaven_clan_rat",
				{
					8,
					13
				},
				"skaven_clan_rat_with_shield",
				{
					10,
					15
				},
				"skaven_storm_vermin_commander",
				{
					2,
					3
				}
			}
		},
		{
			name = "storm_clanrats",
			weight = 3,
			breeds = {
				"skaven_clan_rat",
				{
					10,
					15
				},
				"skaven_clan_rat_with_shield",
				{
					8,
					13
				},
				"skaven_plague_monk",
				{
					1,
					2
				}
			}
		}
	}

	HordeCompositions.event_extra_spice_large = {
		{
			name = "plain",
			weight = 10,
			breeds = {
				"skaven_clan_rat",
				{
					17,
					19
				},
				"skaven_clan_rat_with_shield",
				{
					20,
					24
				},
				"skaven_storm_vermin_commander",
				{
					3,
					4
				}
			}
		},
		{
			name = "lotsofvermin",
			weight = 3,
			breeds = {
				"skaven_clan_rat",
				{
					20,
					24
				},
				"skaven_clan_rat_with_shield",
				{
					17,
					19
				},
				"skaven_storm_vermin_with_shield",
				{
					2,
					3
				}
			}
		}
	}

	TerrorEventBlueprints.generic_disable_pacing = {
		{
			"text",
			text = "",
			duration = 0
		}
	}
	TerrorEventBlueprints.generic_enable_specials = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	---------------------
	--Unscaled Onslaught variants of generic compositions

	HordeCompositions.onslaught_chaos_shields = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_marauder_with_shield",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.onslaught_chaos_berzerkers_small = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_berzerker",
				{
					2,
					3
				}
			}
		}
	}

	HordeCompositions.onslaught_chaos_berzerkers_medium = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_berzerker",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.onslaught_chaos_warriors = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_warrior",
				{
					2,
					3
				}
			}
		}
	}

	HordeCompositions.onslaught_event_small_fanatics = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_fanatic",
				{
					5,
					6
				}
			}
		}
	}

	HordeCompositions.onslaught_plague_monks_small = {
		{
			name = "mines_plague_monks",
			weight = 1,
			breeds = {
				"skaven_plague_monk",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.onslaught_plague_monks_medium = {
		{
			name = "mines_plague_monks",
			weight = 1,
			breeds = {
				"skaven_plague_monk",
				{
					4,
					5
				}
			}
		}
	}

	HordeCompositions.onslaught_storm_vermin_small = {
		{
			name = "somevermin",
			weight = 3,
			breeds = {
				"skaven_storm_vermin_commander",
				{
					2,
					3
				}
			}
		}
	}

	HordeCompositions.onslaught_storm_vermin_medium = {
		{
			name = "somevermin",
			weight = 3,
			breeds = {
				"skaven_storm_vermin_commander",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.onslaught_storm_vermin_white_medium = {
		{
			name = "somevermin",
			weight = 3,
			breeds = {
				"skaven_storm_vermin",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.onslaught_storm_vermin_shields_small = {
		{
			name = "somevermin",
			weight = 3,
			breeds = {
				"skaven_storm_vermin_with_shield",
				{
					2,
					3
				}
			}
		}
	}

	HordeCompositions.onslaught_event_military_courtyard_plague_monks = {
		{
			name = "mixed",
			weight = 1,
			breeds = {
				"skaven_plague_monk",
				{
					3,
					3
				},
				"skaven_clan_rat",
				{
					4,
					6
				}
			}
		}
	}

	HordeCompositions.onslaught_military_end_event_plague_monks = {
		{
			name = "military_plague_monks",
			weight = 1,
			breeds = {
				"skaven_plague_monk",
				{
					3,
					4
				}
			}
		}
	}

	---------------------
	--Custom compositions

	HordeCompositions.mass_trash_skaven = {
		{
			name = "plain",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					22,
					23
				},
				"skaven_clan_rat",
				{
					28,
					31
				}
			}
		}
	}

	HordeCompositions.mass_trash_skaven_mini = {
		{
			name = "plain",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					12,
					13
				},
				"skaven_clan_rat",
				{
					14,
					15
				}
			}
		}
	}

	HordeCompositions.mass_trash_chaos = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_marauder",
				{
					24,
					26
				},
				"chaos_fanatic",
				{
					20,
					25
				}
			}
		}
	}

	HordeCompositions.event_extra_spice_unshielded = {
		{
			name = "few_clanrats",
			weight = 10,
			breeds = {
				"skaven_clan_rat",
				{
					18,
					22
				},
				"skaven_clan_rat_with_shield",
				{
					5,
					7
				}
			}
		},
		{
			name = "storm_clanrats",
			weight = 5,
			breeds = {
				"skaven_clan_rat",
				{
					18,
					22
				},
				"skaven_storm_vermin_commander",
				{
					2,
					3
				}
			}
		}
	}

	HordeCompositions.skaven_shields = {
		{
			name = "plain",
			weight = 5,
			breeds = {
				"skaven_clan_rat_with_shield",
				{
					7,
					9
				}
			}
		},
		{
			name = "somevermin",
			weight = 5,
			breeds = {
				"skaven_clan_rat_with_shield",
				{
					4,
					5
				},
				"skaven_storm_vermin_with_shield",
				{
					1,
					1
				}
			}
		}
	}

	HordeCompositions.event_stormvermin_shielders = {
		{
			name = "plain",
			weight = 10,
			breeds = {
				"skaven_storm_vermin_commander",
				2,
				"skaven_storm_vermin_with_shield",
				{
					2,
					3
				}
			}
		}
	}

	HordeCompositions.event_stormvermin_special = {
		{
			name = "plain",
			weight = 10,
			breeds = {
				"skaven_storm_vermin",
				3,
			}
		}
	}

	HordeCompositions.event_maulers_small = {
		{
			name = "plain",
			weight = 10,
			breeds = {
				"chaos_raider",
				{
					2,
					3
				}
			}
		}
	}

	HordeCompositions.event_maulers_medium = {
		{
			name = "plain",
			weight = 10,
			breeds = {
				"chaos_raider",
				{
					5,
					6
				}
			}
		}
	}

	HordeCompositions.event_bestigors_medium = {
		{
			name = "plain",
			weight = 10,
			breeds = {
				"beastmen_bestigor",
				{
					5,
					6
				}
			}
		}
	}

	---------------------
	--Custom specials & bosses

	HordeCompositions.onslaught_custom_special_denial = {
		{
			name = "gasrat",
			weight = 10,
			breeds = {
				"skaven_poison_wind_globadier",
				{
					1,
					1
				}
			}
		},
		{
			name = "gunner",
			weight = 10,
			breeds = {
				"skaven_ratling_gunner",
				{
					1,
					1
				}
			}
		},
		{
			name = "stormer",
			weight = 10,
			breeds = {
				"chaos_vortex_sorcerer",
				{
					1,
					1
				}
			}
		},
	}

	HordeCompositions.onslaught_custom_specials_heavy_denial = {
		{
			name = "gasrat",
			weight = 10,
			breeds = {
				"skaven_poison_wind_globadier",
				{
					2,
					2
				},
				"skaven_ratling_gunner",
				{
					1,
					1
				},
				"chaos_vortex_sorcerer",
				{
					1,
					1
				}
			}
		},
		{
			name = "gunner",
			weight = 10,
			breeds = {
				"skaven_poison_wind_globadier",
				{
					1,
					1
				},
				"skaven_ratling_gunner",
				{
					2,
					2
				},
				"chaos_vortex_sorcerer",
				{
					1,
					1
				}
			}
		},
		{
			name = "stormer",
			weight = 10,
			breeds = {
				"skaven_poison_wind_globadier",
				{
					1,
					1
				},
				"skaven_ratling_gunner",
				{
					1,
					1
				},
				"chaos_vortex_sorcerer",
				{
					2,
					2
				}
			}
		},
	}

	HordeCompositions.onslaught_custom_special_disabler = {
		{
			name = "assassin",
			weight = 10,
			breeds = {
				"skaven_gutter_runner",
				{
					1,
					1
				}
			}
		},
		{
			name = "packmaster",
			weight = 10,
			breeds = {
				"skaven_pack_master",
				{
					1,
					1
				}
			}
		},
		{
			name = "leech",
			weight = 10,
			breeds = {
				"chaos_corruptor_sorcerer",
				{
					1,
					1
				}
			}
		},
	}

	HordeCompositions.onslaught_custom_specials_heavy_disabler = {
		{
			name = "assassin",
			weight = 10,
			breeds = {
				"skaven_gutter_runner",
				{
					2,
					2
				},
				"skaven_pack_master",
				{
					1,
					1
				}
			}
		},
		{
			name = "packmaster",
			weight = 10,
			breeds = {
				"skaven_pack_master",
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
			name = "leech",
			weight = 10,
			breeds = {
				"chaos_corruptor_sorcerer",
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
		{
			name = "mixed",
			weight = 10,
			breeds = {
				"skaven_gutter_runner",
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
				}
			}
		}
	}

	HordeCompositions.onslaught_custom_special_skaven = {
		{
			name = "assassin",
			weight = 10,
			breeds = {
				"skaven_gutter_runner",
				{
					1,
					1
				}
			}
		},
		{
			name = "packmaster",
			weight = 10,
			breeds = {
				"skaven_pack_master",
				{
					1,
					1
				}
			}
		},
		{
			name = "gasrat",
			weight = 10,
			breeds = {
				"skaven_poison_wind_globadier",
				{
					1,
					1
				}
			}
		},
		{
			name = "gunner",
			weight = 10,
			breeds = {
				"skaven_ratling_gunner",
				{
					1,
					1
				}
			}
		},
		{
			name = "warpfire",
			weight = 10,
			breeds = {
				"skaven_warpfire_thrower",
				{
					1,
					1
				}
			}
		}
	}

	HordeCompositions.onslaught_custom_boss_ogre = {
		{
			name = "ogre",
			weight = 10,
			breeds = {
				"skaven_rat_ogre",
				{
					1,
					1
				}
			}
		},
	}

	HordeCompositions.onslaught_custom_boss_stormfiend = {
		{
			name = "fiend",
			weight = 10,
			breeds = {
				"skaven_stormfiend",
				{
					1,
					1
				}
			}
		},
	}

	HordeCompositions.onslaught_custom_boss_spawn = {
		{
			name = "spawn",
			weight = 10,
			breeds = {
				"chaos_spawn",
				{
					1,
					1
				}
			}
		},
	}

	HordeCompositions.onslaught_custom_boss_troll = {
		{
			name = "troll",
			weight = 10,
			breeds = {
				"chaos_troll",
				{
					1,
					1
				}
			}
		},
	}

	HordeCompositions.onslaught_custom_boss_minotaur = {
		{
			name = "mino",
			weight = 10,
			breeds = {
				"beastmen_minotaur",
				{
					1,
					1
				}
			}
		},
	}

	HordeCompositions.onslaught_custom_boss_random = {
		{
			name = "ogre",
			weight = 5,
			breeds = {
				"skaven_rat_ogre",
				{
					1,
					1
				}
			}
		},
		{
			name = "fiend",
			weight = 5,
			breeds = {
				"skaven_stormfiend",
				{
					1,
					1
				}
			}
		},
		{
			name = "spawn",
			weight = 5,
			breeds = {
				"chaos_spawn",
				{
					1,
					1
				}
			}
		},
		{
			name = "troll",
			weight = 5,
			breeds = {
				"chaos_troll",
				{
					1,
					1
				}
			}
		}
	}


	HordeCompositions.onslaught_custom_boss_random_no_fiend = {
		{
			name = "ogre",
			weight = 5,
			breeds = {
				"skaven_rat_ogre",
				{
					1,
					1
				}
			}
		},
		{
			name = "spawn",
			weight = 5,
			breeds = {
				"chaos_spawn",
				{
					1,
					1
				}
			}
		},
		{
			name = "troll",
			weight = 5,
			breeds = {
				"chaos_troll",
				{
					1,
					1
				}
			}
		}
	}

	HordeCompositions.onslaught_custom_boss_ogre_or_troll = {
		{
			name = "ogre",
			weight = 5,
			breeds = {
				"skaven_rat_ogre",
				{
					1,
					1
				}
			}
		},
		{
			name = "troll",
			weight = 5,
			breeds = {
				"chaos_troll",
				{
					1,
					1
				}
			}
		}
	}

	-- Daredevil Custom
	HordeCompositions.cheekspreader = {
		{
			name = "warcamp_lord",
			weight = 10,
			breeds = {
				"chaos_exalted_champion_warcamp",
				{
					1,
					1
				}
			}
		},
	} 

	HordeCompositions.skarikkspawn = {
		{
			name = "nest_lord",
			weight = 10,
			breeds = {
				"skaven_storm_vermin_warlord",
				{
					1,
					1
				}
			}
		},
	} 

	HordeCompositions.norscaballs = {
		{
			name = "warcamp_lord",
			weight = 10,
			breeds = {
				"chaos_exalted_champion_norsca",
				{
					1,
					1
				}
			}
		},
	} 


	HordeCompositions.onslaught_skaven_double_wave = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"skaven_slave",
				{
					20,
					20
				},
				"skaven_clan_rat",
				{
					12,
					15
				},
				"skaven_storm_vermin_commander",
				{
					10,
					12
				},
				"skaven_plague_monk",
				{
					13,
					15
				},
			}
		}
	}
	
	HordeCompositions.onslaught_chaos_double_wave = {
		{
			name = "plain",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					20,
					20
				},
				"chaos_marauder",
				{
					15,
					18
				},
				"chaos_raider",
				{
					7,
					8
				},
				"chaos_berzerker",
				{
					12,
					14
				},
				"chaos_warrior",
				{
					2,
					2
				}
			}
		}
	}

	-- Dense Skaven Compositions

HordeCompositions.dn_skaven_slave_trash = {
	{
		name = "plain",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				15,
				20
			},
			"skaven_clan_rat",
			{
				20,
				25
			}
		}
	}
}

HordeCompositions.dn_skaven_shielded_trash = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"skaven_clan_rat",
			{
				17,
				19
			},
			"skaven_clan_rat_with_shield",
			{
				20,
				24
			}
		}
	}
}

HordeCompositions.dn_skaven_trash = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"skaven_clan_rat",
			{
				17,
				19
			},
			"skaven_clan_rat_with_shield",
			{
				20,
				24
			}
		}
	},
	{
		name = "shielders",
		weight = 10,
		breeds = {
			"skaven_clan_rat",
			{
				17,
				19
			},
			"skaven_clan_rat_with_shield",
			{
				20,
				24
			}
		}
	}

}

HordeCompositions.dn_skaven_elites = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"skaven_storm_vermin_commander",
			{
				3,
				4
			}
		}
	},
	{
		name = "zerker",
		weight = 10,
		breeds = {
			"skaven_plague_monk",
			{
				4,
				5
			}
		}
	},
	{
		name = "armored",
		weight = 10,
		breeds = {
			"skaven_storm_vermin",
			{
				2,
				3
			}
		}
	}
}

HordeCompositions.dn_white_stormvermin = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"skaven_storm_vermin",
			{
				3,
				4
			}
		}
	}
}

HordeCompositions.dn_stormvermin = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"skaven_storm_vermin_commander",
			{
				3,
				4
			}
		}
	}
}

HordeCompositions.dn_plague_monks = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"skaven_plague_monk",
			{
				3,
				4
			}
		}
	}
}

HordeCompositions.dn_skaven_pursuit = {
	{
		name = "mixed",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				14,
				17
			},
			"skaven_clan_rat",
			{
				30,
				35
			},
			"skaven_clan_rat_with_shield",
			{
				8,
				13
			},
			"skaven_plague_monk", 
			{
				3,
				4
			}
		}
	},
	{
		name = "leader",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				12,
				14
			},
			"skaven_clan_rat",
			{
				20,
				22
			},
			"skaven_clan_rat_with_shield",
			{
				7,
				11
			},
			"skaven_storm_vermin_commander",
			{
				3,
				4
			}
		}
	},
	{
		name = "shielders",
		weight = 5,
		breeds = {
			"skaven_slave",
			{
				14,
				16
			},
			"skaven_clan_rat",
			{
				20,
				21
			},
			"skaven_clan_rat_with_shield",
			{
				7,
				10
			},
			"skaven_storm_vermin_commander",
			{
				2,
				2
			},
			"skaven_plague_monk", 
			{
				3,
				4
			}
		}
	}
}



-- Dense Chaos Horde Comps

HordeCompositions.dn_chaos_trash = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_fanatic",
			{
				22,
				26
			},
			"chaos_marauder",
			{
				12,
				16
			},
			"chaos_marauder_with_shield",
			{
				3,
				9
			}
		}
	},
	{
		name = "shielders",
		weight = 10,
		breeds = {
			"chaos_fanatic",
			{
				18,
				24
			},
			"chaos_marauder",
			{
				12,
				16
			},
			"chaos_marauder_with_shield",
			{
				12,
				16
			}
		}
	}
}

HordeCompositions.dn_chaos_shielded_trash = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_fanatic",
			{
				18,
				24
			},
			"chaos_marauder",
			{
				12,
				16
			},
			"chaos_marauder_with_shield",
			{
				12,
				16
			},
		}
	}
}

HordeCompositions.dn_chaos_elites = {
	{
		name = "plain",
		weight = 10,
		breeds = {
		"chaos_raider",
			{
				3,
				4
			}
		}
	},
	{
		name = "zerker",
		weight = 10,
		breeds = {
		"chaos_berzerker",
			{
				4,
				5
			}
		}
	},
}

HordeCompositions.dn_chaos_zerkers_light = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_berzerker",
			{
				3,
				5
			}
		}
	}
}

HordeCompositions.dn_chaos_zerkers = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_berzerker",
			{
				5,
				7
			}
		}
	}
}

HordeCompositions.dn_chaos_maulers = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_raider",
			{
				4,
				7
			}
		}
	}
}

HordeCompositions.dn_chaos_zerkers_heavy = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_berzerker",
			{
				7,
				10
			}
		}
	}
}

HordeCompositions.dn_chaos_warriors_light = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_warrior",
			{
				1,
				2
			}
		}
	}
}

HordeCompositions.dn_chaos_warriors = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_warrior",
			{
				2,
				3
			}
		}
	}
}

HordeCompositions.dn_chaos_warriors_heavy = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_warrior",
			{
				3,
				4
			}
		}
	}
}

-- Dense Mixed Horde Comps

HordeCompositions.dn_mixed_super_armor = {
	{
		name = "plain",
		weight = 10,
		breeds = {
			"chaos_warrior",
			{
				8,
				8
			},
			"skaven_storm_vermin",
			{
				4,
				4
			}
			
		}
	}	
}

-- Dense Beastmen

-- Dense Specials

HordeCompositions.dn_specials_heavy_disabler = {
	{
		name = "assassin",
		weight = 10,
		breeds = {
			"skaven_gutter_runner",
			{
				2,
				2
			},
			"skaven_pack_master",
			{
				1,
				1
			}
		}
	},
	{
		name = "packmaster",
		weight = 10,
		breeds = {
			"skaven_pack_master",
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
		name = "leech",
		weight = 10,
		breeds = {
			"chaos_corruptor_sorcerer",
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
	{
		name = "mixed",
		weight = 10,
		breeds = {
			"skaven_gutter_runner",
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
			}
		}
	}
}

HordeCompositions.dn_ratling_spam = {
	{
		name = "ratling_guns",
		weight = 10,
		breeds = {
			"skaven_ratling_gunner",
			{
				5,
				5
			}
		}
	}
}

HordeCompositions.dn_warpfire_spam = {
	{
		name = "warpfires",
		weight = 10,
		breeds = {
			"skaven_warpfire_thrower",
			{
				4,
				4
			}
		}
	}
}

HordeCompositions.dn_packmaster_spam = {
	{
		name = "packmasterz",
		weight = 10,
		breeds = {
			"skaven_pack_master",
			{
				5,
				5
			}
		}
	}
}

HordeCompositions.athel_assassin_fire_combo = {
	{
		name = "assassin",
		weight = 10,
		breeds = {
			"skaven_gutter_runner",
			{
				1,
				1
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
}

HordeCompositions.athel_wdnmd = {
	{
		name = "assassin", -- this sounds bad
		weight = 10,
		breeds = {
			"skaven_gutter_runner",
			{
				1,
				1
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
	{
		name = "packmaster",
		weight = 10,
		breeds = {
			"skaven_pack_master",
			{
				1,
				1
			},
			"skaven_warpfire_thrower",
			{
				1,
				1
			}
		}
	},
	{
		name = "gunner",
		weight = 10,
		breeds = {
			"skaven_pack_master",
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
		name = "gas",
		weight = 5,
		breeds = {
			"skaven_gutter_runner",
			{
				1,
				1
			},
			"skaven_poison_wind_globadier",
			{
				1,
				1
			}
		}
	}
}

HordeCompositions.linesman_mixed_horde = {
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
	}
}

HordeCompositions.apocalypse_wave = {
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
                13,
                15,
            },
            "skaven_clan_rat",
            {
                13,
                15,
            },
            "skaven_slave",
            {
                20,
                21,
            },
            "skaven_plague_monk",
            {
                3,
                3,
            },
            "chaos_berzerker",
            {
                3,
                3,
            },
            "chaos_raider",
            {
                3,
                3,
            },
            "skaven_storm_vermin_commander",
            {
                3,
                4,
            },
            "chaos_warrior", 
            {
                1,
                1
            }
        },
    },
}

HordeCompositions.crackaddicts = {
	{
		name = "drugs",
		weight = 10,
		breeds = {
			"beastmen_ungor_archer",
			{
				30,
				30
			}
		}
	},
} 

HordeCompositions.crackaddicts_mini = {
	{
		name = "drugs",
		weight = 10,
		breeds = {
			"beastmen_ungor_archer",
			{
				15,
				15
			}
		}
	},
} 

HordeCompositions.highasf = {
	{
		name = "drugs",
		weight = 10,
		breeds = {
			"beastmen_bestigor",
			{
				10,
				13
			}
		}
	},
} 

HordeCompositions.banners = {
	{
		name = "drugs",
		weight = 10,
		breeds = {
			"beastmen_standard_bearer",
			{
				1,
				1
			}
		}
	},
} 

HordeCompositions.event_small_beastmen = {
	{
		name = "plain",
		weight = 7,
		breeds = {
			"beastmen_gor",
			{
				13,
				14
			}
		}
	},
	{
		name = "mixed",
		weight = 3,
		breeds = {
			"beastmen_ungor",
			{
				3,
				4
			},
			"beastmen_gor",
			{
				9,
				10
			}
		}
	}
}

HordeCompositions.event_medium_beastmen = {
	{
		name = "plain",
		weight = 7,
		breeds = {
			"beastmen_gor",
			{
				16,
				17
			},
			"beastmen_ungor",
			{
				8,
				9
			}
		}
	},
	{
		name = "mixed",
		weight = 3,
		breeds = {
			"beastmen_gor",
			{
				7,
				8
			},
			"beastmen_ungor",
			{
				15,
				16
			}
		}
	}
}

HordeCompositions.event_large_beastmen = {
	{
		name = "plain",
		weight = 7,
		breeds = {
			"beastmen_gor",
			{
				18,
				19
			},
			"beastmen_ungor",
			{
				16,
				17
			}
		}
	},
	{
		name = "mixed",
		weight = 3,
		breeds = {
			"beastmen_gor",
			{
				22,
				23
			},
			"beastmen_ungor",
			{
				14,
				15
			}
		}
	}
}

HordeCompositions.crater_bestigor_medium = {
	{
		name = "ambestigor",
		weight = 3,
		breeds = {
			"beastmen_bestigor",
			{
				9,
				10
			},
		}
	}
}

HordeCompositions.event_balls = {
    {
        name = "plain",
        weight = 5,
        breeds = {
            "skaven_clan_rat",
            {
                40,
                45
            }
        }
    },
}

HordeCompositions.wave_1 = { -- 8
	{
		name = "wave_1",
		weight = 1,
		breeds = {
			"skaven_storm_vermin_commander",
			{
				3,
				3
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
	}
}

HordeCompositions.wave_2 = { -- 10
	{
		name = "wave_2",
		weight = 1,
		breeds = {
			"skaven_storm_vermin_commander",
			{
				6,
				6
			},
			"skaven_storm_vermin",
			{
				4,
				4
			},
		}
	}
}

HordeCompositions.wave_3 = { 
	{
		name = "wave_3",
		weight = 1,
		breeds = {
			"skaven_storm_vermin_commander",
			{
				6,
				6
			},
			"skaven_plague_monk",
			{
				7,
				7
			}
		}
	}
}

HordeCompositions.wave_1 = {
	{
		name = "wave_1",
		weight = 1,
		breeds = {
			"skaven_storm_vermin_commander",
			{
				3,
				3
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
	}
}

HordeCompositions.tarnished = {
    {
        name = "mixed",
        weight = 15,
        breeds = {"chaos_marauder", {9, 9,}, "chaos_fanatic", {10, 12,}, "skaven_clan_rat", {10, 12,}, "skaven_slave", {17, 18,}, "skaven_plague_monk", {2, 2,}, "chaos_berzerker", {2, 2,}, "chaos_raider", {1, 1,}, "skaven_storm_vermin_commander", {2, 2,}, "chaos_warrior", {1, 1} },
    },
    {
        name = "shield_leader",	
        weight = 7, 
        breeds = {"skaven_plague_monk", {3, 3}, "skaven_clan_rat", {10, 12,}, "skaven_slave", {17, 18,}, "skaven_storm_vermin_commander", {3, 3}, "skaven_clan_rat_with_shield", {6, 8}, "skaven_warpfire_thrower", {1, 1}, "chaos_warrior", {1, 1} }
    },
    {
        name = "armored_leader",
        weight = 5,
        breeds = {"skaven_clan_rat", {10, 12,}, "skaven_slave", {17, 18,}, "skaven_storm_vermin_commander", {4, 4}, "skaven_plague_monk", {3, 3}, "skaven_warpfire_thrower", {1, 1}}
    },
    {
        name = "berserker_leader",
        weight = 5,
        breeds = {"skaven_plague_monk", {4, 4}, "skaven_storm_vermin_commander", {3, 3}, "skaven_clan_rat", {10, 12,}, "skaven_slave", {17, 18,}, "skaven_ratling_gunner", {1, 1}}
    },
    {
        name = "chaos_shield_leader",
        weight = 7,
		breeds = {"chaos_fanatic", {17, 20}, "chaos_marauder", {14, 16}, "chaos_raider", {3, 3}, "chaos_berzerker", {3, 3}, "chaos_marauder_with_shield", {6, 7}, "skaven_warpfire_thrower", {1, 1}}
    },
    {
        name = "chaos_berserker_leader",
        weight = 4,
        breeds = {"chaos_fanatic", {17, 20}, "chaos_marauder", {14, 16}, "chaos_raider", {3, 3}, "chaos_berzerker", {4, 4}, "skaven_ratling_gunner", {1, 1}, "chaos_warrior", 1}
    },
    {
        name = "chaos_armored_leader",
        weight = 4,
        breeds = {"chaos_fanatic", {17, 20}, "chaos_marauder", {14, 16}, "chaos_raider", {4, 4}, "chaos_berzerker", {3	, 3}, "skaven_ratling_gunner", {1, 1}, "chaos_warrior", 1}
    },
}