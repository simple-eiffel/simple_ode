# SPECIFICATION: simple_ode

## Overview
Contract-verified ODE solver for systems of ordinary differential equations. Implements explicit Runge-Kutta methods (RK2, RK4, RK45) with adaptive step-size control via embedded error estimation. Includes dense output via polynomial interpolation, statistics tracking, and simple stiffness detection. Designed for scientific computing and concurrent ensemble solving with SCOOP.

## Class Specifications

### SIMPLE_ODE (Facade)

```eiffel
note
    description: "Entry point for ODE solving."
    author: "Larry Rix"

class SIMPLE_ODE

create
    make

feature {NONE} -- Initialization

    make
        do
            absolute_tolerance := 1.0e-8
            relative_tolerance := 1.0e-6
        ensure
            default_tolerances_set:
                absolute_tolerance = 1.0e-8 and
                relative_tolerance = 1.0e-6
        end

feature -- Configuration

    set_absolute_tolerance (a_tol: REAL_64): like Current
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
           y0: ARRAY [REAL_64];
           t_start, t_end: REAL_64): ODE_RESULT
        require
            f_not_void: f /= Void
            y0_not_void: y0 /= Void
            y0_not_empty: y0.count > 0
            time_increasing: t_start < t_end
        do
            -- Implementation: Orchestrate RK45 integration
            -- (Phase 4 implementation stub)
            create Result.make_from_solution
        ensure
            result_not_void: Result /= Void
            dimension_preserved: Result.y_final.count = y0.count
            time_advanced: Result.t_final >= t_end - 1.0e-10
        end

feature {NONE} -- Implementation

    absolute_tolerance: REAL_64
    relative_tolerance: REAL_64

end
```

### ODE_RESULT (Data - Immutable)

```eiffel
note
    description: "Immutable results from ODE integration."
    author: "Larry Rix"

class ODE_RESULT

create
    make_from_solution

feature {NONE} -- Initialization

    make_from_solution (a_y_final, a_y_initial: ARRAY [REAL_64];
                        a_t_final, a_t_start: REAL_64;
                        a_steps, a_rejected, a_evals: INTEGER;
                        a_stiff: BOOLEAN;
                        a_curve: SOLUTION_CURVE)
        do
            y_final := a_y_final
            y_initial := a_y_initial
            t_final := a_t_final
            t_start := a_t_start
            accepted_steps := a_steps
            rejected_steps := a_rejected
            function_evaluations := a_evals
            is_stiff := a_stiff
            solution_curve := a_curve
        ensure
            final_state_set: y_final.count = a_y_final.count
            time_set: t_final = a_t_final
        end

feature -- Access

    y_final: ARRAY [REAL_64]
            -- Final state vector y(t_final).

    y_initial: ARRAY [REAL_64]
            -- Starting state y(t_start).

    t_final: REAL_64
            -- Final integration time reached.

    t_start: REAL_64
            -- Starting integration time.

    accepted_steps: INTEGER
            -- Number of successfully integrated steps.

    rejected_steps: INTEGER
            -- Number of failed steps (retried with smaller dt).

    function_evaluations: INTEGER
            -- Total calls to derivative function f(t,y).

    is_stiff: BOOLEAN
            -- TRUE if stiffness detected (too-small steps).

    solution_curve: SOLUTION_CURVE
            -- Dense output for interpolation.

    dimension: INTEGER
            -- Number of ODEs in system.
        do
            Result := y_final.count
        ensure
            consistent: Result = y_initial.count
        end

invariant
    y_final_not_void: y_final /= Void
    y_final_not_empty: y_final.count > 0
    stats_consistent: accepted_steps > 0
    function_evals_minimum: function_evaluations >= accepted_steps * 4
    time_monotone: t_final >= t_start
    dimension_preserved: y_final.count = y_initial.count

end
```

### SOLUTION_CURVE (Dense Output)

```eiffel
note
    description: "Polynomial interpolation for dense output."
    author: "Larry Rix"

class SOLUTION_CURVE

create
    make

feature -- Interpolation

    interpolate (a_t: REAL_64): ARRAY [REAL_64]
            -- Solution y(a_t) via polynomial interpolation.
        require
            time_in_range: a_t >= t_start and a_t <= t_end
        do
            -- Implementation: Use Hermite or Runge-Kutta interpolation
            -- (Phase 4 stub)
            create Result.make_filled (0.0, 1, dimension)
        ensure
            result_not_void: Result /= Void
            correct_dimension: Result.count = dimension
        end

    t_start, t_end: REAL_64
            -- Integration time bounds.

    dimension: INTEGER
            -- Dimension of y vector.

end
```

