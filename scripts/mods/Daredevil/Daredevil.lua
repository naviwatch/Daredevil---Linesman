local mod = get_mod("Daredevil")
local mutator = mod:persistent_table("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")

--[[
	Functions
--]]

local function count_event_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
end

local function count_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed(breed_name)
end

-- Wwise.load_bank("HELPME")

local enhancement_list = {
	["regenerating"] = true,
	["unstaggerable"] = true
}
local enhancement_1 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
	["unstaggerable"] = true
}
local relentless = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
	["intangible"] = true
}
local enhancement_3 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
	["ranged_immune"] = true
}
local enhancement_4 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["commander"] = true
}
local enhancement_5 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
	["regenerating"] = true
}
local enhancement_6 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["warping"] = true,
	["crushing"] = true
}
local enhancement_7 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["crushing"] = true
}
local shield_shatter = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local function create_weights()
	local crash = nil

	for id, setting in pairs(PackSpawningSettings) do
		setting.name = id

		if not setting.disabled then
			roaming_set = setting.roaming_set
			roaming_set.name = id
			local weights = {}
			local breed_packs_override = roaming_set.breed_packs_override

			if breed_packs_override then
				for i = 1, #breed_packs_override, 1 do
					weights[i] = breed_packs_override[i][2]
				end

				roaming_set.breed_packs_override_loaded_dice = {
					LoadedDice.create(weights)
				}
			end
		end
	end

	-- Adjustment for the new difficulty system of horde compositions from 1.4 - I am not copypasting each composition 3 times. Or 4, doesn't matter.
	for event, composition in pairs(HordeCompositions) do
		if not composition[1][1] then
			local temp_table = table.clone(composition)
			table.clear_array(composition, #composition)
			composition[1] = temp_table
			composition[2] = temp_table
			composition[3] = temp_table
			composition[4] = temp_table
			composition[5] = temp_table
			composition[6] = temp_table
			composition[7] = temp_table
		elseif not composition[6] then
			composition[6] = composition[5]
			composition[7] = composition[5]
		end
	end

	local weights = {}
	local crash = nil

	for key, setting in pairs(HordeSettings) do
        setting.name = key

        if setting.compositions then
            for name, composition in pairs(setting.compositions) do
                for i = 1, #composition, 1 do
                    table.clear_array(weights, #weights)

                    local compositions = composition[i]

                    for j, variant in ipairs(compositions) do
                        weights[j] = variant.weight
                        local breeds = variant.breeds
                        
                        if breeds then
                            for k = 1, #breeds, 2 do
                                local breed_name = breeds[k]
                                local breed = Breeds[breed_name]

                                if not breed then
                                    print(string.format("Bad or non-existing breed in HordeCompositions table %s : '%s' defined in HordeCompositions.", name, tostring(breed_name)))

                                    crash = true
                                elseif not breed.can_use_horde_spawners then
                                    variant.must_use_hidden_spawners = true
                                end
                            end
                        end
                    end

                    compositions.loaded_probs = {
                        LoadedDice.create(weights)
                    }

                    fassert(not crash, "Found errors in HordeComposition table %s - see above. ", name)
                    fassert(compositions.loaded_probs, "Could not create horde composition probablitity table, make sure the table '%s' in HordeCompositions is correctly structured and has an entry for each difficulty.", name)
                end
            end
        end

		if setting.compositions_pacing then
			for name, composition in pairs(setting.compositions_pacing) do
				table.clear_array(weights, #weights)

				for i, variant in ipairs(composition) do
					weights[i] = variant.weight
					local breeds = variant.breeds

					for j = 1, #breeds, 2 do
						local breed_name = breeds[j]
						local breed = Breeds[breed_name]

						if not breed then
							print(string.format("Bad or non-existing breed in HordeCompositionsPacing table %s : '%s' defined in HordeCompositionsPacing.", name, tostring(breed_name)))

							crash = true
						elseif not breed.can_use_horde_spawners then
							variant.must_use_hidden_spawners = true
						end
					end
				end

				composition.loaded_probs = {
					LoadedDice.create(weights)
				}

				fassert(not crash, "Found errors in HordeCompositionsPacing table %s - see above. ", name)
				fassert(composition.loaded_probs, "Could not create horde composition probablitity table, make sure the table '%s' in HordeCompositionsPacing is correctly structured.", name)
			end
		end
	end
end

mod.deepcopy = function(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[mod.deepcopy(orig_key, copies)] = mod.deepcopy(orig_value, copies)
			end
			setmetatable(copy, mod.deepcopy(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

-- Fix to specials being disabled by pacing disables in events.
mod:hook(Pacing, "disable", function (func, self)
	self._threat_population = 1
	self._specials_population = 1
	self._horde_population = 0
	self.pacing_state = "pacing_frozen"
end)

-- Dirty hook to work around lack of node in custom spawners.
mod:hook(AISpawner, "spawn_unit", function (func, self)
	local breed_name = nil
	local breed_list = self._breed_list
	local last = #breed_list
	local spawn_data = breed_list[last]

	breed_list[last] = nil
	last = last - 1

	local breed_name = breed_list[last]
	
	breed_list[last] = nil
	local breed = Breeds[breed_name]
	local unit = self._unit

	-- Code Added by Grim to fix specific spawn issue with Bile Chemists
	--[[
	if breed_name == "chaos_corruptor_sorcerer" then
		if Unit.local_position(self._unit, 0).x == 349.67596435546875 then
			local spawner_system = Managers.state.entity:system("spawner_system")
			self._unit = spawner_system._id_lookup["sorcerer_boss_minion"][1]
			self.changed = true
		end
	elseif self.changed then
		local spawner_system = Managers.state.entity:system("spawner_system")
		self._unit = spawner_system._id_lookup["sorcerer_boss_minion"][5]
		self.changed = nil
	end
	]]

	Unit.flow_event(unit, "lua_spawn")

	local conflict_director = Managers.state.conflict
	local spawn_category = "ai_spawner"
	-- Prevents crashes on custom spawners
	local node = (Unit.has_node(unit, self._config.node) and Unit.node(unit, self._config.node)) or 0
	local parent_index = Unit.scene_graph_parent(unit, node) or 1
	-- End new code
	local parent_world_rotation = Unit.world_rotation(unit, parent_index)
	local spawn_node_rotation = Unit.local_rotation(unit, node)
	local spawn_rotation = Quaternion.multiply(parent_world_rotation, spawn_node_rotation)
	local spawn_type = Unit.get_data(self._unit, "hidden") and "horde_hidden" or "horde"
	local spawn_pos = Unit.world_position(unit, node)
	local animation_events = self._config.animation_events

	if spawn_type == "horde_hidden" and breed.use_regular_horde_spawning then
		spawn_type = "horde"
	end

	local spawn_animation = spawn_type == "horde" and animation_events[math.random(#animation_events)]
	local side_id = spawn_data[1]
	local optional_data = spawn_data[3] or {}

	optional_data.side_id = side_id

	local activate_version = self._activate_version
	local spawned_func = optional_data.spawned_func

	if spawned_func then
		optional_data.spawned_func = function (spawned_unit, ...)
			spawned_func(spawned_unit, ...)

			if activate_version == self._activate_version then
				self._spawned_units[#self._spawned_units + 1] = spawned_unit
			end
		end
	end

	local group_template = spawn_data[2]

	self._num_queued_units = self._num_queued_units + 1
	self._spawned_unit_handles[self._num_queued_units] = conflict_director:spawn_queued_unit(breed, Vector3Box(spawn_pos), QuaternionBox(spawn_rotation), spawn_category, spawn_animation, spawn_type, optional_data, group_template)

	conflict_director:add_horde(1)
end)

-- mod:dofile("scripts/mods/Daredevil/linesman/mutator/status")

local c3dwlines = false

mod:network_register("c3dwlines", function (sender, enable)
	c3dwlines = enable
end)

mod:hook(IngamePlayerListUI, "_update_difficulty", function (func, self)
	local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
	local base_difficulty_name = difficulty_settings.display_name
	local dw = get_mod("catas")
	if dw ~= nil then
		local deathwish = dw:persistent_table("catas")
	
		mod.difficulty_level = mod:get("difficulty_level")

		if mutator.active == true and dw ~= nil then 
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Daredevil")
		end 

		if mutator_plus.active == true and dw ~= nil then
			if mod.difficulty_level == 1 then
				if deathwish.active == true then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " Linesbaby")
				else
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " Deathbaby")
				end
			elseif mod.difficulty_level == 2 then
				if deathwish.active == true then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " Linesboy")
				else
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " Deathboy")
				end
			elseif mod.difficulty_level == 3 then
				if deathwish.active == true then
					self:_set_difficulty_name("MAN")
				else
					self:_set_difficulty_name("Linesman")
				end
			end
		elseif c3dwlines then
			self:_set_difficulty_name("MAN")
		else
			return func(self)
		end
	else 
		if mutator_plus.active == true then
			self:_set_difficulty_name("MAN")
		elseif c3dwlines then
			self:_set_difficulty_name("MAN")
		else
			return func(self)
		end
	end
end)

mod:hook(Presence, "set_presence", function(func, key, value)
	local dw = get_mod("catas")
	if dw ~= nil then
		local deathwish = dw:persistent_table("catas")
		mod.difficulty_level = mod:get("difficulty_level")

		if value == "#presence_modded" then
			func(key, "#presence_modded_difficulty")
		elseif key == "difficulty" then
			if mutator.active == true and deathwish.active == false and dw ~= nil then 
				func(key, "Daredevil")
			elseif mutator.active == true and deathwish.active == true and dw ~= nil then 
				func(key, "DWREDEVIL")
			elseif mutator_plus.active == true and deathwish.active == false and dw ~= nil then
				if mod.difficulty_level == 1 then
					if value == "cataclysm_3" then
						func(key, "C3 Linesbaby")
					elseif value == "cataclysm" then
						func(key, "C1 Linesbaby")
					else
						func(key, "DELI HAM ONLY FOR 1.99")
					end
				elseif mod.difficulty_level == 2 then
					if value == "cataclysm_3" then
						func(key, "C3 Linesboy")
					elseif value == "cataclysm" then
						func(key, "C1 Linesboy")
					else
						func(key, "DELI HAM ONLY FOR 2.99")
					end
				elseif mod.difficulty_level == 3 then
					if value == "cataclysm_3" then
						func(key, "MY LIFE FOR THE OLD WORLD [C3 Linesman]")
					elseif value == "cataclysm" then
						func(key, "MY LIFE FOR HELMGART [C1 Linesman]")
					else
						func(key, "DELI HAM ONLY FOR 3.99")
					end
				end
			elseif mutator_plus.active == true and deathwish.active == true and dw ~= nil then
				if mod.difficulty_level == 1 then
					if value == "cataclysm_3" then
						func(key, "C3 Deathbaby")
					elseif value == "cataclysm" then
						func(key, "C3 Deathbaby")
					else
						func(key, "DELI HAM ONLY FOR 1.99")
					end
				elseif mod.difficulty_level == 2 then
					if value == "cataclysm_3" then
						func(key, "C3 Deathboy")
					elseif value == "cataclysm" then
						func(key, "C3 Deathboy")
					else
						func(key, "DELI HAM ONLY FOR 2.99")
					end
				elseif mod.difficulty_level == 3 then
					if value == "cataclysm_3" then
						func(key, "MAN")
					elseif value == "cataclysm" then
						func(key, "ryan gosling")
					else
						func(key, "DELI HAM ONLY FOR 3.99")
					end
				end
			elseif c3dwlines then
				func(key, "MAN")
			else
				return func(key, value)
			end
		else
			func(key, value)
		end
	else
		if mutator_plus.active == true then
			func(key, "MAN")
		elseif c3dwlines then
			func(key, "MAN")
		else
			func(key, value)
		end
	end
end)

--Custom spawner logic
local custom_spawners = {}

local function setup_custom_raw_spawner(world, terror_event_id, location, rotation)
	local unit = World.spawn_unit(world, "units/hub_elements/empty", location, rotation)
	Unit.set_data(unit, "terror_event_id", terror_event_id)
	Unit.set_data(unit, "extensions", 0, "AISpawner")
	custom_spawners[#custom_spawners + 1] = unit
end

local function setup_custom_horde_spawner(unit, terror_event_id, hidden)
	Unit.set_data(unit, "terror_event_id", terror_event_id)
	Unit.set_data(unit, "hidden", hidden)
	Unit.set_data(unit, "spawner_settings", "spawner1", "enabled", true)
	Unit.set_data(unit, "spawner_settings", "spawner1", "node", "a_spawner_start")
	Unit.set_data(unit, "spawner_settings", "spawner1", "spawn_rate", 2)
	Unit.set_data(unit, "spawner_settings", "spawner1", "animation_events", 0, "spawn_idle")
	Unit.set_data(unit, "extensions", 0, "AISpawner")
	custom_spawners[#custom_spawners + 1] = unit
end

mod:hook(StateIngame, "on_enter", function (func, self)
	func(self)

	if Managers.player.is_server then
		custom_spawners = {}
		local level_key = Managers.state.game_mode:level_key()

		if level_key == "military" then
			setup_custom_raw_spawner(self.world, "bodvarr_superhero", Vector3(121.944, 70.1804, 20.1848), Quaternion.from_elements(0.0182652, 3.62732e-05, 0.00198558, -0.999831))

			local onslaught_courtyard_roof_left_S1 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(144, 55.1, -1.4), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_left_S1, "onslaught_courtyard_roof_left", true)
			
			local onslaught_courtyard_roof_left_S2 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(147.4, 67.8, -1.4), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_left_S2, "onslaught_courtyard_roof_left", true)
			
			local onslaught_courtyard_roof_left_S3 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(144, 80.6, -1.4), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_left_S3, "onslaught_courtyard_roof_left", true)
			
			local onslaught_courtyard_roof_left_S4 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(134.8, 90, -1.4), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_left_S4, "onslaught_courtyard_roof_left", true)
	
			local onslaught_courtyard_roof_right_S1 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(99.9, 55.1, -1.4), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_right_S1, "onslaught_courtyard_roof_right", true)
			
			local onslaught_courtyard_roof_right_S2 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(96.5, 67.8, -1.4), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_right_S2, "onslaught_courtyard_roof_right", true)
			
			local onslaught_courtyard_roof_right_S3 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(99.9, 80.6, -1.4), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_right_S3, "onslaught_courtyard_roof_right", true)
			
			local onslaught_courtyard_roof_right_S4 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(109.4, 90, -1.4), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_right_S4, "onslaught_courtyard_roof_right", true)
			
			local onslaught_courtyard_roof_middle_S1 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(122.2, 98, 4.56), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_courtyard_roof_middle_S1, "onslaught_courtyard_roof_middle", true)
			
			local onslaught_temple_guard_assault_S1 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(-215.1, -85.8, 74.2), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_temple_guard_assault_S1, "onslaught_temple_guard_assault", true)
			
			local onslaught_temple_guard_assault_S2 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(-224.2, -69.1, 74.2), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_temple_guard_assault_S2, "onslaught_temple_guard_assault", true)
		elseif level_key == "catacombs" then
			setup_custom_raw_spawner(self.world, "onslaught_pool_boss_1", Vector3(-163.64, 2.9, -15.9), Quaternion.from_elements(0, 0, -0.009, -0.999))
			setup_custom_raw_spawner(self.world, "onslaught_pool_boss_2", Vector3(-152.19, -27.16, -10.2), Quaternion.from_elements(0, 0, -0.009, -0.999))
			setup_custom_raw_spawner(self.world, "onslaught_pool_boss_3", Vector3(-114.17, -30, 0.3), Quaternion.from_elements(0, 0, 0.709, -0.705))
		elseif level_key == "mines" then
			setup_custom_raw_spawner(self.world, "onslaught_mines_extra_troll_1", Vector3(284.75, -327.1, -29.5), Quaternion.from_elements(0, 0, -0.377, -0.926))
			setup_custom_raw_spawner(self.world, "onslaught_mines_extra_troll_2", Vector3(222.67, -350.32, -21.5), Quaternion.from_elements(0, 0, 0.571, -0.82))
		elseif level_key == "ground_zero" then
			setup_custom_raw_spawner(self.world, "onslaught_ele_guard_c_1", Vector3(-38.7, 11.38, -9.1), Quaternion.from_elements(0, 0, -0.257, -0.966))
			setup_custom_raw_spawner(self.world, "onslaught_ele_guard_c_2", Vector3(-37.2, 12.25, -9.1), Quaternion.from_elements(0, 0, -0.26, -0.966))
			setup_custom_raw_spawner(self.world, "onslaught_ele_guard_c_3", Vector3(-35.3, 13.41, -9.1), Quaternion.from_elements(0, 0, -0.26, -0.966))
			setup_custom_raw_spawner(self.world, "onslaught_ele_guard_c_4", Vector3(-33.6, 14.49, -9.1), Quaternion.from_elements(0, 0, -0.26, -0.966))
			setup_custom_raw_spawner(self.world, "onslaught_ele_guard_c_5", Vector3(-31.6, 15.65, -9.1), Quaternion.from_elements(0, 0, -0.26, -0.966))
			setup_custom_raw_spawner(self.world, "onslaught_ele_guard_c_6", Vector3(-30.2, 16.34, -9.1), Quaternion.from_elements(0, 0, -0.26, -0.966))
		elseif level_key == "bell" then
			setup_custom_raw_spawner(self.world, "onslaught_second_ogre", Vector3(6, -436, 36.5), Quaternion.from_elements(0, 0, 0.798, -0.602))
		elseif level_key == "farmlands" then
			setup_custom_raw_spawner(self.world, "onslaught_farmlands_extra_boss", Vector3(-136.1, -4.8, 7), Quaternion.from_elements(0, 0, 0.988, -0.15))
			setup_custom_raw_spawner(self.world, "onslaught_wall_guard_extra_1", Vector3(-109.97, 244.96, 0.86), Quaternion.from_elements(0, 0, 0.99, -0.138))
			setup_custom_raw_spawner(self.world, "onslaught_hay_barn_bridge_guards_extra_1", Vector3(-72.36, 257.7, 1.08), Quaternion.from_elements(0, 0, 0.871, 0.491))
			setup_custom_raw_spawner(self.world, "onslaught_hay_barn_bridge_guards_extra_2", Vector3(-69.8, 253.7, 1.26), Quaternion.from_elements(0, 0, 0.884, 0.468))
			setup_custom_raw_spawner(self.world, "onslaught_hay_barn_bridge_guards_extra_3", Vector3(-68.7, 255.3, 1.04), Quaternion.from_elements(0, 0, 0.874, 0.486))
			setup_custom_raw_spawner(self.world, "onslaught_hay_barn_bridge_guards_extra_4", Vector3(-69.8, 256.7, 0.93), Quaternion.from_elements(0, 0, 0.894, 0.445))
			setup_custom_raw_spawner(self.world, "onslaught_hay_barn_bridge_guards_extra_5", Vector3(-70.9, 258.3, 0.99), Quaternion.from_elements(0, 0, 0.932, 0.361))
		elseif level_key == "ussingen" then
			setup_custom_raw_spawner(self.world, "onslaught_gate_spawner_1", Vector3(-20.7, -273.77, -2), Quaternion.from_elements(0, 0, 0.91, -0.412))
			setup_custom_raw_spawner(self.world, "onslaught_gate_spawner_2", Vector3(2.68, -274.39, -0.7), Quaternion.from_elements(0, 0, 0.894, 0.446))
			setup_custom_raw_spawner(self.world, "onslaught_gate_spawner_3", Vector3(-10.15, -297.67, 0.5), Quaternion.from_elements(0, 0, 0.956, 0.294))
			
			setup_custom_raw_spawner(self.world, "onslaught_cart_guard_1", Vector3(-23.63, 48.57, 20.5), Quaternion.from_elements(0, 0, 0.989, -0.147))
			setup_custom_raw_spawner(self.world, "onslaught_cart_guard_2", Vector3(-17.70, 39.9, 20.5), Quaternion.from_elements(0, 0, 0.899, 0.437))
		elseif level_key == "skittergate" then
			setup_custom_raw_spawner(self.world, "onslaught_gate_guard", Vector3(-271.67, -355.88, -122.12), Quaternion.from_elements(0, 0, -0.112, -0.994))
			
			local onslaught_CW_gatekeeper_1 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(265.35, 481.66, -16.1), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_CW_gatekeeper_1, "onslaught_CW_gatekeeper_1", false)
			
			local onslaught_CW_gatekeeper_2 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(259.66, 442.29, -14.23), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_CW_gatekeeper_2, "onslaught_CW_gatekeeper_2", false)
			
			local onslaught_CW_gatekeeper_3 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(281.45, 474, -14.85), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_CW_gatekeeper_3, "onslaught_CW_gatekeeper_3", false)
			
			local onslaught_zerker_gatekeeper_1 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(269.59, 432.6, -8.99), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_zerker_gatekeeper_1, "onslaught_zerker_gatekeeper", false)
			
			local onslaught_zerker_gatekeeper_2 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(237, 438.64, -6.85), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_zerker_gatekeeper_2, "onslaught_zerker_gatekeeper", false)
			
			local onslaught_zerker_gatekeeper_3 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(281.45, 474, -14.85), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_zerker_gatekeeper_3, "onslaught_zerker_gatekeeper", false)
		elseif level_key == "dlc_bogenhafen_slum" then
			local onslaught_slum_gauntlet_behind = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(83.87, -43, 6.5), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_slum_gauntlet_behind, "onslaught_slum_gauntlet_behind", false)
			
			local onslaught_slum_gauntlet_cutoff_1 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(165.44, 14.82, 3.6), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_slum_gauntlet_cutoff_1, "onslaught_slum_gauntlet_cutoff", false)
			
			local onslaught_slum_gauntlet_cutoff_2 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(154.77, -9.38, 0.6), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_slum_gauntlet_cutoff_2, "onslaught_slum_gauntlet_cutoff", false)
		elseif level_key == "dlc_bogenhafen_city" then			
			setup_custom_raw_spawner(self.world, "onslaught_sewer_exit_gun_1", Vector3(-23.77, 37.6, 2.1), Quaternion.from_elements(0, 0, -0.109, -0.994))
			setup_custom_raw_spawner(self.world, "onslaught_sewer_exit_gun_2", Vector3(-7.3, 30.48, 13.52), Quaternion.from_elements(0, 0, 0.862, -0.507))
			
			local onslaught_sewer_backspawn_S1 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(-33.87, 194.21, 6.5), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_sewer_backspawn_S1, "onslaught_sewer_backspawn", true)

			local onslaught_sewer_backspawn_S2 = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(-30.42, 202.5, 6.5), Quaternion.identity())
			setup_custom_horde_spawner(onslaught_sewer_backspawn_S2, "onslaught_sewer_backspawn", true)
		elseif level_key == "forest_ambush" then
			setup_custom_raw_spawner(self.world, "onslaught_doomwheel_boss", Vector3(288.65, -103.11, 20.15), Quaternion.from_elements(0, 0, 0.923, -0.385))
		elseif level_key == "dwarf_whaling" then
			local whaletoilet = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(49.478, 159.457, 21.508), Quaternion.identity())
			setup_custom_horde_spawner(whaletoilet, "whaletoilet", true)

			setup_custom_raw_spawner(self.world, "whale_gas", Vector3(-6.62639, 168.118, 41.4601), Quaternion.from_elements(0, 0, 0.968966, -0.247196))

			local behindhut = World.spawn_unit(self.world, "units/hub_elements/empty", Vector3(21.3014, 138.127, 32.8669), Quaternion.identity())
			setup_custom_horde_spawner(behindhut, "behindhut", true)
		end

		local entity_manager = Managers.state.entity
		entity_manager:add_and_register_units(self.world, custom_spawners, #custom_spawners)
	end
end)

