local mod = get_mod("Daredevil")

local menu = {
	name = "Linesman Onslaught & Daredevil",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

menu.options = {}
menu.options.widgets = {
	-- {
	-- 	setting_id    = "auto_enable_deathwish",
	-- 	type          = "checkbox",
	-- 	title		  = "auto_enable_deathwish",
	-- 	tooltip       = "auto_enable_deathwish_tooltip",
	-- 	default_value = false
	-- },
	{
		setting_id = "difficulty_level",
		type = "dropdown",
		default_value = 3,
		title = "difficulty_level",
		tooltip = "difficulty_level_tooltip",
		options = {
			{text = "level_zero", value = 0},
			{text = "level_one", value = 1},
		--	{text = "level_two", value = 2},
			{text = "level_three", value = 3},
			{text = "level_four", value = 4}
		},
	},
	{
		setting_id    = "giga_specials",
		type          = "checkbox",
		title		  = "giga_specials",
		tooltip       = "giga_specials_tooltip",
		default_value = false
	},
	{
		setting_id    = "testers",
		type          = "checkbox",
		title		  = "testers",
		tooltip       = "testers_tooltip",
		default_value = false
	},
--[[
	{
		setting_id    = "grudge",
		type          = "checkbox",
		title		  = "grudge",
		tooltip       = "grudge_tooltip",
		default_value = false
	},
	]]
	{
		setting_id    = "scaling",
		type          = "checkbox",
		title		  = "scaling",
		tooltip       = "scaling_tooltip",
		default_value = false
	},
	{
		setting_id    = "lonk",
		type          = "checkbox",
		title		  = "lonk",
		tooltip       = "lonk_tooltip",
		default_value = false
	},
	{
		setting_id    = "beta",
		type          = "checkbox",
		title		  = "beta",
		tooltip       = "beta_tooltip",
		default_value = false
	},
	{
		setting_id    = "debug",
		type          = "checkbox",
		title		  = "debug",
		tooltip       = "DEBUG_STUFF",
		default_value = false
	}
}

return menu
