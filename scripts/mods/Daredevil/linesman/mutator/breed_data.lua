local mod = get_mod("Daredevil")

-- Taken directly from Beastmen Loader, should fix loot rat crash and if it doesnt im fucking blaming someone
--[[
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
			"chaos_plague_sorcerer",
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
			"skaven_loot_rat",
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

EnemyPackageLoaderSettings.max_loaded_breed_cap = 50
]]


--[[

mod.DEATHWISH =
{
	Off = "Off",
	On = "On"
}

mod.ONSLAUGHT = 
{
	Off = "Off",
	Onslaught = "Onslaught",
	OnslaughtPlus = "OnslaughtPlus",
	OnslaughtSquared = "OnslaughtSquared",
	SpicyOnslaught = "SpicyOnslaught",
	DutchSpice = "DutchSpice",
	DutchSpiceTourney = "DutchSpiceTourney",
	DenseOnslaught = "DenseOnslaught",
	LinesmanOnslaught = "LinesmanOnslaught"
	
	
}

mod.BEASTMENREWORK = 
{
	Off = "Off",
	On = "On"
}

mod.MAKEITHARDER =
{
	Off = "Off",
	Makeitharder = "Makeitharder",
	Morespecials = "Morespecials"
}

mod.DENSELEVEL = 
{
	Off = "Off",
	DENS_C = "DENS_C",
	DENS_0 = "DENS_0",
	DENS_1 = "DENS_1",
	DENS_2 = "DENS_2",
	DENS_3 = "DENS_3"
}

mod.LINESLEVEL = 
{
	Off = "Off",
	L1 = "L1",
	L2 = "L2",
	L3 = "L3"
}

local function is_keep(game_mode_key)
	return game_mode_key == "inn" or game_mode_key == "inn_deus"
end


local deathwish_mod_name = "catas"
local onslaught_mod_name = "Onslaught"
local onslaughtplus_mod_name = "OnslaughtPlus"
local spicyonslaught_mod_name = "SpicyOnslaught"
local dutchspice_mod_name = "DutchSpice"
local dutch_mod_name = "DutchSpiceTourney"
local denseonslaught_mod_name = "Dense Onslaught"
local linesmanonslaught_mod_name = "Daredevil"

local mutator_state_sync = "mutator_state_sync"

mod.mod_mutator_state = {
	deathwish = mod.DEATHWISH.Off,
	onslaught = mod.ONSLAUGHT.Off,
	beastmenrework = mod.BEASTMENREWORK.Off,
	makeitharder = mod.MAKEITHARDER.Off,
	DENSELEVEL = mod.DENSELEVEL.Off,
	LINESLEVEL = mod.LINESLEVEL.Off
}

local function is_mod_mutator_enabled(mod_name, mutator_name)
  local other_mod = get_mod(mod_name)
  local mod_is_enabled = false
  local mutator_is_enabled = false
  if other_mod then
    local omutator = other_mod:persistent_table(mutator_name)
    mod_is_enabled = other_mod:is_enabled()
    mutator_is_enabled = omutator.active
  end
  return mod_is_enabled and mutator_is_enabled
end

local vbm_deathwish_mod_name = "Vermintide Balance Manager"
local function is_deathwish_enabled()
    return is_mod_mutator_enabled(deathwish_mod_name, deathwish_mod_name) or is_mod_mutator_enabled(vbm_deathwish_mod_name, deathwish_mod_name)
end

local function is_onslaught_enabled()
	return is_mod_mutator_enabled(onslaught_mod_name, onslaught_mod_name)
end

local function is_onslaughtplus_enabled()
	return is_mod_mutator_enabled(onslaughtplus_mod_name, onslaughtplus_mod_name)
end

local function is_onslaughtsquared_enabled()
	return is_mod_mutator_enabled(onslaughtplus_mod_name, "OnslaughtSquared")
end

local function is_makeitharder_enabled()
	return is_mod_mutator_enabled(onslaughtplus_mod_name, "EnhancedDifficulty")
end

local function is_morespecials_enabled()
	return is_mod_mutator_enabled(onslaughtplus_mod_name, "MoreSpecials")
end

local function is_beastmenrebalance_enabled()
	return is_mod_mutator_enabled(onslaughtplus_mod_name, "BeastmenRework")
end

local function is_spicyonslaught_enabled()
	return is_mod_mutator_enabled(spicyonslaught_mod_name, "SpicyOnslaught")
end

local function is_dutchspice_enabled()
	return is_mod_mutator_enabled(dutchspice_mod_name, "DutchSpice")
end

local function is_dutch_enabled()
	return is_mod_mutator_enabled(dutch_mod_name, "DutchSpiceTourney")
end

local function is_dense_enabled()
	return is_mod_mutator_enabled(denseonslaught_mod_name, "Dense Onslaught")
end

local function is_lines_enabled()
	return is_mod_mutator_enabled(linesmanonslaught_mod_name, "Daredevil")
end


local function get_deathwish()
	if is_deathwish_enabled() then
		return mod.DEATHWISH.On
	end
	return mod.DEATHWISH.Off
end

local function get_onslaught()
	if is_onslaught_enabled() then
		return mod.ONSLAUGHT.Onslaught
	elseif is_onslaughtplus_enabled() then
		return mod.ONSLAUGHT.OnslaughtPlus
	elseif is_onslaughtsquared_enabled() then
		return mod.ONSLAUGHT.OnslaughtSquared
	elseif is_spicyonslaught_enabled() then
		return mod.ONSLAUGHT.SpicyOnslaught
	elseif is_dutchspice_enabled() then
		return mod.ONSLAUGHT.DutchSpice
	elseif is_dutch_enabled() then
		return mod.ONSLAUGHT.DutchSpiceTourney
	elseif is_dense_enabled() then
		return mod.ONSLAUGHT.DenseOnslaught
	elseif is_lines_enabled then 
		return mod.ONSLAUGHT.LinesmanOnslaught
	end
	return mod.ONSLAUGHT.Off
end

local function get_beastmenrework()
	if is_beastmenrebalance_enabled() then
		return mod.BEASTMENREWORK.On
	end
	return mod.BEASTMENREWORK.Off
end

local function get_makeitharder()
	if is_makeitharder_enabled() then
		return mod.MAKEITHARDER.Makeitharder
	elseif is_morespecials_enabled() then
		return mod.MAKEITHARDER.Morespecials
	end
	return mod.MAKEITHARDER.Off
end

local function get_denselevel()
	if is_dense_enabled() then
		local dense_ons = get_mod("Dense Onslaught")
		if dense_ons then
			local dense_ons_level = dense_ons:get("difficulty_level")
			if dense_ons_level then
				if dense_ons_level == 1 then
					return mod.DENSELEVEL.DENS_1
				elseif dense_ons_level == 2 then
					return mod.DENSELEVEL.DENS_2
				elseif dense_ons_level == 3 then
					return mod.DENSELEVEL.DENS_3
				elseif dense_ons_level == "ons_remastered" then
					return mod.DENSELEVEL.DENS_0
				elseif dense_ons_level == "custom" then
					return mod.DENSELEVEL.DENS_C
				end
			else
				return mod.DENSELEVEL.Off
			end
		else
			return mod.DENSELEVEL.Off
		end
	else
		return mod.DENSELEVEL.Off
	end
end

local function get_lineslevel()
	if is_lines_enabled() then
		local lines_ons = get_mod("Daredevil")
		if lines_ons then
			local lines_ons_level = lines_ons:get("difficulty_level")
			if lines_ons_level then
				if lines_ons_level == 1 then
					return mod.LINESLEVEL.L1
				elseif lines_ons_level == 2 then
					return mod.LINESLEVEL.L2
				elseif lines_ons_level == 3 then
					return mod.LINESLEVEL.L3
				end
			else
				return mod.LINESLEVEL.Off
			end
		else
			return mod.LINESLEVEL.Off
		end
	else
		return mod.LINESLEVEL.Off
	end
end


local function set_local_mod_mutator_state()
	--mod.mod_mutator_state.deathwish = get_deathwish()
	--mod.mod_mutator_state.onslaught = get_onslaught()
	--mod.mod_mutator_state.beastmenrework = get_beastmenrework()
	--mod.mod_mutator_state.makeitharder = get_makeitharder()
	--mod.mod_mutator_state.denselevel = get_denselevel()
	mod.mod_mutator_state.lineslevel = get_lineslevel()
end

local function reset_local_mod_mutator_state()
	--mod.mod_mutator_state.deathwish = mod.DEATHWISH.Off
	--mod.mod_mutator_state.onslaught = mod.ONSLAUGHT.Off
	--mod.mod_mutator_state.beastmenrework = mod.BEASTMENREWORK.Off
	--mod.mod_mutator_state.makeitharder = mod.MAKEITHARDER.Off
	--mod.mod_mutator_state.denselevel = mod.DENSELEVEL.Off
	mod.mod_mutator_state.lineslevel = mod.LINESLEVEL.Off
end

local function sync_mod_mutator_state()
	set_local_mod_mutator_state()
	
	mod:network_send(mutator_state_sync, "others", {
		--deathwish = mod.mod_mutator_state.deathwish,
		--onslaught = mod.mod_mutator_state.onslaught,
		--beastmenrework = mod.mod_mutator_state.beastmenrework,
		--makeitharder = mod.mod_mutator_state.makeitharder,
		--denselevel = mod.mod_mutator_state.denselevel,
		lineslevel = mod.mod_mutator_state.lineslevel
	})
end

mod.on_user_joined = function(player)
	if Managers.state.game_mode.is_server then
		sync_mod_mutator_state()
	end	
end
	
mod:network_register(mutator_state_sync, function(sender, data)
	mod.mod_mutator_state.deathwish = data.deathwish
	mod.mod_mutator_state.onslaught = data.onslaught
	mod.mod_mutator_state.beastmenrework = data.beastmenrework
	mod.mod_mutator_state.makeitharder = data.makeitharder
	-- mod.mod_mutator_state.denselevel = data.denselevel
	-- mod.mod_mutator_state.lineslevel = data.lineslevel -- i dont know if this is even useful and i dont know what this does ice pls help
end)

mod.on_game_state_changed = function(status, state_name)
	if status == "enter" and state_name == "StateIngame" then
		
		local game_mode_key = Managers.state.game_mode:game_mode_key()
		
		-- Don't start recording for the keep
		if (not game_mode_key) or is_keep(game_mode_key) then
			-- Reset our mod mutator state data when we return to the keep
			reset_local_mod_mutator_state()
			return
		end
	elseif status == "exit" and state_name == "StateIngame" then
		-- Sync mutator state to clients if we're the server and we're starting a new game
		local game_mode_key = Managers.state.game_mode:game_mode_key()
		if is_keep(game_mode_key) then
			if Managers.state and Managers.state.game_mode and Managers.state.game_mode.is_server then
				sync_mod_mutator_state()
			end
		end
	end

end

mod:hook(IngamePlayerListUI, "_update_difficulty", function (func, self)
	local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
	local base_difficulty_name = difficulty_settings.display_name
	-- local deathwish_enabled = get_mod("catas") and Managers.vmf.persistent_tables.catas.catas.active
	-- local difficulty_name = deathwish_enabled and base_difficulty_name .. "_DwonsPlus" or base_difficulty_name .. "_OnslaughtPlus"

	if mod.mod_mutator_state.onslaught == "LinesmanOnslaught" then
		if mod.mod_mutator_state.lineslevel == "L1" then
			if mod.mod_mutator_state.deathwish == "On" then
				self:_set_difficulty_name("[PLUS] " .. Localize(base_difficulty_name) .. " DW Linesman")
			else
				self:_set_difficulty_name("[PLUS] " .. Localize(base_difficulty_name) .. " Linesman")
			end	
		elseif mod.mod_mutator_state.lineslevel == "L2" then
			if mod.mod_mutator_state.deathwish == "On" then
				self:_set_difficulty_name("[DUTCH] " .. Localize(base_difficulty_name) .. " DW Linesman")
			else
				self:_set_difficulty_name("[DUTCH] " .. Localize(base_difficulty_name) .. " Linesman")
			end	
		elseif mod.mod_mutator_state.lineslevel == "L3" then
			if mod.mod_mutator_state.deathwish == "On" then
				self:_set_difficulty_name("[DEFAULT] " .. Localize(base_difficulty_name) .. " DW Linesman")
			else
				self:_set_difficulty_name("[DEFAULT] " .. Localize(base_difficulty_name) .. " Linesman")
			end
		end
	else
		return func(self)
	end	
end)

mod:hook(Presence, "set_presence", function(func, key, value)


local deathwish_enabled = get_mod("catas") and Managers.vmf.persistent_tables.catas.catas.active
	if value == "#presence_modded" then
		func(key, "#presence_modded_difficulty")
	  elseif key == "difficulty" then
		if mod.mod_mutator_state.onslaught == "LinesmanOnslaught" and mod.mod_mutator_state.deathwish == "Off" then
			if mod.mod_mutator_state.lineslevel == "L1" then
				if value == "cataclysm_3" then
					func(key, "[PLUS] C3 Linesman")
				elseif value == "cataclysm" then
					func(key, "[PLUS] C1 Linesman")
				else
					func(key, "[PLUS] DELI HAM ONLY FOR 1.99") -- yes
				end	
			elseif mod.mod_mutator_state.lineslevel == "L2" then
				if value == "cataclysm_3" then
					func(key, "[DUTCH] C3 Linesman")
				elseif value == "cataclysm" then
					func(key, "[DUTCH] C1 Linesman")
				else
					func(key, "[DUTCH] DELI HAM ONLY FOR 2.99")
				end	
			elseif mod.mod_mutator_state.lineslevel == "L3" then
				if value == "cataclysm_3" then
					func(key, "[DEFAULT] C3 Linesman")
				elseif value == "cataclysm" then
					func(key, "[DEFAULT] C1 Linesman")
				else
					func(key, "[DEFAULT] DELI HAM ONLY FOR 3.99")
				end	
			end 
		elseif mod.mod_mutator_state.onslaught == "LinesmanOnslaught" and mod.mod_mutator_state.deathwish == "On" then
			if mod.mod_mutator_state.lineslevel == "L1" then
				if value == "cataclysm_3" then
					func(key, "[PLUS] C3 Linesman Deathwish")
				elseif value == "cataclysm" then
					func(key, "[PLUS] C1 DELI HAM (80% OFF) BUY ONE GET ONE FREE")
				else
					func(key, "[PLUS] DELI HAM 80% OFF")
				end	
			elseif mod.mod_mutator_state.lineslevel == "L2" then
				if value == "cataclysm_3" then
					func(key, "[DUTCH] C3 Linesman Deathwish")
				elseif value == "cataclysm" then
					func(key, "[DUTCH] C1 DELI HAM (80% OFF) BUY ONE GET ONE FREE")
				else
					func(key, "[DUTCH] DELI HAM 80% OFF")
				end	
			elseif mod.mod_mutator_state.lineslevel == "L3" then
				if value == "cataclysm_3" then
					func(key, "[DEFAULT] C3 Linesman Deathwish")
				elseif value == "cataclysm" then
					func(key, "[DEFAULT] C1 DELI HAM (80% OFF) BUY ONE GET ONE FREE")
				else
					func(key, "[DEFAULT] DELI HAM 80% OFF")
				end	
			end
		else
			return func(key, value)
		end	
	else
	func(key, value)
  end
end)

	
]]