-- Nest boss logic: Intro Spiral shit
--[[
mod:hook(BTEnterHooks, "on_skaven_warlord_intro_enter", function(func, self, unit, blackboard, t)
	mod:chat_broadcast("Skarrik brave-strong! Man-things not! Cut-crush!")
end)
]]

-- Skarikk guh
mod:hook(Breeds.skaven_storm_vermin_warlord, "run_on_update", function (func, unit, blackboard, t, dt)
	local side = Managers.state.side.side_by_unit[unit]
	local enemy_player_and_bot_units = side.ENEMY_PLAYER_AND_BOT_UNITS
	local enemy_player_and_bot_positions = side.ENEMY_PLAYER_AND_BOT_POSITIONS
	local self_pos = POSITION_LOOKUP[unit]
	local range = BreedActions.skaven_storm_vermin_champion.special_attack_spin.radius
	local num = 0

	for i, position in ipairs(enemy_player_and_bot_positions) do
		local player_unit = enemy_player_and_bot_units[i]

		if Vector3.distance(self_pos, position) < range and not ScriptUnit.extension(player_unit, "status_system"):is_disabled() and not ScriptUnit.extension(player_unit, "status_system"):is_invisible() then
			num = num + 1
		end
	end

	blackboard.surrounding_players = num

	if blackboard.surrounding_players > 0 then
		blackboard.surrounding_players_last = t
	end

	if not blackboard.spawned_at_t then blackboard.spawned_at_t = t end

	if not blackboard.has_spawned_initial_wave and blackboard.spawned_at_t + 4 < t then
		local conflict_director = Managers.state.conflict

		local strictly_not_close_to_players = true
		local silent = false
		local composition_type = "stronghold_boss_initial_wave"
		local limit_spawners, terror_event_id = nil
		local side_id = side.side_id
		conflict_director.horde_spawner:execute_event_horde(t, terror_event_id, side_id, composition_type, limit_spawners, silent, nil, strictly_not_close_to_players)
		blackboard.has_spawned_initial_wave = true
	end

	if blackboard.trickle_timer and blackboard.trickle_timer < t and not blackboard.defensive_mode_duration then
		local conflict_director = Managers.state.conflict

		if conflict_director:count_units_by_breed("skaven_slave") < 10 then
			local strictly_not_close_to_players = true
			local silent = true
			local composition_type = "stronghold_boss_trickle"
			local limit_spawners, terror_event_id = nil
			local side_id = side.side_id

			conflict_director.horde_spawner:execute_event_horde(t, terror_event_id, side_id, composition_type, limit_spawners, silent, nil, strictly_not_close_to_players)

			blackboard.trickle_timer = t + 35
		else
			blackboard.trickle_timer = t + 2
		end
	end

	local breed = blackboard.breed

	if blackboard.dual_wield_mode then
		local hp = ScriptUnit.extension(blackboard.unit, "health_system"):current_health_percent()
		if blackboard.current_phase == 1 and hp < 0.95 then
			blackboard.current_phase = 2
			blackboard.dual_wield_timer = t + 20
			blackboard.dual_wield_mode = false
		end

		if (blackboard.dual_wield_timer < t and not blackboard.active_node) or blackboard.defensive_mode_duration then
			blackboard.dual_wield_timer = t + 20
			blackboard.dual_wield_mode = false
		end
	else
		local hp = ScriptUnit.extension(blackboard.unit, "health_system"):current_health_percent()

		if blackboard.current_phase == 2 and hp < 0.15 then
			blackboard.current_phase = 3
			local new_run_speed = breed.angry_run_speed
			blackboard.run_speed = new_run_speed

			if not blackboard.run_speed_overridden then
				blackboard.navigation_extension:set_max_speed(new_run_speed)
			end
		elseif blackboard.current_phase == 1 and hp < 0.95 then
			blackboard.current_phase = 2
		end

		if blackboard.defensive_mode_duration then
			if not blackboard.defensive_mode_duration_at_t then
				blackboard.defensive_mode_duration_at_t = t + blackboard.defensive_mode_duration - 15
			end

			if blackboard.defensive_mode_duration_at_t <= t then
				blackboard.defensive_mode_duration = nil
				blackboard.defensive_mode_duration_at_t = nil
			else
				blackboard.defensive_mode_duration = t - blackboard.defensive_mode_duration_at_t
				blackboard.dual_wield_mode = false
			end
		elseif blackboard.dual_wield_timer < t and not blackboard.active_node then
			blackboard.dual_wield_mode = true
			blackboard.dual_wield_timer = t + 60
		end
	end

	if blackboard.displaced_units then
		AiUtils.push_intersecting_players(unit, unit, blackboard.displaced_units, breed.displace_players_data, t, dt)
	end
end)

