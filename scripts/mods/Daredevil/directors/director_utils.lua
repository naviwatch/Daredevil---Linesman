local mod = get_mod("Daredevil")

DirectorUtils = {}

ConflictDirectors = ConflictDirectors or {}

DirectorUtils.add_new_ConflictDirector = function (name)
    ConflictDirectors[name] = {
        name = name,
        debug_color = "green",
        disabled = false,
        intensity = mod:dofile("scripts/mods/Daredevil/directors/"..name.."/intensity_settings"),
        pacing = mod:dofile("scripts/mods/Daredevil/directors/"..name.."/pacing_settings"),
        boss = mod:dofile("scripts/mods/Daredevil/directors/"..name.."/boss_settings"),
        specials = mod:dofile("scripts/mods/Daredevil/directors/"..name.."/special_settings"),
        roaming = mod:dofile("scripts/mods/Daredevil/directors/"..name.."/roaming_settings"),
        pack_spawning = mod:dofile("scripts/mods/Daredevil/directors/"..name.."/packspawn_settings"),
        horde = mod:dofile("scripts/mods/Daredevil/directors/"..name.."/horde_settings"),
        factions = {}   
    }
end

return DirectorUtils