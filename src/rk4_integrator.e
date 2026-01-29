note
	description: "RK4 classical Runge-Kutta integration"
	author: "Larry Rix"

class
	RK4_INTEGRATOR

feature -- Integration

	rk4_step (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]];
			  t: REAL_64; y: ARRAY [REAL_64]; dt: REAL_64): TUPLE [y_new: ARRAY [REAL_64]; error: REAL_64]
			-- RK4 step: 4 stages with O(h^5) local error
		require
			f_not_void: f /= Void
			y_not_void: y /= Void
			y_not_empty: y.count > 0
			positive_dt: dt > 0.0
		local
			l_y_new: ARRAY [REAL_64]
			l_k1, l_k2, l_k3, l_k4: ARRAY [REAL_64]
			l_y_temp: ARRAY [REAL_64]
			i: INTEGER
		do
			-- Stage 1: k1 = f(t, y)
			l_k1 := f.item ([t, y])

			-- Intermediate: y_temp = y + dt/2 * k1
			create l_y_temp.make_filled (0.0, y.lower, y.upper)
			from i := y.lower until i > y.upper loop
				l_y_temp [i] := y [i] + (dt / 2.0) * l_k1 [i]
				i := i + 1
			end

			-- Stage 2: k2 = f(t + dt/2, y_temp)
			l_k2 := f.item ([t + dt / 2.0, l_y_temp])

			-- Intermediate: y_temp = y + dt/2 * k2
			from i := y.lower until i > y.upper loop
				l_y_temp [i] := y [i] + (dt / 2.0) * l_k2 [i]
				i := i + 1
			end

			-- Stage 3: k3 = f(t + dt/2, y_temp)
			l_k3 := f.item ([t + dt / 2.0, l_y_temp])

			-- Intermediate: y_temp = y + dt * k3
			from i := y.lower until i > y.upper loop
				l_y_temp [i] := y [i] + dt * l_k3 [i]
				i := i + 1
			end

			-- Stage 4: k4 = f(t + dt, y_temp)
			l_k4 := f.item ([t + dt, l_y_temp])

			-- Result: y_new = y + dt/6 * (k1 + 2*k2 + 2*k3 + k4)
			create l_y_new.make_filled (0.0, y.lower, y.upper)
			from i := y.lower until i > y.upper loop
				l_y_new [i] := y [i] + (dt / 6.0) * (l_k1 [i] + 2.0 * l_k2 [i] + 2.0 * l_k3 [i] + l_k4 [i])
				i := i + 1
			end

			Result := [l_y_new, 0.0]
		ensure
			result_not_void: Result /= Void
			y_new_dimension_preserved: Result.y_new.count = y.count
			error_non_negative: Result.error >= 0.0
		end

end