-- Warcamp boss logic
mod:hook(Breeds.chaos_exalted_champion_warcamp, "run_on_update", function (func, unit, blackboard, t, dt)
	local self_pos = POSITION_LOOKUP[unit]
	local breed = blackboard.breed
	local wwise_world = Managers.world:wwise_world(blackboard.world)
	local range = BreedActions.chaos_exalted_champion.special_attack_aoe.radius
	local num = 0
	local player_average_hp = 0
	local side = Managers.state.side.side_by_unit[unit]
	local enemy_player_and_bot_positions = side.ENEMY_PLAYER_AND_BOT_POSITIONS
	local enemy_player_and_bot_units = side.ENEMY_PLAYER_AND_BOT_UNITS

	for i, position in ipairs(enemy_player_and_bot_positions) do
		local player_unit = enemy_player_and_bot_units[i]

		if Vector3.distance(self_pos, position) < range and not ScriptUnit.extension(player_unit, "status_system"):is_disabled() and not ScriptUnit.extension(player_unit, "status_system"):is_invisible() then
			num = num + 1
		end

		if ScriptUnit.extension(player_unit, "status_system"):is_knocked_down() then
			player_average_hp = player_average_hp - 1
		else
			local player_hp = ScriptUnit.extension(player_unit, "health_system"):current_health_percent()
			player_average_hp = player_average_hp + player_hp
		end
	end

	blackboard.surrounding_players = num

	if blackboard.surrounding_players > 0 then
		blackboard.surrounding_players_last = t
	end

	player_average_hp = player_average_hp / 4
	local hp = ScriptUnit.extension(unit, "health_system"):current_health_percent()

	if blackboard.current_phase == 1 and hp < 0.95 then
		local new_run_speed = breed.angry_run_speed
		blackboard.run_speed = new_run_speed

		if not blackboard.run_speed_overridden then
			blackboard.navigation_extension:set_max_speed(new_run_speed)
		end
	end

	if blackboard.override_spawn_allies_call_position then
		if blackboard.current_phase == 1 and hp < 0.9 then
			blackboard.current_phase = 2
			blackboard.trickle_timer = t + 1
		elseif blackboard.current_phase == 2 and hp < 0.4 then
			blackboard.current_phase = 3
		end
	end

	local conflict_director = Managers.state.conflict

	if blackboard.defensive_mode_duration then
		local remaining = blackboard.defensive_mode_duration - dt

		if remaining <= 0 or (remaining <= 15 and conflict_director:enemies_spawned_during_event() <= 20) then
			blackboard.defensive_mode_duration = nil
		elseif remaining <= 15 and conflict_director:count_units_by_breed("chaos_berzerker") < 10 then
			blackboard.defensive_mode_duration = nil
		else
			blackboard.defensive_mode_duration = remaining
		end
	end

	if hp > 0.05 and blackboard.trickle_timer and blackboard.trickle_timer < t and not blackboard.defensive_mode_duration then
		local timer = hp * 15
		timer = math.max(timer, 5)

		if conflict_director:count_units_by_breed("chaos_marauder") < 10 or conflict_director:count_units_by_breed("chaos_berzerker") < 3 then
			local strictly_not_close_to_players = true
			local silent = true
			local composition_type = "warcamp_boss_event_trickle"
			local limit_spawners = nil
			local terror_event_id = "warcamp_boss_minions"
			local side_id = side.side_id

			conflict_director.horde_spawner:execute_event_horde(t, terror_event_id, side_id, composition_type, limit_spawners, silent, nil, strictly_not_close_to_players)

			blackboard.trickle_timer = t + timer
		else
			blackboard.trickle_timer = t + (timer * 2/3)
		end
	end

	if blackboard.displaced_units then
		AiUtils.push_intersecting_players(unit, unit, blackboard.displaced_units, breed.displace_players_data, t, dt)
	end

	AiBreedSnippets.update_exalted_champion_cheer_state(unit, blackboard, t, dt, player_average_hp)

	if blackboard.ray_can_go_update_time < t and Unit.alive(blackboard.target_unit) then
		local nav_world = blackboard.nav_world
		local target_position = POSITION_LOOKUP[blackboard.target_unit]
		blackboard.ray_can_go_to_target = LocomotionUtils.ray_can_go_on_mesh(nav_world, POSITION_LOOKUP[unit], target_position, nil, 1, 1)
		blackboard.ray_can_go_update_time = t + 0.5
	end
end)

