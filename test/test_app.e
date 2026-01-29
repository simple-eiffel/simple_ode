note
	description: "Test application runner"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run all tests.
		do
			print ("Running simple_ode test suite...%N%N")
			passed := 0
			failed := 0

			print ("ODE Integration Tests%N")
			print ("=====================%N")

			-- Test that core classes can be instantiated
			test_rk2_integrator
			test_rk4_integrator
			test_rk45_integrator
			test_ode_solver
			test_solution_curve
			test_simple_ode

			print_summary

			-- Phase 6: Adversarial tests
			create l_adversarial.make
		end

feature {NONE} -- Tests

	test_rk2_integrator
			-- Test RK2 integrator creation.
		local
			l_integrator: RK2_INTEGRATOR
		do
			if not failed_flag then
				create l_integrator
				passed := passed + 1
				print ("  PASS: test_rk2_integrator%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_rk2_integrator%N")
		end

	test_rk4_integrator
			-- Test RK4 integrator creation.
		local
			l_integrator: RK4_INTEGRATOR
		do
			if not failed_flag then
				create l_integrator
				passed := passed + 1
				print ("  PASS: test_rk4_integrator%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_rk4_integrator%N")
		end

	test_rk45_integrator
			-- Test RK45 integrator creation.
		local
			l_integrator: RK45_INTEGRATOR
		do
			if not failed_flag then
				create l_integrator
				passed := passed + 1
				print ("  PASS: test_rk45_integrator%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_rk45_integrator%N")
		end

	test_ode_solver
			-- Test ODE solver creation.
		local
			l_solver: ODE_SOLVER
		do
			if not failed_flag then
				create l_solver
				passed := passed + 1
				print ("  PASS: test_ode_solver%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_ode_solver%N")
		end

	test_solution_curve
			-- Test solution curve creation.
		local
			l_curve: SOLUTION_CURVE
		do
			if not failed_flag then
				create l_curve.make (0.0, 1.0, 1)
				passed := passed + 1
				print ("  PASS: test_solution_curve%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_solution_curve%N")
		end

	test_simple_ode
			-- Test simple_ode facade creation.
		local
			l_ode: SIMPLE_ODE
		do
			if not failed_flag then
				create l_ode.make
				passed := passed + 1
				print ("  PASS: test_simple_ode%N")
			end
		rescue
			failed := failed + 1
			print ("  FAIL: test_simple_ode%N")
		end

feature {NONE} -- Test Execution

	print_summary
			-- Print test results summary.
		do
			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")
			print ("Total: " + (passed + failed).out + " tests%N")
			print ("========================%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER
	failed_flag: BOOLEAN
	l_adversarial: TEST_ADVERSARIAL

end
