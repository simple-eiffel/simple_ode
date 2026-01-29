note
	description: "SCOOP consumer compatibility test for simple_ode"

class TEST_SCOOP_CONSUMER

inherit
	EQA_TEST_SET

feature -- Tests

	test_scoop_compatibility
			-- Verify library types work in SCOOP context.
		local
			l_solver: SIMPLE_ODE
			l_result: ODE_RESULT
		do
			-- Create instances using library's main types
			create l_solver.make
			l_solver.set_absolute_tolerance (0.00000001)
			l_solver.set_relative_tolerance (0.000001)

			-- Minimal usage to trigger type checking in SCOOP context
			assert ("solver created", l_solver /= Void)
		end

end