--Rasknitt boss logic
mod:hook(BTGreySeerGroundCombatAction, "update_regular_spells", function (func, self, unit, blackboard, t)
	local spell_data = blackboard.spell_data
	local ready_to_summon = nil
	local dialogue_input = ScriptUnit.extension_input(unit, "dialogue_system")
	local warp_lightning_timer = spell_data.warp_lightning_spell_timer
	local vemintide_timer = spell_data.vermintide_spell_timer
	local teleport_timer = spell_data.teleport_spell_timer
	local current_phase = blackboard.current_phase

	if vemintide_timer < t then
		blackboard.current_spell_name = "vermintide"
		ready_to_summon = true
		spell_data.vermintide_spell_timer = t + spell_data.vermintide_spell_cooldown
		local event_data = FrameTable.alloc_table()

		dialogue_input:trigger_networked_dialogue_event("egs_cast_vermintide", event_data)
	elseif warp_lightning_timer < t then
		blackboard.current_spell_name = "warp_lightning"
		ready_to_summon = true
		spell_data.warp_lightning_spell_timer = t + spell_data.warp_lightning_spell_cooldown
		local event_data = FrameTable.alloc_table()

		dialogue_input:trigger_networked_dialogue_event("egs_cast_lightning", event_data)
	end

	return ready_to_summon
end)

