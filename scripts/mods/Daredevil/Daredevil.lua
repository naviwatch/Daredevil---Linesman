local mod = get_mod("Daredevil")
local mutator = mod:persistent_table("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")

--[[
	Functions
--]]

local function count_event_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
end

local function count_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed(breed_name)
end

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
	if breed_name == "chaos_plague_sorcerer" then
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

mod:hook(IngamePlayerListUI, "_update_difficulty", function (func, self)
	local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
	local base_difficulty_name = difficulty_settings.display_name
	local dw = get_mod("catas")
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
	else
		return func(self)
	end
end)

mod:hook(Presence, "set_presence", function(func, key, value)
	local deathwish_enabled = get_mod("catas") and Managers.vmf.persistent_tables.catas.catas.active
	local dw = get_mod("catas")
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
					func(key, "C3 Deathman")
				elseif value == "cataclysm" then
					func(key, "ryan gosling")
				else
					func(key, "DELI HAM ONLY FOR 3.99")
				end
			end
		else
			return func(key, value)
		end
	else
	func(key, value)
  end
end)

--[[
-- In-game UI
mod:hook(IngamePlayerListUI, "_set_difficulty_name", function(func, self, name)
	mod.difficulty_level = mod:get("difficulty_level")

  -- Normal UI
  if mutator.active == true and name ~= "" then
        name = "Daredevil"
        local dw = get_mod("catas")
        if dw ~= nil then
            local deathwish = dw:persistent_table("catas")
            if deathwish.active == true and mutator.active == true then
                name = "Contingency Contract"
            end
        end
    end

	-- Linesman
	if mutator_plus.active == true and name ~= "" then
		if mod.difficulty_level == 3 then 
			name = "[DEFAULT] Linesman Onslaught"
			local dw = get_mod("catas")
			if dw ~= nil then
				local deathwish = dw:persistent_table("catas")
				if deathwish.active == true and mutator_plus.active == true then
					name = "[DEFAULT] Linesman Deathwish"
				end
			end
		elseif mod.difficulty_level == 2 then
			name = "[DUTCH] Linesman Onslaught"
			local dw = get_mod("catas")
			if dw ~= nil then
				local deathwish = dw:persistent_table("catas")
				if deathwish.active == true and mutator_plus.active == true then
					name = "[DUTCH] Linesman Deathwish"
				end
			end
		elseif mod.difficulty_level == 1 then
			name = "[PLUS] Linesman Onslaught"
			local dw = get_mod("catas")
			if dw ~= nil then
				local deathwish = dw:persistent_table("catas")
				if deathwish.active == true and mutator_plus.active == true then
					name = "[PLUS] Linesman Deathwish"
				end
			end
		end
    end

	-- Linesman Beta
	if mutator_plus.active == true and name ~= "" and mod:get("testers") then
        name = "[Beta] Linesman Onslaught"
        local dw = get_mod("catas")
        if dw ~= nil then
            local deathwish = dw:persistent_table("catas")
            if deathwish.active == true and mutator_plus.active == true and mod:get("testers") then
                name = "[Beta] Linesman Deathwish"
            end
        end
    end

    return func(self, name)
end)

-- Steam Presence
mod:hook(Presence, "set_presence", function(func, key, value)
	if value == "#presence_modded" then
		func(key, "#presence_modded_difficulty")
	elseif key == "difficulty" then
		local new_diff = value
		if mutator.active then
			local difficulty_display_name = Managers.state.difficulty:get_difficulty_settings().display_name
			new_diff = "Daredevil"
		end
		if mutator_plus.active then
			local difficulty_display_name = Managers.state.difficulty:get_difficulty_settings().display_name
			new_diff = "Linesman Onslaught"
		end
		func(key, new_diff)
	else
		func(key, value)
	end
	-- return func(key, value)
end)
]]

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

-- Make event horde only spawn when its into the nest
mod:hook(Breeds.skaven_storm_vermin_warlord, "run_on_update", function(func, unit, blackboard, t, dt)
    local side = Managers.state.side.side_by_unit[unit]
    local enemy_player_and_bot_units = side.ENEMY_PLAYER_AND_BOT_UNITS
    local enemy_player_and_bot_positions = side.ENEMY_PLAYER_AND_BOT_POSITIONS
    local self_pos = POSITION_LOOKUP[unit]
    local range = BreedActions.skaven_storm_vermin_champion.special_attack_spin.radius
    local num = 0
    local level_key = Managers.state.game_mode:level_key()
    for i, position in ipairs(enemy_player_and_bot_positions) do
        local player_unit = enemy_player_and_bot_units[i]
        if Vector3.distance(self_pos, position) < range and not ScriptUnit.extension(player_unit, "status_system"):is_disabled() and not ScriptUnit.extension(player_unit, "status_system"):is_invisible() then num = num + 1 end
    end

    blackboard.surrounding_players = num
    if blackboard.surrounding_players > 0 then blackboard.surrounding_players_last = t end
    if not blackboard.spawned_at_t then blackboard.spawned_at_t = t end
    if not blackboard.has_spawned_initial_wave and blackboard.spawned_at_t + 4 < t then
        local conflict_director = Managers.state.conflict
        local strictly_not_close_to_players = true
        local silent = false
        local composition_type = "event_medium"
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
            blackboard.trickle_timer = t + 500
        else
            blackboard.trickle_timer = t + 500
        end
    end

    local breed = blackboard.breed
    if blackboard.dual_wield_mode then
        local hp = ScriptUnit.extension(blackboard.unit, "health_system"):current_health_percent()
        if blackboard.current_phase == 1 and hp < 0.95 then
            blackboard.current_phase = 2
            blackboard.dual_wield_timer = t + 2
            blackboard.dual_wield_mode = false
        end

        if (blackboard.dual_wield_timer < t and not blackboard.active_node) or blackboard.defensive_mode_duration then
            blackboard.dual_wield_timer = t + 2
            blackboard.dual_wield_mode = true
        end
    else
        local hp = ScriptUnit.extension(blackboard.unit, "health_system"):current_health_percent()
        if blackboard.current_phase == 2 and hp < 0.15 then
            blackboard.current_phase = 3
            local new_run_speed = breed.angry_run_speed
            blackboard.run_speed = new_run_speed
            if not blackboard.run_speed_overridden then blackboard.navigation_extension:set_max_speed(new_run_speed) end
        elseif blackboard.current_phase == 1 and hp < 0.95 then
            blackboard.current_phase = 2
        end

        if blackboard.defensive_mode_duration then
            if not blackboard.defensive_mode_duration_at_t then blackboard.defensive_mode_duration_at_t = t + blackboard.defensive_mode_duration - 10 end
            if blackboard.defensive_mode_duration_at_t <= t then
                blackboard.defensive_mode_duration = nil
                blackboard.defensive_mode_duration_at_t = nil
            else
                blackboard.defensive_mode_duration = t - blackboard.defensive_mode_duration_at_t
                blackboard.dual_wield_mode = false
            end
        elseif blackboard.dual_wield_timer < t and not blackboard.active_node then
            blackboard.dual_wield_mode = true
            blackboard.dual_wield_timer = 2
        end
    end

    if blackboard.displaced_units then AiUtils.push_intersecting_players(unit, unit, blackboard.displaced_units, breed.displace_players_data, t, dt) end
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
		conflict_director:spawn_one(Breeds["chaos_plague_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_plague_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_plague_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_plague_sorcerer"], hidden_pos)
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
		conflict_director:spawn_one(Breeds["chaos_plague_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_plague_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_plague_sorcerer"], hidden_pos)
		conflict_director:spawn_one(Breeds["chaos_plague_sorcerer"], hidden_pos)
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
-- Loading in packages
mod:dofile("scripts/mods/Daredevil/linesman/mutator/breed_data")

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

local boss_pre_spawn_func = nil
local custom_grudge_boss = nil
boss_pre_spawn_func = TerrorEventUtils.add_enhancements_for_difficulty
custom_grudge_boss = TerrorEventUtils.generate_enhanced_breed_from_set

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
	["intangible"] = true,
	["unstaggerable"] = true,
	["crushing"] = true
}
local enhancement_7 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
	["crushing"] = true
}
local shield_shatter = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)


