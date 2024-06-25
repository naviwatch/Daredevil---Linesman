local mod = get_mod("Daredevil")

local special_health_step_multipliers = {
    1,
    1,
    1.5,
    2.2,
    3.3,
    4.5,
    4.5,
    4.5,
    1,
}

local function networkify_health(health_amount)
    health_amount = math.clamp(health_amount, 0, 8191.5)

    local decimal = health_amount % 1
    local rounded_decimal = math.round(decimal * 4) * 0.25

    return math.floor(health_amount) + rounded_decimal
end

local function health_steps(value, step_multipliers)
    local value_steps = {}

    for i = 1, 9 do
        local step_value = value * step_multipliers[i]
        local networkifyed_health = networkify_health(step_value)

        value_steps[i] = networkifyed_health
    end

    return value_steps
end

local function steps(value, step_multipliers)
    local value_steps = {}

    for i = 1, 9 do
        local raw_value = value * step_multipliers[i]
        local decimal = raw_value % 1
        local rounded_decimal = math.round(decimal * 4) * 0.25

        value_steps[i] = math.floor(raw_value) + rounded_decimal
    end

    return value_steps
end

-- repurposed for this, used to only increase fiend hp, note that max hp is locked at 8100~k
Breeds.chaos_corruptor_sorcerer.max_health = health_steps(20, special_health_step_multipliers)
Breeds.chaos_vortex_sorcerer.max_health = health_steps(20, special_health_step_multipliers)
Breeds.skaven_warpfire_thrower.max_health = health_steps(12, special_health_step_multipliers)
Breeds.skaven_poison_wind_globadier.max_health = health_steps(20, special_health_step_multipliers)
Breeds.skaven_gutter_runner.max_health = health_steps(12, special_health_step_multipliers)
Breeds.skaven_pack_master.max_health = health_steps(25, special_health_step_multipliers)
Breeds.skaven_ratling_gunner.max_health = health_steps(12, special_health_step_multipliers)
