return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Daredevil` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Daredevil", {
			mod_script       = "scripts/mods/Daredevil/Daredevil",
			mod_data         = "scripts/mods/Daredevil/Daredevil_data",
			mod_localization = "scripts/mods/Daredevil/Daredevil_localization",
		})
	end,
	packages = {
		"resource_packages/Daredevil/Daredevil",
	},
}