mutator.start = function()

	-- Pacing
	--mutator.OriginalConflictDirectors = table.clone(ConflictDirectors)
	mutator.OriginalDifficultySettings = table.clone(DifficultySettings)
	mutator.OriginalBreeds = table.clone(Breeds)
	mutator.OriginalBreedPacks = table.clone(BreedPacks)
	mutator.OriginalBreedActions = table.clone(BreedActions)
	mutator.OriginalBreedPacksBySize = table.clone(BreedPacksBySize)
	mutator.OriginalPackSpawningSettings = table.clone(PackSpawningSettings)
	mutator.OriginalPacingSettings = table.clone(PacingSettings)
	mutator.OriginalRecycleSettings  = table.clone(RecycleSettings)
	mutator.OriginalHordeCompositions = table.clone(HordeCompositions)	
	mutator.OriginalHordeCompositionsPacing = table.clone(HordeCompositionsPacing)
	mutator.OriginalSpecialsSettings = table.clone(SpecialsSettings)
	--mutator.OriginalCurrentSpecialsSettings = table.clone(CurrentSpecialsSettings)

	-- Events and Triggers
	mutator.OriginalGenericTerrorEvents = table.clone(GenericTerrorEvents)
	mutator.OriginalTerrorEventBlueprints = table.clone(TerrorEventBlueprints)
	mutator.OriginalBossSettings = table.clone(BossSettings)
	mutator.OriginalPatrolFormationSettings = table.clone(PatrolFormationSettings)
	
	mutator.OriginalThreatValue = {}
	for name, breed in pairs(Breeds) do
		if breed.threat_value then
			mutator.OriginalThreatValue[name] = breed.threat_value
		end
	end

	-- Gas duration
	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.duration = 6.5 --8
	-- Gas throw cooldown so you dont get barraged by gas artillery
	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.time_between_throws = { 12, 4 } -- 12,2 what the fuck fatshark
	-- Vortex timer
	BreedActions.chaos_vortex_sorcerer.skulk_approach.vortex_spawn_timer = 20 --25

	-- White SV
	--[[
	Breeds.skaven_storm_vermin.bloodlust_health = BreedTweaks.bloodlust_health.beastmen_elite
	Breeds.skaven_storm_vermin.primary_armor_category = 6
	Breeds.skaven_storm_vermin.size_variation_range = { 1.26, 1.28 }
	Breeds.skaven_storm_vermin.max_health = BreedTweaks.max_health.bestigor
	Breeds.skaven_storm_vermin.hit_mass_counts = BreedTweaks.hit_mass_counts.bestigor
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.min = 30
	UnitVariationSettings.skaven_storm_vermin.material_variations.cloth_tint.max = 31
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.min = 1
	UnitVariationSettings.skaven_storm_vermin.material_variations.skin_tint.max = 1
	]]

	--Non-event settings and compositions
	RecycleSettings.max_grunts = 180                         		    	-- Dutch values at 165
	RecycleSettings.push_horde_if_num_alive_grunts_above = 200   	    	
	
	-- Ambient density multiplied by 175% instead of 200
	mod:hook(SpawnZoneBaker, "spawn_amount_rats", function(func, self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
		--local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
		--local base_difficulty_name = difficulty_settings.display_name
		
		num_wanted_rats = math.round(num_wanted_rats *120/100) -- Normal C3

		return func(self, spawns, pack_sizes, pack_rotations, pack_members, zone_data_list, nodes, num_wanted_rats, ...)
	end)

	mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)

		-- local replacements
		--if breed.name == "skaven_clan_rat" then
			--replacements = {Breeds["skaven_plague_monk"], Breeds["skaven_storm_vermin_commander"]} -- Skaven Elites
		--if breed.name == "skaven_clan_rat" or breed.name == "skaven_storm_vermin_commander" or breed.name == "chaos_marauder" or breed.name == "chaos_raider" then 
		--	replacements1 = {Breeds["skaven_storm_vermin_with_shield"]} -- Stop slayer and gk from running rampart 
		--if breed.name == "chaos_raider" then
		--	replacements2 = {Breeds["chaos_marauder"], Breeds["chaos_berzerker"]} -- Chaos Elites
		--end		

		--if replacements then
		--	if math.random() <= 0.13 then
		--		breed = replacements[math.random(1, #replacements)]
		--	end
		--if replacements1 then 
		--	if math.random() <= 0.001 then 
		--		breed = replacements1[math.random(1, #replacements1)]
		--	end 
		--if replacements2 then
		--	if math.random() <= 0.35 then
		--		breed = replacements2[math.random(1, #replacements2)]
		--	end
		--end
		
		--[[
		local nocw
		if breed.name == "chaos_bulwark" then
			nocw = {Breeds["chaos_raider"], Breeds["chaos_berzerker"]} -- To not piss people off
		end

		if nocw then
			if math.random() <= 1 then
				breed = nocw[math.random(1, #nocw)]
			end
		end
		]]
		
		return func(self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, ...)
	end)

	--[[ 
	-- Change intensity	
	mod:hook_safe(Pacing, "update", function(self, t, dt, alive_player_units) 

		local num_alive_player_units = #alive_player_units

		if num_alive_player_units == 0 then
			return
		end

		for k = 1, num_alive_player_units, 1 do
			self.player_intensity[k] = self.player_intensity[k] * 0.7
		end

		self.total_intensity = self.total_intensity * 0.7
	end)
	]]

	-- Taking damage does not make game easier L (VernonKun)
	-- mod:hook(GenericStatusExtension, "add_damage_intensity", function (func, self, percent_health_lost, damage_type)
		-- self.pacing_intensity = math.clamp(self.pacing_intensity + percent_health_lost * CurrentIntensitySettings.intensity_add_per_percent_dmg_taken * 100, 0, 100)
		--self.pacing_intensity_decay_delay = 0.5
	
		--func(self, 0, damage_type)
	--end)

local mean = 1.1
local range = 0.01	

	PackDistributions = {
		periodical = {
			max_low_density = mean,
			min_low_density = mean - range,
			min_hi_density = mean,
			max_hi_density = mean + range,
			random_distribution = false,
			zero_density_below = 0,
			max_hi_dist = 3,
			min_hi_dist = 2,
			max_low_dist = 10,
			min_low_dist = 7,
			zero_clamp_max_dist = 5
		},
		random = {}
	}

	PackSpawningDistribution = {
		standard = {
			goal_density = mean,
			clamp_main_path_zone_area = 100,
			length_density_coefficient = 0,
			spawn_cycle_length = 350,
			clamp_outer_zones_used = 1,
			distribution_method = "periodical",
			calculate_nearby_islands = false
		}
	}

	-- Dense's breedpacks 
	mod:dofile("scripts/mods/Daredevil/breed_pack")

local co = 0.135

	PackSpawningSettings.default.area_density_coefficient = co
	PackSpawningSettings.default_light.area_density_coefficient = co
	PackSpawningSettings.skaven.area_density_coefficient = co
	PackSpawningSettings.skaven_light.area_density_coefficient = co
	PackSpawningSettings.chaos.area_density_coefficient = co
	PackSpawningSettings.chaos_light.area_density_coefficient = co
	PackSpawningSettings.beastmen.area_density_coefficient = co
	PackSpawningSettings.beastmen_light.area_density_coefficient = co
	PackSpawningSettings.skaven_beastmen.area_density_coefficient = co
	PackSpawningSettings.chaos_beastmen.area_density_coefficient = co
	PackSpawningSettings.default.roaming_set = {
		breed_packs = "dense_standard",
		breed_packs_peeks_overide_chance = {
			0.2,
			0.3
		},
		breed_packs_override = {
			{
				"skaven",
				2,
				0.035
			},
			{
				"plague_monks",
				2,
				0.035
			},
			{
				"marauders",
				2,
				0.03
			},
			{
				"marauders_elites",
				2,
				0.03
			}
		}
	}

	PackSpawningSettings.skaven.roaming_set = {
		breed_packs = "dense_skaven",
		breed_packs_peeks_overide_chance = {
			0.2,
			0.3
		},
		breed_packs_override = {
			{
				"skaven",
				2,
				0.035
			},
			{
				"shield_rats",
				2,
				0.035
			},
			{
				"plague_monks",
				2,
				0.035
			}
		}
	}

	PackSpawningSettings.chaos.roaming_set = {
		breed_packs = "dense_chaos",
		breed_packs_peeks_overide_chance = {
			0.2,
			0.3
		},
		breed_packs_override = {
			{
				"marauders_and_warriors",
				2,
				0.03
			},
			{
				"marauders_shields",
				2,
				0.03
			},
			{
				"marauders_elites",
				2,
				0.03
			},
			{
				"marauders_berzerkers",
				2,
				0.03
			}
		}
	}

	-- Make light variations disappear
	PackSpawningSettings.default_light = PackSpawningSettings.default
	PackSpawningSettings.skaven_light = PackSpawningSettings.skaven
	PackSpawningSettings.chaos_light = PackSpawningSettings.chaos
	PackSpawningSettings.beastmen_light = PackSpawningSettings.beastmen

	PackSpawningSettings.default.difficulty_overrides = nil
	PackSpawningSettings.skaven.difficulty_overrides = nil
	PackSpawningSettings.skaven_light.difficulty_overrides = nil
	PackSpawningSettings.chaos.difficulty_overrides = nil
	PackSpawningSettings.beastmen.difficulty_overrides = nil
	PackSpawningSettings.skaven_beastmen.difficulty_overrides = nil
	PackSpawningSettings.chaos_beastmen.difficulty_overrides = nil

	-- PACING
	PacingSettings.default.peak_fade_threshold = 110                      
	PacingSettings.default.peak_intensity_threshold = 120				  
	PacingSettings.default.sustain_peak_duration = { 5, 10 }			  	
	PacingSettings.default.relax_duration = { 10, 13 }                    
	PacingSettings.default.horde_frequency = { 30, 45 }                   
	PacingSettings.default.multiple_horde_frequency = { 7, 9 }           
	PacingSettings.default.max_delay_until_next_horde = { 70, 75 }        
	PacingSettings.default.horde_startup_time = { 12, 20 }                
	PacingSettings.default.multiple_hordes = 3							  -- Came from Dense 

	PacingSettings.default.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.default.mini_patrol.only_spawn_below_intensity = 900   
	PacingSettings.default.mini_patrol.frequency = { 9, 10 }              

	PacingSettings.default.difficulty_overrides = nil
	PacingSettings.default.delay_specials_threat_value = nil

	PacingSettings.chaos.peak_fade_threshold = 110                        
	PacingSettings.chaos.peak_intensity_threshold = 120                   
	PacingSettings.chaos.sustain_peak_duration = { 5, 10 }                
	PacingSettings.chaos.relax_duration = { 13, 15 }					  
	PacingSettings.chaos.horde_frequency = { 30, 45 } 					  -- Base 30/45
	PacingSettings.chaos.multiple_horde_frequency = { 7, 10 } 			  -- Base 7/10
	PacingSettings.chaos.max_delay_until_next_horde = { 74, 78 }		  
	PacingSettings.chaos.horde_startup_time = { 15, 20 }				  
	PacingSettings.chaos.multiple_hordes = 3							  

	PacingSettings.chaos.mini_patrol.only_spawn_above_intensity = 0      
	PacingSettings.chaos.mini_patrol.only_spawn_below_intensity = 900    
	PacingSettings.chaos.mini_patrol.frequency = { 9, 10 }               

	PacingSettings.chaos.difficulty_overrides = nil
	PacingSettings.chaos.delay_specials_threat_value = nil

	PacingSettings.beastmen.peak_fade_threshold = 110					  -- I'm not touching beastmen they suck
	PacingSettings.beastmen.peak_intensity_threshold = 120				 
	PacingSettings.beastmen.sustain_peak_duration = { 5, 10 }			  
	PacingSettings.beastmen.relax_duration = { 10, 13 } 				  
	PacingSettings.beastmen.horde_frequency = { 35, 50 } 				  
	PacingSettings.beastmen.multiple_horde_frequency = { 6, 9 } 		  
	PacingSettings.beastmen.max_delay_until_next_horde = { 75, 95 }       
	PacingSettings.beastmen.horde_startup_time = { 10, 20 }               

	PacingSettings.beastmen.mini_patrol.only_spawn_above_intensity = 0
	PacingSettings.beastmen.mini_patrol.only_spawn_below_intensity = 900
	PacingSettings.beastmen.mini_patrol.frequency = { 8, 10 }

	PacingSettings.beastmen.difficulty_overrides = nil
	PacingSettings.beastmen.delay_specials_threat_value = nil
	PacingSettings.beastmen.delay_horde_threat_value.cataclysm_2 = tt 
	PacingSettings.beastmen.delay_horde_threat_value.cataclysm_3 = tt 
	
	-- INTENSITY
	IntensitySettings.default.intensity_added_per_percent_damage_taken = 0
	IntensitySettings.default.decay_delay = 1
	IntensitySettings.default.decay_per_second = 6
	IntensitySettings.default.intensity_added_knockdown = 50
	IntensitySettings.default.intensity_added_pounced_down = 25
	IntensitySettings.default.max_intensity = 100
	IntensitySettings.default.intensity_added_nearby_kill = 2

	IntensitySettings.default.difficulty_overrides = nil 
	
	-- HORDE SETTINGS
	HordeSettings.default.chance_of_vector = 0.7
	HordeSettings.default.chance_of_vector_blob = 0.65
--	HordeSettings.default.difficulty_overrides.cataclysm.ambush_composition = "medium"
--	HordeSettings.default.difficulty_overrides.cataclysm_2.ambush_composition = "medium"
--	HordeSettings.default.difficulty_overrides.cataclysm_3.ambush_composition = "medium"

	HordeSettings.chaos.chance_of_vector = 0.8
	HordeSettings.chaos.chance_of_vector_blob = 0.5
--	HordeSettings.chaos.difficulty_overrides.cataclysm.ambush_composition = "medium"
--	HordeSettings.chaos.difficulty_overrides.cataclysm_2.ambush_composition = "medium"
--	HordeSettings.chaos.difficulty_overrides.cataclysm_3.ambush_composition = "medium"

	-- Manual no beastmen
	DefaultConflictDirectorSet = {
	"skaven",
	"chaos",
	"default"
	}	

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
	
	Breeds.skaven_dummy_clan_rat = mod.deepcopy(Breeds.skaven_ratling_gunner)
	Breeds.skaven_dummy_clan_rat.size_variation_range = { 3, 3 }
	Breeds.skaven_dummy_clan_rat.walk_speed = 12
	Breeds.skaven_dummy_clan_rat.run_speed = 12
	
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
	HordeCompositionsPacing.beastmen_medium = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					12,
					14
				},
				"beastmen_ungor",
				{
					5,
					7
				}
			}
		},
		{
			name = "plain",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					7,
					9
				},
				"beastmen_ungor",
				{
					8,
					10
				}
			}
		},
		{
			name = "leader_gor",
			weight = 3,
			breeds = {
				"beastmen_gor",
				{
					12,
					14
				},
				"beastmen_ungor",
				{
					5,
					7
				},
				"beastmen_bestigor",
				{
					1,
					2
				}
			}
		},
		{
			name = "leader_ungor",
			weight = 3,
			breeds = {
				"beastmen_gor",
				{
					7,
					9
				},
				"beastmen_ungor",
				{
					8,
					10
				},
				"beastmen_bestigor",
				{
					1,
					2
				}
			}
		},
		sound_settings = HordeCompositionsSoundSettings.beastmen
	}
	HordeCompositionsPacing.beastmen_large = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					16,
					18
				},
				"beastmen_ungor",
				{
					5,
					7
				}
			}
		},
		{
			name = "plain",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					12,
					14
				},
				"beastmen_ungor",
				{
					8,
					10
				}
			}
		},
		{
			name = "leader_gor",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					16,
					18
				},
				"beastmen_ungor",
				{
					5,
					7
				},
				"beastmen_bestigor",
				{
					2,
					2
				}
			}
		},
		{
			name = "leader_ungor",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					12,
					14
				},
				"beastmen_ungor",
				{
					8,
					10
				},
				"beastmen_bestigor",
				{
					2,
					2
				}
			}
		},
		sound_settings = HordeCompositionsSoundSettings.beastmen
	}
	HordeCompositionsPacing.beastmen_huge = {
		{
			name = "plain",
			weight = 3,
			breeds = {
				"beastmen_gor",
				{
					35,
					38
				},
				"beastmen_ungor",
				{
					10,
					12
				},
				"beastmen_bestigor",
				{
					4,
					5
				},
				"chaos_warrior",
				1
			}
		},
		{
			name = "leader",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					30,
					32
				},
				"beastmen_ungor",
				{
					10,
					12
				},
				"beastmen_bestigor",
				{
					4,
					5
				},
				"skaven_storm_vermin_with_shield",
				{
					1,
					2
				},
				"skaven_storm_vermin_commander",
				{
					1,
					2
				},
			}
		},
		{
			name = "leader_gor",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					38,
					40
				},
				"beastmen_ungor",
				{
					10,
					12
				},
				"beastmen_bestigor",
				{
					3,
					4
				},
				"chaos_berzerker",
				{
					1,
					2
				},
				"skaven_plague_monk",
				{
					1,
					2
				},
			}
		},
		{
			name = "leader_ungor",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					38,
					40
				},
				"beastmen_ungor",
				{
					10,
					12
				},
				"beastmen_bestigor",
				{
					3,
					4
				},
				"chaos_raider",
				{
					1,
					2
				},
				"skaven_storm_vermin_commander",
				{
					1,
					2
				},

			}

		},
		sound_settings = HordeCompositionsSoundSettings.beastmen
	}
	HordeCompositionsPacing.beastmen_huge_armor = {
		{
			name = "plain",
			weight = 3,
			breeds = {
				"beastmen_gor",
				{
					30,
					32
				},
				"chaos_marauder_with_shield",
				{
					3,
					4
				},
				"beastmen_ungor",
				{
					10,
					12
				},
				"beastmen_bestigor",
				{
					3,
					4
				},
				"chaos_raider",
				{
					3,
					4
				},
			}
		},
		{
			name = "leader",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					38,
					40
				},
				"beastmen_ungor",
				{
					10,
					12
				},
				"beastmen_bestigor",
				{
					3,
					4
				},
				"chaos_berzerker",
				{
					3,
					4
				},
			}
		},
		{
			name = "leader_gor",
			weight = 7,
			breeds = {
				"beastmen_gor",
				{
					38,
					40
				},
				"beastmen_ungor",
				{
					10,
					12
				},
				"beastmen_bestigor",
				{
					7,
					8
				}
			}
		},
		{
			name = "leader",
			weight = 7,
			breeds = {
				"beastmen_ungor",
				{
					35,
					37
				},
				"beastmen_ungor",
				{
					10,
					12
				},
				"beastmen_bestigor",
				{
					3,
					4
				},
				"skaven_plague_monk",
				{
					3,
					4
				},
			},
		},
		sound_settings = HordeCompositionsSoundSettings.beastmen
	}

	mod:hook(Pacing, "disable", function (func, self)
		self._threat_population = 1
		self._specials_population = 1
		self._horde_population = 0
		self.pacing_state = "pacing_frozen"
	end)
	
	mod:hook(TerrorEventMixer.init_functions, "control_specials", function (func, event, element, t)
		local conflict_director = Managers.state.conflict
		local specials_pacing = conflict_director.specials_pacing
		local not_already_enabled = specials_pacing:is_disabled()
	
		if specials_pacing then
			specials_pacing:enable(element.enable)
	
			if element.enable and not_already_enabled then
				local delay = math.random(5, 12)
				local per_unit_delay = math.random(8, 16)
				local t = Managers.time:time("game")
	
				specials_pacing:delay_spawning(t, delay, per_unit_delay, true)
			end
		end		
	end)

	local ssms = 7 
	SpecialsSettings.default.max_specials = ssms
	SpecialsSettings.default_light.max_specials = ssms
	SpecialsSettings.skaven.max_specials = ssms
	SpecialsSettings.skaven_light.max_specials = ssms
	SpecialsSettings.chaos.max_specials = ssms
	SpecialsSettings.chaos_light.max_specials = ssms
	SpecialsSettings.beastmen.max_specials = ssms
	SpecialsSettings.skaven_beastmen.max_specials = ssms
	SpecialsSettings.chaos_beastmen.max_specials = ssms
	
	PacingSettings.default.delay_specials_threat_value = nil
	PacingSettings.chaos.delay_specials_threat_value = nil
	PacingSettings.beastmen.delay_specials_threat_value = nil
	

	Breeds.skaven_warpfire_thrower.threat_value = 2
	Breeds.skaven_gutter_runner.threat_value = 4
--	Breeds.skaven_pack_master.threat_value = 2
--	Breeds.skaven_poison_wind_globadier.threat_value = 4
	Breeds.skaven_ratling_gunner.threat_value = 2
	Breeds.chaos_corruptor_sorcerer.threat_value = 2
	Breeds.chaos_vortex_sorcerer.threat_value = 4
	
	Managers.state.conflict:set_threat_value("skaven_warpfire_thrower", 2)
	Managers.state.conflict:set_threat_value("skaven_gutter_runner", 4)
--	Managers.state.conflict:set_threat_value("skaven_pack_master", 2)
--	Managers.state.conflict:set_threat_value("skaven_poison_wind_globadier", 4)
	Managers.state.conflict:set_threat_value("skaven_ratling_gunner", 2)
	Managers.state.conflict:set_threat_value("chaos_corruptor_sorcerer", 2)
	Managers.state.conflict:set_threat_value("chaos_vortex_sorcerer", 4)

	SpecialsSettings.default.methods.specials_by_slots = {
		max_of_same = 3,                                        
		coordinated_attack_cooldown_multiplier = 0.4,
		chance_of_coordinated_attack = 0.3,
		select_next_breed = "get_random_breed",
		after_safe_zone_delay = {
			5,
			20
		},
		spawn_cooldown = {
			25,
			30
		}
	}

	SpecialsSettings.default_light = SpecialsSettings.default
	SpecialsSettings.skaven = SpecialsSettings.default
	SpecialsSettings.skaven_light = SpecialsSettings.default
	SpecialsSettings.chaos = SpecialsSettings.default
	SpecialsSettings.chaos_light = SpecialsSettings.default
	SpecialsSettings.beastmen = SpecialsSettings.default

	SpecialsSettings.default.breeds = {
		"skaven_gutter_runner",
		"skaven_gutter_runner",
		"skaven_pack_master",
		"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_ratling_gunner",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"chaos_vortex_sorcerer",
		"chaos_corruptor_sorcerer",
		"chaos_corruptor_sorcerer",
		"skaven_warpfire_thrower",
		"skaven_warpfire_thrower",
		"skaven_warpfire_thrower",
	}

