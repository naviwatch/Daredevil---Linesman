local mod = get_mod("Daredevil")

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

Breeds.skaven_dummy_clan_rat = mod.deepcopy(Breeds.skaven_plague_monk)
Breeds.skaven_dummy_clan_rat.size_variation_range = { 1, 1.2 }

Breeds.skaven_dummy_slave = mod.deepcopy(Breeds.skaven_storm_vermin)
Breeds.skaven_dummy_slave.size_variation_range = { 1.32, 1.35 }

Breeds.beastmen_gor_dummy = mod.deepcopy(Breeds.chaos_raider) 
Breeds.skaven_dummy_slave.size_variation_range = { 1.32, 1.35 }

local difficulty_start = 5 - 1 --Just change Legend and up values
local difficulties = 8 - difficulty_start --How many times to do

for i=1, difficulties do
	local i = i + difficulty_start
	Breeds.skaven_dummy_clan_rat.diff_stagger_resist[i] = 35
	Breeds.skaven_dummy_slave.diff_stagger_resist[i] = 35
	Breeds.beastmen_gor_dummy.diff_stagger_resist[i] = 33
end

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

-- Set up grudge marks
local enhancement_list = {
	["crushing"] = true,
	["raging"] = true
}

mod:hook(ConflictDirector, "spawn_queued_unit", function(func, self, breed, boxed_spawn_pos, boxed_spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, unit_data)
		if breed.name == "skaven_plague_monk" then -- plague monks
			optional_data = { enhancements = enhancement_list }
		else
			optional_data = optional_data or {}
		end

	optional_data.side_id = optional_data.side_id or self.default_enemy_side_id

	local enemy_package_loader = self.enemy_package_loader

	if not enemy_package_loader.breed_processed[breed.name] then
		local ignore_breed_limits = optional_data and optional_data.ignore_breed_limits
		local success, replacement_breed_name = enemy_package_loader:request_breed(breed.name, ignore_breed_limits, spawn_category)

		if not success then
			printf("[ConflictDirector] Replacing wanted breed (%s) with %s", breed.name, replacement_breed_name or "nil")

			breed = Breeds[replacement_breed_name]
		end
	end

	local spawn_queue = self.spawn_queue
	local spawn_index = self.first_spawn_index + self.spawn_queue_size

	self.spawn_queue_size = self.spawn_queue_size + 1
	self.spawn_queue_id = self.spawn_queue_id + 1

	local data = spawn_queue[spawn_index]

	fassert(breed, "no supplied breed")

	if data then
		data[1] = breed
		data[2] = boxed_spawn_pos
		data[3] = boxed_spawn_rot
		data[4] = spawn_category
		data[5] = spawn_animation
		data[6] = spawn_type
		data[7] = optional_data
		data[8] = group_data
		data[9] = unit_data
		data[10] = self.spawn_queue_id
	else
		data = {
			breed,
			boxed_spawn_pos,
			boxed_spawn_rot,
			spawn_category,
			spawn_animation,
			spawn_type,
			optional_data,
			group_data,
			unit_data,
			self.spawn_queue_id,
		}
		spawn_queue[spawn_index] = data
	end

	local breed_name = breed.name

	mod:echo(breed_name)

	self.num_queued_spawn_by_breed[breed_name] = self.num_queued_spawn_by_breed[breed_name] + 1

	return self.spawn_queue_id
end)

local enhancement_list = {
	["crushing"] = true,
	["raging"] = true
}

mod:hook(ConflictDirector, "_spawn_unit", function(func, self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, spawn_index)
	if breed.name == "skaven_plague_monk" then -- plague monks
		optional_data = { enhancements = enhancement_list }
	end

	return func(self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, optional_data, group_data, spawn_index)
end)


