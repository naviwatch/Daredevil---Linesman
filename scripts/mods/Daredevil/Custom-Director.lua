local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")

mod:dofile("scripts/mods/Daredevil/directors/directors_init")

-- mod.density = 1

-- mod:command("add_monk_pack", "", function()
-- 	BreedPackUtils.add_breedpack("monks_only", "skaven_plague_monk")
-- end)

-- mod:command("add_shield_wall_pack", "", function()
-- 	BreedPackUtils.add_breedpack("shield_wall", "beastmen_ungor_archer", "skaven_clan_rat_with_shield")
-- end)

mod:set("dlc_bogenhafen_slum", "helloWorld")

mod:hook(LevelAnalysis, "_setup_level_data", function(func, self, level_name, level_seed)

    
    local result = func(self, level_name, level_seed)
    -- mod:echo(self.spawn_zone_data.roaming_set)
    for k,v in pairs(self.spawn_zone_data.zones) do
        -- local directors = {"tester", "skaven"}

        --populate unpopulated ambient zones
        -- if not v.roaming_set then
        --     self.spawn_zone_data.zones[k].roaming_set = directors[math.random(1, #directors)]
        -- end

        if v.roaming_set and mutator_plus.active then
            mod:echo(mod:get(level_name))
            self.spawn_zone_data.zones[k].roaming_set = mod:get(level_name) or "default"
        end

        --populate all zones with override director
        -- self.spawn_zone_data.zones[k].roaming_set = directors[math.random(1, #directors)]

    end
    return result 
end)

