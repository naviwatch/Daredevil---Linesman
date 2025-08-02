local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance")
local conflict_director = Managers.state.conflict
local bl = get_mod("Beastmen Loader")

local enhancement_list = {
    ["regenerating"] = true,
    ["unstaggerable"] = true
}
local enhancement_1 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
    ["unstaggerable"] = true
}
local relentless = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
    ["intangible"] = true
}
local enhancement_3 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
    ["ranged_immune"] = true
}
local enhancement_4 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
    ["commander"] = true
}
local enhancement_5 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local enhancement_list = {
    ["regenerating"] = true
}
local enhancement_6 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
    ["warping"] = true,
    ["crushing"] = true
}
local enhancement_7 = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
    ["crushing"] = true
}
local shield_shatter = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)
local enhancement_list = {
    ["crushing"] = true,
    --	["intangible"] = true,
    ["unstaggerable"] = true
}
local bob = TerrorEventUtils.generate_enhanced_breed_from_set(enhancement_list)

local function respawn_check()
    for i, player in pairs(Managers.player:players()) do
        if player.player_unit then
            local status_extension = ScriptUnit.has_extension(player.player_unit, "status_system")
            if status_extension and not status_extension.is_ready_for_assisted_respawn(status_extension) then
                return true
            end
        end
    end
    return false
end

local function stop_progress_event()
    return true
end

local function progress_event(required_progress, terror_event_name)
    local level_analysis = conflict_director.level_analysis
    local main_path_data = level_analysis.main_path_data
    local ahead_travel_dist = conflict_director.main_path_info.ahead_travel_dist
    local total_travel_dist = main_path_data.total_dist
    local travel_percentage = ahead_travel_dist / total_travel_dist * 100

    while true do
        if required_progress <= travel_percentage then
            conflict_director:start_terror_event(terror_event_name)
            mod:echo("STARTING EVENT STARTING EVENT STARTING EVENT")
            break
        end

        if stop_progress_event() then
            break
        end
    end
end

