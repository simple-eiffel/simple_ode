# CONTRACT DESIGN: simple_ode

## Class Contracts

### SIMPLE_ODE

```eiffel
set_absolute_tolerance (a_tol: REAL_64): like Current
    require
        positive_tolerance: a_tol > 0.0
        reasonable_tolerance: a_tol < 1.0e-1
    ensure
        tolerance_set: absolute_tolerance = a_tol
        result_current: Result = Current

set_relative_tolerance (a_tol: REAL_64): like Current
    require
        positive_tolerance: a_tol > 0.0
        reasonable_tolerance: a_tol < 1.0e-2
    ensure
        tolerance_set: relative_tolerance = a_tol
        result_current: Result = Current

solve (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]];
       y0: ARRAY [REAL_64];
       t_start, t_end: REAL_64): ODE_RESULT
    require
        f_not_void: f /= Void
        y0_not_void: y0 /= Void
        y0_not_empty: y0.count > 0
        increasing_time: t_start < t_end
        tolerances_set: absolute_tolerance > 0.0 and relative_tolerance > 0.0
    ensure
        result_not_void: Result /= Void
        final_state_dimension: Result.y_final.count = y0.count
        final_time_reached: Result.t_final >= t_end - 1.0e-10
        monotone_steps: Result.accepted_steps > 0
```

### ODE_SOLVER

```eiffel
integrate_step (a_state: ODE_STATE; a_dt: REAL_64): ODE_STATE
    require
        state_not_void: a_state /= Void
        positive_dt: a_dt > 0.0
        dt_bounded: a_dt < a_state.remaining_time
    ensure
        result_not_void: Result /= Void
        time_advanced: Result.t = a_state.t + a_dt
        dimension_unchanged: Result.y.count = a_state.y.count
        monotone_time: Result.t >= a_state.t

check_error_control (a_error: REAL_64; a_state: ODE_STATE): BOOLEAN
    require
        error_non_negative: a_error >= 0.0
        state_not_void: a_state /= Void
    ensure
        -- Returns TRUE if error <= tolerance
        result_means_accept: Result implies
            a_error <= absolute_tolerance +
            relative_tolerance * a_state.y_norm
```

### RK45_INTEGRATOR

```eiffel
rk45_step (a_state: ODE_STATE; a_dt: REAL_64): TUPLE [y: ARRAY [REAL_64];
                                                        error: REAL_64]
    require
        state_not_void: a_state /= Void
        positive_dt: a_dt > 0.0
    ensure
        result_dimension: Result.y.count = a_state.y.count
        error_non_negative: Result.error >= 0.0
        error_bounded: Result.error < 1.0e-3 * a_dt
        -- RK4 order O(h^5) local error
```

### ODE_RESULT

```eiffel
invariant
    result_not_void: y_final /= Void
    statistics_valid: accepted_steps > 0
    function_evals_positive: function_evaluations >= accepted_steps * 4
    -- At least 4 evaluations per RK4 step
    time_advanced: t_final > t_start
    dimension_preserved: y_final.count = y_initial.count
```

## Design by Contract Principles

1. **Preconditions enforce input validity:** Positive tolerances, increasing time bounds
2. **Postconditions verify outputs:** Final state matches dimension, time monotonic
3. **Invariants maintain class correctness:** Statistics consistent, dimension unchanged
4. **Frame conditions specify unchanged:** y dimension, starting conditions
5. **MML not needed Phase 1:** Simple value results, not collections

## Contract Completeness

Every public feature answers:
- **What changed?** Time advanced, state updated
- **How changed?** RK4 step formula applied
- **What didn't change?** Dimension of y vector, initial conditions

## Error Specification

RK45 embedded pair error control:
```
error_estimate = ||y_RK4 - y_RK5|| / (atol + rtol * ||y||)
step_accepted if error_estimate <= 1.0
step_rejected if error_estimate > 1.0 (retry with smaller dt)
```

## Convergence Guarantees

**RK4 convergence order:**
- Global error O(h⁴) where h = average step size
- Local error O(h⁵)
- Achieves contract specifications on test problems

**RK45 error control:**
- Adapts step size to maintain error < tolerance
- Contracts verify tolerance respected