--	SpecialsSettings.chaos.breeds = SpecialsSettings.default.breeds
--[[
	SpecialsSettings.chaos.breeds = {
		"skaven_gutter_runner",
		"skaven_gutter_runner",
		"skaven_gutter_runner",
		"skaven_pack_master",
		"skaven_pack_master",
		"skaven_pack_master",
		"skaven_ratling_gunner",
		"skaven_ratling_gunner",
		"skaven_poison_wind_globadier",
		"skaven_poison_wind_globadier",
		"chaos_vortex_sorcerer",
		"chaos_vortex_sorcerer",
		"chaos_corruptor_sorcerer",
		"chaos_corruptor_sorcerer",
		"skaven_warpfire_thrower",
	}
]]

	SpecialsSettings.default.difficulty_overrides.hard = nil
	SpecialsSettings.default.difficulty_overrides.harder = nil
	SpecialsSettings.default.difficulty_overrides.hardest = nil
	SpecialsSettings.default.difficulty_overrides.cataclysm = nil
	SpecialsSettings.default.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.default.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.default_light.difficulty_overrides.hard = nil
	SpecialsSettings.default_light.difficulty_overrides.harder = nil
	SpecialsSettings.default_light.difficulty_overrides.hardest = nil
	SpecialsSettings.default_light.difficulty_overrides.cataclysm = nil
	SpecialsSettings.default_light.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.default_light.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.skaven.difficulty_overrides.hard = nil
	SpecialsSettings.skaven.difficulty_overrides.harder = nil
	SpecialsSettings.skaven.difficulty_overrides.hardest = nil
	SpecialsSettings.skaven.difficulty_overrides.cataclysm = nil
	SpecialsSettings.skaven.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.skaven.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.skaven_light.difficulty_overrides.hard = nil
	SpecialsSettings.skaven_light.difficulty_overrides.harder = nil
	SpecialsSettings.skaven_light.difficulty_overrides.hardest = nil
	SpecialsSettings.skaven_light.difficulty_overrides.cataclysm = nil
	SpecialsSettings.skaven_light.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.skaven_light.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.chaos.difficulty_overrides.hard = nil
	SpecialsSettings.chaos.difficulty_overrides.harder = nil
	SpecialsSettings.chaos.difficulty_overrides.hardest = nil
	SpecialsSettings.chaos.difficulty_overrides.cataclysm = nil
	SpecialsSettings.chaos.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.chaos.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.chaos_light.difficulty_overrides.hard = nil
	SpecialsSettings.chaos_light.difficulty_overrides.harder = nil
	SpecialsSettings.chaos_light.difficulty_overrides.hardest = nil
	SpecialsSettings.chaos_light.difficulty_overrides.cataclysm = nil
	SpecialsSettings.chaos_light.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.chaos_light.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.beastmen.difficulty_overrides.hard = nil
	SpecialsSettings.beastmen.difficulty_overrides.harder = nil
	SpecialsSettings.beastmen.difficulty_overrides.hardest = nil
	SpecialsSettings.beastmen.difficulty_overrides.cataclysm = nil
	SpecialsSettings.beastmen.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.beastmen.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.hard = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.harder = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.hardest = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.cataclysm = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.skaven_beastmen.difficulty_overrides.cataclysm_3 = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.hard = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.harder = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.hardest = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.cataclysm = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.cataclysm_2 = nil
	SpecialsSettings.chaos_beastmen.difficulty_overrides.cataclysm_3 = nil
	
	Breeds.skaven_rat_ogre.threat_value = 25
	Breeds.skaven_stormfiend.threat_value = 25
	Breeds.chaos_spawn.threat_value = 25
	Breeds.chaos_troll.threat_value = 25
	Breeds.beastmen_minotaur.threat_value = 25

	Managers.state.conflict:set_threat_value("skaven_rat_ogre", 25)
	Managers.state.conflict:set_threat_value("skaven_stormfiend", 25)
	Managers.state.conflict:set_threat_value("chaos_spawn", 25)
	Managers.state.conflict:set_threat_value("chaos_troll", 25)
	Managers.state.conflict:set_threat_value("beastmen_minotaur", 25)

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
			}
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
				"beastmen_standard_bearer"
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
				"beastmen_standard_bearer"
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
				"beastmen_standard_bearer"
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
				"beastmen_standard_bearer"
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
				"beastmen_standard_bearer",
				"beastmen_standard_bearer"
			},
			{
				"beastmen_bestigor",
				"beastmen_bestigor"
			}
		}
	}

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
				"skaven_storm_vermin_with_shield",
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
					10,
					14
				},
				"skaven_storm_vermin",
				{
					1,
					1
				},
				"skaven_storm_vermin_with_shield",
				{
					2,
					2
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
	---------------------
	--Righteous Stand

	TerrorEventBlueprints.military.military_courtyard_event_01 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 200
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "courtyard_hidden",
			composition_type = "mass_trash_skaven"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_courtyard_roof_middle",
			breed_name = "chaos_warrior_exalted_norsca",
			optional_data = {
				max_health_modifier = 1.16
			}
		},
		{
			"event_horde",
			spawner_id = "courtyard_hidden",
			composition_type = "mass_trash_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "onslaught_courtyard_roof_middle",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"event_horde",
			spawner_id = "onslaught_courtyard_roof_middle",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"event_horde",
			spawner_id = "onslaught_courtyard_roof_middle",
			composition_type = "onslaught_custom_specials_disabler"
		},	
		{
			"continue_when",
			duration = 75,
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") < 1
			end
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard_hidden",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard_hidden",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "onslaught_courtyard_roof_middle",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 90,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 4
			end
		},
		{
			"event_horde",
			spawner_id = "courtyard_hidden",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_storm_vermin_commander") < 7 and count_event_breed("skaven_slave") < 14 and count_event_breed("skaven_plague_monk") < 7
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "courtyard",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 30 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 20 and count_event_breed("skaven_plague_monk") < 10
			end
		},
				{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "onslaught_event_military_courtyard_plague_monks"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 10 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "onslaught_mixed_double_wave"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 10,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 10 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_02 = TerrorEventBlueprints.military.military_courtyard_event_01

	TerrorEventBlueprints.military.military_courtyard_event_specials_01 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "courtyard",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_specials_02 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_specials",
			enable = false 
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_specials_03 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_specials_04 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_left",
			composition_type = "onslaught_custom_specials_heavy_disabler"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_courtyard_event_specials_05 = {
		{
			"set_master_event_running",
			name = "military_courtyard"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_courtyard_roof_right",
			composition_type = "onslaught_custom_specials_heavy_disabler"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "military_courtyard_event_specials_done"
		}
	}

	--01	Warriors & Plague Monks
	--02	Berzerkers & Stormvermins
	--03	Mixed Shielders
	--04	Extra Denial
	--05	Extra Disablers

	HordeCompositions.onslaught_military_mauler_assault = {
		{
			name = "plain",
			weight = 1,
			breeds = {
				"chaos_raider",
				{
				10,
				10
				},
				"chaos_warrior",
				{
				3,
				4
				},
			}
		}
	}

	HordeCompositions.military_end_event_chaos_01 = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_raider",
				{
					10,
					13,
				},
				"chaos_marauder",
				{
					20,
					22
				},
				"chaos_fanatic",
				{
					20,
					22
				}
			}
		},
		{
			name = "mixed",
			weight = 3,
			breeds = {
				"chaos_raider",
				{
					10,
					13,
				},
				"chaos_marauder_with_shield",
				{
					10,
					12
				},
				"chaos_marauder",
				{
					8,
					9
				},
				"chaos_fanatic",
				{
					18,
					19
				}
			}
		}
	}

	HordeCompositions.military_end_event_berzerkers = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_berzerker",
				15,
				"chaos_marauder_with_shield",
				20
			}
		}
	}

	TerrorEventBlueprints.military.military_temple_guards = {
		{
			"disable_kick"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards02",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards05",
			breed_name = "chaos_marauder_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards06",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards07",
			breed_name = "chaos_marauder_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_guards09",
			breed_name = "chaos_warrior"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_temple_guard_assault",
			composition_type = "onslaught_military_mauler_assault"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_start = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"disable_kick"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "end_event_start",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_boss_ogre"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 25 and count_event_breed("skaven_clan_rat_with_shield") < 24 and count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_start_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_01_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_01_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_01_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_01_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_02_left = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_02_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_02_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_02_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_02_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_02_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_02_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_chaos_01"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_02_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_03_left = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 25 and count_event_breed("skaven_slave") < 28 and count_event_breed("skaven_storm_vermin_commander") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_03_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_03_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 25 and count_event_breed("skaven_slave") < 28 and count_event_breed("skaven_storm_vermin_commander") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_03_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_03_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_middle",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 25 and count_event_breed("skaven_slave") < 28 and count_event_breed("skaven_storm_vermin_commander") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_03_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_03_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 15 and count_event_breed("skaven_slave") < 18 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_storm_vermin_with_shield") < 5 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_03_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_04_left = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_04_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_04_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_04_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_04_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_middle",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_04_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_04_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 9 and count_event_breed("skaven_clan_rat_with_shield") < 9 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 6 and count_event_breed("chaos_fanatic") < 12 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_plague_monk") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_04_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_05_left = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "end_event_left",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_clan_rat_with_shield") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_05_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_05_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "end_event_right",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_clan_rat_with_shield") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_05_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_05_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "end_event_middle",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_clan_rat_with_shield") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_05_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_05_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "end_event_back",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_military_end_event_plague_monks"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_clan_rat_with_shield") < 5 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 2 and count_event_breed("skaven_plague_monk") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_05_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_06_right = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_right_hidden",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_right_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 1 and count_event_breed("chaos_marauder") < 2 and count_event_breed("chaos_marauder_with_shield") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_06_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_06_middle = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_middle",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_left_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 1 and count_event_breed("chaos_marauder") < 2 and count_event_breed("chaos_marauder_with_shield") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_06_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_survival_06_back = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_back_hidden",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "military_end_event_berzerkers"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 1 and count_event_breed("chaos_marauder") < 2 and count_event_breed("chaos_marauder_with_shield") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_06_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_01 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_02 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_03 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_04 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_05 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.military.military_end_event_specials_06 = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"event_horde",
			spawner_id = "end_event_left_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "end_event_right_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "end_event_back_hidden",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_gutter_runner") < 2 and count_event_breed("skaven_pack_master") < 2 and count_event_breed("skaven_ratling_gunner") < 2 and count_event_breed("skaven_warpfire_thrower") and count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("chaos_vortex_sorcerer") < 3 and count_event_breed("chaos_corruptor_sorcerer") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_specials_done"
		}
	}

	--01 2x denial 1x skaven
	--02 2x denial 1x disabler
	--03 2x disabler 1x denial
	--04 2x disabler 1x skaven
	--05 Mass denial
	--06 3x skaven

	TerrorEventBlueprints.military.military_end_event_survival_escape = {
		{
			"set_master_event_running",
			name = "military_end_event_survival"
		},
		{
			"control_specials",
			enable = true
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_start",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "military_end_event_survival_escape_done"
		}
	}

	---------------------
	--Convocation of Decay

	TerrorEventBlueprints.catacombs.catacombs_puzzle_event_loop = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_puzzle_event_loop"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 30 and count_event_breed("skaven_slave") < 36 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 12
			end
		},
		{
			"delay",
			duration = 7
		},
		{
			"flow_event",
			flow_event_name = "catacombs_puzzle_event_loop_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_puzzle_event_a = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_puzzle_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"flow_event",
			flow_event_name = "catacombs_puzzle_event_a_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_puzzle_event_b = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_puzzle_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"flow_event",
			flow_event_name = "catacombs_puzzle_event_b_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_puzzle_event_c = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_puzzle_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "enemy_door",
			composition_type = "event_maulers_medium"
		},
		{
			"flow_event",
			flow_event_name = "catacombs_puzzle_event_c_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_special_event_a = {
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_storm_vermin_shields_small"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_special_event_b = {
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_02",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_02",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_02",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_special_event_c = {
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_01",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_02",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "puzzle_special_03",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "puzzle_event_loop",
			composition_type = "onslaught_plague_monks_medium"
		},
	}

	--a shields & warriors
	--b maulers
	--c berzerkers

	--a special shielded storm
	--b special monk
	--c special mass warpfire

	--Because otherwise triple boss event is triggered early by respawning player..
	local function living_player_has_dropped()
		for i, player in pairs(Managers.player:players()) do
			if player.player_unit then
				local status_extension = ScriptUnit.has_extension(player.player_unit, "status_system")
				if status_extension and not status_extension.is_ready_for_assisted_respawn(status_extension) then
					if POSITION_LOOKUP[player.player_unit].z < -15 then
						return true
					end
				end
			end
		end
		return false
	end


	TerrorEventBlueprints.catacombs.catacombs_load_sorcerers = {
		{
			"force_load_breed_package",
			breed_name = "chaos_dummy_sorcerer"
		},
		{
			"continue_when",
			condition = function (t)
				return living_player_has_dropped()
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_pool_boss_1",
			breed_name = "chaos_exalted_champion_norsca"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_pool_boss_2",
			breed_name = "skaven_storm_vermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_pool_boss_3",
			breed_name = "skaven_rat_ogre"
		}
	}


	TerrorEventBlueprints.catacombs.catacombs_end_event_01 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 6,
			spawner_id = "end_event",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_storm_vermin_commander") < 10 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 16 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_01_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_02 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 30 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 6,
			spawner_id = "end_event",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 16 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 6,
			spawner_id = "end_event",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},

		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 16 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 8 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 16 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_02_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_specials_01 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event_specials"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_specials_02 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event_specials"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.catacombs.catacombs_end_event_specials_03 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "catacombs_end_event_specials"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "catacombs_end_event_specials_done"
		}
	}

	---------------------
	--Hunger in the Dark

	TerrorEventBlueprints.mines.mines_end_event_start = {
		{
			"disable_kick"
		},
		{
			"enable_bots_in_carry_event"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_first_wave = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_3",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_1",
			breed_name = "chaos_troll"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 30 and count_event_breed("skaven_slave") < 30 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_first_wave_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_loop = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_mines_extra_troll_3",
			breed_name = "chaos_troll"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 25 and count_event_breed("chaos_berzerker") < 12
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 25 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 10 and count_event_breed("chaos_raider") < 12
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 20 and count_event_breed("chaos_fanatic") < 25 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 12
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"delay",
			duration = 2
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"delay",
			duration = 2
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_loop_02 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 20 and count_event_breed("chaos_fanatic") < 25 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 10
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "event_maulers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 20 and count_event_breed("chaos_fanatic") < 25 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 12 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event",
			composition_type = "event_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_chaos",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_plague_monks_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 10 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 9
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_loop_02_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_specials_01 = {
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") + count_event_breed("chaos_vortex_sorcerer")) < 8 and (count_event_breed("skaven_gutter_runner") + count_event_breed("skaven_pack_master") + count_event_breed("chaos_corruptor_sorcerer")) < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_specials_02 = {
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") + count_event_breed("chaos_vortex_sorcerer")) < 8 and (count_event_breed("skaven_gutter_runner") + count_event_breed("skaven_pack_master") + count_event_breed("chaos_corruptor_sorcerer")) < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_specials_03 = {
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer",
				"chaos_vortex_sorcerer"
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") + count_event_breed("chaos_vortex_sorcerer")) < 8 and (count_event_breed("skaven_gutter_runner") + count_event_breed("skaven_pack_master") + count_event_breed("chaos_corruptor_sorcerer")) < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_stop = {
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_trolls = {
		{
			"force_load_breed_package",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_01",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_02",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_03",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_04",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_05",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_06",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_07",
			breed_name = "chaos_dummy_troll"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_08",
			breed_name = "chaos_dummy_troll"
		},
		{
			"stop_event",
			stop_event_name = "mines_end_event_loop"
		},
		{
			"stop_event",
			stop_event_name = "mines_end_event_loop_02"
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_trolls_done"
		}
	}

	TerrorEventBlueprints.mines.mines_troll_boss = {
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_bell_boss",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "onslaught_mines_horde_front",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "troll_boss",
			breed_name = "chaos_troll"
		},
		{
			"set_time_challenge",
			time_challenge_name = "mines_speed_event"
		},
		{
			"set_time_challenge",
			time_challenge_name = "mines_speed_event_cata"
		},
		{
			"continue_when",
			duration = 90,
			condition = function (t)
				return count_event_breed("chaos_troll") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_troll_boss_done"
		},
		{
			"has_completed_time_challenge",
			time_challenge_name = "mines_speed_event"
		},
		{
			"has_completed_time_challenge",
			time_challenge_name = "mines_speed_event_cata"
		}
	}

	TerrorEventBlueprints.mines.mines_end_event_escape = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "end_event"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "escape",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 15 and count_event_breed("chaos_berzerker") < 10
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "escape",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 12 and count_event_breed("skaven_slave") < 15 and (count_event_breed("skaven_storm_vermin") + count_event_breed("skaven_storm_vermin_with_shield")) < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "mines_end_event_escape_done"
		}
	}

	---------------------
	--Halescourge

	TerrorEventBlueprints.ground_zero.gz_elevator_guards_a = {
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_1",
			breed_name = "skaven_storm_vermin_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_2",
			breed_name = "skaven_storm_vermin_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_3",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_4",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_5",
			breed_name = "skaven_storm_vermin_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_a_6",
			breed_name = "skaven_storm_vermin_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_1",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_2",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_3",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_4",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_5",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_6",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_7",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "ele_guard_b_8",
			breed_name = "skaven_clan_rat_with_shield"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_1",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_2",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_3",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_4",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_5",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_ele_guard_c_6",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"delay",
			duration = 5
		}
	}

	local ACTIONS = BreedActions.chaos_exalted_sorcerer
	local restore_bubbledude = {
		"BTSpawnAllies",
		enter_hook = "sorcerer_spawn_horde",
		name = "sorcerer_spawn_horde",
		action_data = ACTIONS.spawn_allies_horde
	}

	table.insert(BreedBehaviors.chaos_exalted_sorcerer[7], 2, restore_bubbledude)

	TerrorEventBlueprints.ground_zero.gz_chaos_boss = {
		{
			"set_master_event_running",
			name = "gz_chaos_boss"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"spawn_at_raw",
			spawner_id = "warcamp_chaos_boss",
			breed_name = "chaos_exalted_sorcerer"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_sorcerer") == 1
			end
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_sorcerer") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "gz_chaos_boss_dead"
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	HordeCompositions.sorcerer_boss_event_defensive = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					10,
					14
				},
				"chaos_marauder",
				{
					16,
					18
				},
				"chaos_marauder_with_shield",
				{
					12,
					15
				},
				"chaos_raider",
				{
					5,
					6
				},
				"chaos_warrior",
				1,
				"chaos_plague_sorcerer",
				2
			}
		},
		{
			name = "wave_b",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					9,
					11
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_marauder_with_shield",
				{
					10,
					12
				},
				"chaos_berzerker",
				{
					5,
					6
				},
				"chaos_warrior",
				1,
				"chaos_plague_sorcerer",
				2
			}
		},
		{
			name = "wave_c",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					9,
					11
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_warrior",
				{
					2,
					3
				},
				"chaos_plague_sorcerer",
				2
			}
		},
		{
			name = "wave_d",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					12,
					15
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_raider",
				{
					6,
					7
				},
				"chaos_warrior",
				1,
				"chaos_plague_sorcerer",
				2
			}
		},
		{
			name = "wave_e",
			weight = 4,
			breeds = {
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
				"chaos_warrior",
				1,
				"chaos_plague_sorcerer",
				2
			}
		},
		start_time = 0
	}

	HordeCompositions.sorcerer_extra_spawn = HordeCompositions.sorcerer_boss_event_defensive

	---------------------
	--Athel Yenlui

	