mod:hook_origin(ConflictDirector, "_post_spawn_unit", function(func, self, ai_unit, go_id, breed, spawn_pos, spawn_category, spawn_animation, optional_data, spawn_type, spawn_queue_id)
	self._spawn_queue_id_lut[spawn_queue_id] = ai_unit
	self._spawn_queue_id_lut[ai_unit] = spawn_queue_id
	if breed.name == "skaven_plague_monk" then 
		optional_data = { enhancements = sb_with_dmg_buff }
	else 
		optional_data = optional_data or {}
	end 

	local breed_name = breed.name

	Managers.state.game_mode:post_ai_spawned(ai_unit, breed, optional_data)

	local blackboard = BLACKBOARDS[ai_unit]

	blackboard.enemy_id = optional_data.spawn_queue_index

	if optional_data.enhancements then
		TerrorEventUtils.apply_breed_enhancements(ai_unit, breed, optional_data)
		mod:echo("Applying grudge mark")
	end

	Unit.set_data(ai_unit, "spawn_type", spawn_type)

	local level_settings = self.level_settings
	local climate_type = level_settings.climate_type or "default"

	Unit.set_flow_variable(ai_unit, "climate_type", climate_type)
	Unit.flow_event(ai_unit, "climate_type_set")

	if optional_data.enhancements then
		Managers.telemetry_events:ai_spawned(blackboard.enemy_id, breed.name, spawn_pos, optional_data.enhancements)
		mod:echo("Applying grudge mark 2")
	end

	blackboard.spawn_animation = spawn_animation
	blackboard.optional_spawn_data = optional_data

	local side_id = optional_data.side_id or Managers.state.side.side_by_unit[ai_unit].side_id
	local conflict_data = self._conflict_data_by_side[side_id]
	local spawned = conflict_data.spawned
	local spawned_lookup = conflict_data.spawned_lookup
	local num_spawned_ai = conflict_data.num_spawned_ai + 1

	conflict_data.num_spawned_ai = num_spawned_ai
	spawned[num_spawned_ai] = ai_unit
	spawned_lookup[ai_unit] = num_spawned_ai
	self._num_spawned_ai = self._num_spawned_ai + 1
	self._all_spawned_units[self._num_spawned_ai] = ai_unit
	self._all_spawned_units_lookup[ai_unit] = self._num_spawned_ai
	self.num_spawned_by_breed[breed_name] = self.num_spawned_by_breed[breed_name] + 1

	local num_spawned_by_breed = conflict_data.num_spawned_by_breed
	local num_spawned_by_breed_max = conflict_data.num_spawned_by_breed_max
	local spawned_units_by_breed = conflict_data.spawned_units_by_breed

	num_spawned_by_breed[breed_name] = num_spawned_by_breed[breed_name] + 1
	spawned_units_by_breed[breed_name][ai_unit] = ai_unit

	if not optional_data.ignore_event_counter and self.running_master_event then
		blackboard.master_event_id = self._master_event_id
		conflict_data.num_spawned_ai_event = conflict_data.num_spawned_ai_event + 1
		conflict_data.num_spawned_by_breed_during_event[breed_name] = conflict_data.num_spawned_by_breed_during_event[breed_name] + 1
	else
		blackboard.master_event_id = nil
	end

	Managers.state.event:trigger("ai_unit_spawned", ai_unit, breed_name, side_id, blackboard.master_event_id)

	if breed.spawn_stinger then
		local wwise_world = Managers.world:wwise_world(self._world)
		local wwise_playing_id, wwise_source_id = WwiseWorld.trigger_event(wwise_world, breed.spawn_stinger)

		Managers.state.network.network_transmit:send_rpc_clients("rpc_server_audio_event", NetworkLookup.sound_events[breed.spawn_stinger])
	end

	local locomotion_extension = blackboard.locomotion_extension

	if locomotion_extension then
		locomotion_extension:ready(go_id, blackboard)
	end

	if optional_data.spawned_func then
		optional_data.spawned_func(ai_unit, breed, optional_data)
	end

	if USE_ENGINE_SLOID_SYSTEM then
		EngineOptimized.add_static_unit_data(ai_unit, 2.2, optional_data.side_id)
	end

	if breed.boss then
		local dialogue_system = Managers.state.entity:system("dialogue_system")

		dialogue_system:trigger_mission_giver_event("vs_mg_new_spawn_monster")
	end
end)