mod:hook(AiBreedSnippets, "on_grey_seer_update", function (func, unit, blackboard, t)
	local breed = blackboard.breed
	local mounted_data = blackboard.mounted_data
	local health_extension = ScriptUnit.extension(blackboard.unit, "health_system")
	local hp = health_extension:current_health_percent()
	local hit_reaction_extension = blackboard.hit_reaction_extension
	local position = POSITION_LOOKUP[unit]
	local current_phase = blackboard.current_phase
	local mount_unit = mounted_data.mount_unit
	local network_manager = Managers.state.network
	local game = network_manager:game()
	local go_id = Managers.state.unit_storage:go_id(unit)
	local network_transmit = network_manager.network_transmit
	local dialogue_input = ScriptUnit.extension_input(unit, "dialogue_system")

	if blackboard.intro_timer or current_phase == 6 then
		return
	end

	if blackboard.current_phase ~= 5 and blackboard.death_sequence then
		blackboard.current_phase = 5
		local event_data = FrameTable.alloc_table()

		dialogue_input:trigger_networked_dialogue_event("egs_death_scene", event_data)

		blackboard.face_player_when_teleporting = true
		blackboard.death_sequence = nil
		local strictly_not_close_to_players = true
		local silent = true
		local composition_type = "skittergate_grey_seer_trickle"
		local limit_spawners, terror_event_id = nil
		local conflict_director = Managers.state.conflict

		conflict_director.horde_spawner:execute_event_horde(t, terror_event_id, composition_type, limit_spawners, silent, nil, strictly_not_close_to_players)
	elseif current_phase == 2 and hp < 0.5 then
		blackboard.current_phase = 3
	elseif current_phase == 1 and hp < 0.75 then
		blackboard.current_phase = 2
	end

	if not Unit.alive(mount_unit) and blackboard.current_phase ~= 5 and blackboard.current_phase ~= 6 then
		if blackboard.current_phase ~= 4 then
			local event_data = FrameTable.alloc_table()

			dialogue_input:trigger_networked_dialogue_event("egs_stormfiend_dead", event_data)
		end

		blackboard.current_phase = 4
		blackboard.knocked_off_mount = true
		blackboard.call_stormfiend = nil
		blackboard.about_to_mount = nil
		blackboard.should_mount_unit = nil
	end

	if blackboard.unlink_unit then
		blackboard.unlink_unit = nil
		local mount_blackboard = mount_unit and BLACKBOARDS[mount_unit]

		if mount_blackboard then
			mount_blackboard.linked_unit = nil
		end

		blackboard.quick_teleport_timer = t + 10
		blackboard.quick_teleport = nil
		blackboard.hp_at_knocked_off = hp
		local game = Managers.state.network:game()
		local mount_go_id = Managers.state.unit_storage:go_id(mount_unit)

		if game and mount_go_id then
			GameSession.set_game_object_field(game, mount_go_id, "animation_synced_unit_id", 0)
		end
	end

	local call_mount_hp_threshold = 0.25

	if mounted_data.knocked_off_mounted_timer and blackboard.hp_at_knocked_off and call_mount_hp_threshold <= blackboard.hp_at_knocked_off - hp then
		mounted_data.knocked_off_mounted_timer = t
	end

	if blackboard.knocked_off_mount and Unit.alive(mount_unit) then
		local mount_blackboard = BLACKBOARDS[mount_unit]
		local mounted_timer_finished = mounted_data.knocked_off_mounted_timer and mounted_data.knocked_off_mounted_timer <= t
		local should_call_stormfiend = not blackboard.call_stormfiend and not mount_blackboard.intro_rage and mounted_timer_finished and not mount_blackboard.goal_position and not mount_blackboard.anim_cb_move

		if should_call_stormfiend then
			blackboard.call_stormfiend = true
		elseif mounted_timer_finished then
			blackboard.about_to_mount = true
			local mount_unit_position = POSITION_LOOKUP[mount_unit]
			local distance_to_goal = Vector3.distance(position, mount_unit_position)

			if distance_to_goal < 2 then
				blackboard.knocked_off_mount = nil
				blackboard.should_mount_unit = true
				blackboard.ready_to_summon = nil
				blackboard.about_to_mount = nil
				blackboard.call_stormfiend = nil
				mount_blackboard.should_mount_unit = true
				local health_extension = ScriptUnit.extension(mount_unit, "health_system")
				local mount_hp = health_extension:current_health_percent()
				mount_blackboard.hp_at_mounted = mount_hp
			end
		end
	end

	if blackboard.trickle_timer and blackboard.trickle_timer < t and not blackboard.defensive_mode_duration and current_phase < 4 then
		local conflict_director = Managers.state.conflict
		local timer = hp * 8

		if blackboard.knocked_off_mount or not Unit.alive(mount_unit) then
			timer = timer * 0.5
		end

		if conflict_director:count_units_by_breed("skaven_slave") < 60 then
			local strictly_not_close_to_players = true
			local silent = true
			local composition_type = "skittergate_grey_seer_trickle"
			local limit_spawners, terror_event_id = nil

			conflict_director.horde_spawner:execute_event_horde(t, terror_event_id, composition_type, limit_spawners, silent, nil, strictly_not_close_to_players)

			blackboard.trickle_timer = t + timer
		else
			blackboard.trickle_timer = t + (timer / 2)
		end
	end

	if blackboard.missile_bot_threat_unit then
		local bot_threat_position = POSITION_LOOKUP[blackboard.missile_bot_threat_unit]
		local radius = 2
		local height = 1
		local half_height = height * 0.5
		local size = Vector3(radius, half_height, radius)
		bot_threat_position = bot_threat_position - Vector3.up() * half_height

		Managers.state.entity:system("ai_bot_group_system"):aoe_threat_created(bot_threat_position, "cylinder", size, nil, 1)

		blackboard.missile_bot_threat_unit = nil
	end
end)