TerrorEventBlueprints.elven_ruins.elven_ruins_end_event = {
	{
		"set_freeze_condition",
		max_active_enemies = 100
	},
	{
		"set_time_challenge",
		time_challenge_name = "elven_ruins_speed_event"
	},
	{
		"set_time_challenge",
		time_challenge_name = "elven_ruins_speed_event_cata"
	},
	{
		"set_master_event_running",
		name = "ruins_end_event"
	},
	{
		"control_pacing",
		enable = false
	},
	{
		"control_specials",
		enable = false
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"disable_kick"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"delay",
		duration = {
			4,
			5
		}
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_disabler"
	},
	{
		"delay",
		duration = 5
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "end_event_chaos",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "chaos_vortex_sorcerer"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"continue_when",
		duration = 20, -- 10
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_small" 
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_disabler"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "athel_assassin_fire_combo"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"delay",
		duration = {
			18,
			20
		}
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_storm_vermin_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "dn_skaven_pursuit"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 10,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "dn_skaven_pursuit"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_storm_vermin_small"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "athel_wdnmd"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = {
			2,
			3
		}
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_large"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_skaven_pursuit"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_storm_vermin_small"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = {
			2,
			3
		}
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_ratling_spam"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_skaven_pursuit"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_storm_vermin_small"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = {
			2,
			3
		}
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_ratling_spam"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_skaven_pursuit"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_storm_vermin_small"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = {
			2,
			3
		}
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_ratling_spam"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_skaven_pursuit"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_storm_vermin_small"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = {
			2,
			3
		}
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_ratling_spam"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_skaven_pursuit"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_storm_vermin_small"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = {
			2,
			3
		}
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_large"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_storm_vermin_with_shield") < 2
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_warpfire_thrower"
	},
	{
		"delay",
		duration = 4
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "event_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "dn_ratling_spam"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_plague_monks_small"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 25,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_bottomtier",
		composition_type = "onslaught_custom_special_denial"
	},
	{
		"delay",
		duration = {
			5,
			7
		}
	},
	{
		"continue_when",
		duration = 30,
		condition = function (t)
			return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_commander") < 9 and count_event_breed("skaven_storm_vermin_with_shield") < 9
		end
	},
}

TerrorEventBlueprints.elven_ruins.elven_ruins_end_event_flush = {
	{
		"set_freeze_condition",
		max_active_enemies = 100
	},
	{
		"has_completed_time_challenge",
		time_challenge_name = "elven_ruins_speed_event"
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 8,
		spawner_id = "elven_ruins_toptier",
		composition_type = "event_extra_spice_medium"
	},
	{
		"delay",
		duration = {
			1,
			2
		}
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_boss_ogre"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_boss_spawn"
	},
	{
		"event_horde",
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_custom_boss_stormfiend"
	},
	{
		"delay",
		duration = {
			3,
			4
		}
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_stinger"
	},
	{
		"event_horde",
		limit_spawners = 4,
		spawner_id = "elven_ruins_toptier",
		composition_type = "athel_wdnmd"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"event_horde",
		limit_spawners = 3,
		spawner_id = "elven_ruins_toptier",
		composition_type = "onslaught_plague_monks_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "onslaught_mines_horde_front",
		composition_type = "onslaught_custom_special_denial"
	},
}

