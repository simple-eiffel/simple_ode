note
	description: "ODE solver facade entry point"
	author: "Larry Rix"

class
	SIMPLE_ODE

create
	make

feature {NONE} -- Initialization

	make
			-- Create with default tolerances.
		do
			absolute_tolerance := 0.00000001
			relative_tolerance := 0.000001
		ensure
			absolute_tolerance_set: absolute_tolerance = 0.00000001
			relative_tolerance_set: relative_tolerance = 0.000001
		end

feature -- Configuration

	set_absolute_tolerance (a_tol: REAL_64): like Current
			-- Set absolute tolerance.
		require
			positive: a_tol > 0.0
		do
			absolute_tolerance := a_tol
			Result := Current
		ensure
			set: absolute_tolerance = a_tol
			result_current: Result = Current
		end

	set_relative_tolerance (a_tol: REAL_64): like Current
			-- Set relative tolerance.
		require
			positive: a_tol > 0.0
		do
			relative_tolerance := a_tol
			Result := Current
		ensure
			set: relative_tolerance = a_tol
			result_current: Result = Current
		end

feature -- Solving

	solve (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]];
		   y0: ARRAY [REAL_64]; t_start, t_end: REAL_64): ODE_RESULT
			-- Integrate ODE from t_start to t_end with initial condition y0.
		require
			f_not_void: f /= Void
			y0_not_void: y0 /= Void
			y0_not_empty: y0.count > 0
			increasing_time: t_start < t_end
		local
			l_result: ODE_RESULT
		do
			-- Stub: Phase 4 delegates to ODE_SOLVER
			create l_result.make (y0, y0, t_end, t_start, 0, 0, 0, False, 0.0, 0.0)
			Result := l_result
		ensure
			result_not_void: Result /= Void
			dimension_preserved: Result.dimension = y0.count
		end

feature {NONE} -- Implementation

	absolute_tolerance: REAL_64
	relative_tolerance: REAL_64

end