-- Nurgloth boss logic
leech_spawn_count = 0
mod:hook(BTSpawnAllies, "_spawn", function (func, self, unit, data, blackboard, t)
	func(self, unit, data, blackboard, t)
	local comp = blackboard.action.name
	if comp == "spawn_allies_defensive" or comp == "spawn_allies_devensive_intense" then
		local conflict_director = Managers.state.conflict
		local hidden_pos = conflict_director.specials_pacing:get_special_spawn_pos()
		conflict_director:spawn_one(Breeds["chaos_vortex_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_vortex_sorcerer"], hidden_pos)
	elseif comp == "spawn_allies_offensive" then
		local conflict_director = Managers.state.conflict
		local hidden_pos = conflict_director.specials_pacing:get_special_spawn_pos()
		conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
	elseif comp == "spawn_allies_trickle" then
		if leech_spawn_count == 4 then
			leech_spawn_count = 0
		else
			local conflict_director = Managers.state.conflict
			local hidden_pos = conflict_director.specials_pacing:get_special_spawn_pos()
			conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
			leech_spawn_count = leech_spawn_count + 1
		end
	end
end)

mod:hook(BTQuickTeleportAction, "enter", function (func, self, unit, blackboard, t)
	func(self, unit, blackboard, t)
	if blackboard.action.name == "teleport_to_aoe" then
		local conflict_director = Managers.state.conflict
		local hidden_pos = conflict_director.specials_pacing:get_special_spawn_pos()
		conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_corruptor_sorcerer"], hidden_pos)
	end
end)