TerrorEventBlueprints.elven_ruins.elven_ruins_end_event_device_fiddlers = {
	{
		"control_specials",
		enable = false
	},
	{
		"spawn_at_raw",
		spawner_id = "device_skaven_1",
		breed_name = "skaven_clan_rat"
	},
	{
		"spawn_at_raw",
		spawner_id = "device_skaven_2",
		breed_name = "skaven_clan_rat"
	},
	{
		"spawn_at_raw",
		spawner_id = "device_skaven_3",
		breed_name = "skaven_clan_rat"
	}
}

	---------------------
	--Screaming Bell

	HordeCompositions.event_bell_monks = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"skaven_plague_monk",
				{
					7,
					7
				}
			}
		}
	}
	
	HordeCompositions.event_bell_monks_muertos = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"skaven_plague_monk",
				{
					33,
					33
				}
			}
		}
	}

	HordeCompositions.event_bell_warriors = {
		{
			name = "plain",
			weight = 7,
			breeds = {
				"chaos_warrior",
				10
			}
		}
	}

	TerrorEventBlueprints.bell.canyon_bell_event = {
		{
			"set_master_event_running",
			name = "canyon_bell_event"
		},
		{
			"set_time_challenge",
			time_challenge_name = "bell_speed_event"
		},
		{
			"set_time_challenge",
			time_challenge_name = "bell_speed_event_cata"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enabled = false
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
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			condition = function (t)
				return spawned_during_event() < 15
			end
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "event_bell_monks_muertos"
		},
		{
			"event_horde",
			spawner_id = "canyon_bell_event",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"delay",
			duration = 7
		},
		{
			"flow_event",
			flow_event_name = "canyon_bell_event_done"
		}
	}

	-- GrudgeMarkedNames.skaven = "Bob the Builder"
	local enhancement_list = {
		["warping"] = true,
		["unstaggerable"] = true
	}
	local enhancement_7 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

	TerrorEventBlueprints.bell.canyon_ogre_boss = {
		{
			"spawn_at_raw",
			spawner_id = "canyon_ogre_boss",
			breed_name = "skaven_dummy_clan_rat",
			optional_data = {
				enhancements = enhancement_7,
				max_health_modifier = 20,
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_second_ogre",
			breed_name = "skaven_dummy_clan_rat",
			optional_data = {
				enhancements = enhancement_7,
				max_health_modifier = 20,
			}
		},
	}

	TerrorEventBlueprints.bell.canyon_escape_event = {
		{
			"set_master_event_running",
			name = "canyon_escape_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "canyon_escape_event",
			composition_type = "dn_skaven_pursuit"
		},
		{
			"delay",
			duration = 5
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_clan_rat_with_shield") < 8 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 3
			end
		}
	}

	---------------------
	--Fort Brachsenbr𣫥

	HordeCompositions.event_fort_pestilen = {
		{
			name = "mixed",
			weight = 5,
			breeds = {
				"skaven_slave",
				{
					17,
					19
				},
				"skaven_clan_rat",
				{
					23,
					25
				},
				"skaven_plague_monk",
				{
					4,
					5
				}
			}
		}
	}

	HordeCompositions.event_fort_savagery = {
		{
			name = "mixed",
			weight = 5,
			breeds = {
				"chaos_fanatic",
				{
					19,
					23
				},
				"chaos_marauder",
				{
					10,
					11
				},
				"chaos_berzerker",
				{
					4,
					5
				}
			}
		}
	}

	TerrorEventBlueprints.fort.fort_pacing_off = {
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.fort.fort_terror_event_climb = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "fort_terror_event_climb"
		},
		{
			"event_horde",
			spawner_id = "terror_event_climb",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 18 and count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_clan_rat_with_shield") < 10 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_terror_event_climb_done"
		}
	}

	TerrorEventBlueprints.fort.fort_terror_event_inner_yard_skaven = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "fort_terror_event_inner_yard"
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_slave") < 24 and count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_clan_rat_with_shield") < 6 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_terror_event_inner_yard_done"
		}
	}

	TerrorEventBlueprints.fort.fort_terror_event_inner_yard_chaos = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "fort_terror_event_inner_yard"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "terror_event_inner_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_marauder") < 10 and count_event_breed("chaos_marauder_with_shield") < 7
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_terror_event_inner_yard_done"
		}
	}

	TerrorEventBlueprints.fort.fort_horde_gate = {
		{
			"set_master_event_running",
			name = "fort_horde_gate"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "fort_horde_gate",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "fort_horde_gate",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_gate",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("skaven_storm_vermin") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_horde_gate_done"
		}
	}

	-- TerrorEventBlueprints.fort.fort_horde_cannon = {
		-- {
			-- "set_master_event_running",
			-- name = "fort_horde_cannon"
		-- },
		-- {
			-- "set_freeze_condition",
			-- max_active_enemies = 100
		-- },
		-- {
			-- "control_pacing",
			-- enable = false
		-- },
		-- {
			-- "control_specials",
			-- enable = false
		-- },
		-- {
			-- "event_horde",
			-- spawner_id = "fort_horde_cannon",
			-- composition_type = "event_fort_pestilen"
		-- },
		-- {
			-- "delay",
			-- duration = 5
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "siege_1",
			-- breed_name = "skaven_warpfire_thrower"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "siege_2",
			-- breed_name = "skaven_poison_wind_globadier"
		-- },
		-- {
			-- "delay",
			-- duration = {
				-- 5,
				-- 9
			-- }
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "siege_4",
			-- breed_name = "skaven_poison_wind_globadier"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "siege_6",
			-- breed_name = "skaven_ratling_gunner"
		-- },
		-- {
			-- "continue_when",
			-- condition = function (t)
				-- return count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_plague_monk") < 6 and count_event_breed("skaven_poison_wind_globadier") < 4 and count_event_breed("skaven_warpfire_thrower") < 4 and count_event_breed("skaven_ratling_gunner") < 4
			-- end
		-- },
		-- {
			-- "delay",
			-- duration = 7
		-- },
		-- {
			-- "flow_event",
			-- flow_event_name = "fort_horde_cannon_done"
		-- }
	-- }

	TerrorEventBlueprints.fort.fort_horde_cannon_skaven = {
		{
			"set_master_event_running",
			name = "fort_horde_cannon"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_pestilen"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			},
		},
		{
			"delay",
			duration = 60
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 30
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "event_extra_spice_large"
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("skaven_slave") < 25 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 15 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 6 and count_event_breed("skaven_poison_wind_globadier") < 10 and count_event_breed("skaven_warpfire_thrower") < 6 and count_event_breed("skaven_ratling_gunner") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_horde_cannon_done"
		}
	}

	TerrorEventBlueprints.fort.fort_horde_cannon_chaos = {
		{
			"set_master_event_running",
			name = "fort_horde_cannon"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "event_fort_savagery"
		},
		{
			"event_horde",
			spawner_id = "fort_horde_cannon",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 8
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "fort_horde_cannon",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 20
		},
		{
			"spawn_at_raw",
			spawner_id = "manual_special_spawners",
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_gutter_runner",
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("chaos_fanatic") < 15 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 10 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_warrior") < 4 and count_event_breed("skaven_poison_wind_globadier") < 10 and count_event_breed("skaven_warpfire_thrower") < 6 and count_event_breed("chaos_vortex_sorcerer") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "fort_horde_cannon_done"
		}
	}

	TerrorEventBlueprints.fort.fort_siegers = {
		{
			"set_master_event_running",
			name = "fort_siegers"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_1",
			breed_name = "skaven_stormfiend"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_2",
			breed_name = "chaos_berzerker"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_3",
			breed_name = "chaos_marauder"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_4",
			breed_name = "chaos_marauder"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_5",
			breed_name = "chaos_berzerker"
		},
		{
			"spawn_at_raw",
			spawner_id = "siege_6",
			breed_name = "chaos_marauder"
		},
		{
			"continue_when",
			duration = 180,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 2 and count_event_breed("chaos_raider") < 2 and count_event_breed("chaos_marauder") < 2 and count_event_breed("chaos_marauder_with_shield") < 2 and count_event_breed("skaven_stormfiend") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "siege_broken"
		}
	}

	---------------------
	--Into the Nest

	TerrorEventBlueprints.skaven_stronghold.stronghold_pacing_off = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.skaven_stronghold.stronghold_pacing_on = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.skaven_stronghold.stronghold_horde_water_wheels = {
		{
			"set_master_event_running",
			name = "stronghold_horde_water_wheels"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "stronghold_horde_water_wheels",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "stronghold_horde_water_wheels",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"control_specials",
			enable = true
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_clan_rat_with_shield") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 4 and count_event_breed("skaven_storm_vermin") < 8 and count_breed("skaven_storm_vermin_commander") < 6 and count_breed("skaven_plague_monk") < 4
			end
		},
		{	
			"flow_event",
			flow_event_name = "stronghold_horde_water_wheels_done"
		}
	}

	TerrorEventBlueprints.skaven_stronghold.stronghold_boss = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "stronghold_boss"
		},
		{
			"spawn_at_raw",
			spawner_id = "stronghold_boss",
			breed_name = "skaven_storm_vermin_warlord",
			optional_data = {
				max_health_modifier = 1.5,
				enhancements = enhancement_4
			}
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_warlord") == 1
			end
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_warlord") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "stronghold_boss_killed"
		},
		{
			"delay",
			duration = 8
		},

		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	HordeCompositions.stronghold_boss_event_defensive = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"skaven_slave",
				{
					5,
					7
				},
				"skaven_clan_rat",
				{
					20,
					22
				},
				"skaven_clan_rat_with_shield",
				{
					15,
					20
				},
				"skaven_plague_monk",
				{
					6,
					8
				},
				"skaven_storm_vermin_with_shield",
				4,
			}
		},
		{
			name = "somevermin",
			weight = 4,
			breeds = {
				"skaven_clan_rat",
				{
					10,
					12
				},
				"skaven_clan_rat_with_shield",
				{
					22,
					24
				},
				"skaven_plague_monk",
				{
					9,
					10
				},
				"skaven_storm_vermin_with_shield",
				4,
			}
		}
	}

	HordeCompositions.stronghold_boss_trickle = {
		{
			name = "plain",
			weight = 8,
			breeds = {
				"skaven_slave",
				{
					8,
					10
				},
				"skaven_clan_rat",
				{
					7,
					8
				},
				"skaven_clan_rat_with_shield",
				{
					5,
					6
				}
			}
		},
		{
			name = "plain",
			weight = 2,
			breeds = {
				"skaven_slave",
				{
					5,
					6
				},
				"skaven_clan_rat",
				{
					5,
					6
				},
				"skaven_clan_rat_with_shield",
				{
					4,
					5
				},
				"skaven_storm_vermin_commander",
				3
			}
		}
	}

	HordeCompositions.stronghold_boss_initial_wave = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"skaven_storm_vermin",
				14,
				"skaven_plague_monk",
				8,
				"skaven_clan_rat",
				{
					15,
					17
				}
			}
		}
	}

	BreedActions.skaven_storm_vermin_warlord.spawn_allies.difficulty_spawn_list = {
			easy = {
				"skaven_storm_vermin"
			},
			normal = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			hard = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			survival_hard = {
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			harder = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			survival_harder = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			hardest = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			},
			survival_hardest = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}
	}

	BreedActions.skaven_storm_vermin_warlord.spawn_sequence.considerations.time_since_last.max_value = 800

	--See hooks for boss behaviour changes.

	---------------------
	--Against the Grain

	TerrorEventBlueprints.farmlands.farmlands_rat_ogre = {
		{
			"set_master_event_running",
			name = "farmlands_boss_barn"
		},
		{
			"spawn_at_raw",
			spawner_id = "farmlands_rat_ogre",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") == 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_spawned"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("beastmen_minotaur") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_dead"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_storm_fiend = {
		{
			"set_master_event_running",
			name = "farmlands_boss_barn"
		},
		{
			"spawn_at_raw",
			spawner_id = "farmlands_rat_ogre",
			breed_name = "skaven_stormfiend"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_stormfiend") == 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_spawned"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("beastmen_minotaur") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_dead"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_chaos_troll = {
		{
			"set_master_event_running",
			name = "farmlands_boss_barn"
		},
		{
			"spawn_at_raw",
			spawner_id = "farmlands_rat_ogre",
			breed_name = "chaos_troll"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_troll") == 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_spawned"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("beastmen_minotaur") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_dead"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_chaos_spawn = {
		{
			"set_master_event_running",
			name = "farmlands_boss_barn"
		},
		{
			"spawn_at_raw",
			spawner_id = "farmlands_rat_ogre",
			breed_name = "chaos_spawn"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_spawn") == 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_spawned"
		},
		{
			"delay",
			duration = 1
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("beastmen_minotaur") < 1 and count_event_breed("chaos_troll") < 1 and count_event_breed("chaos_spawn") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "farmlands_barn_boss_dead"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_spawn_guards = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"spawn_at_raw",
			spawner_id = "wall_guard_01",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "wall_guard_02",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "wall_guard_03",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_wall_guard_extra_1",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "windmill_guard",
			breed_name = "chaos_warrior"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_01 = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "farmlands_prisoner_event_01"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "square_front",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "square_front",
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "square_center",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 25 and count_event_breed("skaven_slave") < 50
			end
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 35 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			spawner_id = "hay_barn_back",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_back",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_specials_heavy_disabler"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 35 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			spawner_id = "square_front",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "square_front",
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_bridge_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 35 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_hay_barn_bridge_guards = {
		{
			"spawn_at_raw",
			spawner_id = "hay_barn_bridge_guards",
			breed_name = "chaos_warrior",
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_1",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_2",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_3",
			breed_name = "chaos_berzerker"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_4",
			breed_name = "chaos_berzerker"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_hay_barn_bridge_guards_extra_5",
			breed_name = "chaos_berzerker"
		},
		{
			"set_time_challenge",
			time_challenge_name = "farmlands_speed_event"
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_hay_barn = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "farmlands_prisoner_event_hay_barn"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "hay_barn_guards",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "hay_barn_manual_spawns",
			breed_name = "chaos_marauder"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_cellar_invis",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_cellar_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "hay_barn_cellar_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "hay_barn_front_invis",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "hay_barn_interior",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 30 and count_event_breed("chaos_warrior") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "Against_the_Grain_2nd_event",
			breed_name = "skaven_ratling_gunner",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function,
				size_variation_range = {
				    3,
				    3
				}
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_storm_vermin_commander") < 16
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_stormvermin_shielders"
		},
		{
			"spawn_at_raw",
			spawner_id = "Against_the_Grain_2nd_event",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function,
				size_variation_range = {
				    1.4,
				    1.45
				}
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 35,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 45 and count_event_breed("skaven_storm_vermin_commander") < 16 and count_event_breed("skaven_storm_vermin_with_shield") < 10
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("skaven_storm_vermin_commander") < 16
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_upper_square = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "farmlands_prisoner_event_upper_square"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "square_center",
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 30 and count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard_invis",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40 and count_event_breed("chaos_marauder") < 30
			end
		},
		{
			"event_horde",
			spawner_id = "sawmill_creek",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "sawmill_creek",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "sawmill_creek",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			spawner_id = "sawmill_creek",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_sawmill_door = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "farmlands_prisoner_event_sawmill_door"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "sawmill_interior",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "sawmill_interior",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_prisoner_event_sawmill = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "farmlands_prisoner_event_sawmill"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "sawmill_interior",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "sawmill_interior_invis",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "sawmill_interior_invis",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "sawmill_interior_invis",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "elven_ruins_toptier",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "skaven_shields"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 30 and count_event_breed("skaven_clan_rat_with_shield") < 30 and count_event_breed("skaven_slave") < 40
			end
		}
	}

	TerrorEventBlueprints.farmlands.farmlands_gate_open_event = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"has_completed_time_challenge",
			time_challenge_name = "farmlands_speed_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "sawmill_yard",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	---------------------
	--Empire in Flames

	TerrorEventBlueprints.ussingen.ussingen_gate_guards = {
		{
			"spawn_at_raw",
			spawner_id = "onslaught_gate_spawner_1",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_gate_spawner_2",
			breed_name = "chaos_warrior"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_gate_spawner_3",
			breed_name = "chaos_warrior"
		},
		{
			"delay",
			duration = 0.8
		},
		{
			"spawn_at_raw",
			spawner_id = "gate_spawner_1",
			breed_name = "chaos_warrior"
		},
		{
			"delay",
			duration = 0.8
		},
		{
			"spawn_at_raw",
			spawner_id = "gate_spawner_2",
			breed_name = "chaos_warrior"
		}
	}

TerrorEventBlueprints.ussingen.ussingen_payload_event_01 = {
	{
		"control_pacing",
		enable = false
	},
	{
		"disable_kick"
	},
	{
		"enable_bots_in_carry_event"
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100
	},
	{
		"set_master_event_running",
		name = "ussingen_payload_event"
	},
	{
		"spawn_at_raw",
		spawner_id = "onslaught_cart_guard_1",
		breed_name = "chaos_warrior"
	},
	{
		"spawn_at_raw",
		spawner_id = "onslaught_cart_guard_2",
		breed_name = "chaos_warrior"
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_start",
		composition_type = "event_large_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_start",
		composition_type = "event_maulers_medium"
	},
	{
		"delay",
		duration = 5
	},
	{
		"event_horde",
		limit_spawners = 1,
		spawner_id = "ussingen_payload_start",
		composition_type = "onslaught_chaos_double_wave"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_start",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 10
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 5
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_transit",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"delay",
		duration = 8
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 5
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_large_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_maulers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_double_wave"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_maulers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_maulers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_maulers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_maulers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_maulers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	},
	{
		"delay",
		duration = 6
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 2,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"delay",
		duration = 10
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "skaven_ratling_gunner"
	},
	{
		"continue_when",
		duration = 80,
		condition = function (t)
			return count_event_breed("chaos_berzerker") < 5 and count_event_breed("chaos_raider") < 4 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 11 and count_event_breed("chaos_fanatic") < 16 and count_event_breed("chaos_warrior") < 4
		end
	}
}

TerrorEventBlueprints.ussingen.ussingen_payload_event_02 = {
	{
		"control_pacing",
		enable = false
	},
	{
		"set_freeze_condition",
		max_active_enemies = 100
	},
	{
		"set_master_event_running",
		name = "ussingen_payload_event"
	},
	{
		"delay",
		duration = 4
	},
	{
		"play_stinger",
		stinger_name = "enemy_horde_chaos_stinger"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "event_medium_chaos"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"event_horde",
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_warriors"
	},
	{
		"delay",
		duration = 3
	},
	{
		"event_horde",
		limit_spawners = 4,
		spawner_id = "ussingen_payload_square",
		composition_type = "event_small_chaos"
	},
	{
		"event_horde",
		limit_spawners = 4,
		spawner_id = "ussingen_payload_square",
		composition_type = "onslaught_chaos_shields"
	},
	{
		"event_horde",
		limit_spawners = 4,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 4,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 4,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"event_horde",
		limit_spawners = 4,
		spawner_id = "ussingen_payload_transit",
		composition_type = "onslaught_chaos_berzerkers_medium"
	},
	{
		"delay",
		duration = 5
	},
	{
		"spawn_special",
		amount = 1,
		breed_name = "chaos_vortex_sorcerer"
	},
	{
		"delay",
		duration = 12
	},
	{
		"control_pacing",
		enable = true
	},
	{
		"control_specials",
		enable = true
	}
}

	TerrorEventBlueprints.ussingen.ussingen_gate_open_event = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "ussingen_gate_open",
			composition_type = "event_ussingen_gate_group"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "ussingen_mansion_garden_payload",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "ussingen_mansion_garden_payload",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 8
		},
		{
			"control_specials",
			enable = true
		}
	}

	HordeCompositions.event_ussingen_gate_group = {
		{
			name = "storm_slaves",
			weight = 1,
			breeds = {
				"skaven_slave",
				57,
				"skaven_clan_rat_with_shield",
				14,
				"skaven_storm_vermin_commander",
				{
					7,
					8
				}
			}
		}
	}

	TerrorEventBlueprints.ussingen.ussingen_escape = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "ussingen_escape"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_escape_event",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_escape_event",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_escape_event",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussingen_escape_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_raider") < 6 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 14
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "ussigen_escape_event",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "ussingen_escape_restart"
		}
	}

	---------------------
	--Festering Ground

	TerrorEventBlueprints.nurgle.nurgle_end_event01 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 6) and count_event_breed("skaven_slave") < 6 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 10  and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield") < 5) and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_custom_special_denial"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 5) and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 10 and count_event_breed("skaven_storm_vermin") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 10) and count_event_breed("skaven_slave") < 8 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_storm_vermin_with_shield") < 4 and count_event_breed("chaos_berzerker") < 5 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 7) and count_event_breed("skaven_slave") < 7 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield") < 10) and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_monk",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 10 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 7) and count_event_breed("skaven_slave") < 7 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event01_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_specials_01 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 7,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_specials_02 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 7,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_specials_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_specials_03 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier",
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 7,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_ratling_gunner") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_pack_master") + count_event_breed("skaven_gutter_runner") + count_event_breed("chaos_corruptor_sorcerer") < 9
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_specials_done"
		}
	}

	--01 2 Denial 1 random
	--02 1 Denial 1 disabler 1 random
	--03 1 Denial 2 random
	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_01 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_02 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "event_chaos_extra_spice_small"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_03 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_04 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "nurgle_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_05 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_loop_06 = {
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_monk",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_monk",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_marauder") < 7 and count_event_breed("chaos_warrior") < 5 and count_event_breed("chaos_raider") < 10 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_escape = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"spawn_at_raw",
			spawner_id = "Festering_escape_event",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function,
				size_variation_range = {
				    1.2,
				    1.25
				}
			}
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "onslaught_chaos_double_wave"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_clan_rat_with_shield") < 15 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_escape_done"
		}
	}

	TerrorEventBlueprints.nurgle.nurgle_end_event_escape_02 = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"set_master_event_running",
			name = "nurgle_end_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_clan_rat_with_shield") < 15 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "nurgle_end_event02",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_clan_rat_with_shield") < 15 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "nurgle_end_event02",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_slave") < 30 and count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_clan_rat_with_shield") < 15 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "nurgle_end_event_escape_02_done"
		}
	}


	---------------------
	--Warcamp

	HordeCompositions.event_warcamp_elites = {
		{
			name = "zerker",
			weight = 3,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_berzerker",
				{
					4,
					5
				}
			}
		},
		{
			name = "mixed",
			weight = 2,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_raider",
				{
					2,
					3
				},
				"chaos_berzerker",
				{
					2,
					3
				}
			}
		},
		{
			name = "mauler",
			weight = 5,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_raider",
				{
					4,
					5
				}
			}
		},
	}

	TerrorEventBlueprints.warcamp.warcamp_payload = {
		{
			"set_master_event_running",
			name = "warcamp_payload"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 6
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "chaos_warriors"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_l",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "payload_event_r",
			composition_type = "event_maulers_medium"
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_marauder") < 18 and count_event_breed("chaos_marauder_with_shield") < 18
			end
		},
		{
			"flow_event",
			flow_event_name = "warcamp_payload"
		}
	}

	-- TerrorEventBlueprints.warcamp.warcamp_door_guard = {
		-- {
			-- "disable_kick"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_shield_dude_1",
			-- breed_name = "chaos_warrior"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_shield_dude_2",
			-- breed_name = "chaos_warrior"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_sword_dude_1",
			-- breed_name = "chaos_berzerker"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_sword_dude_2",
			-- breed_name = "chaos_berzerker"
		-- },
		-- {
			-- "spawn_at_raw",
			-- spawner_id = "wc_2h_dude_1",
			-- breed_name = "chaos_warrior"
		-- }
	-- }

	TerrorEventBlueprints.warcamp.warcamp_camp = {
		{
			"set_master_event_running",
			name = "warcamp_camp"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "camp_event",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "payload_event_l",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "camp_event",
			composition_type = "event_warcamp_elites"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "camp_event",
			composition_type = "event_warcamp_elites"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 10 and count_event_breed("chaos_raider") < 10 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield") < 25) and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "warcamp_camp_restart"
		}
	}

	HordeCompositions.warcamp_boss_event_trickle = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_marauder",
				{
					6,
					8
				},
				"chaos_berzerker",
				{
					6,
					7
				}
			}
		},
		{
			name = "somevermin",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					6,
					8
				},
				"chaos_raider",
				{
					2,
					3
				},
				"chaos_berzerker",
				{
					5,
					6
				}
			}
		}
	}

	HordeCompositions.warcamp_boss_event_defensive = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_marauder",
				{
					9,
					12
				},
				"chaos_marauder_with_shield",
				{
					10,
					12
				},
				"chaos_berzerker",
				{
					5,
					6
				},
				"chaos_raider",
				{
					5,
					6
				},
				"chaos_warrior",
				{
					2,
					3
				}
			}
		},
		{
			name = "horde",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					25,
					31
				},
				"chaos_marauder",
				{
					10,
					11
				},
				"chaos_berzerker",
				{
					10,
					12
				}
			}
		},
		{
			name = "somevermin",
			weight = 2,
			breeds = {
				"chaos_warrior",
				{
					4,
					5
				},
				"chaos_berzerker",
				{
					6,
					7
				},
				"chaos_marauder_with_shield",
				{
					13,
					15
				}
			}
		}
	}

	TerrorEventBlueprints.warcamp.warcamp_chaos_boss = {
		{
			"set_master_event_running",
			name = "warcamp_chaos_boss"
		},
		{
			"spawn_at_raw",
			spawner_id = "warcamp_chaos_boss",
			breed_name = "chaos_exalted_champion_warcamp",
			optional_data = {
				max_health_modifier = 1.5,
				enhancements = enhancement_5
			}
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_warcamp") == 1
			end
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_camp_boss_top",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_camp_boss_top_behind",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_camp_boss_top_left",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "onslaught_camp_boss_top_right",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_warcamp") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "warcamp_chaos_boss_dead"
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	--See hooks for warcamp boss behaviour changes.

	---------------------
	--Skittergate

	TerrorEventBlueprints.skittergate.skittergate_spawn_guards = {
		{
			"spawn_at_raw",
			spawner_id = "gate_guard_01",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gate_guard_02",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_gate_guard",
			breed_name = "skaven_storm_vermin_commander"
		}
	}

	TerrorEventBlueprints.skittergate.skittergate_chaos_boss = {
		{
			"set_master_event_running",
			name = "skittergate_chaos_boss"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_1",
			composition_type = "onslaught_skittergate_warriors_one"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_3",
			composition_type = "onslaught_skittergate_warriors_three"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_2",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_2",
			composition_type = "onslaught_skittergate_warriors_two"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_1",
			composition_type = "onslaught_skittergate_warriors_one"
		},
		{
			"event_horde",
			spawner_id = "onslaught_CW_gatekeeper_3",
			composition_type = "onslaught_skittergate_warriors_three"
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "skittergate_chaos_boss",
			breed_name = "chaos_exalted_champion_norsca"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") == 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner",
				"skaven_pack_master",
				"chaos_corruptor_sorcerer"
			}
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") < 1 or count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			spawner_id = "onslaught_zerker_gatekeeper",
			composition_type = "onslaught_skittergate_warriors_three"
		},
		{
			"event_horde",
			spawner_id = "onslaught_zerker_gatekeeper",
			composition_type = "onslaught_skittergate_zerker"
		},
		{
			"event_horde",
			spawner_id = "onslaught_zerker_gatekeeper",
			composition_type = "onslaught_skittergate_zerker"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") < 1
			end
		},
		{
			"delay",
			duration = 2
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_champion_norsca") < 1 and count_event_breed("chaos_spawn_exalted_champion_norsca") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "skittergate_chaos_boss_killed"
		}
	}

	HordeCompositions.onslaught_skittergate_warriors_one = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_warrior",
				1,
			}
		}
	}

	HordeCompositions.onslaught_skittergate_warriors_two = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_warrior",
				2,
			}
		}
	}

	HordeCompositions.onslaught_skittergate_warriors_three = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_warrior",
				3,
			}
		}
	}

	HordeCompositions.onslaught_skittergate_zerker = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"chaos_berzerker",
				{
					10,
					12
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_raider",
				{
					3,
					4
				}
			}
		}
	}

	TerrorEventBlueprints.skittergate.skittergate_gatekeeper_marauders = {
		{
			"spawn_at_raw",
			spawner_id = "skittergate_gatekeeper_marauder_01",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "skittergate_gatekeeper_marauder_02",
			breed_name = "chaos_raider"
		},
		{
			"spawn_at_raw",
			spawner_id = "skittergate_gatekeeper_marauder_03",
			breed_name = "chaos_marauder_with_shield"
		}
	}

	TerrorEventBlueprints.skittergate.skittergate_terror_event_02 = {
		{
			"set_master_event_running",
			name = "skittergate_terror_event_02"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "terror_event_02",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "terror_event_02",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "terror_event_02",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"control_specials",
			enable = true
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 15 and count_event_breed("skaven_slave") < 20 and (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 12
			end
		},
		{
			"flow_event",
			flow_event_name = "skittergate_terror_event_02_done"
		}
	}

	BreedActions.skaven_grey_seer.ground_combat.spawn_allies_cooldown = 18

	BreedActions.skaven_grey_seer.ground_combat.staggers_until_teleport = 1
	BreedActions.skaven_grey_seer.ground_combat.warp_lightning_spell_cooldown = {
			2,
			2,
			2,
			2
	}

	BreedActions.skaven_grey_seer.ground_combat.vermintide_spell_cooldown = {
			4,
			4,
			4,
			4
	}

	BreedActions.skaven_grey_seer.ground_combat.teleport_spell_cooldown = {
			1.5,
			1.5,
			1.5,
			1.5
	}

	HordeCompositions.skittergate_boss_event_defensive = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"skaven_storm_vermin",
				{
					14,
					16
				},
				"skaven_clan_rat",
				{
					10,
					12
				},
				"skaven_clan_rat_with_shield",
				{
					7,
					9
				},
				"skaven_storm_vermin_with_shield",
				{
					3,
					5
				}
			}
		},
		{
			name = "somevermin",
			weight = 3,
			breeds = {
				"skaven_slave",
				{
					25,
					30
				},
				"skaven_storm_vermin",
				{
					10,
					12
				},
				"skaven_storm_vermin_with_shield",
				{
					1,
					2
				},
				"skaven_plague_monk",
				{
					8,
					10
				}

			}
		},
		{
			name = "berzerkers",
			weight = 3,
			breeds = {
				"skaven_plague_monk",
				{
					16,
					18
				},
				"skaven_clan_rat_with_shield",
				{
					10,
					12
				},
				"skaven_storm_vermin_with_shield",
				1
			}
		},
		{
			name = "shield_vermins",
			weight = 8,
			breeds = {
				"skaven_storm_vermin_with_shield",
				{
					10,
					11
				},
				"skaven_clan_rat_with_shield",
				{
					10,
					12
				},
				"skaven_storm_vermin",
				6,
			}
		}
	}

	HordeCompositions.skittergate_grey_seer_trickle = {
		{
			name = "plain",
			weight = 6,
			breeds = {
				"skaven_slave",
				{
					16,
					20
				},
				"skaven_clan_rat",
				{
					9,
					10
				},
				"skaven_clan_rat_with_shield",
				{
					6,
					8
				},
				"skaven_storm_vermin_commander",
				{
					8,
					9
				},
				"skaven_plague_monk",
				{
					7,
					8
				},
				"skaven_storm_vermin_with_shield",
				1
			}
		}
	}

	--See hooks for boss logic.

	---------------------
	--The Pit

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_pacing_off = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_pacing_off = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	HordeCompositions.chaos_elites = {
		{
			name = "zerker",
			weight = 1,
			breeds = {
				"chaos_berzerker",
				{
					4,
					4
				}
			}
		},
		{
			name = "mauler",
			weight = 1,
			breeds = {
				"chaos_raider",
				{
					2,
					2
				}
			}
		}
	}

	HordeCompositions.slum_cw = {
		{
			name = "chaos_warrior",
			weight = 2,
			breeds = {
				"chaos_warrior",
					1
			}
		}
	}

	HordeCompositions.slum_specials = {
		{
			name = "leech",
			weight = 2,
			breeds = {
				"chaos_corruptor_sorcerer",
				2,
			}
		},
		{
			name = "warpfire",
			weight = 2,
			breeds = {
				"skaven_warpfire_thrower",
				2,
			}
		},
		{
			name = "mixed",
			weight = 3,
			breeds = {
				"chaos_corruptor_sorcerer",
				1,
				"skaven_warpfire_thrower",
				1,
			}
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_start = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_slum_event_start"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_specials",
			enable = false
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_mid_01",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_left_01",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_right_01",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_right_01",
			composition_type = "slum_cw"
		},
		{
			"delay",
			duration = 15
		},	
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_slum_event_start_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_loop = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_left_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_left_01",
			composition_type = "mass_trash_skaven"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_mid_01",
			composition_type = "mass_trash_chaos"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_right_01",
			composition_type = "slum_cw"
		},
		{
			"delay",
			duration = 48
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_slum_event_loop_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_spice_mid = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_mid_01",
			composition_type = "onslaught_chaos_double_wave"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_front_mid_01",
			composition_type = "onslaught_custom_special_disabler"
		},
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_spice_left = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "event_small"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_spice_right = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_left_01",
			composition_type = "event_small"
		},
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_event_end_loop = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_roof_01",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_roof_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_roof_01",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_event_roof_01",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("chaos_marauder_with_shield") + count_event_breed("chaos_marauder")) < 14
			end
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 20 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 5
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_slum_event_end_loop"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_gauntlet_part_01 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_slum_gauntlet_master"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"control_specials",
			enable = false
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_cutoff",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_cutoff",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_special",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 2
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_special",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_special",
			amount = 1,
			breed_name = "skaven_pack_master"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_behind",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_behind",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_slum_gauntlet_behind",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_special",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_01",
			breed_name = "skaven_pack_master"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_gauntlet_wall = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_slum_gauntlet_master"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall_01",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall_01",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall_01",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall_01",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "bogenhafen_slum_gauntlet_wall",
			composition_type = "onslaught_chaos_warriors"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_slum.dlc_bogenhafen_slum_gauntlet_part_02 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_slum_gauntlet_master"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"event_horde",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"spawn_special",
			spawner_id = "dlc_bogenhafen_slum_gauntlet_part_02",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_berzerker") < 3 and (count_event_breed("chaos_marauder_with_shield") + count_event_breed("chaos_marauder")) < 9 and count_event_breed("chaos_warrior") < 2 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 10 and count_event_breed("skaven_slave") < 14 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_slum_gauntlet_part_02_done"
		}
	}

	---------------------
	--Blightreaper

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_disable_pacing = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_start = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_sewer_start"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "event_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "sewer_start",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 18
			end
		},
		{
			"delay",
			duration = 20
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_start_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_spice = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_spice",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_spice",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_spice",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_spice",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 18
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_spice_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_mid01 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_sewer_mid01"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "sewer_mid",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_large_chaos"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 25
			end
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_at_raw",
			spawner_id = "sewer_rawspawner01",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_mid",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_mid",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_mid",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_mid",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "sewer_mid",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 8 and count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_slave") < 15
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_mid01_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_end = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_sewer_end"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "onslaught_sewer_backspawn",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_end_chaos",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 20 and count_event_breed("chaos_marauder_with_shield") < 20
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_end_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "sewer_mid",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"control_specials",
			enable = true
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_end_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_sewer_escape = {
		{
			"set_master_event_running",
			name = "bogenhafenhafen_sewer_escape"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewer_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_sewer_exit_gun_1",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_sewer_exit_gun_2",
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
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_marauder_with_shield") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_sewer_escape_done"
		}
	}

	HordeCompositions.onslaught_blightreaper_temple_easy = {
		{
			name = "skaven_offensive",
			weight = 1,
			breeds = {
				"skaven_storm_vermin_commander",
				{
					4,
					5
				},
				"skaven_plague_monk",
				{
					4,
					5
				}
			}
		},
		{
			name = "skaven_mixed",
			weight = 1,
			breeds = {
				"skaven_storm_vermin_with_shield",
				5,
				"skaven_plague_monk",
				{
					5,
					5
				}
			}
		},
		{
			name = "skaven_defensive",
			weight = 1,
			breeds = {
				"skaven_storm_vermin_with_shield",
				5,
				"skaven_storm_vermin_commander",
				{
					4,
					5
				}
			}
		},
		{
			name = "chaos_mixed",
			weight = 1,
			breeds = {
				"chaos_berzerker",
				{
					6,
					7
				},
				"chaos_marauder_with_shield",
				16,
			}
		},
		{
			name = "chaos_offensive",
			weight = 1,
			breeds = {
				"chaos_warrior",
				3,
				"chaos_raider",
				{
					5,
					6
				},
			}
		},
		{
			name = "chaos_zerg",
			weight = 1,
			breeds = {
				"chaos_warrior",
				3,
				"chaos_berzerker",
				{
					5,
					6
				},
			}
		},
		{
			name = "chaos_defensive",
			weight = 1,
			breeds = {
				"chaos_raider",
				{
					6,
					7
				},
				"chaos_marauder_with_shield",
				16,
			}
		},
		{
			name = "chaos_leader",
			weight = 1,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_raider",
				{
					3,
					4
				},
				"chaos_marauder_with_shield",
				{
					8,
					10
				},
				"chaos_berzerker",
				{
					3,
					4
				}
			}
		}
	}

	HordeCompositions.onslaught_blightreaper_temple_hard = {
		{
			name = "chaos_defensive",
			weight = 1,
			breeds = {
				"chaos_warrior",
				6,
				"chaos_marauder_with_shield",
				{
					10,
					12
				}
			}
		},
		{
			name = "chaos_offensive",
			weight = 1,
			breeds = {
				"chaos_warrior",
				4,
				"chaos_raider",
				{
					5,
					6
				}
			}
		},
		{
			name = "chaos_zerg",
			weight = 1,
			breeds = {
				"chaos_warrior",
				4,
				"chaos_berzerker",
				{
					6,
					7
				}
			}
		},
		{
			name = "chaos_leader",
			weight = 1,
			breeds = {
				"chaos_warrior",
				2,
				"chaos_marauder_with_shield",
				{
					8,
					10
				},
				"chaos_raider",
				{
					4,
					6
				},
				"chaos_berzerker",
				{
					4,
					6
				}
			}
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_loop = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_loop"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_loop",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_plague_monk") < 5 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_warrior") < 3 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_gutter_runner") < 4 and count_event_breed("skaven_pack_master") < 4 and (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_ratling_gunner")) < 7
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_plague_monk") < 5 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_warrior") < 3 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_gutter_runner") < 4 and count_event_breed("skaven_pack_master") < 4 and (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_ratling_gunner")) < 7
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_plague_monk") < 5 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_warrior") < 3 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_gutter_runner") < 4 and count_event_breed("skaven_pack_master") < 4 and (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_ratling_gunner")) < 7
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_loop",
			composition_type = "event_medium_shield"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("skaven_plague_monk") < 5 and count_event_breed("chaos_fanatic") < 24 and count_event_breed("chaos_marauder") < 16 and count_event_breed("chaos_warrior") < 3 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("skaven_gutter_runner") < 4 and count_event_breed("skaven_pack_master") < 4 and (count_event_breed("skaven_poison_wind_globadier") + count_event_breed("skaven_warpfire_thrower") + count_event_breed("skaven_ratling_gunner")) < 7
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_loop_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_start = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_end_start"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"disable_kick"
		},
		{
			"control_specials",
			enable = true
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_start",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_custom_special_disabler"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"event_horde",
			spawner_id = "temple_event_start",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_start_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button1 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button1"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button1",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_custom_specials_heavy_disabler"
		},
		{
			"delay",
			duration = 30
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner01",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button1_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button2 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button2"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "event_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner01",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner02",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button4",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button4",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button4",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window1",
			breed_name = "storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front4",
			breed_name = "storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_storm_vermin") < 8 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button2_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button3 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button3"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stingers_plague_monk"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button3",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "temple_event_button3",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button3",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window1",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front4",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"event_horde",
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_blightreaper_temple_easy"
		},
		{
			"spawn_special",
			amount = 3,
			spawner_id = "temple_event_button3",
			breed_name = "chaos_corruptor_sorcerer"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window1",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front4",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button3",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_storm_vermin_commander") < 10 and count_event_breed("skaven_slave") < 35 and count_event_breed("skaven_storm_vermin_with_shield") < 8 and count_event_breed("skaven_plague_monk") < 10 and count_event_breed("chaos_marauder") < 26 and count_event_breed("chaos_marauder_with_shield") < 20 and count_event_breed("chaos_raider") < 10 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button3_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button4 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button4"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button4",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button4",
			composition_type = "onslaught_blightreaper_temple_hard"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window2",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front2",
			breed_name = "khorne_buff_spawn_function",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button4",
			composition_type = "onslaught_blightreaper_temple_hard"
		},
		{
			"delay",
			duration = 5
		},
				{
			"spawn_at_raw",
			spawner_id = "onslaught_button_window2",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_front2",
			breed_name = "khorne_buff_spawn_function",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button4_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_button5 = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_button5"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "temple_rawspawner01",
			breed_name = "chaos_spawn",
			optional_data = {
				max_health_modifier = 0.75
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_button_hidden",
			breed_name = "chaos_spawn",
			optional_data = {
				max_health_modifier = 0.75
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button5",
			composition_type = "onslaught_blightreaper_temple_hard"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "temple_event_button2",
			composition_type = "onslaught_custom_specials_heavy_denial"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button5_done"
		}
	}

	TerrorEventBlueprints.dlc_bogenhafen_city.dlc_bogenhafen_city_temple_escape = {
		{
			"set_master_event_running",
			name = "dlc_bogenhafen_city_temple_escape"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "temple_event_escape",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 24 and count_event_breed("chaos_marauder_with_shield") < 15 and count_event_breed("chaos_raider") < 8 and count_event_breed("chaos_berzerker") < 8 and count_event_breed("chaos_warrior") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_bogenhafen_city_temple_button5_done"
		}
	}

	-------------------
	--Horn of Magnus

	HordeCompositions.onslaught_gutter_assistants = {
		{
			name = "monk",
			weight = 5,
			breeds = {
				"skaven_plague_monk",
				1
			}
		},
		{
			name = "shield",
			weight = 5,
			breeds = {
				"skaven_storm_vermin_with_shield",
				1
			}
		},
		{
			name = "pack",
			weight = 5,
			breeds = {
				"skaven_pack_master",
				1
			}
		},
		{
			name = "warpfire",
			weight = 2,
			breeds = {
				"skaven_warpfire_thrower",
				1
			}
		}
	}

	TerrorEventBlueprints.magnus.magnus_gutter_runner_treasure = {
		{
			"spawn_special",
			breed_name = "skaven_gutter_runner",
			amount = {
				2,
				3
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_gutterrunner_stinger"
		},
		{
			"event_horde",
			composition_type = "onslaught_gutter_assistants"
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "gutter_runner_treasure_restart"
		}
	}

	TerrorEventBlueprints.magnus.magnus_door_a = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 12
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_magnus_boss_middle",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 12
		},
		{
			"continue_when",
			duration = 10,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 12 and count_breed("chaos_fanatic") < 16 and count_breed("chaos_raider") < 6 and count_breed("chaos_berzerker") < 6
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"spawn_special",
			spawner_id = "magnus_door_event_specials",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_special",
			spawner_id = "magnus_door_event_specials",
			breed_name = "skaven_warpfire_thrower"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			spawner_id = "magnus_door_event_specials",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			},
			amount = {
				1,
				2
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "skaven_poison_wind_globadier",
			spawner_id = "magnus_door_event_specials",
			amount = {
				1,
				2
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_extra_spice_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.magnus.magnus_door_b = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_magnus_boss_middle",
			breed_name = "chaos_troll"
		},
		{
			"delay",
			duration = 12
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_specials",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn",
			{
				1,
				2
			},
			spawner_id = "magnus_door_event_specials",
			breed_name = "chaos_warrior"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_extra_spice_small"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("skaven_clan_rat") + count_breed("skaven_clan_rat_with_shield")) < 10 and count_breed("skaven_slave") < 15 and (count_breed("skaven_storm_vermin_commander") + count_breed("skaven_storm_vermin_with_shield")) < 4 and count_breed("skaven_plague_monk") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"continue_when",
			duration = 12,
			condition = function (t)
				return (count_breed("chaos_marauder") + count_breed("chaos_marauder_with_shield")) < 8 and count_breed("chaos_fanatic") < 13 and count_breed("chaos_raider") < 4 and count_breed("chaos_berzerker") < 4
			end
		},
		{
			"continue_when",
			duration = 5,
			condition = function (t)
				return count_breed("chaos_troll") < 1
			end
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.magnus.magnus_end_event = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "magnus_end_event"
		},
		{
			"flow_event",
			flow_event_name = "magnus_horn_crescendo_starting"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn_first",
			composition_type = "event_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "magnus_end_event_first_wave_killed"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"disable_kick"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_chaos",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 10 and count_event_breed("chaos_fanatic") < 18 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_warrior") < 3
			end
		},
		{
			"delay",
			duration = 4
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"control_specials",
			enable = true
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 1
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("chaos_marauder") + count_event_breed("chaos_marauder_with_shield")) < 10 and count_event_breed("chaos_fanatic") < 18 and count_event_breed("chaos_raider") < 6 and count_event_breed("chaos_berzerker") < 6 and count_event_breed("chaos_warrior") < 3
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_magnus_boss_end",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 18 and count_event_breed("skaven_slave") < 25 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_plague_monk") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "magnus_tower_horn",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "magnus_tower_horn",
			composition_type = "onslaught_storm_vermin_white_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 3 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 1 and count_event_breed("skaven_plague_monk") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "magnus_horn_event_done"
		},
		{
			"delay",
			duration = 5
		},
		{
			"control_pacing",
			enable = true
		}
	}

		---------------------
	--Garden of Morr

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_1_a = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium",
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium",
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium",
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium",
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "cemetery_brew_event_specials",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_1_b = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_special",
			breed_name = "skaven_poison_wind_globadier",
			amount = 3
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_2_a = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"spawn_special",
			breed_name = "skaven_poison_wind_globadier",
			amount = 2
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "chaos_vortex_sorcerer",
			amount = 2
		},
		{
			"delay",
			duration = 5
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_2_b = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_2",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = slaanesh_buff_spawn_function
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "chaos_vortex_sorcerer",
			amount = 2
		},
		{
			"delay",
			duration = 5
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_3_a = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_special",
			breed_name = "skaven_warpfire_thrower",
			amount = 3
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_3_b = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"spawn_special",
			breed_name = "skaven_ratling_gunner",
			amount = 3
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "cemetery_brew_event_specials",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_3",
			breed_name = "skaven_storm_vermin",
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_4_a = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_event_4_b = {
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"event_horde",
			composition_type = "event_extra_spice_medium"
		}
	}

	TerrorEventBlueprints.cemetery.cemetery_plague_brew_exit_event = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_4",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_4",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "cemetery_brew_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_cemetery_chain_4",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_fanatic") < 3 and count_event_breed("chaos_marauder_with_shield") < 2
			end
		}
	}

	---------------------
	--Engines of War

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_loop = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_extra_spice_unshielded"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 30
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = {
				2,
				4
			}
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_poison_wind_globadier"
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_slave") < 12 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 5
			end
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_loop_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_resistance_loop = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "forest_camp_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_camp_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = {
				4,
				9
			}
		},
		{
			"spawn_special",
			amount = 2,
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_gutter_runner"
			}
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_pack_master"
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 10 and count_event_breed("skaven_slave") < 24 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 16 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 10
			end
		},
		{
			"delay",
			duration = {
				13,
				17
			}
		},
		{
			"event_horde",
			spawner_id = "forest_camp_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"spawn_special",
			amount = 2,
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner"
			}
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "skaven_camp_loop",
			composition_type = "onslaught_skaven_double_wave"
		},
		{
			"delay",
			duration = {
				4,
				9
			}
		},
		{
			"spawn_special",
			amount = 2,
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_poison_wind_globadier"
			}
		},
		{
			"spawn_special",
			spawner_id = "forest_camp_specials",
			breed_name = {
				"skaven_pack_master",
				"skaven_gutter_runner",
				"skaven_poison_wind_globadier",
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			}
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 10 and count_event_breed("skaven_slave") < 24 and (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 16 and (count_event_breed("skaven_storm_vermin_commander") + count_event_breed("skaven_storm_vermin_with_shield")) < 10
			end
		},
		{
			"delay",
			duration = {
				13,
				17
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_resistance_loop_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_a = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_commander") < 12
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_a_done"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_b = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 12
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_b_done"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_c = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "skaven_shields"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat_with_shield") < 20 and count_event_breed("skaven_storm_vermin_with_shield") < 10
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "skaven_shields"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "skaven_shields"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat_with_shield") < 10 and count_event_breed("skaven_storm_vermin_with_shield") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_c_done"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_skaven_camp_finale = {
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"stop_event",
			stop_event_name = "forest_skaven_camp_resistance_loop"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_door_a",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_door_a",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_door_a",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_doomwheel_boss",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_stormfiend") < 1
			end
		},
		{
			"stop_master_event"
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_finale_done"
		},
		{
			"disable_bots_in_carry_event"
		},
		{
			"control_pacing",
			enable = true
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_event_loop = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "forest_end_event",
			composition_type = "event_extra_spice_small"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield")) < 8 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_loop_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_event_a = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = {
				6,
				9
			}
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_specials",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = {
				30,
				34
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_event_b = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_small_chaos"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_event_small_fanatics"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_maulers_small"
		},
		{
			"delay",
			duration = {
				40,
				45
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_event_c = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"delay",
			duration = 15
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_extra_spice_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = {
				38,
				42
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	TerrorEventBlueprints.forest_ambush.forest_end_finale = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "onslaught_custom_boss_minotaur"
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_finale",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event_chaos",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_storm_vermin_commander") < 5 and count_event_breed("chaos_raider") < 5 and count_event_breed("chaos_warrior") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	---------------------
	--Dark Omens

	local horde_sound_settings = {
		skaven = {
			stinger_sound_event = "enemy_horde_stinger",
			music_states = {
				horde = "horde"
			}
		},
		chaos = {
			stinger_sound_event = "enemy_horde_chaos_stinger",
			music_states = {
				pre_ambush = "pre_ambush_chaos",
				horde = "horde_chaos"
			}
		},
		beastmen = {
			stinger_sound_event = "enemy_horde_beastmen_stinger",
			music_states = {
				pre_ambush = "pre_ambush_beastmen",
				horde = "horde_beastmen"
			}
		}
	}

	local function num_spawned_enemies()
		local spawned_enemies = Managers.state.conflict:spawned_units()

		return #spawned_enemies
	end

	local function num_alive_standards()
		local alive_standards = Managers.state.conflict:alive_standards()

		return #alive_standards
	end

	TerrorEventBlueprints.crater.crater_mid_event = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "crater_mid_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_beastmen_stinger"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = true
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_01",
			composition_type = "onslaught_custom_boss_minotaur",
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_01",
			composition_type = "ungor_archers",
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_02",
			composition_type = "ungor_archers",
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("beastmen_minotaur") < 1 and count_breed("beastmen_ungor_archer") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_01",
			composition_type = "event_medium_beastmen",
			sound_settings = horde_sound_settings.beastmen
		},
		{
			"event_horde",
			limit_spawners = 3,
			spawner_id = "crater_mid_event_door_horde_02",
			composition_type = "event_medium_beastmen",
			sound_settings = horde_sound_settings.beastmen
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("beastmen_gor") < 1 and count_breed("beastmen_ungor") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_mid_event_enable_gate"
		},
		{
			"delay",
			duration = 1
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_beastmen_stinger"
		},
		{
			"event_horde",
			limit_spawners = 1,
			spawner_id = "crater_mid_event_door_elite_02",
			composition_type = "crater_bestigor_medium",
			sound_settings = horde_sound_settings.beastmen
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_bestigor") < 1
			end
		},
		{
			"delay",
			duration = 1
		},
		{
			"control_specials",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "crater_mid_event_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_manual_spawns = {
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_01",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_02",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_03",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_04",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_05",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_06",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_07",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_08",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_10",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_11",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_12",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_13",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_14",
			breed_name = "beastmen_bestigor"
		},
		{
			"spawn_at_raw",
			spawner_id = "crater_end_event_manual_spawn_15",
			breed_name = "beastmen_bestigor"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_intro_wave = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_intro_wave"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_beastmen_stinger"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event_intro_wave",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event_intro_wave",
			composition_type = "event_large_beastmen"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 55,
			condition = function (t)
				return count_event_breed("beastmen_gor") < 4 and count_breed("beastmen_ungor") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_intro_wave_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_wave_01 = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_wave_01"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 16
			end
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 10
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_medium_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_medium_beastmen"
		},
		{
			"continue_when",
			duration = 90,
			condition = function (t)
				return num_alive_standards() < 1 and count_event_breed("beastmen_gor") < 8 and count_event_breed("beastmen_ungor") < 8
			end
		},
		{
			"spawn_at_raw",
			breed_name = "beastmen_minotaur",
			spawner_id = "event_minotaur"
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_01_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_wave_02 = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_wave_02"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 14
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 20
			end
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 10
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"continue_when",
			duration = 180,
			condition = function (t)
				return num_alive_standards() < 1 and count_event_breed("beastmen_gor") < 8 and count_event_breed("beastmen_ungor") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_02_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_wave_03 = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_wave_03"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 20
			end
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 12
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "ungor_archers"
		},
		{
			"continue_when",
			duration = 180,
			condition = function (t)
				return num_alive_standards() < 1 and count_event_breed("beastmen_gor") < 8 and count_event_breed("beastmen_ungor") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_03_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_wave_04 = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "crater_end_event_wave_04"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return num_spawned_enemies() < 16
			end
		},
		{
			"spawn_special",
			breed_name = "beastmen_bestigor",
			amount = 12
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "event_large_beastmen"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "ungor_archers"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "crater_end_event",
			composition_type = "ungor_archers"
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_04_repeat"
		},
		{
			"continue_when",
			duration = 180,
			condition = function (t)
				return num_alive_standards() < 1 and count_event_breed("beastmen_gor") < 5 and count_event_breed("beastmen_ungor") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "crater_end_event_wave_04_done"
		}
	}

	TerrorEventBlueprints.crater.crater_end_event_minotaur = {
		{
			"spawn_at_raw",
			breed_name = "beastmen_minotaur",
			spawner_id = "event_minotaur",
			difficulty_requirement = HARD
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_minotaur") == 2
			end
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("beastmen_minotaur") < 2
			end
		}
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
				"beastmen_standard_bearer",
				2
			}
		}
	}

	---------------------
	--Old Haunts

	TerrorEventBlueprints.dlc_portals.dlc_portals_control_pacing_disabled = {
		{
			"text",
			text = "",
			duration = 0
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_temple_inside = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "dlc_portals_temple_inside"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_hordes",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside",
			composition_type = "onslaught_storm_vermin_shields_small"
		},
		{
			"delay",
			duration = 6
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_portals_temple_inside_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_temple_inside_specials = {
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_custom_special_skaven"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_ladder_left1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_ladder_right1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_temple_yard = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_temple_yard"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_temple_yard",
			composition_type = "event_large_chaos"
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_special",
			spawner_id = "portals_temple_yard",
			amount = 1,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_warpfire_thrower"
			}
		},
		{
			"spawn_special",
			spawner_id = "portals_temple_yard",
			amount = 1,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_warpfire_thrower"
			}
		},
		{
			"event_horde",
			spawner_id = "portals_temple_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_inside_specials",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_temple_yard",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"delay",
			duration = 6
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 25 and count_event_breed("chaos_fanatic") < 30 and count_event_breed("chaos_raider") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "dlc_portals_temple_yard_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_temple_yard_exit = {
		{
			"spawn_at_raw",
			spawner_id = "portals_temple_yard_exit",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 18
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"control_hordes",
			enable = true
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_guards = {
		{
			"event_horde",
			spawner_id = "portals_end_event_guards",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_guards",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_guards",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_guards",
			composition_type = "chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_stairs1",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_hordes",
			enable = false
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_a = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_event"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_special",
			breed_name = "skaven_pack_master",
			spawner_id = "portals_end_event_specials",
			amount = 1,
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 15
			end
		},
		{
			"flow_event",
			flow_event_name = "portals_end_event_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_b = {
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_event"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 7
		},
		{
			"spawn_special",
			spawner_id = "portals_end_event_specials",
			amount = 1,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_warpfire_thrower"
			}
		},
		{
			"spawn_special",
			spawner_id = "portals_end_event_specials",
			amount = 1,
			breed_name = {
				"skaven_ratling_gunner"
			},
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "onslaught_chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_basement",
			breed_name = "chaos_warrior",
			optional_data = {
				spawned_func = khorne_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			duration = 55,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 12 and count_event_breed("chaos_fanatic") < 14 and count_event_breed("chaos_warrior") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "portals_end_event_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_c = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_event"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "plague_monks_medium"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_basement",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_entrance",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"spawn_special",
			spawner_id = "portals_end_event_specials",
			amount = 2,
			breed_name = {
				"skaven_warpfire_thrower",
				"skaven_ratling_gunner"
			},
		},
		{
			"spawn_special",
			spawner_id = "portals_end_event_specials",
			amount = 1,
			breed_name = {
				"skaven_gutter_runner"
			},
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 55,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "portals_end_event_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_event_d = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_event"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event",
			composition_type = "plague_monks_medium",
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_stairs1",
			breed_name = "skaven_plague_monk",
			optional_data = {
				spawned_func = nurgle_buff_spawn_function
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 55,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 15 and count_event_breed("chaos_fanatic") < 15 and count_event_breed("chaos_raider") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "portals_end_event_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_escape_specials = {
		{
			"event_horde",
			spawner_id = "portals_end_escape_specials",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_specials",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_specials",
			composition_type = "plague_monks_medium"
		},
		{
			"spawn_special",
			spawner_id = "portals_end_escape_specials",
			amount = 3,
			breed_name = {
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 4
		},
		{
			"spawn_special",
			spawner_id = "portals_end_escape_specials",
			amount = 3,
			breed_name = {
				"skaven_pack_master"
			}
		},
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_escape_a = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_escape"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "portals_end_event_skaven",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_special",
			spawner_id = "portals_end_escape_specials",
			amount = 4,
			breed_name = {
				"skaven_poison_wind_globadier",
				"skaven_ratling_gunner"
			}
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "plague_monks_medium"
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_special",
			breed_name = "skaven_warpfire_thrower",
			spawner_id = "portals_end_escape_specials",
			amount = 1,
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 15 and count_event_breed("skaven_plague_monk") < 8 and count_event_breed("skaven_storm_vermin_with_shield") < 6
			end
		},
		{
			"delay",
			duration = {
				1,
				4
			}
		},
		{
			"flow_event",
			flow_event_name = "portals_end_escape_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_escape_b = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_escape"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_skaven",
			composition_type = "event_maulers_medium"
		},
		{
			"spawn_special",
			spawner_id = "portals_end_escape_specials",
			amount = 2,
			breed_name = {
				"chaos_corruptor_sorcerer",
				"skaven_warpfire_thrower"
			}
		},
		{
			"delay",
			duration = 7
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 12 and count_event_breed("chaos_fanatic") < 12
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "event_medium_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "onslaught_chaos_shields"
		},
		{
			"spawn_special",
			breed_name = "skaven_ratling_gunner",
			spawner_id = "portals_end_escape_specials",
			amount = 1,
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 15 and count_event_breed("chaos_fanatic") < 15 and count_event_breed("chaos_raider") < 6
			end
		},
		{
			"delay",
			duration = {
				1,
				4
			}
		},
		{
			"flow_event",
			flow_event_name = "portals_end_escape_done"
		}
	}

	TerrorEventBlueprints.dlc_portals.dlc_portals_end_escape_yard = {
		{
			"set_freeze_condition",
			max_active_enemies = 80
		},
		{
			"set_master_event_running",
			name = "dlc_portals_end_escape_yard"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_chaos_stinger"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "event_small_chaos"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard_specials",
			composition_type = "chaos_warriors"
		},
		{
			"spawn_at_raw",
			spawner_id = "onslaught_haunts_heads_portal",
			breed_name = "chaos_spawn",
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 12 and count_event_breed("chaos_fanatic") < 12
			end
		},
		{
			"event_horde",
			spawner_id = "portals_end_escape_yard",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 3 and count_event_breed("chaos_fanatic") < 3 and count_event_breed("chaos_raider") < 2
			end
		},
		{
			"delay",
			duration = {
				1,
				5
			}
		},
		{
			"flow_event",
			flow_event_name = "portals_end_escape_yard_done"
		}
	}

	-------------------
	--Blood in the Darkness

	TerrorEventBlueprints.dlc_bastion.bastion_gate_event = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "bastion_gate_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_hordes",
			enable = false
		},
		{
			"control_specials",
			enable = false 
		},
		{
			"delay",
			duration = 1
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 25 and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_ratling_gunner",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_ratling_gunner",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_poison_wind_globadier",
			spawner_id = "bastion_gate_event_special"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_large"
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_medium_shield"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_gate_event_special",
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_extra_spice_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return (count_event_breed("skaven_clan_rat") + count_event_breed("skaven_clan_rat_with_shield") < 24) and count_event_breed("skaven_slave") < 32 and count_event_breed("skaven_storm_vermin_commander") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "event_medium_shield"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "chaos_warriors"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 45,
			condition = function (t)
				return count_event_breed("skaven_plague_monk") < 14 and count_event_breed("chaos_warrior") < 1
			end
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "event_chaos_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "chaos_warriors_small"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 20 and count_event_breed("chaos_fanatic") < 22 and count_event_breed("chaos_warrior") < 10
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "chaos_warriors_small"
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "event_medium_chaos"
		},
		{
			"delay",
			duration = 7
		},
		{
			"event_horde",
			limit_spawners = 8,
			spawner_id = "bastion_gate_event_chaos",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("chaos_marauder") < 8 and count_event_breed("chaos_fanatic") < 8 and count_event_breed("chaos_warrior") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_gate_event_done"
		}
	}

	TerrorEventBlueprints.dlc_bastion.bastion_finale_event = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"disable_kick"
		},
		{
			"set_freeze_condition",
			max_active_enemies = 100
		},
		{
			"set_master_event_running",
			name = "bastion_finale_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"delay",
			duration = 10
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 22 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "nngl_bastion_vo_sorcerer_taunt"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 120,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 22 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"flow_event",
			flow_event_name = "nngl_bastion_vo_sorcerer_taunt"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_medium_shield"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 22 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_storm_vermin_with_shield") < 6
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_small"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier"
			},
			optional_data = {
				spawned_func = tzeentch_buff_spawn_function
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower"
			},
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 70,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 16 and count_event_breed("skaven_slave") < 22 and count_event_breed("skaven_storm_vermin_commander") < 3 and count_event_breed("skaven_storm_vermin_with_shield") < 6 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "nngl_bastion_vo_sorcerer_taunt"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_medium_shield"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "onslaught_plague_monks_medium"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_pack_master",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "bastion_finale_event_boss",
			breed_name = {
				"skaven_ratling_gunner",
				"skaven_warpfire_thrower",
				"skaven_poison_wind_globadier",
				"skaven_poison_wind_globadier"
			},
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_warpfire_thrower") < 3 and count_event_breed("skaven_warpfire_thrower") < 3 and count_event_breed("skaven_pack_master") < 3 and count_event_breed("skaven_poison_wind_globadier") < 3 and count_event_breed("skaven_gutter_runner") < 3
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event",
			composition_type = "storm_vermin_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 20 and count_event_breed("skaven_slave") < 28 and count_event_breed("skaven_storm_vermin_commander") < 6 and count_event_breed("skaven_storm_vermin_with_shield") < 6 and count_event_breed("skaven_plague_monk") < 8
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_vo_finale_tiring"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "nngl_bastion_vo_sorcerer_taunt"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "bastion_finale_event_boss"
		}
	}

	TerrorEventBlueprints.dlc_bastion.bastion_event_rat_ogre = {
		{
			"set_master_event_running",
			name = "bastion_event_boss"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_custom_boss_ogre"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_warrior") < 1 and count_event_breed("chaos_raider") < 1 and count_event_breed("chaos_berzerker") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_finale_event_escape"
		}
	}
	
	TerrorEventBlueprints.dlc_bastion.bastion_event_storm_fiend = {
		{
			"set_master_event_running",
			name = "bastion_event_boss"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_custom_boss_stormfiend"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_maulers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_warrior") < 1 and count_event_breed("chaos_raider") < 1 and count_event_breed("chaos_berzerker") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_finale_event_escape"
		}
	}
	
	TerrorEventBlueprints.dlc_bastion.bastion_event_chaos_spawn = {
		{
			"set_master_event_running",
			name = "bastion_event_boss"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_custom_boss_spawn"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "chaos_warriors_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_pack_master",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			breed_name = "skaven_gutter_runner",
			spawner_id = "bastion_finale_event_boss",
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_warrior") < 1 and count_event_breed("chaos_raider") < 1 and count_event_breed("chaos_berzerker") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "bastion_finale_event_escape"
		}
	}
	
		TerrorEventBlueprints.dlc_bastion.bastion_finale_event_gauntlet = {
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_stormvermin_shielders"
		},
		{
			"delay",
			duration = 2
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "storm_vermin_medium"
		},
		{
			"delay",
			duration = 7
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "bastion_finale_event_escape",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5
			end
		}
	}

	-----------------
	--Enchanter's lair

	TerrorEventBlueprints.dlc_castle.castle_catacombs_welcome_committee = {
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "event_large_chaos"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "onslaught_chaos_berzerkers_medium"
		},
		{
			"event_horde",
			spawner_id = "catacombs_welcome_committee",
			composition_type = "onslaught_chaos_berzerkers_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "catacombs_special_welcome",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "catacombs_special_welcome",
			composition_type = "chaos_warriors"
		},
		{
			"event_horde",
			spawner_id = "catacombs_special_welcome",
			composition_type = "onslaught_chaos_warriors"
		}
	}

	TerrorEventBlueprints.dlc_castle.castle_chaos_boss = {
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "castle_chaos_boss"
		},
		{
			"spawn_at_raw",
			spawner_id = "castle_chaos_boss",
			breed_name = "chaos_exalted_sorcerer_drachenfels"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("chaos_exalted_sorcerer_drachenfels") == 1
			end
		},
		{
			"flow_event",
			flow_event_name = "castle_chaos_boss_spawn"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("chaos_exalted_sorcerer_drachenfels") < 1
			end
		},
		{
			"control_specials",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "castle_chaos_boss_dead"
		}
	}

	TerrorEventBlueprints.dlc_castle.castle_catacombs_end_event_loop = {
		{
			"set_master_event_running",
			name = "escape_catacombs"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "escape_catacombs",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 18 and count_event_breed("skaven_slave") < 16
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "castle_catacombs_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.dlc_castle.castle_catacombs_end_event_loop_extra_spice = {
		{
			"set_master_event_running",
			name = "escape_catacombs"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape_spice",
			composition_type = "event_extra_spice_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape_spice",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape_spice",
			composition_type = "onslaught_storm_vermin_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "castle_catacombs_end_event_loop_extra_spice_done"
		}
	}

	HordeCompositions.chaos_event_defensive = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					45,
					51
				},
				"chaos_marauder",
				{
					21,
					23
				},
				"chaos_marauder_with_shield",
				{
					22,
					24
				},
				"chaos_berzerker",
				{
					6,
					7
				}
			}
		},
		{
			name = "wave_b",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_marauder_with_shield",
				{
					18,
					20
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
				"chaos_warrior",
				2
			}
		},
		{
			name = "wave_c",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					22,
					23
				},
				"chaos_marauder_with_shield",
				{
					20,
					22
				},
				"chaos_raider",
				{
					23,
					25
				}
			}
		},
		{
			name = "wave_d",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					15,
					17
				},
				"chaos_marauder_with_shield",
				{
					18,
					20
				},
				"chaos_berzerker",
				{
					23,
					25
				}
			}
		},
		{
			name = "wave_e",
			weight = 2,
			breeds = {
				"chaos_fanatic",
				{
					18,
					20
				},
				"chaos_marauder",
				{
					22,
					23
				},
				"chaos_marauder_with_shield",
				{
					20,
					25
				},
				"chaos_warrior",
				10
			}
		},
		end_time = 9999,
		start_time = 0
	}

	HordeCompositions.chaos_event_defensive_intense = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					45,
					51
				},
				"chaos_marauder",
				{
					25,
					27
				},
				"chaos_marauder_with_shield",
				{
					30,
					31
				},
				"chaos_berzerker",
				{
					8,
					9
				}
			}
		},
		{
			name = "wave_b",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					20,
					24
				},
				"chaos_marauder_with_shield",
				{
					30,
					32
				},
				"chaos_raider",
				{
					5,
					6
				},
				"chaos_berzerker",
				{
					5,
					6
				},
				"chaos_warrior",
				2
			}
		},
		{
			name = "wave_c",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					15,
					17
				},
				"chaos_marauder_with_shield",
				{
					20,
					22
				},
				"chaos_raider",
				{
					25,
					27
				}
			}
		},
		{
			name = "wave_d",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					22,
					24
				},
				"chaos_marauder",
				{
					20,
					22
				},
				"chaos_marauder_with_shield",
				{
					20,
					22
				},
				"chaos_berzerker",
				{
					25,
					27
				}
			}
		},
		{
			name = "wave_e",
			weight = 4,
			breeds = {
				"chaos_fanatic",
				{
					18,
					20
				},
				"chaos_marauder",
				{
					22,
					24
				},
				"chaos_marauder_with_shield",
				15,
				"chaos_warrior",
				10
			}
		},
		end_time = 9999,
		start_time = 0
	}

	HordeCompositions.chaos_event_offensive_small = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					10,
					12
				},
				"chaos_fanatic",
				{
					8,
					10
				},
				"chaos_raider",
				{
					2,
					3
				},
				"chaos_berzerker",
				{
					2,
					3
				},
				"chaos_warrior",
				1
			}
		},
		end_time = 9999,
		start_time = 0
	}

	HordeCompositions.chaos_event_offensive = {
		{
			name = "wave_a",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					25,
					30
				},
				"chaos_fanatic",
				{
					25,
					30
				},
				"chaos_berzerker",
				8
			}
		},
		{
			name = "wave_b",
			weight = 4,
			breeds = {
				"chaos_marauder",
				{
					25,
					30
				},
				"chaos_fanatic",
				{
					25,
					30
				},
				"chaos_raider",
				7
			}
		},
		end_time = 9999,
		start_time = 0
	}

	create_weights()

	mod:enable_all_hooks()

	mutator.active = true