local function create_weights()
    local crash = nil

    for id, setting in pairs(PackSpawningSettings) do
        setting.name = id

        if not setting.disabled then
            roaming_set = setting.roaming_set
            roaming_set.name = id
            local weights = {}
            local breed_packs_override = roaming_set.breed_packs_override

            if breed_packs_override then
                for i = 1, #breed_packs_override, 1 do
                    weights[i] = breed_packs_override[i][2]
                end

                roaming_set.breed_packs_override_loaded_dice = {
                    LoadedDice.create(weights)
                }
            end
        end
    end

    -- Adjustment for the new difficulty system of horde compositions from 1.4 - I am not copypasting each composition 3 times. Or 4, doesn't matter.
    for event, composition in pairs(HordeCompositions) do
        if not composition[1][1] then
            local temp_table = table.clone(composition)
            table.clear_array(composition, #composition)
            composition[1] = temp_table
            composition[2] = temp_table
            composition[3] = temp_table
            composition[4] = temp_table
            composition[5] = temp_table
            composition[6] = temp_table
            composition[7] = temp_table
        elseif not composition[6] then
            composition[6] = composition[5]
            composition[7] = composition[5]
        end
    end

    local weights = {}
    local crash = nil

    for key, setting in pairs(HordeSettings) do
        setting.name = key

        if setting.compositions then
            for name, composition in pairs(setting.compositions) do
                for i = 1, #composition, 1 do
                    table.clear_array(weights, #weights)

                    local compositions = composition[i]

                    for j, variant in ipairs(compositions) do
                        weights[j] = variant.weight
                        local breeds = variant.breeds

                        if breeds then
                            for k = 1, #breeds, 2 do
                                local breed_name = breeds[k]
                                local breed = Breeds[breed_name]

                                if not breed then
                                    print(string.format(
                                    "Bad or non-existing breed in HordeCompositions table %s : '%s' defined in HordeCompositions.",
                                        name, tostring(breed_name)))

                                    crash = true
                                elseif not breed.can_use_horde_spawners then
                                    variant.must_use_hidden_spawners = true
                                end
                            end
                        end
                    end

                    compositions.loaded_probs = {
                        LoadedDice.create(weights)
                    }

                    fassert(not crash, "Found errors in HordeComposition table %s - see above. ", name)
                    fassert(compositions.loaded_probs,
                        "Could not create horde composition probablitity table, make sure the table '%s' in HordeCompositions is correctly structured and has an entry for each difficulty.",
                        name)
                end
            end
        end

        if setting.compositions_pacing then
            for name, composition in pairs(setting.compositions_pacing) do
                table.clear_array(weights, #weights)

                for i, variant in ipairs(composition) do
                    weights[i] = variant.weight
                    local breeds = variant.breeds

                    for j = 1, #breeds, 2 do
                        local breed_name = breeds[j]
                        local breed = Breeds[breed_name]

                        if not breed then
                            print(string.format(
                            "Bad or non-existing breed in HordeCompositionsPacing table %s : '%s' defined in HordeCompositionsPacing.",
                                name, tostring(breed_name)))

                            crash = true
                        elseif not breed.can_use_horde_spawners then
                            variant.must_use_hidden_spawners = true
                        end
                    end
                end

                composition.loaded_probs = {
                    LoadedDice.create(weights)
                }

                fassert(not crash, "Found errors in HordeCompositionsPacing table %s - see above. ", name)
                fassert(composition.loaded_probs,
                    "Could not create horde composition probablitity table, make sure the table '%s' in HordeCompositionsPacing is correctly structured.",
                    name)
            end
        end
    end
end

-- PACING
PacingSettings.default.peak_fade_threshold = 110
PacingSettings.default.peak_intensity_threshold = 120
PacingSettings.default.sustain_peak_duration = { 5, 10 }
PacingSettings.default.relax_duration = { 10, 13 }
PacingSettings.default.horde_frequency = { 30, 45 }
PacingSettings.default.multiple_horde_frequency = { 7, 9 }
PacingSettings.default.max_delay_until_next_horde = { 70, 75 }
PacingSettings.default.horde_startup_time = { 12, 20 }
PacingSettings.default.multiple_hordes = 3   -- Came from Dense

PacingSettings.default.mini_patrol.only_spawn_above_intensity = 0
PacingSettings.default.mini_patrol.only_spawn_below_intensity = 900
PacingSettings.default.mini_patrol.frequency = { 9, 10 }

PacingSettings.default.difficulty_overrides = nil
PacingSettings.default.delay_specials_threat_value = nil

PacingSettings.chaos.peak_fade_threshold = 110
PacingSettings.chaos.peak_intensity_threshold = 120
PacingSettings.chaos.sustain_peak_duration = { 5, 10 }
PacingSettings.chaos.relax_duration = { 13, 15 }
PacingSettings.chaos.horde_frequency = { 30, 45 }           -- Base 30/45
PacingSettings.chaos.multiple_horde_frequency = { 7, 10 }   -- Base 7/10
PacingSettings.chaos.max_delay_until_next_horde = { 74, 78 }
PacingSettings.chaos.horde_startup_time = { 15, 20 }
PacingSettings.chaos.multiple_hordes = 3

PacingSettings.chaos.mini_patrol.only_spawn_above_intensity = 0
PacingSettings.chaos.mini_patrol.only_spawn_below_intensity = 900
PacingSettings.chaos.mini_patrol.frequency = { 9, 10 }

PacingSettings.chaos.difficulty_overrides = nil
PacingSettings.chaos.delay_specials_threat_value = nil

PacingSettings.beastmen.peak_fade_threshold = 110   -- I'm not touching beastmen they suck
PacingSettings.beastmen.peak_intensity_threshold = 120
PacingSettings.beastmen.sustain_peak_duration = { 5, 10 }
PacingSettings.beastmen.relax_duration = { 10, 13 }
PacingSettings.beastmen.horde_frequency = { 35, 50 }
PacingSettings.beastmen.multiple_horde_frequency = { 6, 9 }
PacingSettings.beastmen.max_delay_until_next_horde = { 75, 95 }
PacingSettings.beastmen.horde_startup_time = { 10, 20 }

PacingSettings.beastmen.mini_patrol.only_spawn_above_intensity = 0
PacingSettings.beastmen.mini_patrol.only_spawn_below_intensity = 900
PacingSettings.beastmen.mini_patrol.frequency = { 8, 10 }

PacingSettings.beastmen.difficulty_overrides = nil
PacingSettings.beastmen.delay_specials_threat_value = nil
PacingSettings.beastmen.delay_horde_threat_value.cataclysm_2 = tt
PacingSettings.beastmen.delay_horde_threat_value.cataclysm_3 = tt

-- INTENSITY
IntensitySettings.default.intensity_added_per_percent_damage_taken = 0
IntensitySettings.default.decay_delay = 1
IntensitySettings.default.decay_per_second = 6
IntensitySettings.default.intensity_added_knockdown = 50
IntensitySettings.default.intensity_added_pounced_down = 25
IntensitySettings.default.max_intensity = 100
IntensitySettings.default.intensity_added_nearby_kill = 2

IntensitySettings.default.difficulty_overrides = nil

-- HORDE SETTINGS
HordeSettings.default.chance_of_vector = 0.7
HordeSettings.default.chance_of_vector_blob = 0.65
--	HordeSettings.default.difficulty_overrides.cataclysm.ambush_composition = "medium"
--	HordeSettings.default.difficulty_overrides.cataclysm_2.ambush_composition = "medium"
--	HordeSettings.default.difficulty_overrides.cataclysm_3.ambush_composition = "medium"

HordeSettings.chaos.chance_of_vector = 0.8
HordeSettings.chaos.chance_of_vector_blob = 0.5

HordeSettingsBasics = {
    ambush = {
        max_spawners = math.huge,
        max_size,
        max_hidden_spawner_dist = 40,
        max_horde_spawner_dist = 35,
        min_hidden_spawner_dist = 5,
        min_horde_spawner_dist = 1,
        min_spawners = math.huge,
        start_delay = 3.45,
    },
    vector = {
        max_size,
        main_path_chance_spawning_ahead = 0.67,
        main_path_dist_from_players = 30,
        max_hidden_spawner_dist = 30,
        max_horde_spawner_dist = 20,
        max_spawners = 10,
        min_hidden_spawner_dist = 0,
        min_horde_spawner_dist = 0,
        raw_dist_from_players = 13,
        start_delay = 4,
    },
    vector_blob = {
        max_size,
        main_path_chance_spawning_ahead = 0.67,
        main_path_dist_from_players = 60,
        raw_dist_from_players = 13,
        start_delay = 1,
    },
}