-- Because it's crashy in here
mod:hook(AiUtils, "push_intersecting_players", function (func, unit, source_unit, displaced_units, data, t, dt, hit_func, ...)
	local side = Managers.state.side.side_by_unit[source_unit or unit]
	if side then
		func(unit, source_unit, displaced_units, data, t, dt, hit_func, ...)
	end
end)


-- UI Stuff

--[[
mod:hook_origin(TerrorEventUtils, "generate_enhanced_breed_from_set", function(enhancement_set)
	local list = {}
	local BreedEnhancements = BreedEnhancements

	for name, value in pairs(enhancement_set) do
		if value and BreedEnhancements[name] then
			local enhancement = BreedEnhancements[name]

			list[#list + 1] = enhancement
		end
	end

	return list
end)
]]

-- Daredevii
mod:dofile("scripts/mods/Daredevil/dd_mutator")

--[[
	---------------------------------	
	---------------------------------
	---------------------------------
	---------------------------------
]]

-- Chinese Onslaught variation

mod:network_register("rpc_enable_white_sv", function (sender, enable)
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.min = 31
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.max = 31
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.min = 1
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.max = 1
end)

mod:network_register("rpc_disable_white_sv", function (sender, enable)
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.min = 0
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.max = 30
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.min = 0
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.max = 5
end)

mod:network_register("bob_name_enable", function (sender, enable)
	--[[
	Breeds.skaven_dummy_clan_rat = mod.deepcopy(Breeds.skaven_ratling_gunner)
	Breeds.skaven_dummy_clan_rat.size_variation_range = { 3, 3 }
	Breeds.skaven_dummy_clan_rat.boss = true -- No WHC/Shade cheese fight this big man fair and square
	]]
	GrudgeMarkedNames.skaven = { "Bob the Builder" }
end)

mod:network_register("bob_name_disable", function (sender, enable)
	GrudgeMarkedNames.skaven = { "name_grudge_skaven_001" }
end)

mod:network_register("giant_so_true", function (sender, enable)
	Breeds.skaven_dummy_slave = mod.deepcopy(Breeds.chaos_troll)
	Breeds.skaven_dummy_slave.height = 4.35
	Breeds.skaven_dummy_slave.size_variation_range = { 1.45, 1.45 }
end)

mod:network_register("giant_so_false", function (sender, enable)
	Breeds.skaven_dummy_slave = mod.deepcopy(Breeds.skaven_dummy_slave)
end)

mod:network_register("breed_loading_in", function (sender, enable)
	EnemyPackageLoaderSettings.categories = {
		{
			id = "bosses",
			dynamic_loading = false,
			limit = math.huge,
			breeds = {
				"chaos_spawn",
				"chaos_troll",
				"skaven_rat_ogre",
				"skaven_stormfiend",
				"beastmen_minotaur"
			}
		},
		{
			id = "specials",
			dynamic_loading = false,
			limit = math.huge,
			breeds = {
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"skaven_poison_wind_globadier",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"chaos_vortex_sorcerer",
				"beastmen_standard_bearer"
			}
		},
		{
			id = "level_specific",
			dynamic_loading = true,
			limit = math.huge,
			breeds = {
				"chaos_dummy_sorcerer",
				"chaos_exalted_champion_warcamp",
				"chaos_exalted_sorcerer",
				"skaven_storm_vermin_warlord",
				"skaven_storm_vermin_champion",
				"chaos_plague_wave_spawner",
				"skaven_stormfiend_boss",
				"skaven_grey_seer"
			}
		},
		{
			id = "debug",
			dynamic_loading = true,
			forbidden_in_build = "release",
			limit = math.huge,
			breeds = {
				"chaos_zombie",
				"chaos_tentacle",
				"chaos_tentacle_sorcerer",
				"skaven_stormfiend_demo"
			}
		},
		{
			id = "always_loaded",
			dynamic_loading = false,
			breeds = {
				"chaos_vortex",
				"critter_rat",
				"critter_pig",
				"critter_nurgling",
				"beastmen_gor",
				"beastmen_bestigor",
				"beastmen_ungor",
				"chaos_warrior",
				"chaos_raider",
				"skaven_clan_rat",
				"skaven_clan_rat_with_shield",
				"skaven_plague_monk",
				"skaven_slave",
				"chaos_marauder",
				"chaos_marauder_with_shield",
				"chaos_berzerker",
				"skaven_storm_vermin",
				"skaven_storm_vermin_with_shield",
				"chaos_fanatic",
				"skaven_storm_vermin_warlord",
				"chaos_exalted_sorcerer_drachenfels",
				"chaos_exalted_sorcerer",
				"skaven_storm_vermin_champion",
				"chaos_bulwark"
			}
		}
	}
end)

mod:hook_safe("ChatManager", "_add_message_to_list", function (self, channel_id, message_sender, local_player_id, message, is_system_message, pop_chat, is_dev, message_type, link, data)
	if message == JOIN_MESSAGE and not mutator_plus.active then
		mod:network_send("rpc_enable_white_sv", "local", true)
		mod:network_send("bob_name_enable", "local", true)
		mod:network_send("giant_so_true", "local", true)
		mod:network_send("c3dwlines", "local", true)
		mod:network_send("breed_loading_in", "local", true)
--		mod:network_send("linesman_ost", "local", true)
	end
end)

mod.on_user_joined = function (player)
	if mutator_plus.active then
		mod:network_send("rpc_enable_white_sv", "others", true)
		mod:network_send("bob_name_enable", "others", true)
		mod:network_send("giant_so_true", "local", true)
		mod:network_send("c3dwlines", "others", true)
		mod:network_send("breed_loading_in", "others", true)
--		mod:network_send("linesman_ost", "others", true)
	end
end

mutator_plus.start = function()
	mod:dofile("scripts/mods/Daredevil/linesman/linesman")
end

mutator_plus.stop = function()

	Breeds = table.clone(mutator_plus.OriginalBreeds)	
	mod:dofile("scripts/settings/horde_compositions")
	mod:dofile("scripts/settings/horde_compositions_pacing")
	mod:dofile("scripts/settings/conflict_settings")
	mod:dofile("scripts/settings/patrol_formation_settings")
	mod:dofile("scripts/settings/terror_event_blueprints")
	mod:dofile("scripts/settings/unit_variation_settings")
	mod:dofile("scripts/settings/level_settings")
	mod:dofile("scripts/managers/conflict_director/conflict_director")
	mod:dofile("scripts/managers/conflict_director/spawn_zone_baker")
	mod:dofile("scripts/managers/conflict_director/pacing")
	mod:dofile("scripts/managers/conflict_director/specials_pacing")

	ExplosionTemplates.standard_bearer_explosion.explosion.damage_profile = "standard_bearer_explosion"
    ExplosionTemplates.standard_bearer_explosion.explosion.catapult_players = true
    ExplosionTemplates.standard_bearer_explosion.explosion.player_push_speed = 10

	-- Only send rpc if host disables mutator
	mod:network_send("rpc_disable_white_sv", "all", true)
	mod:network_send("bob_name_disable", "all", true)
	mod:network_send("c3dwlines", "others", false)
	mod:network_send("giant_so_false", "all", true)


	---------------------

	create_weights()

	mod:disable_all_hooks()
		
	mutator_plus.active = false
end

mutator_plus.toggle = function()
	if Managers.state.game_mode == nil or (Managers.state.game_mode._game_mode_key ~= "inn" and Managers.player.is_server) then
		mod:echo("You must be in the keep to do that!")
		return
	end
	if Managers.matchmaking:_matchmaking_status() ~= "idle" then
		mod:echo("You must cancel matchmaking before toggling this.")
		return
	end
	if mod:get("giga_specials") then
		mod:chat_broadcast("are you ok???")
	end
	if mod:get("lonk") then
		mod:chat_broadcast("die")
	end
	if not mutator_plus.active then
		if not Managers.player.is_server then
			mod:echo("You must be the host to activate this.")
			return
		end
		mutator_plus.start()

		if mod.difficulty_level == 1 then
			mod:chat_broadcast("Linesbaby Onslaught ENABLED.")
			mod:chat_broadcast("L猛已启动")
		elseif mod.difficulty_level == 2 then
			mod:chat_broadcast("Linesboy Onslaught ENABLED.")
			mod:chat_broadcast("L猛已启动")
		elseif mod.difficulty_level == 3 then
			mod:chat_broadcast("Linesman Onslaught ENABLED.")
			mod:chat_broadcast("L猛已启动")
		end

		if mod:get("beta") then
			mod:chat_broadcast("Running Linesman BETA Version 3.0.0")
			mod:chat_broadcast("这是Linesman BETA！")
		else 
			mod:chat_broadcast("Version 3.0.0")
		end 
	else
		mutator_plus.stop()
		mod:chat_broadcast("Loser!!!!!!!!!!!!!!!!!!!!!!!!!!!!! FUCKING LOSER FUCK YOU FUCK YOU FUCK YOU FUCK HYOYJERHEJKHEWGPWEYGHWBMJ")
		mod:chat_broadcast("L猛已关掉")
	end
end

--[[
	Callback
--]]
-- Call when game state changes (e.g. StateLoading -> StateIngame)
-- mod:dofile("scripts/mods/Daredevil/helpers") -- Run helpers functions

mod.on_game_state_changed = function(status, state)
	if not Managers.player.is_server and mutator_plus.active and Managers.state.game_mode ~= nil then
		mutator_plus.stop()
		mod:echo("Linesman Onslaught was disabled because you are no longer the server.")
	end
	return
end

mod.on_setting_changed = function(self, setting_name)
	local player = Managers.player:local_player()
	local unit = player.player_unit
--[[
	if mod:get("friendly_dr") then
		if Unit.alive(unit) then
			local buff_system = Managers.state.entity:system("buff_system")
			local server_controlled = false

			buff_system:add_buff(unit, "markus_knight_guard_defence_buff", unit, server_controlled)
		end
		mod:echo("Applying 50%% DR.")
	else
		local buff_extension = ScriptUnit.extension(unit, "buff_system")
		local dr_buff = buff_extension:get_non_stacking_buff("markus_knight_guard_defence_buff")

		buff_extension:remove_buff(dr_buff.id)
		mod:echo("Removed 50%% DR.")
	end
	]]

	--[[
	if mod:get("newbie_dr") then
		if Unit.alive(unit) then
			local buff_system = Managers.state.entity:system("buff_system")
			local server_controlled = false

			buff_system:add_buff(unit, "sienna_necromancer_5_2_buff", unit, server_controlled)
		end
		mod:echo("Applying 80%% DR.")
	else
		local buff_extension = ScriptUnit.extension(unit, "buff_system")
		local dre_buff = buff_extension:get_non_stacking_buff("sienna_necromancer_5_2_buff")

		buff_extension:remove_buff(dre_buff.id)
		mod:echo("Removed 80%% DR.")
	end
	]]
end

--[[
	Execution
--]]
mod:command("linesman", " Die", function() 
mutator_plus.toggle()
if not mutator_plus.active then
	mod:disable_all_hooks()
end
end)

--[[
mod:command("STOPTHEVOICESPLEASE", " Stops all music played during Linesman.", function()
    local wwise_world = Wwise.wwise_world(Managers.world:world("level_world"))
    WwiseWorld.trigger_event(wwise_world, "Play_curse_egg_of_tzeentch_alert_egg_destroyed")
end)  

mod:command("darksoulseldenring", " Plays Bob Boss fight OST.", function()
    local wwise_world = Wwise.wwise_world(Managers.world:world("level_world"))
    WwiseWorld.trigger_event(wwise_world, "Play_curse_egg_of_tzeentch_alert_low")
end)  
]]

mod:command("ihateconvo", " i HATE convocation of DECAY more like convocation of PISS", function()
	TerrorEventBlueprints.catacombs.catacombs_load_sorcerers = {
		{
			"force_load_breed_package",
			breed_name = "chaos_dummy_sorcerer"
		},
		{
			"control_hordes",
			enable = true
		}
	}
	mod:chat_broadcast("FUCK convo")
end)