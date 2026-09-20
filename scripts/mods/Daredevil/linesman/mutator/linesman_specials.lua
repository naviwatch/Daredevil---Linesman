local mod = get_mod("Daredevil")
local mutator_plus = mod:persistent_table("Daredevil+")
local lb = get_mod("LinesmanBalance") or get_mod("Dream Balance") or get_mod("Dream Onslaught")
local sbp = get_mod("simple_balance_patch")
local conflict_director = Managers.state.conflict
-- ============================================================================
-- CONSTANTS AND CONFIGURATION
-- ============================================================================
local DIFFICULTY = {
    BABY = 0,
    BOY = 1,
    MAN = 3,
    BOOMER = 4,
}
local current_difficulty = mod.difficulty_level
local is_baby = current_difficulty == DIFFICULTY.BABY
local is_boy = current_difficulty == DIFFICULTY.BOY
local is_man = current_difficulty == DIFFICULTY.MAN
local is_boomer = current_difficulty == DIFFICULTY.BOOMER
local SPECIAL_CONFIG = {
    base_slots = 7,
    max_of_same = 3,
    coordinated_attack_cooldown = 0.3,
    default_after_safe_zone = { 20, 45 },
    boomer_after_safe_zone = { 10, 15 },
}
local TIMER_CONFIG = {
    giga_specials = {
        slots = 6,
        min_timer = 0,
        max_timer = 10,
    },
    lb_enabled = {
        slots = 7,
        min_timer = 35,
        max_timer = 45,
    },
    sbp_enabled = {
        slots = 7,
        min_timer = 35,
        max_timer = 50,
    },
    default = {
        slots = 7,
        min_timer = 30,
        max_timer = 45,
    },
    baby_or_boy_override = {
        min_timer = 37,
        max_timer = 50,
    },
}
local SURGE_CONFIG = {
    timer_range = { 0, 10 },
    duration = 30,
    chance = lb and 0.3 or 0,
    cooldown_multiplier = 0.2,
    cooldown_range = { 60, 90 },
}
local SAME_BREED_CONFIG = {
    max_slots = 3,
    chance = 0.3,
    stagger_time = 7,
}
local HORDE_CONFIG = {
    spawn_chance = 0,
}
local FIXED_COOLDOWN_TIMERS = {
    default = { 10, 25 },
    baby_override = { 20, 25 },
}
local FIXED_COOLDOWN_SLOTS = {
    dlc_termite_3 = 2,
    default = 1,
}
local NO_VORTEX_LEVELS = { "mines", "dlc_castle", "fort" }
local VORTEX_REPLACEMENTS = {
    "skaven_gutter_runner",
    "skaven_poison_wind_globadier",
    "skaven_pack_master",
    "skaven_explosive_loot_rat"
}
-- ============================================================================
-- BREED POOLS
-- ============================================================================
local function create_breed_pool(base_breeds)
    local pool = {}
    for _, breed in ipairs(base_breeds) do
        table.insert(pool, breed)
    end
    return pool
end
local BREED_POOLS = {
    base = create_breed_pool({
        "skaven_gutter_runner", "skaven_pack_master", "skaven_ratling_gunner",
        "skaven_poison_wind_globadier", "skaven_warpfire_thrower",
        "chaos_vortex_sorcerer", "chaos_corruptor_sorcerer",
        "skaven_gutter_runner", "skaven_pack_master", "skaven_ratling_gunner",
        "skaven_warpfire_thrower", "skaven_poison_wind_globadier",
        "chaos_corruptor_sorcerer",
        "skaven_gutter_runner", "skaven_ratling_gunner",
        "skaven_poison_wind_globadier", "skaven_warpfire_thrower",
        "chaos_vortex_sorcerer", "chaos_corruptor_sorcerer",
    }),
    
    skaven = create_breed_pool({
        "skaven_gutter_runner", "skaven_pack_master", "skaven_ratling_gunner",
        "skaven_poison_wind_globadier", "skaven_warpfire_thrower",
        "skaven_gutter_runner", "skaven_pack_master", "skaven_ratling_gunner",
        "skaven_warpfire_thrower", "skaven_poison_wind_globadier",
        "skaven_gutter_runner", "skaven_ratling_gunner",
        "skaven_poison_wind_globadier", "skaven_warpfire_thrower",
    }),
    
    chaos = create_breed_pool({
        "skaven_gutter_runner", "skaven_pack_master", "skaven_ratling_gunner",
        "skaven_poison_wind_globadier", "skaven_warpfire_thrower",
        "chaos_vortex_sorcerer", "chaos_corruptor_sorcerer",
        "skaven_gutter_runner", "skaven_pack_master", "skaven_ratling_gunner",
        "skaven_warpfire_thrower", "skaven_poison_wind_globadier",
        "chaos_corruptor_sorcerer",
        "skaven_gutter_runner", "skaven_ratling_gunner",
        "skaven_poison_wind_globadier", "skaven_warpfire_thrower",
        "chaos_corruptor_sorcerer",
    }),
    
    beastmen = create_breed_pool({
        "skaven_gutter_runner", "skaven_pack_master", "skaven_ratling_gunner",
        "skaven_poison_wind_globadier", "skaven_warpfire_thrower",
        "chaos_vortex_sorcerer", "chaos_corruptor_sorcerer",
        "skaven_gutter_runner", "skaven_pack_master", "skaven_ratling_gunner",
        "skaven_warpfire_thrower", "skaven_poison_wind_globadier",
        "chaos_corruptor_sorcerer",
        "skaven_gutter_runner", "skaven_ratling_gunner",
        "skaven_poison_wind_globadier", "skaven_warpfire_thrower",
        "chaos_corruptor_sorcerer",
    }),
}
-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================
local function is_vortex_replacement_level(level_name)
    for _, name in ipairs(NO_VORTEX_LEVELS) do
        if level_name == name then
            return true
        end
    end
    return false