end

mutator.stop = function()

	-- Breeds = table.clone(mutator.OriginalBreeds)	
	mod:dofile("scripts/settings/horde_compositions")
	mod:dofile("scripts/settings/horde_compositions_pacing")
	mod:dofile("scripts/settings/conflict_settings")
	mod:dofile("scripts/settings/patrol_formation_settings")
	mod:dofile("scripts/settings/terror_event_blueprints")
	mod:dofile("scripts/settings/unit_variation_settings")
	mod:dofile("scripts/managers/conflict_director/conflict_director")
	mod:dofile("scripts/managers/conflict_director/spawn_zone_baker")
	mod:dofile("scripts/managers/conflict_director/pacing")
	mod:dofile("scripts/managers/conflict_director/specials_pacing")

	---------------------

	create_weights()

	mod:disable_all_hooks()
		
	mutator.active = false
end

mutator.toggle = function()
	if Managers.state.game_mode == nil or (Managers.state.game_mode._game_mode_key ~= "inn" and Managers.player.is_server) then
		mod:echo("You must be in the keep to do that!")
		return
	end
	if Managers.matchmaking:_matchmaking_status() ~= "idle" then
		mod:echo("You must cancel matchmaking before toggling this.")
		return
	end
	if mod:get("giga_specials") then
		SpecialsSettings.default.methods.specials_by_slots = {
			max_of_same = 2,                                        
			coordinated_attack_cooldown_multiplier = 0.5,
			chance_of_coordinated_attack = 0,
			select_next_breed = "get_random_breed",
			after_safe_zone_delay = {
				5,
				20
			},
			spawn_cooldown = {
				0,
				10
			}
		}
	
		SpecialsSettings.default_light = SpecialsSettings.default
		SpecialsSettings.skaven = SpecialsSettings.default
		SpecialsSettings.skaven_light = SpecialsSettings.default
		SpecialsSettings.chaos = SpecialsSettings.default
		SpecialsSettings.chaos_light = SpecialsSettings.default
		SpecialsSettings.beastmen = SpecialsSettings.default

		local ssms = 5 
		SpecialsSettings.default.max_specials = ssms
		SpecialsSettings.default_light.max_specials = ssms
		SpecialsSettings.skaven.max_specials = ssms
		SpecialsSettings.skaven_light.max_specials = ssms
		SpecialsSettings.chaos.max_specials = ssms
		SpecialsSettings.chaos_light.max_specials = ssms
		SpecialsSettings.beastmen.max_specials = ssms
		SpecialsSettings.skaven_beastmen.max_specials = ssms
		SpecialsSettings.chaos_beastmen.max_specials = ssms

		mod:chat_broadcast("are you ok???")
		end
	if not mutator.active then
		if not Managers.player.is_server then
			mod:echo("You must be the host to activate this.")
			return
		end
		mutator.start()
		mod:chat_broadcast("Daredevil ENABLED. Note that this is NOT Linesman Onslaught and instead is the deprecated and harder version.")
	else
		mutator.stop()
		mod:chat_broadcast("Loser")
	end
