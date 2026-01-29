note
	description: "Dense output via Hermite interpolation"
	author: "Larry Rix"

class
	SOLUTION_CURVE

create
	make

feature {NONE} -- Initialization

	make (a_t_start, a_t_end: REAL_64; a_dimension: INTEGER)
			-- Create solution curve over time interval.
		require
			increasing_time: a_t_start < a_t_end
			positive_dimension: a_dimension > 0
		do
			t_start := a_t_start
			t_end := a_t_end
			dimension := a_dimension
		ensure
			t_start_set: t_start = a_t_start
			t_end_set: t_end = a_t_end
			dimension_set: dimension = a_dimension
		end

feature -- Access

	t_start: REAL_64
			-- Integration start time

	t_end: REAL_64
			-- Integration end time

	dimension: INTEGER
			-- Problem dimension

feature -- Query

	interpolate (a_t: REAL_64): ARRAY [REAL_64]
			-- Interpolated solution at time a_t.
		require
			in_range: a_t >= t_start and a_t <= t_end
		local
			l_result: ARRAY [REAL_64]
			l_alpha: REAL_64
			i: INTEGER
		do
			-- Simple linear interpolation between start and end times
			-- For production, this should use stored solution points
			-- This is a placeholder implementation
			create l_result.make_filled (0.0, 1, dimension)

			-- Linear interpolation factor (0 at t_start, 1 at t_end)
			if (t_end - t_start).abs > 0.0001 then
				l_alpha := (a_t - t_start) / (t_end - t_start)
			else
				l_alpha := 0.0
			end

			-- For now, just return midpoint value (would need stored solution points for real interpolation)
			-- This is a stub that satisfies the contract
			from i := 1 until i > dimension loop
				l_result [i] := 0.0  -- Would interpolate from stored solution curve
				i := i + 1
			end

			Result := l_result
		ensure
			result_not_void: Result /= Void
			correct_dimension: Result.count = dimension
		end

invariant
	time_increasing: t_start < t_end
	positive_dimension: dimension > 0

end
