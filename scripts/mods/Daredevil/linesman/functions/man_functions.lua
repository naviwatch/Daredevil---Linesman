local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict

mod.difficulty_level = mod:get("difficulty_level")
local man = mod.difficulty_level == 3

local dlc_termite_delay_horde = { 160, 200 }

-- holy mother of kino
mod:hook_origin(ConflictDirector, "update_horde_pacing", function(self, t, dt)
    local pacing = self.pacing
    local level_name = Managers.level_transition_handler:get_current_level_key()

    if pacing:horde_population() < 1 or pacing.pacing_state == "pacing_frozen" then
        self._next_horde_time = nil

        return
    end

    if not self._next_horde_time then
        -- New Intensity stuff
        if mutator_plus.active and level_name == "dlc_termite_3" then
            self._next_horde_time = t + 120
        else
            self._next_horde_time = t + ConflictUtils.random_interval(CurrentPacing.horde_frequency)
        end
        --	print("Setting horde timers to 30-45s")
    end

    if t > self._next_horde_time and not self.delay_horde then
        local enemy_data = self._conflict_data_by_side[self.default_enemy_side_id]
        local num_spawned = #enemy_data.spawned
        local horde_failed

        if mutator_plus.active then
            horde_failed = num_spawned > 160
        else
            horde_failed = num_spawned > RecycleSettings.push_horde_if_num_alive_grunts_above
        end

        if horde_failed then
            local pacing_setting = CurrentPacing

            if RecycleSettings.push_horde_in_time then
                print("HORDE: Pushing horde in time; too many units out " .. num_spawned)

                self._next_horde_time = t + 5

                pacing:annotate_graph("Pushed horde", "red")
            else
                mod:echo("HORDE: Skipped horde; too many units out")

                self._next_horde_time = t + ConflictUtils.random_interval(pacing_setting.horde_frequency)

                pacing:annotate_graph("Failed horde", "red")
            end

            return
        end

        local wave, horde_type, no_fallback, optional_wave_composition

        if script_data.ai_pacing_disabled then
            self._next_horde_time = math.huge
            self._multiple_horde_count = nil
            wave = "unknown"
            self._wave = wave
        else
            local set_standard_horde
            local pacing_setting = CurrentPacing

            if pacing_setting.multiple_hordes then
                if self._multiple_horde_count then
                    self._multiple_horde_count = self._multiple_horde_count - 1

                    if self._multiple_horde_count <= 0 then
                        print("HORDE: last wave, reset to standard horde delay")

                        optional_wave_composition = self._current_wave_composition
                        self._multiple_horde_count = nil
                        self._current_wave_composition = nil
                        wave = "multi_last_wave"

                        if mutator_plus.active and level_name == "dlc_termite_3" then
                            self._next_horde_time = t + ConflictUtils.random_interval(dlc_termite_delay_horde)
                        else
                            self._next_horde_time = t + ConflictUtils.random_interval(pacing_setting.max_delay_until_next_horde)
                        end
                    else
                        local time_delay = ConflictUtils.random_interval(pacing_setting.multiple_horde_frequency)

                        print("HORDE: next wave, multiple_horde_frequency -> Time delay", time_delay)

                        self._next_horde_time = t + time_delay
                        wave = "multi_consecutive_wave"
                        optional_wave_composition = self._current_wave_composition
                    end

                    horde_type = "multi_followup"
                    no_fallback = true
                else
                    self._multiple_horde_count = pacing_setting.multiple_hordes - 1
                    self._next_horde_time = t + ConflictUtils.random_interval(pacing_setting.multiple_horde_frequency)
                    wave = "multi_first_wave"
                end
            else
                self._next_horde_time = t + ConflictUtils.random_interval(pacing_setting.horde_frequency)
                wave = "single_wave"
            end

            self._wave = wave
        end

        local horde_settings = CurrentHordeSettings

        if not horde_type then
            if horde_settings.mix_paced_hordes then
                -- Map modifiers
                if mutator_plus.active and not mod.difficulty_level == 4 then
                    im_not_gonna_sugarcoat_it, wves = PseudoRandomDistribution.flip_coin(wves, horde_settings.chance_of_vector)

                    if im_not_gonna_sugarcoat_it then
                        horde_type = "vector"
                    else
                        horde_type = "ambush"
                    end

                    -- Override the stuff above
                    if not lb then
                        if man and self.horde_spawner.num_paced_hordes <= 6 or self.horde_spawner.num_paced_hordes <= 18 then -- 6th horde ambush starts
                            horde_type = "vector"
                        end
                    end
                else
                    if self.horde_spawner.num_paced_hordes % 2 == 0 then
                        horde_type = math.random() < horde_settings.chance_of_vector and "vector" or "ambush"
                    else
                        horde_type = self.horde_spawner.last_paced_horde_type == "vector" and "ambush" or "vector"
                    end
                end
            else
                horde_type = math.random() < horde_settings.chance_of_vector and "vector" or "ambush"
            end

            --[[
				-- Check for triple ambush
				if mutator_plus.active then
					if self.horde_spawner.num_paced_hordes % 3 == 0 and horde_type == "ambush" and self.horde_spawner.last_paced_horde_type == "ambush" then
						horde_type = "vector"
					end
				end
				]]

            if mutator_plus.active and not mod.difficulty_level == 4 then
                if lb then
                    blob_blob_blob, bbb = PseudoRandomDistribution.flip_coin(bbb, horde_settings.chance_of_vector_blob)
                    if bbb then
                        horde_type = "vector_blob"
                    end
                else
                    if horde_type == "vector" and math.random() <= horde_settings.chance_of_vector_blob then
                        horde_type = "vector_blob"
                    end
                end
            else
                if horde_type == "vector" and math.random() <= horde_settings.chance_of_vector_blob then
                    horde_type = "vector_blob"
                end
            end

            -- Horde overrides
            if mutator_plus.active and self.horde_spawner.num_paced_hordes ~= nil and not mod.difficulty_level == 4 then 
                if level_name == "dlc_termite_1" then -- Freaky Temple
                   horde_type = math.random() < horde_settings.chance_of_vector_termite_1 and "vector" or "ambush"
                end

                if level_name == "dlc_termite_3" then -- Well of Shit
                    horde_type = math.random() < horde_settings.chance_of_vector_blob and "vector_blob" or "ambush"
                end
                
                if man and self.horde_spawner.num_paced_hordes <= 3 or self.horde_spawner.num_paced_hordes <= 6 then -- Force set to vector_blob at the end because im a good person
                    horde_type = "vector_blob"
                end
            end

            local composition = horde_type == "vector" and horde_settings.vector_composition or
                horde_type == "vector_blob" and horde_settings.vector_blob_composition or
                horde_settings.ambush_composition

            if wave and type(composition) == "table" then
                optional_wave_composition = composition[math.random(#composition)]

                printf("HORDE: Chosing horde wave composition %s", optional_wave_composition)

                self._current_wave_composition = optional_wave_composition
            end
        elseif horde_type == "multi_followup" then
            horde_type = self.horde_spawner.last_paced_horde_type
        end

        print("Time for new HOOORDE!", wave)

        self._horde_ends_at = t + 120

        local extra_data = {
            multiple_horde_count = self._multiple_horde_count,
            horde_wave = wave,
            optional_wave_composition = optional_wave_composition,
        }
        local side_id = self.default_enemy_side_id

        print("HORDE: Spawning hordes while " .. #enemy_data.spawned .. " other ai are spawned")
        self.horde_spawner:horde(horde_type, extra_data, side_id, no_fallback)
    end
end)

-- Stop spawner from spawning one extra enemy in horde
local spawn_list_a = {}
local spawn_list_b = {}

local function D(...)
    if script_data.debug_hordes then
        printf(...)
    end
end

local function copy_array(source, index_a, index_b, dest)
    local j = 1

    for i = index_a, index_b do
        dest[j] = source[i]
        j = j + 1
    end
end

local spawn_list = {
    "skaven_slave",
    "skaven_clan_rat",
    "skaven_slave",
    "skaven_clan_rat",
    "skaven_slave",
    "skaven_clan_rat",
    "skaven_slave",
    "skaven_clan_rat",
    "skaven_slave",
    "skaven_clan_rat"
}

local spawn_list = {}
local spawn_list_hidden = {}
local copy_list = {}

local ok_spawner_breeds = {
    skaven_clan_rat = true,
    skaven_slave = true
}
--[[
	mod:hook_origin(HordeSpawner, "compose_horde_spawn_list", function (self, variant)
		local i = 1
	
		table.clear_array(spawn_list_a, #spawn_list_a)
		table.clear_array(spawn_list_b, #spawn_list_b)
	
		local breeds = variant.breeds
	
		for i = 1, #breeds, 2 do
			local breed_name = breeds[i]
			local amount = breeds[i + 1]
			local num_to_spawn = ConflictUtils.random_interval(amount)
			local spawn_list = ok_spawner_breeds[breed_name] and spawn_list_a or spawn_list_b
			local start = #spawn_list
	
			for j = start + 1, start + num_to_spawn do
				spawn_list[j] = breed_name
			end
		end
	
		table.shuffle(spawn_list_a)
		table.shuffle(spawn_list_b)
	
		local sum_a = #spawn_list_a
		local sum_b = #spawn_list_b
		local sum = sum_a + sum_b
	
		return sum, sum_a, sum_b
	end)
	--]]

mod:hook_origin(HordeSpawner, "compose_blob_horde_spawn_list", function(self, composition_type)
    --mod:echo("Blob Horde Spawning")
    local composition = CurrentHordeSettings.compositions_pacing[composition_type]
    local index = LoadedDice.roll_easy(composition.loaded_probs)
    local variant = composition[index]
    local i = 1
    local spawn_list = spawn_list_a

    table.clear_array(spawn_list_a, #spawn_list_a)

    local breeds = variant.breeds

    for i = 1, #breeds, 2 do
        local breed_name = breeds[i]
        local amount = breeds[i + 1]
        local num_to_spawn = ConflictUtils.random_interval(amount)
        local start = #spawn_list + 1
        local total_intensity = Managers.state.conflict.pacing:get_pacing_intensity()
        local horde_spawner = Managers.state.conflict.horde_spawner
        local num_paced_hordes = horde_spawner.num_paced_hordes
        local valid_difficulty = man
        local horde_limit = num_paced_hordes <= 6

        if mutator_plus.active and not lb then
            if valid_difficulty and horde_limit and not mod:get("testers") then -- If its the first two hordes, lower difficulty by spawning less
                for j = start, start + num_to_spawn - 3 do
                    spawn_list[j] = breed_name
                end
            else
                if mod:get("debug") then
                    mod:chat_broadcast("LOW Intensity HORDE NUMBERS")
                end
                for j = start, start + num_to_spawn - 1 do
                    spawn_list[j] = breed_name
                end
            end
        else
            for j = start, start + num_to_spawn - 1 do
                spawn_list[j] = breed_name
            end
        end
    end

    table.shuffle(spawn_list)
    return spawn_list, #spawn_list
end)

mod:hook(HordeSpawner, "execute_vector_blob_horde", function(func, self, extra_data, side_id, fallback)
    local settings = CurrentHordeSettings.vector_blob
	local roll = math.random()
	local spawn_horde_ahead 
    
    if man and self.num_paced_hordes <= 3 or self.num_paced_hordes <= 6 then
        spawn_horde_ahead = true
    else
        spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead
    end

	print("wants to spawn " .. (spawn_horde_ahead and "ahead" or "behind") .. " within distance: ", settings.main_path_dist_from_players)

	local success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

	if not success then
		print("\tcould not, tries to spawn" .. (not spawn_horde_ahead and "ahead" or "behind"))

		success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(not spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

		if not success then
			local roll = math.random()
			local spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead
			local distance_bonus = 20

			success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players + distance_bonus, settings.raw_dist_from_players, side_id)
		end
	end

    return func(self, extra_data, side_id, fallback)
end)

local dialogue_system_init_data = {
	faction = "enemy",
}

-- New spawn unit shit 
mod:hook_origin(ConflictDirector, "_spawn_unit", function(self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, spawn_index)
	local breed_unit_field = script_data.use_optimized_breed_units and breed.opt_base_unit or breed.base_unit
	local base_unit_name = type(breed_unit_field) == "string" and breed_unit_field or breed_unit_field[Math.random(#breed_unit_field)]
	local unit_template = breed.unit_template
	local entity_manager = Managers.state.entity
	local nav_world = entity_manager:system("ai_system"):nav_world()

	optional_data.spawn_queue_index = spawn_index

	local inventory_init_data

	if breed.has_inventory then
		local breed_inventory_field = script_data.use_optimized_breed_units and breed.opt_default_inventory_template or breed.default_inventory_template
		local breed_inventory_template = type(breed_inventory_field) == "string" and breed_inventory_field or breed_inventory_field[Math.random(#breed_inventory_field)]

		inventory_init_data = {
			optional_spawn_data = optional_data,
			inventory_template = breed_inventory_template,
			inventory_configuration_name = optional_data.inventory_configuration_name,
		}
	end

	local aim_init_data

	if breed.aim_template ~= nil then
		aim_init_data = {
			husk = false,
			template = breed.aim_template,
		}
	end

	local animation_movement_init_data

	if breed.animation_movement_template ~= nil then
		animation_movement_init_data = {
			husk = false,
			template = breed.animation_movement_template,
		}
	end

	dialogue_system_init_data.breed_name = breed.name

	local difficulty_rank = Managers.state.difficulty:get_difficulty_rank()
	local health = breed.max_health and breed.max_health[difficulty_rank]

	if health then
		local max_health_modifier = optional_data.max_health_modifier or 1

		health = health * max_health_modifier 
	end

    -- Modifications start
    if mutator_plus.active then 
        -- Detection range
        local perception = breed.perception
        if perception then -- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/1bd09637f5786e97fe47b1c7e2d37d35aecff6aa/scripts/unit_extensions/human/ai_player_unit/perception_utils.lua#L65
            perception = optional_data.perception or perception
         --   mod:echo(perception)
        end

        local detection_radius = breed.detection_radius 
        if detection_radius then -- set to max if using all seeing 
            detection_radius = optional_data.detection_radius or perception
        end

        local target_selection = breed.target_selection
        if target_selection then -- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/1bd09637f5786e97fe47b1c7e2d37d35aecff6aa/scripts/unit_extensions/human/ai_player_unit/target_selection_utils.lua
            target_selection = optional_data.target_selection or target_selection

            --[[
            if breed.name == "skaven_ratling_gunner" or breed.name == "skaven_gutter_runner" or breed.name == "skaven_pack_master" then
                mod:echo(target_selection)
            end
            ]]
        -- target selection check
        end
    end

	local side_id = optional_data.side_id
	local extension_init_data = {
		health_system = {
			health = health,
			optional_data = optional_data,
		},
		ai_system = {
			size_variation = 1,
			size_variation_normalized = 1,
			breed = breed,
			nav_world = nav_world,
			spawn_type = spawn_type,
			spawn_category = spawn_category,
			optional_spawn_data = optional_data,
			side_id = side_id,
		},
		locomotion_system = {
			nav_world = nav_world,
			breed = breed,
		},
		ai_navigation_system = {
			nav_world = nav_world,
		},
		death_system = {
			is_husk = false,
			death_reaction_template = breed.death_reaction,
			disable_second_hit_ragdoll = breed.disable_second_hit_ragdoll,
		},
		hit_reaction_system = {
			is_husk = false,
			hit_reaction_template = breed.hit_reaction,
			hit_effect_template = breed.hit_effect_template,
		},
		ai_inventory_system = inventory_init_data,
		ai_group_system = group_data,
		dialogue_system = dialogue_system_init_data,
		aim_system = aim_init_data,
		proximity_system = {
			breed = breed,
		},
		buff_system = {
			breed = breed,
		},
		animation_movement_system = animation_movement_init_data,
	}

	if optional_data.prepare_func then
		optional_data.prepare_func(breed, extension_init_data, optional_data, spawn_pos, spawn_rot)
	end

	Managers.state.game_mode:pre_ai_spawned(breed, optional_data)

	local spawn_pose = Matrix4x4.from_quaternion_position(spawn_rot, spawn_pos)
	local size_variation_range = optional_data.size_variation_range or breed.size_variation_range

	if size_variation_range then
		local size_normalized = Math.random()
		local size = math.lerp(size_variation_range[1], size_variation_range[2], size_normalized)

		extension_init_data.ai_system.size_variation = size
		extension_init_data.ai_system.size_variation_normalized = size_normalized

		Matrix4x4.set_scale(spawn_pose, Vector3(size, size, size))
	end

	local ai_unit, go_id = Managers.state.unit_spawner:spawn_network_unit(base_unit_name, unit_template, extension_init_data, spawn_pose)

	self:_post_spawn_unit(ai_unit, go_id, breed, spawn_pos, spawn_category, spawn_animation, optional_data, spawn_type, spawn_index)

	return ai_unit, go_id
end)


-- Ambience hooks
if lb or mod:get("ubercharge") then
	local function array_copy(source, dest, size)
		for i = 1, size do
			dest[i] = source[i]
		end
	end

	local function array_remove_element(array, index, size)
		local element = array[index]

		array[index] = array[size]
		array[size] = nil

		return element
	end

	local work_list = {}
	local lookup = {}

	mod:hook_origin(SpawnZoneBaker, "generate_spawns", function(self, spawn_cycle_length, goal_density, area_density_coefficient, length_density_coefficient, conflict_director_name, mutator_list)
		if not InterestPointUnitsLookup then
			ConflictUtils.generate_spawn_point_lookup(self.world)
		end

		if not self.spawn_zones_available then
			print("No spawn zones where found, can't generate spawns")
		end

		self._all_hi_data = {}
		self._count_up = 0

		local difficulty, difficulty_tweak = Managers.state.difficulty:get_difficulty()

		self.composition_difficulty = DifficultyTweak.converters.composition(difficulty, difficulty_tweak)

		local zones = self.zones
		local num_main_zones = self.num_main_zones
		local zone_convert = self.zone_convert

		conflict_director_name = conflict_director_name or "default"

		local conflict_director = ConflictDirectors[conflict_director_name]
		local seed = self._initial_seed
		local great_cycles = MainPathSpawningGenerator.generate_great_cycles(conflict_director, mutator_list, zones, zone_convert, num_main_zones, spawn_cycle_length, seed)
		local spawns, pack_sizes, pack_rotations, pack_members, zone_data_list = {}, {}, {}, {}, {}
		local distribution = "random" -- PackSpawningDistribution.standard.distribution_method -- set to periodical at base
		local dist_data = PackDistributions[distribution]
		local num_great_cycles = #great_cycles

		for i = 1, num_great_cycles do
			local cycle = great_cycles[i]
			local cycle_zones = cycle.zones
			local num_cycle_zones = #cycle_zones
			local sum_density, num_hi = 0, 0
			local zone

			if distribution == "random" then
				for j = 1, num_cycle_zones do
					zone = cycle_zones[j]

					local density = PackDistributions.linesman.min_density + self:_random() * (PackDistributions.linesman.max_density - PackDistributions.linesman.min_density) -- self:_random() / min + self:random() * (max - min)

					zone.density = density
					sum_density = sum_density + density
				end
			elseif distribution == "periodical" then
				local len, density, period_end
				local hi = self:_random() > 0.5

				len, density, hi = self:periodical(hi, dist_data)
				zone = cycle_zones[1]
				zone.period_length = len
				zone.hi = hi

				local hi_data = self:create_hi_data(zone, zone.pack_type)

				period_end = len
				num_hi = hi and 1 or 0

				local period_counter, second_part

				for j = 1, num_cycle_zones do
					zone = cycle_zones[j]
					zone.hi_data = hi_data

					if period_end < j then
						len, density, hi = self:periodical(hi, dist_data)
						second_part = false
						period_end = j + len - 1

						if num_cycle_zones < period_end then
							len = num_cycle_zones - j
							period_end = num_cycle_zones
						end

						zone.period_length = len
						zone.hi_data = hi_data
						zone.hi = hi
						hi_data = self:create_hi_data(zone, zone.pack_type)
						num_hi = num_hi + (hi and 1 or 0)
					elseif dist_data.random_distribution then
						if hi then
							density = dist_data.min_hi_density + self:_random() * (dist_data.max_hi_density - dist_data.min_hi_density)
						else
							density = dist_data.min_low_density + self:_random() * (dist_data.max_low_density - dist_data.min_low_density)
						end
					elseif period_counter == dist_data.zero_clamp_max_dist and not hi then
						second_part = true
						density = dist_data.min_low_density + self:_random() * (dist_data.max_low_density - dist_data.min_low_density)
					end

					period_counter = zone.period_length and 1 or period_counter + 1

					if density < dist_data.zero_density_below and not second_part then
						density = 0
					end

					zone.density = density
					zone.hi = hi
					sum_density = sum_density + density
				end
			end

			local average_goal_density, pack_spawning_setting, goal_density = 0

			for j = 1, num_cycle_zones do
				local cycle_zone = cycle_zones[j]

				if pack_spawning_setting ~= cycle_zone.pack_spawning_setting then
					goal_density = PackDistributions.linesman.goal_density -- 0.45
				end

				average_goal_density = average_goal_density + goal_density
			end

			if sum_density > 0 then
				local normalizer = average_goal_density / sum_density
				local remainder = 0

				print("-------------> JOW Perfect-density", average_goal_density, "Sum density", sum_density, "Normalized coefficient:", normalizer)

				if mod:get("debug") then
					mod:echo("JOW Perfect-density: " .. average_goal_density .. " Sum density: " .. sum_density .. " Normalized coefficient: " .. normalizer)
				end

				for j = 1, num_cycle_zones do
					local cycle_zone = cycle_zones[j]

					cycle_zone.density = cycle_zone.density * normalizer

					if remainder > 0 then
						cycle_zone.density = cycle_zone.density + remainder
						remainder = 0
					end

					if cycle_zone.density > 1 then
						remainder = remainder + cycle_zone.density - 1
						cycle_zone.density = 1
					end
				end

				if distribution == "periodical" then
				--	self:inject_special_packs(num_hi, cycle_zones)
				end

				local kept = 1

				for j = 1, num_cycle_zones do
					local center_zone = cycle_zones[j]
					local center_density = center_zone.density
					local outer = center_zone.outer
					local density = center_density

					for k = 1, #outer do
						local cycle_zone = outer[k]

						density = math.clamp(density * kept + (1 - kept) * (2 * self:_random() - 1), 0, 1)
						cycle_zone.density = density
						cycle_zone.hi_data = center_zone.hi_data
						cycle_zone.hi = center_zone.hi
					end
				end

				self:populate_spawns_by_rats(pack_spawning_setting, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, cycle_zones, pack_spawning_setting, length_density_coefficient, nil, true, nil)

				for j = 1, num_cycle_zones do
					local center_zone = cycle_zones[j]
					local outer_zones = center_zone.outer
					local pack_spawning_setting = center_zone.pack_spawning_setting
					local num_zones_to_clamp = pack_spawning_setting.basics.clamp_outer_zones_used

					if num_zones_to_clamp then
						local num_zones = #outer_zones
						local num_to_remove = num_zones - num_zones_to_clamp

						if num_to_remove > 0 then
							array_copy(outer_zones, work_list, num_zones)

							local work_list_size = #outer_zones

							for k = 1, num_to_remove do
								array_remove_element(work_list, self:_random(1, work_list_size), work_list_size)

								work_list_size = work_list_size - 1
							end

							outer_zones = work_list
						end
					end
					
					self:populate_spawns_by_rats(pack_spawning_setting, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, outer_zones, area_density_coefficient, 0, center_zone.pack_type, nil, center_zone)
				end
			else
				print(sprintf("Spawn density in great_cycle %d is 0, num cycle zones: %d ", i, num_cycle_zones))
			end
		end

		local island_zones = {}

		for i = num_main_zones + 1, #zones do
			local zone = zones[i]
			local parent_zone_index = zone.parent_zone_id

			if not parent_zone_index then
				print("Missing parent zone id for island-zone", i)
				table.dump(zone, "ISLAND ZONE", 2)
			end

			local parent_zone = parent_zone_index and self.level_analyzer:get_zone_from_unique_id(zone_convert, parent_zone_index)

			if parent_zone then
				local conflict_setting = parent_zone.conflict_setting
				local pack_spawning_setting = parent_zone.pack_spawning_setting
				local pack_type = parent_zone.pack_type
				local area_density_coefficient = pack_spawning_setting.area_density_coefficient
				local ok_to_spawn = not zone.on_roof or BreedPacks[pack_type].roof_spawning_allowed

				if ok_to_spawn then
					local sub_zones = zone.sub
					local sub_areas = zone.sub_areas

					for j = 1, #sub_zones do
						local nodes = sub_zones[j]
						local area = sub_areas[j]
						local density = self:_random()
						local num_wanted_rats = math.floor(area * density * area_density_coefficient)
						local island_zone = {
							total_area = 0,
							nodes = nodes,
							area = area,
							outer = {},
							pack_type = pack_type,
							pack_spawning_setting = pack_spawning_setting,
							conflict_setting = conflict_setting,
							unique_zone_id = zone.unique_zone_id,
						}

						island_zone.period_length = 1
						island_zone.hi = false
						island_zone.island = true
						island_zone.density = density
						island_zone.parent_zone = parent_zone

						self:create_hi_data(island_zone, pack_type)

						island_zones[#island_zones + 1] = island_zone
						island_zone.unique_zone_id = #island_zones

						local child_islands = parent_zone.islands

						if not child_islands then
							child_islands = {}
							parent_zone.islands = child_islands
						end

						child_islands[#child_islands + 1] = island_zone.unique_zone_id

						if num_wanted_rats > 0 then
							self:spawn_amount_rats(spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, pack_type, area, island_zone)
						end
					end
				end
			end
		end

		fassert(#spawns == #pack_sizes, "Mismatching sizes!")

		self.great_cycles = great_cycles
		self.island_zones = island_zones

		table.clear(lookup)

		return spawns, pack_sizes, pack_rotations, pack_members, zone_data_list
	end)
end