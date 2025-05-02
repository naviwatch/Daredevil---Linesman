local mod = get_mod("Daredevil")

	Breeds.skaven_rat_ogre.threat_value = 25
	Breeds.skaven_stormfiend.threat_value = 25
	Breeds.chaos_spawn.threat_value = 25
	Breeds.chaos_troll.threat_value = 25
	Breeds.beastmen_minotaur.threat_value = 25

	--[[
	Managers.state.conflict:set_threat_value("skaven_rat_ogre", 25)
	Managers.state.conflict:set_threat_value("skaven_stormfiend", 25)
	Managers.state.conflict:set_threat_value("chaos_spawn", 25)
	Managers.state.conflict:set_threat_value("chaos_troll", 25)
	Managers.state.conflict:set_threat_value("beastmen_minotaur", 25)
	]]
	
	--[[
	mod:hook_origin(LevelAnalysis, "_give_events", function (self, main_paths, terror_spawners, generated_event_list, terror_event_list, conflict_director_section_list, terror_event_category)
		local spawn_distance = 0
		local padding = 10
		local start_index, end_index
		local map_start_section = self._skip_to_map_section or 1
	
		for i = map_start_section, #conflict_director_section_list do
			local boxed_pos, gizmo_unit, event_data
			local terror_event_kind = generated_event_list[i]
			local terror_event_name, override_spawn_distance
			local director = conflict_director_section_list[i]
			local boss_settings = director.boss
			local event_settings = boss_settings[terror_event_category]
	
			if terror_event_kind == "event_boss" or terror_event_kind == "event_patrol" then
				local event_lookup = event_settings.event_lookup
				local terror_events = event_lookup[terror_event_kind]
	
				terror_event_name = terror_events[self:_random(#terror_events)]
	
				local patrol_success, dist, fail_reason
	
				if terror_event_kind == "event_patrol" then
					patrol_success, fail_reason, boxed_pos, event_data, dist = self:pick_boss_spline(i, padding, spawn_distance)
	
					fassert(patrol_success, "[LevelAnalysis] Failed finding patrol spline! [reason=%s]", fail_reason)
					print(" ----> using boss spline path!")
	
					spawn_distance = dist
					override_spawn_distance = dist
				else
					local override_boss_events = Managers.mechanism:mechanism_setting_for_title("playable_boss_terror_events")
	
					if override_boss_events then
						local available_bosses_events = FrameTable.alloc_table()
	
						for playable_boss, playable_boss_events in pairs(override_boss_events) do
							if PlayerUtils.get_career_override(playable_boss) then
								table.append(available_bosses_events, playable_boss_events)
							end
						end
	
						if not table.is_empty(available_bosses_events) then
							terror_event_name = table.random(available_bosses_events)
						end
					end
	
					print(" ----> using boss gizmo!")
	
					local data = terror_spawners[terror_event_kind]
					local level_sections = data.level_sections
					local spawners = data.spawners
	
					start_index = level_sections[i]
					end_index = level_sections[i + 1] - 1
	
					fassert(start_index <= end_index, "Level Error: Too few boss-gizmo spawners of type '%s' in section %d: start-index: %d, end-index: %d,", terror_event_kind, i, tostring(start_index), tostring(end_index))
	
					local start_travel_dist = spawners[start_index][2]
					local end_travel_dist = spawners[end_index][2]
					local forbidden_dist = padding - (start_travel_dist - spawn_distance)
	
					print(string.format("[LevelAnalysis] section: %d, start-index: %d, end-index: %d, forbidden-dist: %.1f start-travel-dist: %.1f, end-travel-dist: %.1f spawn_distance %.1f", i, start_index, end_index, forbidden_dist, start_travel_dist, end_travel_dist, spawn_distance))
	
					if forbidden_dist > 0 then
						local forbidden_travel_dist = start_travel_dist + forbidden_dist
						local new_start_index
	
						for j = start_index, end_index do
							local travel_dist = spawners[j][2]
	
							if forbidden_travel_dist <= travel_dist then
								new_start_index = j
	
								break
							else
								print("[LevelAnalysis] \t\t--> since forbidden dist, skipping spawner ", j, " at distance,", travel_dist)
							end
						end
	
						if new_start_index then
							print("[LevelAnalysis] \t\t--> found new spawner ", new_start_index, " at distance,", spawners[new_start_index][2], " passing forbidden dist:", forbidden_travel_dist)
	
							start_index = new_start_index
						else
							print(string.format("[LevelAnalysis] failed to find spawner - too few spawners in section %d, forbidden-dist %.1f from: %.1f to: %.1f", i, forbidden_dist, forbidden_travel_dist, end_travel_dist))
							print("[LevelAnalysis] \t\t--> fallback -> using main-path spawning for section", i, forbidden_travel_dist, end_travel_dist)
	
							local random_dist = self:_random_float_interval(forbidden_travel_dist, end_travel_dist)
							local pos = MainPathUtils.point_on_mainpath(main_paths, random_dist)
	
							if pos then
								spawn_distance = random_dist
								boxed_pos = Vector3Box(pos)
								event_data = {
									event_kind = terror_event_kind,
								}
							else
								print("[LevelAnalysis] \t\t--> fallback 2 -> pick any spawner in segment (MIGHT GET BOSSES VERY CLOSE TO EACHOTHER)", i)
	
								start_index = level_sections[i]
							end
						end
					end
	
					if not boxed_pos then
						local spawner_index = self:_random(start_index, end_index)
						local spawner = spawners[spawner_index]
						local spawner_pos = Unit.local_position(spawner[1], 0)
	
						boxed_pos = Vector3Box(spawner_pos)
						gizmo_unit = spawner[1]
						spawn_distance = spawner[2]
						event_data = {
							gizmo_unit = gizmo_unit,
							event_kind = terror_event_kind,
						}
					end
				end
			elseif terror_event_kind == "event_special" then -- encampment wont be used anyways so we'll override this with our own L
				-- id love to do it how fatshark did but i cannot be assed to figure it out so therefore we're going to use a horrible workaround method
				-- \(˚☐˚”)/ 
				local conflict_director = Managers.state.conflict
				terror_event_name = "darktide"

				-- Completely steal the stuff for event_bosses to determine when and where to trigger the special spam
				local data = terror_spawners["event_boss"]
				local level_sections = data.level_sections
				local spawners = data.spawners

				start_index = level_sections[i]
				end_index = level_sections[i + 1] - 1

				fassert(start_index <= end_index, "Level Error: Too few boss-gizmo spawners of type '%s' in section %d: start-index: %d, end-index: %d,", terror_event_kind, i, tostring(start_index), tostring(end_index))

				local start_travel_dist = spawners[start_index][2]
				local end_travel_dist = spawners[end_index][2]
				local forbidden_dist = padding - (start_travel_dist - spawn_distance)

				print(string.format("[LevelAnalysis] section: %d, start-index: %d, end-index: %d, forbidden-dist: %.1f start-travel-dist: %.1f, end-travel-dist: %.1f spawn_distance %.1f", i, start_index, end_index, forbidden_dist, start_travel_dist, end_travel_dist, spawn_distance))

				if forbidden_dist > 0 then
					local forbidden_travel_dist = start_travel_dist + forbidden_dist
					local new_start_index

					for j = start_index, end_index do
						local travel_dist = spawners[j][2]

						if forbidden_travel_dist <= travel_dist then
							new_start_index = j

							break
						else
							print("[LevelAnalysis] \t\t--> since forbidden dist, skipping spawner ", j, " at distance,", travel_dist)
						end
					end

					if new_start_index then
						print("[LevelAnalysis] \t\t--> found new spawner ", new_start_index, " at distance,", spawners[new_start_index][2], " passing forbidden dist:", forbidden_travel_dist)

						start_index = new_start_index
					else
						print(string.format("[LevelAnalysis] failed to find spawner - too few spawners in section %d, forbidden-dist %.1f from: %.1f to: %.1f", i, forbidden_dist, forbidden_travel_dist, end_travel_dist))
						print("[LevelAnalysis] \t\t--> fallback -> using main-path spawning for section", i, forbidden_travel_dist, end_travel_dist)

						local random_dist = self:_random_float_interval(forbidden_travel_dist, end_travel_dist)
						local pos = MainPathUtils.point_on_mainpath(main_paths, random_dist)

						if pos then
							spawn_distance = random_dist
							boxed_pos = Vector3Box(pos)
							event_data = {
								event_kind = "event_special",
							}
						else
							print("[LevelAnalysis] \t\t--> fallback 2 -> pick any spawner in segment (MIGHT GET BOSSES VERY CLOSE TO EACHOTHER)", i)

							start_index = level_sections[i]
						end
					end
				end

				if not boxed_pos then
					local spawner_index = self:_random(start_index, end_index)
					local spawner = spawners[spawner_index]
					local spawner_pos = Unit.local_position(spawner[1], 0)

					boxed_pos = Vector3Box(spawner_pos)
					gizmo_unit = spawner[1]
					spawn_distance = spawner[2]
					event_data = {
						gizmo_unit = gizmo_unit,
						event_kind = terror_event_kind,
					}
				end
			else
				terror_event_name = "nothing"
	
				local data = terror_spawners.event_boss
				local level_sections = data.level_sections
				local spawners = data.spawners
				local start_index = level_sections[i]
				local end_index = level_sections[i + 1] - 1
				local index = math.floor((start_index + end_index) / 2)
	
				index = math.clamp(index, start_index, level_sections[i + 1])
	
				local spawner = spawners[index]
	
				boxed_pos = Vector3Box(Unit.local_position(spawner[1], 0))
				gizmo_unit = spawner[1]
				spawn_distance = spawner[2]
			end
	
			if terror_event_kind ~= "nothing" then
				if event_settings.terror_events_using_packs then
					self.enemy_recycler:add_terror_event_in_area(boxed_pos, terror_event_name, event_data)
				else
					local override_boss_activation_distance = terror_event_kind == "event_boss" and Managers.mechanism:mechanism_setting_for_title("override_boss_activation_distance")
					local activation_distance = override_boss_activation_distance or 45
					local spawn_dist
	
					if override_spawn_distance then
						spawn_dist = override_spawn_distance - activation_distance
					end
	
					self.enemy_recycler:add_main_path_terror_event(boxed_pos, terror_event_name, activation_distance, event_data, spawn_dist)
				end
			end
	
			local debug_color_name = event_settings and event_settings.debug_color or "deep_pink"
	
			terror_event_list[#terror_event_list + 1] = {
				boxed_pos,
				terror_event_name,
				spawn_distance,
				debug_color_name,
			}
		end
	end)
	]]

	--[[
	if mod:get("beta") then 
		BossSettings.default.event_lookup = {
			event_boss = {"boss_event_chaos_troll", "boss_event_chaos_spawn", "boss_event_storm_fiend", "boss_event_rat_ogre",},
			event_patrol = {"boss_event_spline_patrol"},
			event_special = {"darktide"}
		}

		BossSettings.default_light.event_lookup = {
			event_boss = {"boss_event_chaos_troll", "boss_event_chaos_spawn", "boss_event_storm_fiend", "boss_event_rat_ogre",},
			event_patrol = {"boss_event_spline_patrol"},
			event_special = {"darktide"}
		}

		BossSettings.skaven.event_lookup = {
			event_boss = {"boss_event_chaos_troll", "boss_event_chaos_spawn", "boss_event_storm_fiend", "boss_event_rat_ogre",},
			event_patrol = {"boss_event_spline_patrol"},
			event_special = {"darktide"}
		}

		BossSettings.skaven_light.event_lookup = {
			event_boss = {"boss_event_chaos_troll", "boss_event_chaos_spawn", "boss_event_storm_fiend", "boss_event_rat_ogre",},
			event_patrol = {"boss_event_spline_patrol"},
			event_special = {"darktide"}
		}
		
		BossSettings.chaos.event_lookup = {
			event_boss = {"boss_event_chaos_troll", "boss_event_chaos_spawn", "boss_event_storm_fiend", "boss_event_rat_ogre",},
			event_patrol = {"boss_event_spline_patrol"},
			event_special = {"darktide"}
		}

		BossSettings.chaos_light.event_lookup = {
			event_boss = {"boss_event_chaos_troll", "boss_event_chaos_spawn", "boss_event_storm_fiend", "boss_event_rat_ogre",},
			event_patrol = {"boss_event_spline_patrol"},
			event_special = {"darktide"}
		}

		BossSettings.default.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.default_light.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.skaven.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.skaven_light.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.chaos.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.chaos_light.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.beastmen.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.skaven_beastmen.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.chaos_beastmen.boss_events.events = {"event_boss", "event_patrol", "event_special"}
		BossSettings.beastmen_light.boss_events.events = {"event_boss", "event_patrol", "event_special"}

		-- Limit each stuff to 1 only 
		mod:hook(LevelAnalysis, "_hand_placed_terror_creation", function(func, self, main_paths, terror_event_list, terror_event_category)
			local num_sections, conflict_director_section_list
			local terror_spawners = self.terror_spawners
			local last_num_sections, last_event_type
		
			for event_type, data in pairs(terror_spawners) do
				print("[LevelAnalysis] grouping spawners for ", event_type)
		
				num_sections, conflict_director_section_list = self:group_spawners(data.spawners, data.level_sections)
		
				if last_num_sections and num_sections ~= last_num_sections then
					error("Not all sectors has boss event gizmos in level for  " .. (num_sections < last_num_sections and event_type or last_event_type))
				end
		
				last_num_sections = num_sections
				last_event_type = event_type
		
				print("[LevelAnalysis] ")
			end

			local max_events_of_this_kind = {
				event_boss = 1,
				event_patrol = 1,
				event_special = 1
			}
			local generated_event_list = self:_generate_event_name_list(conflict_director_section_list, max_events_of_this_kind, terror_event_category)
		
			self:_override_generated_event_list(generated_event_list, conflict_director_section_list, terror_event_category)
		
			return func(self, main_paths, terror_event_list, terror_event_category)
		end)
	else
		]]
		BossSettings.default.boss_events.event_lookup.event_boss = {"boss_event_chaos_troll", "boss_event_chaos_spawn", "boss_event_storm_fiend", "boss_event_rat_ogre"}
		BossSettings.default_light.boss_events.event_lookup.event_boss = {"boss_event_chaos_troll", "boss_event_chaos_spawn", "boss_event_storm_fiend", "boss_event_rat_ogre"}
		
		BossSettings.default.boss_events.events = {"event_boss", "event_patrol"}
		BossSettings.default_light.boss_events.events = {"event_boss", "event_patrol"}
		BossSettings.skaven.boss_events.events = {"event_boss", "event_patrol"}
		BossSettings.skaven_light.boss_events.events = {"event_boss", "event_patrol"}
		BossSettings.chaos.boss_events.events = {"event_boss", "event_patrol",}
		BossSettings.chaos_light.boss_events.events = {"event_boss", "event_patrol",}
		BossSettings.beastmen.boss_events.events = {"event_boss", "event_patrol"}
		BossSettings.skaven_beastmen.boss_events.events = {"event_boss", "event_patrol",}
		BossSettings.chaos_beastmen.boss_events.events = {"event_boss", "event_patrol",}
		BossSettings.beastmen_light.boss_events.events = {"event_boss", "event_patrol"}

	-- Settings required to allow Plague Monks in Patrols 
	Breeds.skaven_plague_monk.patrol_active_perception = "perception_regular"
	Breeds.skaven_plague_monk.patrol_passive_perception = "perception_regular"
	Breeds.skaven_plague_monk.patrol_active_target_selection = "storm_patrol_death_squad_target_selection"
	Breeds.skaven_plague_monk.patrol_passive_target_selection = "patrol_passive_target_selection"
	Breeds.skaven_plague_monk.dont_wield_weapon_on_patrol = true
	Breeds.skaven_plague_monk.patrol_detection_radius = 10
	Breeds.skaven_plague_monk.panic_close_detection_radius_sq = 9
	Breeds.skaven_plague_monk.passive_in_patrol_start_anim = "move_fwd"
	
	BeastmenStandardTemplates.healing_standard.radius = 10
	UtilityConsiderations.beastmen_place_standard.distance_to_target.max_value = 15
	GenericTerrorEvents.boss_event_beastmen_spline_patrol = {
		{
			"spawn_patrol",
			patrol_template = "spline_patrol",
			formations = {
				"beastmen_standard",
				"storm_vermin_two_column",
				"chaos_warrior_default"
			}
		}
	}

	GenericTerrorEvents.boss_event_skaven_beastmen_spline_patrol = {
		{
			"spawn_patrol",
			patrol_template = "spline_patrol",
			formations = {
				"beastmen_standard",
				"storm_vermin_two_column",
				"chaos_warrior_default"
			}
		}
	}
	GenericTerrorEvents.boss_event_chaos_beastmen_spline_patrol = {
		{
			"spawn_patrol",
			patrol_template = "spline_patrol",
			formations = {
				"beastmen_standard",
				"storm_vermin_two_column",
				"chaos_warrior_default"
			}
		}
	}
	GenericTerrorEvents.boss_event_spline_patrol = {
		{
			"spawn_patrol",
			patrol_template = "spline_patrol",
			formations = {
				"beastmen_standard",
				"storm_vermin_two_column",
				"chaos_warrior_default"
			}
		}
	}
	GenericTerrorEvents.boss_event_skaven_spline_patrol = {
		{
			"spawn_patrol",
			patrol_template = "spline_patrol",
			formations = {
				"beastmen_standard",
				"storm_vermin_two_column",
				"chaos_warrior_default"
			}
		}
	}
	GenericTerrorEvents.boss_event_chaos_spline_patrol = {
		{
			"spawn_patrol",
			patrol_template = "spline_patrol",
			formations = {
				"beastmen_standard",
				"storm_vermin_two_column",
				"chaos_warrior_default"
			}
		}
	}
	PatrolFormationSettings.chaos_warrior_default = {
		settings = PatrolFormationSettings.default_marauder_settings,

		normal = {
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			},
			{
				"chaos_raider"
			},
			{
				"chaos_raider"
			},
			{
				"chaos_marauder",
				"chaos_marauder"
			},
			{
				"chaos_marauder",
				"chaos_marauder"
			},
			{
				"chaos_warrior"
			},
			{
				"chaos_marauder",
				"chaos_marauder"
			}
		},
		hard = {
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			},
			{
				"chaos_warrior"
			},
			{
				"chaos_marauder",
				"chaos_marauder"
			},
			{
				"chaos_raider",
				"chaos_raider"
			},
			{
				"chaos_marauder",
				"chaos_marauder"
			},
			{
				"chaos_warrior"
			},
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			}
		},
		harder = {
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			},
			{
				"chaos_raider",
				"chaos_raider"
			},
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			}
		},
		hardest = {
			{
				"chaos_raider"
			},
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			},
			{
				"chaos_raider",
				"chaos_raider"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_marauder_with_shield",
				"chaos_marauder_with_shield"
			}
		},
		cataclysm = {
			{
				"chaos_raider"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_berzerker",
				"chaos_berzerker"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_berzerker",
				"chaos_berzerker"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_raider",
				"chaos_raider"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_berzerker",
				"chaos_berzerker"
			},
			{
				"chaos_raider",
				"chaos_raider"
			},
			{
				"chaos_raider",
				"chaos_raider"
			},
		}
	}

	-- Patrol Composition Changed From Dutch
	PatrolFormationSettings.storm_vermin_two_column = {
		settings = {
			extra_breed_name = {
								"skaven_storm_vermin_with_shield",
								"skaven_plague_monk"
								},
			use_controlled_advance = true,	
			sounds = {
				PLAYER_SPOTTED = "storm_vermin_patrol_player_spotted",
				FORMING = "Play_stormvermin_patrol_forming",
				FOLEY = "Play_stormvermin_patrol_foley",
				FORMATED = "Play_stormvemin_patrol_formated",
				FOLEY_EXTRA = "Play_stormvermin_patrol_shield_foley",
				FORMATE = "storm_vermin_patrol_formate",
				CHARGE = "storm_vermin_patrol_charge",
				VOICE = "Play_stormvermin_patrol_voice"
			},
			offsets = PatrolFormationSettings.default_settings.offsets,
			speeds = PatrolFormationSettings.default_settings.speeds
		},
		normal = {
			{
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_clan_rat",
				"skaven_clan_rat"
			},
			{
				"skaven_clan_rat",
				"skaven_clan_rat"
			},
			{
				"skaven_clan_rat",
				"skaven_clan_rat"
			}
		},
		hard = {
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}
		},
		harder = {
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}
		},
		hardest = {
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}
		},
		-- Patrol Composition Changed From Dutch
		cataclysm = {
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_plague_monk",
				"skaven_plague_monk",
				"skaven_plague_monk",
				"skaven_plague_monk"
			},
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_plague_monk",
				"skaven_plague_monk"
			},
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_plague_monk",
				"skaven_plague_monk"
			},
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			}
		}
	}
	-- Patrol Composition Changed From Dutch
	PatrolFormationSettings.beastmen_standard = {
		settings = {
			extra_breed_name = {
								"skaven_storm_vermin_with_shield",
								"skaven_storm_vermin",
								"skaven_plague_monk",
								"chaos_warrior",
								"chaos_raider",
								"chaos_berzerker"
								},
			use_controlled_advance = true,
			sounds = {
				PLAYER_SPOTTED = "beastmen_patrol_player_spotted",
				FORMING = "beastmen_patrol_forming",
				FOLEY = "beastmen_patrol_foley",
				FORMATED = "beastmen_patrol_formated",
				FORMATE = "beastmen_patrol_formate",
				CHARGE = "beastmen_patrol_charge",
				VOICE = "beastmen_patrol_voice"
			},
			offsets = PatrolFormationSettings.default_settings.offsets,
			speeds = PatrolFormationSettings.default_settings.speeds
		},
		normal = {
			{
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor"
			},
			{
				"beastman_ungor",
				"beastman_ungor"
			},
			{
				"beastman_ungor",
				"beastman_ungor"
			},
			{
				"beastmen_bestigor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			}
		},
		hard = {
			{
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor"
			},
			{
				"beastman_ungor",
				"beastman_ungor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastman_ungor",
				"beastman_ungor"
			},
			{
				"beastmen_bestigor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			}
		},
		harder = {
			{
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			}
		},
		hardest = {
			{
				"beastmen_bestigor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			},
			{
				"beastmen_gor",
				"beastmen_gor"
			}
		},
		-- Changed from Dutch 
		cataclysm = {
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"skaven_storm_vermin_with_shield",
				"skaven_storm_vermin_with_shield"
			},
			{
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"chaos_berzerker",
				"chaos_berzerker"
			},
			{
				"chaos_warrior",
				"chaos_warrior"
			},
			{
				"chaos_raider",
				"chaos_raider"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			}
		}
	}