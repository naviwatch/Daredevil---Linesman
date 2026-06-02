local mod = get_mod("Daredevil")

local menu = {
	name = "Linesman Onslaught & Daredevil",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

menu.options = {}
menu.options.widgets = {
	{
		setting_id = "difficulty_level",
		type = "dropdown",
		default_value = 3,
		title = "difficulty_level",
		tooltip = "difficulty_level_tooltip",
		options = {
			{ text = "level_zero",  value = 0 },
			{ text = "level_one",   value = 1 },
			--	{text = "level_two", value = 2},
			{ text = "level_three", value = 3 },
			{ text = "level_four",  value = 4 }
		},
	},
	{
		setting_id = "mutators",
		type = "group",
		title = "mutators_title",
		tooltip = "mutators_tooltip",
		sub_widgets = {
			{
				setting_id    = "giga_specials",
				type          = "checkbox",
				title         = "giga_specials",
				tooltip       = "giga_specials_tooltip",
				default_value = false
			},
			{
				setting_id    = "testers",
				type          = "checkbox",
				title         = "testers",
				tooltip       = "testers_tooltip",
				default_value = false
			},
			--[[
			{
				setting_id    = "lonk",
				type          = "checkbox",
				title         = "lonk",
				tooltip       = "lonk_tooltip",
				default_value = false
			},
			]]
			{
				setting_id    = "ubercharge",
				type          = "checkbox",
				title         = "ubercharge",
				tooltip       = "ubercharge_tooltip",
				default_value = false
			},
			{
				setting_id    = "midmonster",
				type          = "checkbox",
				title         = "midmonster",
				tooltip       = "midmonster_tooltip",
				default_value = false
			},
			{
				setting_id    = "btmp",
				type          = "checkbox",
				title         = "btmp",
				tooltip       = "btmp_tooltip",
				default_value = false
			},
		},
	},
	{
		setting_id = "debug_stuff",
		type = "group",
		title = "debug_stuff_title",
		sub_widgets = {
			{
				setting_id    = "scaling",
				type          = "checkbox",
				title		  = "scaling",
				tooltip       = "scaling_tooltip",
				default_value = false
			},
			{
				setting_id    = "beta",
				type          = "checkbox",
				title         = "beta",
				tooltip       = "beta_tooltip",
				default_value = false
			},
			{
				setting_id    = "debug",
				type          = "checkbox",
				title         = "debug",
				tooltip       = "DEBUG_STUFF",
				default_value = false
			}
		},
	},
}
return menu