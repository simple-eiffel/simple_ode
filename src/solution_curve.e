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
			create solution_points.make (100)
			create time_points.make (100)
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

feature -- Modification

	add_solution_point (a_t: REAL_64; a_y: ARRAY [REAL_64])
			-- Store solution point at time a_t.
		require
			valid_time: a_t >= t_start and a_t <= t_end
			valid_dimension: a_y.count = dimension
		local
			l_y_copy: ARRAY [REAL_64]
			i: INTEGER
		do
			create l_y_copy.make_filled (0.0, 1, dimension)
			from i := 1 until i > dimension loop
				l_y_copy [i] := a_y [i]
				i := i + 1
			end
			time_points.extend (a_t)
			solution_points.extend (l_y_copy)
		ensure
			point_added: time_points.count = old time_points.count + 1
		end

feature -- Query

	interpolate (a_t: REAL_64): ARRAY [REAL_64]
			-- Interpolated solution at time a_t via linear interpolation.
		require
			in_range: a_t >= t_start and a_t <= t_end
		local
			l_result: ARRAY [REAL_64]
			l_alpha: REAL_64
			l_i: INTEGER
			l_i_next: INTEGER
			l_t1, l_t2: REAL_64
			l_y1, l_y2: ARRAY [REAL_64]
			i: INTEGER
		do
			create l_result.make_filled (0.0, 1, dimension)

			if time_points.count < 2 then
				-- No stored points; return zero vector (degenerate case)
				Result := l_result
			else
				-- Find the two adjacent stored points that bracket a_t
				from l_i := 1 until l_i > time_points.count - 1 loop
					if time_points [l_i] <= a_t and a_t <= time_points [l_i + 1] then
						l_i_next := l_i + 1

						l_t1 := time_points [l_i]
						l_t2 := time_points [l_i_next]
						l_y1 := solution_points [l_i]
						l_y2 := solution_points [l_i_next]

						-- Linear interpolation factor
						if (l_t2 - l_t1).abs > 0.0001 then
							l_alpha := (a_t - l_t1) / (l_t2 - l_t1)
						else
							l_alpha := 0.0
						end

						-- Interpolate each dimension
						from i := 1 until i > dimension loop
							l_result [i] := l_y1 [i] + l_alpha * (l_y2 [i] - l_y1 [i])
							i := i + 1
						end

						l_i := time_points.count  -- Exit loop
					end
					l_i := l_i + 1
				end
			end

			Result := l_result
		ensure
			result_not_void: Result /= Void
			correct_dimension: Result.count = dimension
		end

feature {NONE} -- Implementation

	solution_points: ARRAYED_LIST [ARRAY [REAL_64]]
			-- Stored solution vectors at each time point

	time_points: ARRAYED_LIST [REAL_64]
			-- Time values at each solution point

invariant
	time_increasing: t_start < t_end
	positive_dimension: dimension > 0
	points_synchronized: solution_points.count = time_points.count

end
