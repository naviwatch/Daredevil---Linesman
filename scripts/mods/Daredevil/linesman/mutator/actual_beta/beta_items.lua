local mod = get_mod("Daredevil")

mod:hook(PickupSystem, "populate_pickups", function (func, self, checkpoint_data)
	if checkpoint_data then
		local checkpoint_seed = checkpoint_data.seed

		self:set_seed(checkpoint_seed)
	end

	local level_settings = LevelHelper:current_level_settings()
	local level_pickup_settings = level_settings.pickup_settings

	if not level_pickup_settings then
		Application.warning("[PickupSystem] CURRENT LEVEL HAS NO PICKUP DATA IN ITS SETTINGS, NO PICKUPS WILL SPAWN ")

		return
	end

	local difficulty_manager = Managers.state.difficulty
	local difficulty = difficulty_manager:get_difficulty()
	local level_name = Managers.level_transition_handler:get_current_level_key()
	local pickup_settings
	
	if mutator_plus.active == true then
		if level_name == "dlc_dwarf_beacons" or level_name == "nurgle" or level_name == "warcamp" or level_name == "dlc_bastion" or level_name == "forest_ambush" then
			pickup_settings = level_pickup_settings[4]
		end
	else
		pickup_settings = level_pickup_settings[difficulty]
	end


	local ignore_sections = level_settings.ignore_sections_in_pickup_spawning

	local function comparator(a, b)
		local percentage_a = Unit.get_data(a, "percentage_through_level")
		local percentage_b = Unit.get_data(b, "percentage_through_level")

		fassert(percentage_a, "Level Designer working on %s, You need to rebuild paths (pickup spawners broke)", level_settings.display_name)
		fassert(percentage_b, "Level Designer working on %s, You need to rebuild paths (pickup spawners broke)", level_settings.display_name)

		return percentage_a < percentage_b
	end

	self:spawn_guarenteed_pickups()

	local mutator_handler = Managers.state.game_mode._mutator_handler
	local primary_pickup_spawners = self.primary_pickup_spawners
	local primary_pickup_settings = pickup_settings.primary or pickup_settings

	primary_pickup_settings = mutator_handler:pickup_settings_updated_settings(primary_pickup_settings)

	self:_spawn_spread_pickups(primary_pickup_spawners, primary_pickup_settings, comparator, 1, ignore_sections)

	local secondary_pickup_spawners = self.secondary_pickup_spawners
	local secondary_pickup_settings = pickup_settings.secondary

	secondary_pickup_settings = mutator_handler:pickup_settings_updated_settings(secondary_pickup_settings)

	if secondary_pickup_settings then
		self:_spawn_spread_pickups(secondary_pickup_spawners, secondary_pickup_settings, comparator, 2, ignore_sections)
	end
	
	return func(self, checkpoint_data)
end)

