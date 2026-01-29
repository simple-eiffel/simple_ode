note
	description: "RK45 Dormand-Prince with embedded error estimation"
	author: "Larry Rix"

class
	RK45_INTEGRATOR

feature -- Integration

	rk45_step (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]];
			   t: REAL_64; y: ARRAY [REAL_64]; dt: REAL_64): TUPLE [y_rk4, y_rk5: ARRAY [REAL_64]; error: REAL_64]
			-- RK45 step: 6 stages with embedded error pair
		require
			f_not_void: f /= Void
			y_not_void: y /= Void
			y_not_empty: y.count > 0
			positive_dt: dt > 0.0
		local
			l_y_rk4, l_y_rk5: ARRAY [REAL_64]
			l_k1, l_k2, l_k3, l_k4, l_k5, l_k6: ARRAY [REAL_64]
			l_y_temp: ARRAY [REAL_64]
			l_error: REAL_64
			i: INTEGER
		do
			-- Stage 1: k1 = f(t, y)
			l_k1 := f.item ([t, y])

			-- Stage 2: k2 = f(t + 1/5*dt, y + 1/5*dt*k1)
			create l_y_temp.make_filled (0.0, y.lower, y.upper)
			from i := y.lower until i > y.upper loop
				l_y_temp [i] := y [i] + (dt / 5.0) * l_k1 [i]
				i := i + 1
			end
			l_k2 := f.item ([t + dt / 5.0, l_y_temp])

			-- Stage 3: k3 = f(t + 3/10*dt, y + 3/40*dt*k1 + 9/40*dt*k2)
			from i := y.lower until i > y.upper loop
				l_y_temp [i] := y [i] + (3.0 * dt / 40.0) * l_k1 [i] + (9.0 * dt / 40.0) * l_k2 [i]
				i := i + 1
			end
			l_k3 := f.item ([t + 3.0 * dt / 10.0, l_y_temp])

			-- Stage 4: k4 = f(t + 4/5*dt, y + 44/45*dt*k1 - 56/15*dt*k2 + 32/9*dt*k3)
			from i := y.lower until i > y.upper loop
				l_y_temp [i] := y [i] + (44.0 * dt / 45.0) * l_k1 [i] - (56.0 * dt / 15.0) * l_k2 [i] + (32.0 * dt / 9.0) * l_k3 [i]
				i := i + 1
			end
			l_k4 := f.item ([t + 4.0 * dt / 5.0, l_y_temp])

			-- Stage 5: k5 = f(t + 8/9*dt, y + (19372/6561*k1 - 25360/2187*k2 + 64448/6561*k3 - 212/729*k4)*dt)
			from i := y.lower until i > y.upper loop
				l_y_temp [i] := y [i] + dt * ((19372.0 / 6561.0) * l_k1 [i] - (25360.0 / 2187.0) * l_k2 [i] +
					(64448.0 / 6561.0) * l_k3 [i] - (212.0 / 729.0) * l_k4 [i])
				i := i + 1
			end
			l_k5 := f.item ([t + 8.0 * dt / 9.0, l_y_temp])

			-- Stage 6: k6 = f(t + dt, y + (9017/3168*k1 - 355/33*k2 + 46732/5247*k3 + 49/176*k4 - 5103/18656*k5)*dt)
			from i := y.lower until i > y.upper loop
				l_y_temp [i] := y [i] + dt * ((9017.0 / 3168.0) * l_k1 [i] - (355.0 / 33.0) * l_k2 [i] +
					(46732.0 / 5247.0) * l_k3 [i] + (49.0 / 176.0) * l_k4 [i] - (5103.0 / 18656.0) * l_k5 [i])
				i := i + 1
			end
			l_k6 := f.item ([t + dt, l_y_temp])

			-- RK4 solution: y + dt * (35/384*k1 + 500/1113*k3 + 125/192*k4 - 2187/6784*k5 + 11/84*k6)
			create l_y_rk4.make_filled (0.0, y.lower, y.upper)
			from i := y.lower until i > y.upper loop
				l_y_rk4 [i] := y [i] + dt * ((35.0 / 384.0) * l_k1 [i] + (500.0 / 1113.0) * l_k3 [i] +
					(125.0 / 192.0) * l_k4 [i] - (2187.0 / 6784.0) * l_k5 [i] + (11.0 / 84.0) * l_k6 [i])
				i := i + 1
			end

			-- RK5 solution: y + dt * (5179/57600*k1 + 7571/16695*k3 + 393/640*k4 - 92097/339200*k5 + 187/2100*k6 + 1/40*k2)
			create l_y_rk5.make_filled (0.0, y.lower, y.upper)
			from i := y.lower until i > y.upper loop
				l_y_rk5 [i] := y [i] + dt * ((5179.0 / 57600.0) * l_k1 [i] + (1.0 / 40.0) * l_k2 [i] +
					(7571.0 / 16695.0) * l_k3 [i] + (393.0 / 640.0) * l_k4 [i] -
					(92097.0 / 339200.0) * l_k5 [i] + (187.0 / 2100.0) * l_k6 [i])
				i := i + 1
			end

			-- Error: max |y_rk5 - y_rk4|
			l_error := 0.0
			from i := y.lower until i > y.upper loop
				if (l_y_rk5 [i] - l_y_rk4 [i]).abs > l_error then
					l_error := (l_y_rk5 [i] - l_y_rk4 [i]).abs
				end
				i := i + 1
			end

			Result := [l_y_rk4, l_y_rk5, l_error]
		ensure
			result_not_void: Result /= Void
			y_rk4_dimension: Result.y_rk4.count = y.count
			y_rk5_dimension: Result.y_rk5.count = y.count
			error_non_negative: Result.error >= 0.0
		end

end
