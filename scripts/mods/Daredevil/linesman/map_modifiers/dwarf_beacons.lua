local mod = get_mod("Daredevil")

local co = 0.1355
PackSpawningSettings.default.area_density_coefficient = co
PackSpawningSettings.skaven.area_density_coefficient = co
PackSpawningSettings.chaos.area_density_coefficient = co
PackSpawningSettings.beastmen.area_density_coefficient = co

GenericTerrorEvents.fuck_you = {
    {
        "spawn_special",
        amount = 1,
        breed_name = "chaos_vortex_sorcerer"
    },
    {
        "spawn_special",
        amount = 3,
        breed_name = "skaven_ratling_gunner"
    },
}

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