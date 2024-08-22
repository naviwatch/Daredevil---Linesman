local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
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
	LINES_1 = "LINES_1",
	LINES_2 = "LINES_2",
	LINES_3 = "LINES_3",
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
local linesonslaught_mod_name = "Daredevil"

local mutator_state_sync = "mutator_state_sync"

mod.mod_mutator_state = {
	deathwish = mod.DEATHWISH.Off,
	onslaught = mod.ONSLAUGHT.Off,
	beastmenrework = mod.BEASTMENREWORK.Off,
	makeitharder = mod.MAKEITHARDER.Off,
	DENSELEVEL = mod.DENSELEVEL.Off,
--    LINESLEVEL = mod.LINESLEVEL.Off
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

local function is_deathwish_enabled()
	return is_mod_mutator_enabled(deathwish_mod_name, deathwish_mod_name)
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
    return is_mod_mutator_enabled(linesonslaught_mod_name, "Daredevil+")
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
    elseif is_lines_enabled() then
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

--[[
local function get_lineslevel()
	if is_lines_enabled() then
		local lines_ons = get_mod("Daredevil")
		if lines_ons then
			local lines_ons_level = lines_ons:get("difficulty_level")
			if lines_ons_level then
				if lines_ons_level == 1 then
					return mod.LINESLEVEL.LINES_1
				elseif lines_ons_level == 2 then
					return mod.LINESLEVEL.LINES_2
				elseif lines_ons_level == 3 then
					return mod.LINESLEVEL.LINES_3
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
]]


local function set_local_mod_mutator_state()
	mod.mod_mutator_state.deathwish = get_deathwish()
	mod.mod_mutator_state.onslaught = get_onslaught()
	mod.mod_mutator_state.beastmenrework = get_beastmenrework()
	mod.mod_mutator_state.makeitharder = get_makeitharder()
	mod.mod_mutator_state.denselevel = get_denselevel()
--    mod.mod_mutator_state.lineslevel = get_lineslevel()
end

local function reset_local_mod_mutator_state()
	mod.mod_mutator_state.deathwish = mod.DEATHWISH.Off
	mod.mod_mutator_state.onslaught = mod.ONSLAUGHT.Off
	mod.mod_mutator_state.beastmenrework = mod.BEASTMENREWORK.Off
	mod.mod_mutator_state.makeitharder = mod.MAKEITHARDER.Off
	mod.mod_mutator_state.denselevel = mod.DENSELEVEL.Off
 --   mod.mod_mutator_state.lineslevel = mod.LINESLEVEL.Off
end

local function sync_mod_mutator_state()
	set_local_mod_mutator_state()
	
	mod:network_send(mutator_state_sync, "others", {
		deathwish = mod.mod_mutator_state.deathwish,
		onslaught = mod.mod_mutator_state.onslaught,
		beastmenrework = mod.mod_mutator_state.beastmenrework,
		makeitharder = mod.mod_mutator_state.makeitharder,
		denselevel = mod.mod_mutator_state.denselevel,
   --     lineslevel = mod.mod_mutator_state.lineslevel
	})
end
	

mod:network_register(mutator_state_sync, function(sender, data)
	mod.mod_mutator_state.deathwish = data.deathwish
	mod.mod_mutator_state.onslaught = data.onslaught
	mod.mod_mutator_state.beastmenrework = data.beastmenrework
	mod.mod_mutator_state.makeitharder = data.makeitharder
	-- mod.mod_mutator_state.denselevel = data.denselevel
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

	if mod.mod_mutator_state.onslaught == "Onslaught" then
		if mod.mod_mutator_state.deathwish == "On" then
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Dwons")
		else
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Onslaught")
		end
	elseif mod.mod_mutator_state.onslaught == "OnslaughtPlus" then
		if mod.mod_mutator_state.deathwish == "On" then
			if mod.mod_mutator_state.beastmenrework == "On" then
				if (mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials") then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " DwonsPlus+ (BR)")
				else 
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " DwonsPlus (BR)")
				end
			else
				if (mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials") then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " DwonsPlus+")
				else 
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " DwonsPlus")
				end
			end	
		else
			if mod.mod_mutator_state.beastmenrework == "On" then
				if (mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials") then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " OnslaughtPlus+ (BR)")
				else 
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " OnslaughtPlus (BR)")
				end
			else
				if (mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials") then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " OnslaughtPlus+")
				else 
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " OnslaughtPlus")
				end
			end	
		end
	elseif mod.mod_mutator_state.onslaught == "OnslaughtSquared" then
		if mod.mod_mutator_state.deathwish == "On" then
			if mod.mod_mutator_state.beastmenrework == "On" then
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " DwonsSquared+ (BR)")
				else 
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " DwonsSquared (BR)")
				end
			else
				if (mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials") then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " DwonsSquared+")
				else 
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " DwonsSquared")
				end
			end	
		else
			if mod.mod_mutator_state.beastmenrework == "On" then
				if (mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials") then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " OnslaughtSquared+ (BR)")
				else 
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " OnslaughtSquared (BR)")
				end
			else
				if (mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials") then
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " OnslaughtSquared+")
				else 
					self:_set_difficulty_name(Localize(base_difficulty_name) .. " OnslaughtSquared")
				end
			end	
		end
	elseif 	mod.mod_mutator_state.onslaught == "DutchSpice" then
		if mod.mod_mutator_state.deathwish == "On" then
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Something Spicy")
		else
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Something Mild")
		end
	elseif 	mod.mod_mutator_state.onslaught == "DutchSpiceTourney" then
		if mod.mod_mutator_state.deathwish == "On" then
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Dwutch")
		else
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Dutch")
		end	
	elseif 	mod.mod_mutator_state.onslaught == "SpicyOnslaught" then
		if mod.mod_mutator_state.deathwish == "On" then
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Something Extra Spicy")
		else
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Something Extra Mild")
		end	
	elseif mod.mod_mutator_state.onslaught == "DenseOnslaught" then
		if mod.mod_mutator_state.denselevel == "DENS_1" then
			if mod.mod_mutator_state.deathwish == "On" then
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " D1 DWONS")
			else
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " D1 Onslaught")
			end	
		elseif mod.mod_mutator_state.denselevel == "DENS_2" then
			if mod.mod_mutator_state.deathwish == "On" then
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " D2 DWONS")
			else
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " D2 Onslaught")
			end	
		elseif mod.mod_mutator_state.denselevel == "DENS_3" then
			if mod.mod_mutator_state.deathwish == "On" then
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " D3 DWONS")
			else
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " D3 Onslaught")
			end
		elseif mod.mod_mutator_state.denselevel == "DENS_0" then
			if mod.mod_mutator_state.deathwish == "On" then
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " D0 DWONS")
			else
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " D0 Onslaught")
			end
		elseif mod.mod_mutator_state.denselevel == "DENS_C" then
			if mod.mod_mutator_state.deathwish == "On" then
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " Dn DWONS")
			else
				self:_set_difficulty_name(Localize(base_difficulty_name) .. " Dn Onslaught")
			end
		end
	elseif 	mod.mod_mutator_state.onslaught == "LinesmanOnslaught" then
		if mod.mod_mutator_state.deathwish == "On" then
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Deathman Onslaught")
		else
			self:_set_difficulty_name(Localize(base_difficulty_name) .. " Linesman Onslaught")
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
		if mod.mod_mutator_state.onslaught == "OnslaughtPlus" and mod.mod_mutator_state.deathwish == "Off" then
			if mod.mod_mutator_state.beastmenrework == "On" then
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					if value == "cataclysm_3" then
						func(key, "C3 OnslaughtPlus+ (BR)")
					elseif value == "cataclysm" then
						func(key, "C1 OnslaughtPlus+ (BR)")
					else
						func(key, "OnslaughtPlus+ (BR)")
					end	
				else
					if value == "cataclysm_3" then
						func(key, "C3 OnslaughtPlus (BR)")
					elseif value == "cataclysm" then
						func(key, "C1 OnslaughtPlus (BR)")
					else
						func(key, "OnslaughtPlus (BR)")
					end	
				end
			else
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					if value == "cataclysm_3" then
						func(key, "C3 OnslaughtPlus+")
					elseif value == "cataclysm" then
						func(key, "C1 OnslaughtPlus+")
					else
						func(key, "OnslaughtPlus+")
					end	
				else
					if value == "cataclysm_3" then
						func(key, "C3 OnslaughtPlus")
					elseif value == "cataclysm" then
						func(key, "C1 OnslaughtPlus")
					else
						func(key, "OnslaughtPlus")
					end	
				end
			end
		elseif mod.mod_mutator_state.onslaught == "OnslaughtSquared" and mod.mod_mutator_state.deathwish == "Off" then 
			if mod.mod_mutator_state.beastmenrework == "On" then
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					if value == "cataclysm_3" then
						func(key, "C3 OnslaughtSquared+ (BR)")
					elseif value == "cataclysm" then
						func(key, "C1 OnslaughtSquared+ (BR)")
					else
						func(key, "OnslaughtSquared+ (BR)")
					end	
				else
					if value == "cataclysm_3" then
						func(key, "C3 OnslaughtSquared (BR)")
					elseif value == "cataclysm" then
						func(key, "C1 OnslaughtSquared (BR)")
					else
						func(key, "OnslaughtSquared (BR)")
					end	
				end
			else
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					if value == "cataclysm_3" then
						func(key, "C3 OnslaughtSquared+")
					elseif value == "cataclysm" then
						func(key, "C1 OnslaughtSquared+")
					else
						func(key, "OnslaughtSquared+")
					end	
				else
					if value == "cataclysm_3" then
						func(key, "C3 OnslaughtSquared")
					elseif value == "cataclysm" then
						func(key, "C1 OnslaughtSquared")
					else
						func(key, "OnslaughtSquared")
					end	
				end
			end
		elseif mod.mod_mutator_state.onslaught == "OnslaughtPlus" and mod.mod_mutator_state.deathwish == "On" then
			if mod.mod_mutator_state.beastmenrework == "On" then
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					if value == "cataclysm_3" then
						func(key, "C3 DwonsPlus+ (BR)")
					elseif value == "cataclysm" then
						func(key, "C1 DwonsPlus+ (BR)")
					else
						func(key, "DwonsPlus+ (BR)")
					end	
				else
					if value == "cataclysm_3" then
						func(key, "C3 DwonsPlus (BR)")
					elseif value == "cataclysm" then
						func(key, "C1 DwonsPlus (BR)")
					else
						func(key, "DwonsPlus (BR)")
					end	
				end
			else
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					if value == "cataclysm_3" then
						func(key, "C3 DwonsPlus+")
					elseif value == "cataclysm" then
						func(key, "C1 DwonsPlus+")
					else
						func(key, "DwonsPlus+")
					end	
				else
					if value == "cataclysm_3" then
						func(key, "C3 DwonsPlus")
					elseif value == "cataclysm" then
						func(key, "C1 DwonsPlus")
					else
						func(key, "DwonsPlus")
					end	
				end
			end
		elseif mod.mod_mutator_state.onslaught == "OnslaughtSquared" and mod.mod_mutator_state.deathwish == "On" then
			if mod.mod_mutator_state.beastmenrework == "On" then
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					if value == "cataclysm_3" then
						func(key, "C3 DwonsSquared+ (BR)")
					elseif value == "cataclysm" then
						func(key, "C1 DwonsSquared+ (BR)")
					else
						func(key, "DwonsSquared+ (BR)")
					end	
				else
					if value == "cataclysm_3" then
						func(key, "C3 DwonsSquared (BR)")
					elseif value == "cataclysm" then
						func(key, "C1 DwonsSquared (BR)")
					else
						func(key, "DwonsSquared (BR)")
					end	
				end
			else
				if mod.mod_mutator_state.makeitharder == "Makeitharder" or mod.mod_mutator_state.makeitharder == "Morespecials" then
					if value == "cataclysm_3" then
						func(key, "C3 DwonsSquared+")
					elseif value == "cataclysm" then
						func(key, "C1 DwonsSquared+")
					else
						func(key, "DwonsSquared+")
					end	
				else
					if value == "cataclysm_3" then
						func(key, "C3 DwonsSquared")
					elseif value == "cataclysm" then
						func(key, "C1 DwonsSquared")
					else
						func(key, "DwonsSquared")
					end	
				end
			end
		elseif mod.mod_mutator_state.onslaught == "Onslaught" and mod.mod_mutator_state.deathwish == "Off" then
			if value == "cataclysm_3" then
				func(key, "C3 Onslaught")
			elseif value == "cataclysm" then
				func(key, "C1 Onslaught")
			else
				func(key, "Onslaught")
			end
		elseif mod.mod_mutator_state.onslaught == "Onslaught" and mod.mod_mutator_state.deathwish == "On" then
			if value == "cataclysm_3" then
				func(key, "C3 Dwons")
			elseif value == "cataclysm" then
				func(key, "C1 Dwons")
			else
				func(key, "Dwons")
			end
		elseif mod.mod_mutator_state.onslaught == "DutchSpice" and mod.mod_mutator_state.deathwish == "Off" then
			if value == "cataclysm_3" then
				func(key, "C3 Something Mild")
			elseif value == "cataclysm" then
				func(key, "C1 Something Mild")
			else
				func(key, "Something Mild")
			end
		elseif mod.mod_mutator_state.onslaught == "DutchSpice" and mod.mod_mutator_state.deathwish == "On" then
			if value == "cataclysm_3" then
				func(key, "C3 Something Spicy")
			elseif value == "cataclysm" then
				func(key, "C1 Something Spicy")
			else
				func(key, "Something Spicy")
			end	
		elseif mod.mod_mutator_state.onslaught == "DutchSpiceTourney" and mod.mod_mutator_state.deathwish == "Off" then
			if value == "cataclysm_3" then
				func(key, "C3 Dutch")
			elseif value == "cataclysm" then
				func(key, "C1 Dutch")
			else
				func(key, "Dutch")
			end
		elseif mod.mod_mutator_state.onslaught == "DutchSpiceTourney" and mod.mod_mutator_state.deathwish == "On" then
			if value == "cataclysm_3" then
				func(key, "C3 Dwutch")
			elseif value == "cataclysm" then
				func(key, "C1 Dwutch")
			else
				func(key, "Dwutch")
			end		
		elseif mod.mod_mutator_state.onslaught == "SpicyOnslaught" and mod.mod_mutator_state.deathwish == "Off" then
			if value == "cataclysm_3" then
				func(key, "C3 Something Extra Mild")
			elseif value == "cataclysm" then
				func(key, "C1 Something Extra Mild")
			else
				func(key, "Something Extra Mild")
			end	
		elseif mod.mod_mutator_state.onslaught == "SpicyOnslaught" and mod.mod_mutator_state.deathwish == "On" then
			if value == "cataclysm_3" then
				func(key, "C3 Something Extra Spicy")
			elseif value == "cataclysm" then
				func(key, "C1 Something Extra Spicy")
			else
				func(key, "Something Extra Spicy")
			end		
		elseif mod.mod_mutator_state.onslaught == "DenseOnslaught" and mod.mod_mutator_state.deathwish == "Off" then
			if mod.mod_mutator_state.denselevel == "DENS_1" then
				if value == "cataclysm_3" then
					func(key, "C3 D1 Onslaught")
				elseif value == "cataclysm" then
					func(key, "C1 D1 Onslaught")
				else
					func(key, "D1 Onslaught")
				end	
			elseif mod.mod_mutator_state.denselevel == "DENS_2" then
				if value == "cataclysm_3" then
					func(key, "C3 D2 Onslaught")
				elseif value == "cataclysm" then
					func(key, "C1 D2 Onslaught")
				else
					func(key, "D2 Onslaught")
				end	
			elseif mod.mod_mutator_state.denselevel == "DENS_3" then
				if value == "cataclysm_3" then
					func(key, "C3 D3 Onslaught")
				elseif value == "cataclysm" then
					func(key, "C1 D3 Onslaught")
				else
					func(key, "D3 Onslaught")
				end	
			elseif mod.mod_mutator_state.denselevel == "DENS_0" then
				if value == "cataclysm_3" then
					func(key, "C3 D0 Onslaught")
				elseif value == "cataclysm" then
					func(key, "C1 D0 Onslaught")
				else
					func(key, "D0 Onslaught")
				end
			elseif mod.mod_mutator_state.denselevel == "DENS_C" then
				if value == "cataclysm_3" then
					func(key, "C3 Dn Onslaught")
				elseif value == "cataclysm" then
					func(key, "C1 Dn Onslaught")
				else
					func(key, "Dn Onslaught")
				end
			end
		elseif mod.mod_mutator_state.onslaught == "DenseOnslaught" and mod.mod_mutator_state.deathwish == "On" then
			if mod.mod_mutator_state.denselevel == "DENS_1" then
				if value == "cataclysm_3" then
					func(key, "C3 D1 DWONS")
				elseif value == "cataclysm" then
					func(key, "C1 D1 DWONS")
				else
					func(key, "D1 DWONS")
				end	
			elseif mod.mod_mutator_state.denselevel == "DENS_2" then
				if value == "cataclysm_3" then
					func(key, "C3 D2 DWONS")
				elseif value == "cataclysm" then
					func(key, "C1 D2 DWONS")
				else
					func(key, "D2 DWONS")
				end	
			elseif mod.mod_mutator_state.denselevel == "DENS_3" then
				if value == "cataclysm_3" then
					func(key, "C3 D3 DWONS")
				elseif value == "cataclysm" then
					func(key, "C1 D3 DWONS")
				else
					func(key, "D3 DWONS")
				end	
			elseif mod.mod_mutator_state.denselevel == "DENS_0" then
				if value == "cataclysm_3" then
					func(key, "C3 D0 Onslaught")
				elseif value == "cataclysm" then
					func(key, "C1 D0 Onslaught")
				else
					func(key, "D0 Onslaught")
				end
			elseif mod.mod_mutator_state.denselevel == "DENS_C" then
				if value == "cataclysm_3" then
					func(key, "C3 Dn DWONS")
				elseif value == "cataclysm" then
					func(key, "C1 Dn DWONS")
				else
					func(key, "Dn DWONS")
				end
			end
		elseif mod.mod_mutator_state.onslaught == "LinesmanOnslaught" and mod.mod_mutator_state.deathwish == "Off" then
			if value == "cataclysm_3" then
				func(key, "C3 Linesman Onslaught")
			elseif value == "cataclysm" then
				func(key, "C1 Linesman Onslaught")
			else
				func(key, "Linesman Onslaught")
			end	
		elseif mod.mod_mutator_state.onslaught == "LinesmanOnslaught" and mod.mod_mutator_state.deathwish == "On" then
			if value == "cataclysm_3" then
				func(key, "C3 Deathman Onslaught")
			elseif value == "cataclysm" then
				func(key, "C1 Ryan Gosling")
			else
				func(key, "Deathman Onslaught")
			end	
        else
			return func(key, value)
		end	
	else
	func(key, value)
  end
end)

	
