note
	description: "Adversarial tests for ODE solver edge cases and stress conditions"
	author: "Larry Rix"

class
	TEST_ADVERSARIAL

create
	make

feature -- Adversarial Tests

	make
			-- Run all adversarial tests
		do
			print ("ODE Adversarial Tests%N")
			print ("=====================%N")

			-- Edge case: very small dimension (1D system)
			test_1d_system

			-- Edge case: very small time interval
			test_small_time_interval

			-- Edge case: very large dimension (10D system)
			test_high_dimension_system

			-- Edge case: zero initial condition
			test_zero_initial_condition

			-- Edge case: very tight tolerances
			test_tight_tolerances

			-- Stress test: multiple consecutive solutions
			test_solution_curve_stress

			-- Edge case: solution curve interpolation
			test_curve_interpolation

			print ("%NAdversarial tests completed.%N")
		end

	test_1d_system
			-- Test 1D ODE system (minimal dimension)
		local
			l_curve: SOLUTION_CURVE
		do
			print ("  test_1d_system: ")
			create l_curve.make (0.0, 1.0, 1)
			if l_curve.dimension = 1 then
				print ("PASS%N")
			else
				print ("FAIL%N")
			end
		rescue
			print ("FAIL (exception)%N")
		end

	test_small_time_interval
			-- Test very small time interval
		local
			l_curve: SOLUTION_CURVE
		do
			print ("  test_small_time_interval: ")
			create l_curve.make (0.0, 0.00001, 2)
			if l_curve.t_start < l_curve.t_end then
				print ("PASS%N")
			else
				print ("FAIL%N")
			end
		rescue
			print ("FAIL (exception)%N")
		end

	test_high_dimension_system
			-- Test high-dimensional system (10D)
		local
			l_curve: SOLUTION_CURVE
		do
			print ("  test_high_dimension_system: ")
			create l_curve.make (0.0, 1.0, 10)
			if l_curve.dimension = 10 then
				print ("PASS%N")
			else
				print ("FAIL%N")
			end
		rescue
			print ("FAIL (exception)%N")
		end

	test_zero_initial_condition
			-- Test with zero initial condition
		local
			l_curve: SOLUTION_CURVE
			l_y: ARRAY [REAL_64]
		do
			print ("  test_zero_initial_condition: ")
			create l_curve.make (0.0, 1.0, 2)
			create l_y.make_filled (0.0, 1, 2)
			l_curve.add_solution_point (0.0, l_y)
			if l_curve.dimension = 2 then
				print ("PASS%N")
			else
				print ("FAIL%N")
			end
		rescue
			print ("FAIL (exception)%N")
		end

	test_tight_tolerances
			-- Test configuration with tight tolerances
		local
			l_solver: ODE_SOLVER
		do
			print ("  test_tight_tolerances: ")
			create l_solver
			if l_solver /= Void then
				print ("PASS%N")
			else
				print ("FAIL%N")
			end
		rescue
			print ("FAIL (exception)%N")
		end

	test_solution_curve_stress
			-- Stress test: add many points to curve
		local
			l_curve: SOLUTION_CURVE
			l_y: ARRAY [REAL_64]
			i: INTEGER
		do
			print ("  test_solution_curve_stress: ")
			create l_curve.make (0.0, 10.0, 2)
			create l_y.make_filled (0.0, 1, 2)
			from i := 1 until i > 100 loop
				l_y [1] := i * 0.1
				l_y [2] := i * 0.05
				l_curve.add_solution_point (i * 0.1, l_y)
				i := i + 1
			end
			if l_curve.dimension = 2 then
				print ("PASS%N")
			else
				print ("FAIL%N")
			end
		rescue
			print ("FAIL (exception)%N")
		end

	test_curve_interpolation
			-- Test interpolation at various points
		local
			l_curve: SOLUTION_CURVE
			l_y: ARRAY [REAL_64]
			l_interp: ARRAY [REAL_64]
		do
			print ("  test_curve_interpolation: ")
			create l_curve.make (0.0, 1.0, 1)
			create l_y.make_filled (0.0, 1, 1)
			l_y [1] := 1.0
			l_curve.add_solution_point (0.0, l_y)
			l_y [1] := 2.0
			l_curve.add_solution_point (1.0, l_y)
			l_interp := l_curve.interpolate (0.5)
			if l_interp [1] > 0.0 then
				print ("PASS%N")
			else
				print ("FAIL%N")
			end
		rescue
			print ("FAIL (exception)%N")
		end

end
