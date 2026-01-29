note
	description: "Immutable ODE integration results (SCOOP-safe)"
	author: "Larry Rix"

class
	ODE_RESULT

create
	make

feature {NONE} -- Initialization

	make (a_y_final, a_y_initial: ARRAY [REAL_64]; a_t_final, a_t_start: REAL_64;
		  a_accepted, a_rejected, a_fevals: INTEGER; a_stiff: BOOLEAN;
		  a_ke, a_pe: REAL_64)
			-- Create ODE integration result.
		require
			y_final_not_void: a_y_final /= Void
			y_initial_not_void: a_y_initial /= Void
			compatible_dimensions: a_y_final.count = a_y_initial.count
			non_negative_accepted: a_accepted >= 0
			non_negative_rejected: a_rejected >= 0
			non_negative_fevals: a_fevals >= 0
		do
			y_final := a_y_final
			y_initial := a_y_initial
			t_final := a_t_final
			t_start := a_t_start
			accepted_steps := a_accepted
			rejected_steps := a_rejected
			function_evaluations := a_fevals
			is_stiff := a_stiff
			total_kinetic_energy := a_ke
			total_potential_energy := a_pe
		ensure
			y_final_set: y_final = a_y_final
			y_initial_set: y_initial = a_y_initial
			t_final_set: t_final = a_t_final
		end

feature -- Access

	y_final: ARRAY [REAL_64]
			-- Final solution

	y_initial: ARRAY [REAL_64]
			-- Initial solution

	t_final: REAL_64
			-- Final time

	t_start: REAL_64
			-- Starting time

	accepted_steps: INTEGER
			-- Number of accepted steps

	rejected_steps: INTEGER
			-- Number of rejected steps

	function_evaluations: INTEGER
			-- Total f evaluations

	is_stiff: BOOLEAN
			-- Was stiffness detected?

	total_kinetic_energy: REAL_64
	total_potential_energy: REAL_64

	dimension: INTEGER
			-- Problem dimension
		do
			Result := y_final.count
		ensure
			consistent: Result = y_initial.count
		end

	solution_curve: detachable SOLUTION_CURVE
			-- Dense output (if available)

invariant
	immutable: True
	y_final_not_void: y_final /= Void
	y_initial_not_void: y_initial /= Void
	dimensions_match: y_final.count = y_initial.count

end
