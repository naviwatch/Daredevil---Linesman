local mod = get_mod("Daredevil")

-- All taken from Empowered
-- Skarikk animation scaling
mod:hook(GameNetworkManager, "anim_event", function(func, self, unit, event)
	-- if event ~= "move_fwd" and event ~= "move_bwd" and event ~= "idle" then
		-- mod:echo(event)
	-- end
	-- if event == "attack_pushback_swing" then
		-- Managers.state.network:anim_set_variable_float(unit, "reset_speed", 3)
	-- end
	--attack_pushback_swing
	if event == "attack_combo_1" or event == "attack_combo_2" or event == "attack_combo_3" then
		LocomotionUtils.set_animation_translation_scale(unit, Vector3(1.6, 1.6, 1))
	elseif event == "attack_run_2" then
		local blackboard = BLACKBOARDS[unit]
		if blackboard.target_dist > 4 then
			local wanted_scale = math.min(blackboard.target_dist / 4, 2)
			LocomotionUtils.set_animation_translation_scale(unit, Vector3(wanted_scale, wanted_scale, 1))
		end
	end
	func(self, unit, event)
end)

-- Bodvarr stagger resilience
mod:hook(BreedActions.chaos_exalted_champion.stagger, "custom_enter_function", function (func, unit, blackboard, t, action)
	local stagger_anims = blackboard.action.stagger_anims[blackboard.stagger_type]

	if blackboard.stagger_type == 6 then
		if blackboard.chain_stagger_resistant_t and blackboard.chain_stagger_resistant_t < t then
			blackboard.chain_stagger_resistant_t = nil
			blackboard.num_chain_stagger = 1
		end

		local num_chain_stagger = blackboard.num_chain_stagger or 1
		blackboard.num_chain_stagger = num_chain_stagger + 1

		if not blackboard.chain_stagger_resistant_t and blackboard.num_chain_stagger > 1 and blackboard.stagger_type == 6 then
			blackboard.chain_stagger_resistant_t = t + 8
		end

		if blackboard.chain_stagger_resistant_t and t < blackboard.chain_stagger_resistant_t then
			stagger_anims = blackboard.action.stagger_anims[3]
			blackboard.stagger_time = t + 2
		end
	end

	return stagger_anims, "idle"
end)

------------------------------------------------------
-- Lord Skarikk

	BreedActions.skaven_storm_vermin_warlord.special_attack_cleave.player_push_speed = 0
	BreedActions.skaven_storm_vermin_warlord.special_attack_cleave.player_push_speed_blocked = 3

	BreedActions.skaven_storm_vermin_warlord.special_attack_sweep_left.player_push_speed = 6
	BreedActions.skaven_storm_vermin_warlord.special_attack_sweep_left.player_push_speed_blocked = 8

	BreedActions.skaven_storm_vermin_warlord.special_attack_sweep_right.player_push_speed = 6
	BreedActions.skaven_storm_vermin_warlord.special_attack_sweep_right.player_push_speed_blocked = 8

	BreedActions.skaven_storm_vermin_warlord.dual_attack_cleave.player_push_speed = 5
	BreedActions.skaven_storm_vermin_warlord.dual_attack_cleave.player_push_speed_blocked = 6
	BreedActions.skaven_storm_vermin_warlord.dual_attack_cleave.considerations.distance_to_target.max_value = 8

	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.player_push_speed_blocked = 2
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.player_push_speed = 1
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.ignores_dodging = true
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.considerations.distance_to_target_flat_sq.max_value = 16

	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[1].player_push_speed_blocked = 2
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[1].player_push_speed = 1
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[1].ignores_dodging = true
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[1].rotation_speed = 10
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[1].rotation_time = 3
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[1].attack_time = 2

	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[2].player_push_speed_blocked = 2
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[2].player_push_speed = 1
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[2].ignores_dodging = true
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[2].attack_time = 2

	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[3].player_push_speed_blocked = 2
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[3].player_push_speed = 1
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[3].ignores_dodging = true
	BreedActions.skaven_storm_vermin_warlord.dual_combo_attack2.attacks[3].attack_time = 0.55

	BreedActions.skaven_storm_vermin_warlord.special_attack_champion.considerations.distance_to_target.max_value = 7
	BreedActions.skaven_storm_vermin_warlord.special_attack_champion_defensive.considerations.distance_to_target.max_value = 7

	BreedActions.skaven_storm_vermin_warlord.dual_lunge_attack.player_push_speed = 10
	BreedActions.skaven_storm_vermin_warlord.dual_lunge_attack.player_push_speed_blocked = 10
	BreedActions.skaven_storm_vermin_warlord.dual_lunge_attack.considerations.distance_to_target.max_value = 9
	BreedActions.skaven_storm_vermin_warlord.dual_lunge_attack.considerations.time_since_last.max_value = 6
	BreedActions.skaven_storm_vermin_warlord.dual_lunge_attack.range = 3.25
	BreedActions.skaven_storm_vermin_warlord.dual_lunge_attack.fatigue_type = BreedTweaks.fatigue_types.elite_sweep.normal_attack

	BreedActions.skaven_storm_vermin_warlord.special_running_attack.player_push_speed = 8
	BreedActions.skaven_storm_vermin_warlord.special_running_attack.player_push_speed_blocked = 10
	BreedActions.skaven_storm_vermin_warlord.special_running_attack.considerations.distance_to_target.max_value = 9
	BreedActions.skaven_storm_vermin_warlord.special_running_attack.considerations.time_since_last.max_value = 5
	BreedActions.skaven_storm_vermin_warlord.special_running_attack.range = 3
	BreedActions.skaven_storm_vermin_warlord.special_running_attack.fatigue_type = BreedTweaks.fatigue_types.elite_sweep.normal_attack
	BreedActions.skaven_storm_vermin_warlord.special_running_attack.attack_sequence = {
		{
			attack_anim = "attack_run_2"
		}
	}

	BreedActions.skaven_storm_vermin_warlord.special_lunge_attack.considerations.distance_to_target.max_value = 10

	BreedActions.skaven_storm_vermin_warlord.special_attack_spin.attack_sequence[2].at = 1.7
	BreedActions.skaven_storm_vermin_warlord.defensive_mode_spin.attack_sequence[2].ready_function = function (unit, blackboard, t)
		local charge_t = t - blackboard.attack_sequence_start_time
	
		return (charge_t > 0.75 and blackboard.surrounding_players > 0) or charge_t > 2.5
	end	