end


--[[
	Callback
--]]
-- Call when game state changes (e.g. StateLoading -> StateIngame)
mod.on_game_state_changed = function(status, state)
	if not Managers.player.is_server and mutator.active and Managers.state.game_mode ~= nil then
		mutator.stop()
		mod:echo("The Daredevil mutator was disabled because you are no longer the server.")
	end
	return
end

--[[
	Execution
--]]
mod:command("daredevil", " With unwavering resolve, we shall unite to forge a righteous path, wielding the flames of justice to vanquish heresy, and cleansing this world of its putrid filth.", function() 
mutator.toggle()
if not mutator.active then
	mod:disable_all_hooks()
end
end)

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
	Breeds.skaven_dummy_clan_rat = mod.deepcopy(Breeds.skaven_ratling_gunner)
	Breeds.skaven_dummy_clan_rat.size_variation_range = { 3, 3 }
	Breeds.skaven_dummy_clan_rat.boss = true -- No WHC/Shade cheese fight this big man fair and square
	GrudgeMarkedNames.skaven = { "Bob the Builder" }
end)

mod:network_register("bob_name_disable", function (sender, enable)
	GrudgeMarkedNames.skaven = { "name_grudge_skaven_001" }
end)

mod:hook_safe("ChatManager", "_add_message_to_list", function (self, channel_id, message_sender, local_player_id, message, is_system_message, pop_chat, is_dev, message_type, link, data)
	if message == JOIN_MESSAGE and not mutator_plus.active then
		mod:network_send("rpc_enable_white_sv", "local", true)
		mod:network_send("bob_name_enable", "local", true)
	end
end)