end
local function get_random_vortex_replacement()
    return VORTEX_REPLACEMENTS[math.random(1, #VORTEX_REPLACEMENTS)]
end
local function get_fixed_cooldown_slot_count(level_name)
    if level_name == "dlc_termite_3" then
        return FIXED_COOLDOWN_SLOTS.dlc_termite_3
    end
    return FIXED_COOLDOWN_SLOTS.default
end
-- ============================================================================
-- SPECIAL SETTINGS INITIALIZATION
-- ============================================================================
local function calculate_special_settings()
    local config = {}
    
    if mod:get("giga_specials") then
        config = TIMER_CONFIG.giga_specials
        mod:chat_broadcast("Unending Specials ENABLED.")
    elseif lb then
        config = TIMER_CONFIG.lb_enabled
    elseif sbp then
        config = TIMER_CONFIG.sbp_enabled
    else
        config = TIMER_CONFIG.default
    end
    
    local min_timer = config.min_timer
    local max_timer = config.max_timer
    
    if is_boy or is_baby then
        min_timer = TIMER_CONFIG.baby_or_boy_override.min_timer
        max_timer = TIMER_CONFIG.baby_or_boy_override.max_timer
    end
    
    local coordinated_chance = (not is_boomer or lb) and 0.5 or 0
    
    local after_safe_zone = SPECIAL_CONFIG.default_after_safe_zone
    if is_boomer then
        after_safe_zone = SPECIAL_CONFIG.boomer_after_safe_zone
    end
    
    return {
        slots = config.slots,
        min_timer = min_timer,
        max_timer = max_timer,
        max_of_same = SPECIAL_CONFIG.max_of_same,
        coordinated_chance = coordinated_chance,
        after_safe_zone_delay = after_safe_zone,
    }
end

local special_settings = calculate_special_settings()

SpecialsSettings.default.max_specials = special_settings.slots
SpecialsSettings.default.spawn_method = "specials_by_slots"
SpecialsSettings.default.methods = {}
SpecialsSettings.default.methods.specials_by_slots = {
    max_of_same = special_settings.max_of_same,
    coordinated_attack_cooldown_multiplier = SPECIAL_CONFIG.coordinated_attack_cooldown,
    chance_of_coordinated_attack = special_settings.coordinated_chance,
    select_next_breed = "get_random_breed",
    after_safe_zone_delay = special_settings.after_safe_zone_delay,
    spawn_cooldown = {
        special_settings.min_timer,
        special_settings.max_timer,
    },
}
SpecialsSettings.default.breeds = BREED_POOLS.base
local default_override = table.clone(SpecialsSettings.default)
SpecialsSettings.default.difficulty_overrides.hardest = default_override
SpecialsSettings.default.difficulty_overrides.cataclysm = default_override
SpecialsSettings.default.difficulty_overrides.cataclysm_3 = default_override

table.merge_recursive(SpecialsSettings.default_light, SpecialsSettings.default)
table.merge_recursive(SpecialsSettings.skaven, SpecialsSettings.default)
table.merge_recursive(SpecialsSettings.chaos, SpecialsSettings.default)
table.merge_recursive(SpecialsSettings.chaos_light, SpecialsSettings.default)
table.merge_recursive(SpecialsSettings.beastmen, SpecialsSettings.default)

SpecialsSettings.skaven.breeds = BREED_POOLS.skaven
SpecialsSettings.chaos.breeds = BREED_POOLS.chaos
SpecialsSettings.beastmen.breeds = BREED_POOLS.beastmen
SpecialsSettings.skaven_beastmen = SpecialsSettings.beastmen
SpecialsSettings.chaos_beastmen = SpecialsSettings.beastmen

SpecialsSettings.skaven.difficulty_overrides.hardest.breeds = BREED_POOLS.skaven
SpecialsSettings.skaven.difficulty_overrides.cataclysm.breeds = BREED_POOLS.skaven
SpecialsSettings.skaven.difficulty_overrides.cataclysm_3.breeds = BREED_POOLS.skaven

table.merge_recursive(SpecialsSettings.skaven_light, SpecialsSettings.skaven)
-- ============================================================================
-- SPAWNING LOGIC
-- ============================================================================
local level_name = Managers.level_transition_handler:get_current_level_key()

local function spawn_custom_horde(slot)
    if level_name == "mines" and slot.breed ~= "chaos_vortex_sorcerer" then
        local num_to_spawn = 1
        local spawn_list = {}
        for i = 1, num_to_spawn do
            table.insert(spawn_list, slot.breed)
        end
        local side = Managers.state.conflict.default_enemy_side_id
        Managers.state.conflict.horde_spawner:execute_custom_horde(spawn_list, false, side)
    end
end

local function replace_vortex_sorcerer(breed_name)
    if is_vortex_replacement_level(level_name) and breed_name == "chaos_vortex_sorcerer" then
        return get_random_vortex_replacement()
    end
    return breed_name
end

local function process_slot(self, slot, t, method_data, spawn_queue, slots_to_spawn, use_fixed_cooldown, specials_settings, slots)
    if slot.state == "waiting" then
        if t > slot.time then
            if mutator_plus.active and not use_fixed_cooldown and math.random() <= HORDE_CONFIG.spawn_chance then
                spawn_custom_horde(slot)
                local cooldown_range = (mutator_plus.active and self._surge_active) and SURGE_CONFIG.timer_range or method_data.spawn_cooldown
                slot.time = t + ConflictUtils.random_interval(cooldown_range) + 10
            else
                slot.unit = nil
                slot.state = method_data.always_coordinated and "coordinating" or "wants_to_spawn"
                slot.time = nil
                slot.desc = ""
                table.insert(slots_to_spawn, slot)
            end
        end
        
        if slot.special_spawn_stinger and t > slot.special_spawn_stinger_at_t then
            self:_play_stinger(slot.special_spawn_stinger, slot)
            slot.special_spawn_stinger = nil
            slot.special_spawn_stinger_at_t = nil
        end
    end
    
    if slot.state == "alive" and not HEALTH_ALIVE[slot.unit] then
        local breed_name, health_modifier = SpecialsPacing.select_breed_functions[method_data.select_next_breed](slots, specials_settings, method_data, self._state_data)
        
        breed_name = replace_vortex_sorcerer(breed_name)
        local breed = Breeds[breed_name]
        
        local cooldown_range = (mutator_plus.active and self._surge_active) and SURGE_CONFIG.timer_range or method_data.spawn_cooldown
        local time = use_fixed_cooldown and (t + ConflictUtils.random_interval(FIXED_COOLDOWN_TIMERS.default)) or (t + ConflictUtils.random_interval(cooldown_range))
        
        if breed.special_spawn_stinger then
            slot.special_spawn_stinger = breed.special_spawn_stinger
            slot.special_spawn_stinger_at_t = time - (breed.special_spawn_stinger_time or 6)
        else
            slot.special_spawn_stinger = nil
            slot.special_spawn_stinger_at_t = nil
        end
        
        slot.time = time
        slot.breed = breed_name
        slot.unit = nil
        slot.state = "waiting"
        slot.desc = ""
        slot.health_modifier = health_modifier
    end
end

local function group_same_breed_slots(slots_to_spawn, spawn_queue, t)
    if not mutator_plus.active or #slots_to_spawn == 0 then
        for _, slot in ipairs(slots_to_spawn) do
            table.insert(spawn_queue, slot)
        end
        return
    end
    
    local breed_groups = {}
    for _, slot in ipairs(slots_to_spawn) do
        local breed = slot.breed
        breed_groups[breed] = breed_groups[breed] or {}
        table.insert(breed_groups[breed], slot)
    end
    
    for breed, group in pairs(breed_groups) do
        if #group > 1 and math.random() <= SAME_BREED_CONFIG.chance then
            local num_to_group = math.min(#group, SAME_BREED_CONFIG.max_slots)
            local base_time = t + 10
            
            for i = 1, num_to_group do
                local slot = group[i]
                slot.time = base_time + (i - 1) * SAME_BREED_CONFIG.stagger_time
                slot.state = "waiting"
                
                for j, queued_slot in ipairs(spawn_queue) do
                    if queued_slot == slot then
                        table.remove(spawn_queue, j)
                        break
                    end
                end
            end
            
            for i = num_to_group + 1, #group do
                table.insert(spawn_queue, group[i])
            end
        else
            for _, slot in ipairs(group) do
                table.insert(spawn_queue, slot)
            end
        end
    end
end

mod:hook_origin(SpecialsPacing, "specials_by_slots", function(self, t, specials_settings, method_data, slots, spawn_queue)
    local num_slots = #slots
    local waiting = 0
    local about_to_respawn = false
    local slots_to_spawn = {}
    
    self._surge_active = self._surge_active or false
    self._surge_end_time = self._surge_end_time or 0
    self._last_surge_end_time = self._last_surge_end_time or 0
    self._surge_cooldown_duration = self._surge_cooldown_duration or 0
    
    if self._surge_active and t >= self._surge_end_time then
        self._surge_active = false
        self._last_surge_end_time = t
        self._surge_cooldown_duration = math.random(
            SURGE_CONFIG.cooldown_range[1], 
            SURGE_CONFIG.cooldown_range[2]
        )
    end
    
    if method_data.always_coordinated then
        local state_data = self._state_data
        if t > state_data.coordinated_timer then
            self:set_next_coordinated_attack(t, specials_settings, method_data, slots, spawn_queue)
        end
        self._specials_timer = t + 1
        return
    end
    
    local fixed_cooldown_count = get_fixed_cooldown_slot_count(level_name)
    
    if mutator_plus.active and not mod:get("giga_specials") then
        for i = 1, fixed_cooldown_count do
            process_slot(self, slots[i], t, method_data, spawn_queue, slots_to_spawn, true, specials_settings, slots)
        end
        for i = fixed_cooldown_count + 1, num_slots do
            process_slot(self, slots[i], t, method_data, spawn_queue, slots_to_spawn, false, specials_settings, slots)
        end
    else
        for i = 1, num_slots do
            process_slot(self, slots[i], t, method_data, spawn_queue, slots_to_spawn, false, specials_settings, slots)
        end
    end
    
    group_same_breed_slots(slots_to_spawn, spawn_queue, t)
    
    if about_to_respawn and waiting == num_slots then
        local do_coordinated = math.random() <= method_data.chance_of_coordinated_attack
        
        if do_coordinated then
            print("Coordinated attack!")
            mod:chat_broadcast("Coordinated attack!")
            
            local coordinated_multiplier = method_data.coordinated_attack_cooldown_multiplier or 0.5
            
            if mutator_plus.active then
                local surge_cooldown_expired = t > self._last_surge_end_time + self._surge_cooldown_duration
                local do_surge = surge_cooldown_expired and math.random() <= SURGE_CONFIG.chance
                
                if do_surge then
                    self._surge_active = true
                    self._surge_end_time = t + SURGE_CONFIG.duration
                    coordinated_multiplier = SURGE_CONFIG.cooldown_multiplier
                    mod:chat_broadcast("Surge activated!")
                end
            end
            
            local average_slot_time = 0
            for i = 1, num_slots do
                average_slot_time = average_slot_time + (slots[i].time or 0)
            end
            
            local coordinated_time
            if average_slot_time > 0 then
                average_slot_time = average_slot_time / num_slots
                coordinated_time = t + (average_slot_time - t) * coordinated_multiplier
            else
                coordinated_time = t + 20
            end
            
            local state_data = self._state_data
            for i = 1, num_slots do
                local slot = slots[i]
                local breed_name, health_modifier = SpecialsPacing.select_breed_functions[method_data.select_next_breed](
                    slots, specials_settings, method_data, state_data, do_coordinated
                )
                
                breed_name = replace_vortex_sorcerer(breed_name)
                local breed = Breeds[breed_name]
                local time = coordinated_time + (method_data.coordinated_trickle_time and 
                    i * method_data.coordinated_trickle_time or i * 2)
                
                if breed.special_spawn_stinger then
                    slot.special_spawn_stinger = breed.special_spawn_stinger
                    slot.special_spawn_stinger_at_t = time - (breed.special_spawn_stinger_time or 6)
                else
                    slot.special_spawn_stinger = nil
                    slot.special_spawn_stinger_at_t = nil
                end
                
                slot.time = time
                slot.breed = breed_name
                slot.unit = nil
                slot.state = "waiting"
                slot.health_modifier = health_modifier
                slot.desc = (mutator_plus.active and self._surge_active) and "surge attack" or "coordinated attack"
            end
        end
    end
    
    self._specials_timer = t + 1
end)