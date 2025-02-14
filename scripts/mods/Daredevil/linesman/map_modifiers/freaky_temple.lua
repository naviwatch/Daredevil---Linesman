local mod = get_mod("Daredevil")

local co

if mod.difficulty_level == 1 then 
    co = 0.075
else
    co = 0.11
end

PackSpawningSettings.default.area_density_coefficient = co
PackSpawningSettings.skaven.area_density_coefficient = co
PackSpawningSettings.chaos.area_density_coefficient = co
PackSpawningSettings.beastmen.area_density_coefficient = co

BossSettings.default.boss_events.events = {"event_patrol"}
BossSettings.default_light.boss_events.events = {"event_patrol"}
BossSettings.skaven.boss_events.events = {"event_patrol"}
BossSettings.skaven_light.boss_events.events = {"event_patrol"}
BossSettings.chaos.boss_events.events = {"event_patrol",}
BossSettings.chaos_light.boss_events.events = {"event_patrol",}
BossSettings.beastmen.boss_events.events = { "event_patrol"}
BossSettings.skaven_beastmen.boss_events.events = { "event_patrol",}
BossSettings.chaos_beastmen.boss_events.events = { "event_patrol",}
BossSettings.beastmen_light.boss_events.events = { "event_patrol" }