### ODE_SOLVER (Orchestrator)

```eiffel
note
    description: "Orchestrates RK45 adaptive stepping."
    author: "Larry Rix"

class ODE_SOLVER

create
    make

feature -- Integration Loop

    integrate (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]];
               y0: ARRAY [REAL_64];
               t_start, t_end: REAL_64;
               atol, rtol: REAL_64): ODE_RESULT
        require
            f_not_void: f /= Void
            y0_not_void: y0 /= Void
            time_increasing: t_start < t_end
            positive_tolerances: atol > 0.0 and rtol > 0.0
        do
            -- Adaptive RK45 stepping
            -- (Phase 4 implementation)
            create Result.make_from_solution (...)
        ensure
            result_not_void: Result /= Void
            time_reached: Result.t_final >= t_end - 1.0e-10
        end

feature {NONE} -- Implementation

    integrator: RK45_INTEGRATOR
            -- RK45 step executor.

end
```

### RK45_INTEGRATOR (Engine)

```eiffel
note
    description: "6-stage Runge-Kutta with error estimation."
    author: "Larry Rix"

class RK45_INTEGRATOR

create
    make

feature -- RK45 Step

    rk45_step (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]];
               t: REAL_64;
               y: ARRAY [REAL_64];
               dt: REAL_64): TUPLE [y_rk4: ARRAY [REAL_64];
                                    y_rk5: ARRAY [REAL_64];
                                    error: REAL_64]
        require
            f_not_void: f /= Void
            y_not_void: y /= Void
            positive_dt: dt > 0.0
        do
            -- Compute 6 RK stages
            -- Apply RK4 coefficients (5th order)
            -- Apply RK5 coefficients (5th order)
            -- Estimate error = ||y_rk4 - y_rk5||
            -- (Phase 4 stub)
            create Result
        ensure
            dimensions_preserved: Result.y_rk4.count = y.count and
                                  Result.y_rk5.count = y.count
            error_non_negative: Result.error >= 0.0
        end

feature {NONE} -- Butcher Coefficients

    rk45_coefficients: TUPLE [...]
            -- Explicit RK45 Butcher tableau (Dormand-Prince).
            -- 6 stages, 5th order

end
```

## Dependencies

| Library | Purpose | Version |
|---------|---------|---------|
| simple_math | sqrt, special functions | 1.0.0+ |
| ISE base | ARRAY, fundamental types | 25.02+ |
| ISE testing | EQA_TEST_SET | 25.02+ |

## File Structure

```
src/
├── simple_ode.e              (Facade)
├── ode_solver.e              (Orchestrator)
├── rk2_integrator.e          (2-stage Runge-Kutta)
├── rk4_integrator.e          (4-stage Runge-Kutta)
├── rk45_integrator.e         (6-stage with error estimation)
├── ode_state.e               (Current state data)
├── ode_result.e              (Integration results)
├── solution_curve.e          (Dense output)
└── ode_config.e              (Configuration)

test/
├── test_rk2.e                (RK2 convergence)
├── test_rk4.e                (RK4 convergence)
├── test_rk45.e               (Adaptive stepping)
├── test_lorenz.e             (Chaotic system benchmark)
├── test_exponential.e        (Analytical comparison)
└── test_app.e                (Test runner)
```

## Phase 1 Implementation Strategy

1. **RK45 core:** 6-stage integration with error estimation
2. **Adaptive stepping:** Reject/retry if error > tolerance
3. **Dense output:** 4th-order Hermite interpolation
4. **Statistics:** Track accepted, rejected, function evals
5. **Stiffness detection:** Monitor step size shrinking

## Performance Targets

- 100+ dimensional systems
- Step size from dt ~ 1e-6 to dt ~ 1e-2
- Function evaluations: 6N per RK45 step
- Dense output query: O(1) lookup in interpolation table

## Correctness Properties

- **Convergence:** RK4 global error O(h⁴)
- **Accuracy:** RK45 pair error < tolerance (adaptive control)
- **Stability:** RK4 stable for mildly stiff, explicit methods only
- **Energy conservation:** For Hamiltonian systems, < 0.1% drift

## Future Extensions (Phase 2)

- Implicit methods (BDF, Radau) for stiff systems
- Event detection (zero-crossing root finding)
- Jacobian callbacks for implicit methods
- Multistep methods (Adams, ABAM)