mod.on_user_joined = function (player)
	if mutator_plus.active then
		mod:network_send("rpc_enable_white_sv", "others", true)
		mod:network_send("bob_name_enable", "others", true)
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

	-- Revert HP
	Breeds.chaos_corruptor_sorcerer.max_health = BreedTweaks.max_health.chaos_corruptor_sorcerer
	Breeds.chaos_vortex_sorcerer.max_health = BreedTweaks.max_health.chaos_vortex_sorcerer
	Breeds.skaven_warpfire_thrower.max_health = BreedTweaks.max_health.skaven_warpfire_thrower
	Breeds.skaven_poison_wind_globadier.max_health = BreedTweaks.max_health.skaven_poison_wind_globadier
	Breeds.skaven_gutter_runner.max_health = BreedTweaks.max_health.skaven_gutter_runner
	Breeds.skaven_pack_master.max_health = BreedTweaks.max_health.skaven_pack_master
	Breeds.skaven_ratling_gunner.max_health = BreedTweaks.max_health.skaven_ratling_gunner

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
			mod:chat_broadcast("Running Linesman BETA v1.3.8.1")
		else 
			mod:chat_broadcast("Version 1.3.8.1")
		end 
	else
		mutator_plus.stop()
		mod:network_send("rpc_disable_white_sv", "all", true)
		mod:network_send("bob_name_disable", "all", true)
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
