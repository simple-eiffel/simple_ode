note
	description: "Main ODE integration orchestrator with adaptive stepping"
	author: "Larry Rix"

class
	ODE_SOLVER

feature -- Integration

	integrate (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]];
			   y0: ARRAY [REAL_64]; t_start, t_end: REAL_64;
			   atol, rtol: REAL_64): ODE_RESULT
			-- Integrate with adaptive RK45 stepping.
		require
			f_not_void: f /= Void
			y0_not_void: y0 /= Void
			y0_not_empty: y0.count > 0
			increasing_time: t_start < t_end
			positive_tolerances: atol > 0.0 and rtol > 0.0
		local
			l_result: ODE_RESULT
			l_integrator: RK45_INTEGRATOR
			l_t: REAL_64
			l_y: ARRAY [REAL_64]
			l_dt: REAL_64
			l_dt_new: REAL_64
			l_rk45_result: TUPLE [y_rk4, y_rk5: ARRAY [REAL_64]; error: REAL_64]
			l_step_count: INTEGER
			l_accepted_steps: INTEGER
			l_rejected_steps: INTEGER
			l_max_error: REAL_64
			l_y_scale: REAL_64
			l_tolerance: REAL_64
			i: INTEGER
		do
			create l_integrator

			l_t := t_start
			l_y := y0
			l_dt := (t_end - t_start) / 10.0  -- Initial guess: 10 steps
			l_step_count := 0
			l_accepted_steps := 0
			l_rejected_steps := 0
			l_max_error := 0.0

			-- Adaptive stepping loop
			from until l_t >= t_end or l_step_count > 10000 loop
				-- Prevent overshooting
				if l_t + l_dt > t_end then
					l_dt := t_end - l_t
				end

				-- RK45 step
				l_rk45_result := l_integrator.rk45_step (f, l_t, l_y, l_dt)

				-- Compute maximum tolerance
				l_max_error := 0.0
				from i := l_y.lower until i > l_y.upper loop
					l_y_scale := atol + rtol * l_y [i].abs
					l_tolerance := (l_rk45_result.y_rk5 [i] - l_rk45_result.y_rk4 [i]).abs / l_y_scale
					if l_tolerance > l_max_error then
						l_max_error := l_tolerance
					end
					i := i + 1
				end

				-- Accept or reject step
				if l_max_error < 1.0 then
					-- Accept step
					l_t := l_t + l_dt
					l_y := l_rk45_result.y_rk5
					l_accepted_steps := l_accepted_steps + 1

					-- Adjust step size for next iteration (conservative growth)
					if l_max_error > 0.0 then
						l_dt_new := l_dt * (0.9 / (l_max_error ^ 0.2))
					else
						l_dt_new := l_dt * 2.0  -- Double step if no error
					end
					l_dt := l_dt_new
				else
					-- Reject step, reduce step size
					l_dt := l_dt * 0.5
					l_rejected_steps := l_rejected_steps + 1
				end

				l_step_count := l_step_count + 1
			end

			create l_result.make (y0, l_y, l_t, t_end, l_step_count, l_accepted_steps, l_rejected_steps, (l_t >= t_end), l_max_error, 0.0)
			Result := l_result
		ensure
			result_not_void: Result /= Void
			dimension_preserved: Result.dimension = y0.count
			time_advanced: Result.t_final >= t_start
		end

end
