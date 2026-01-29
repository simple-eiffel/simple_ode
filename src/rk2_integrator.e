note
	description: "RK2 midpoint integration method"
	author: "Larry Rix"

class
	RK2_INTEGRATOR

feature -- Integration

	rk2_step (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]];
			  t: REAL_64; y: ARRAY [REAL_64]; dt: REAL_64): TUPLE [y_new: ARRAY [REAL_64]; error: REAL_64]
			-- RK2 step: k1=f(t,y), k2=f(t+dt/2, y+dt*k1/2), y_new=y+dt*k2
		require
			f_not_void: f /= Void
			y_not_void: y /= Void
			y_not_empty: y.count > 0
			positive_dt: dt > 0.0
		local
			l_y_new: ARRAY [REAL_64]
			l_k1, l_k2: ARRAY [REAL_64]
			l_y_mid: ARRAY [REAL_64]
			i: INTEGER
		do
			-- Stage 1: k1 = f(t, y)
			l_k1 := f.item ([t, y])

			-- Midpoint: y_mid = y + dt/2 * k1
			create l_y_mid.make_filled (0.0, y.lower, y.upper)
			from i := y.lower until i > y.upper loop
				l_y_mid [i] := y [i] + (dt / 2.0) * l_k1 [i]
				i := i + 1
			end

			-- Stage 2: k2 = f(t + dt/2, y_mid)
			l_k2 := f.item ([t + dt / 2.0, l_y_mid])

			-- Result: y_new = y + dt * k2
			create l_y_new.make_filled (0.0, y.lower, y.upper)
			from i := y.lower until i > y.upper loop
				l_y_new [i] := y [i] + dt * l_k2 [i]
				i := i + 1
			end

			Result := [l_y_new, 0.0]
		ensure
			result_not_void: Result /= Void
			y_new_dimension_preserved: Result.y_new.count = y.count
			error_non_negative: Result.error >= 0.0
		end

end
