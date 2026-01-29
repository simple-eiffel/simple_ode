note
	description: "ODE solution state (time + solution vector)"
	author: "Larry Rix"

class
	ODE_STATE

create
	make

feature {NONE} -- Initialization

	make (a_t: REAL_64; a_y: ARRAY [REAL_64]; a_remaining: REAL_64)
			-- Create ODE state at time t with solution vector y.
		require
			y_not_void: a_y /= Void
			y_not_empty: a_y.count > 0
			remaining_non_negative: a_remaining >= 0.0
		do
			t := a_t
			y := a_y
			remaining_time := a_remaining
		ensure
			t_set: t = a_t
			y_set: y = a_y
			remaining_set: remaining_time = a_remaining
		end

feature -- Access

	t: REAL_64
			-- Current time

	y: ARRAY [REAL_64]
			-- Solution vector

	remaining_time: REAL_64
			-- Time remaining to integrate

	y_norm: REAL_64
			-- Norm of solution vector ||y||
		local
			i: INTEGER
			sum: REAL_64
		do
			sum := 0.0
			from i := y.lower until i > y.upper loop
				sum := sum + y [i] * y [i]
				i := i + 1
			end
			Result := (sum).sqrt
		ensure
			non_negative: Result >= 0.0
		end

invariant
	y_not_void: y /= Void
	y_not_empty: y.count > 0

end
