# INTERFACE DESIGN: simple_ode

## Public API Summary

### Entry Point: SIMPLE_ODE

| Feature | Purpose | Typical Use |
|---------|---------|-------------|
| make | Default creation | `create solver.make` |
| set_absolute_tolerance (a_tol: REAL_64) | Configure abs tolerance | `.set_absolute_tolerance (1.0e-6)` |
| set_relative_tolerance (a_tol: REAL_64) | Configure rel tolerance | `.set_relative_tolerance (1.0e-8)` |
| solve (f, y0, t_start, t_end) | Solve ODE system | `.solve (f, [1.0, 2.0, 3.0], 0.0, 10.0)` |

### Builder Pattern Example

```eiffel
local
    solver: SIMPLE_ODE
    result: ODE_RESULT
    f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]]
    y0: ARRAY [REAL_64]
do
    create solver.make

    solver.set_absolute_tolerance (1.0e-8)
         .set_relative_tolerance (1.0e-6)

    create y0.make_filled (0.0, 1, 3)
    y0[1] := 1.0  -- x
    y0[2] := 0.0  -- y
    y0[3] := 0.0  -- z (Lorenz initial condition)

    -- f is user-provided callback computing derivatives
    result := solver.solve (f, y0, 0.0, 10.0)

    -- Access results
    print ("Final time: " + result.t_final.out)
    print ("Steps: " + result.accepted_steps.out)
    print ("Final state: " + result.y_final[1].out)
end
```

### User-Provided Derivative Function

```eiffel
-- Example: Lorenz system
-- dx/dt = σ(y - x)
-- dy/dt = x(ρ - z) - y
-- dz/dt = xy - βz

local
    f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]]
    sigma, rho, beta: REAL_64
do
    sigma := 10.0
    rho := 28.0
    beta := 8.0 / 3.0

    create f.make (
        agent (t: REAL_64; y: ARRAY [REAL_64]): ARRAY [REAL_64]
            local
                dydt: ARRAY [REAL_64]
            do
                create dydt.make_filled (0.0, 1, 3)
                dydt[1] := sigma * (y[2] - y[1])
                dydt[2] := y[1] * (rho - y[3]) - y[2]
                dydt[3] := y[1] * y[2] - beta * y[3]
                Result := dydt
            end
    )
end
```

### Query Results (ODE_RESULT)

| Feature | Returns | Purpose |
|---------|---------|---------|
| y_final | ARRAY [REAL_64] | Final state values |
| t_final | REAL_64 | Final time (should be >= t_end) |
| y_initial | ARRAY [REAL_64] | Starting state (copy) |
| accepted_steps | INTEGER | Successful integration steps |
| rejected_steps | INTEGER | Failed steps (retried with smaller dt) |
| function_evaluations | INTEGER | Total f(t,y) calls |
| is_stiff | BOOLEAN | TRUE if stiffness detected (tiny steps) |
| solution_curve | SOLUTION_CURVE | Dense output for arbitrary time queries |

### Dense Output (Solution Interpolation)

```eiffel
local
    result: ODE_RESULT
    curve: SOLUTION_CURVE
    y_at_5: ARRAY [REAL_64]
do
    result := solver.solve (f, y0, 0.0, 10.0)
    curve := result.solution_curve

    -- Query solution at arbitrary time
    y_at_5 := curve.interpolate (5.0)  -- Time 5.0

    -- Use interpolated state
    print ("x(5.0) = " + y_at_5[1].out)
    print ("y(5.0) = " + y_at_5[2].out)
    print ("z(5.0) = " + y_at_5[3].out)
end
```

## Command-Query Separation

| Feature | Type | Modifies? | Returns |
|---------|------|-----------|---------|
| set_absolute_tolerance | Command | YES | like Current |
| set_relative_tolerance | Command | YES | like Current |
| solve | Command | YES | ODE_RESULT |
| accepted_steps | Query | NO | INTEGER |
| y_final | Query | NO | ARRAY [REAL_64] |
| is_stiff | Query | NO | BOOLEAN |

## Error Handling Pattern

```eiffel
local
    result: ODE_RESULT
do
    result := solver.solve (f, y0, 0.0, 10.0)

    if result.is_stiff then
        print ("WARNING: Stiff behavior detected")
        print ("Step size fell below threshold")
        print ("Consider using Phase 2 implicit methods")
    end

    if result.rejected_steps > result.accepted_steps then
        print ("Many rejections; problem may be difficult")
    end

    -- Always get the result (no exceptions)
    process_solution (result.y_final, result.solution_curve)
end
```

## Fluent API Examples

### Example 1: Solve with Custom Tolerances
```eiffel
result := create {SIMPLE_ODE}.make
    .set_absolute_tolerance (1.0e-8)
    .set_relative_tolerance (1.0e-6)
    .solve (lorenz_derivative, [1.0, 0.0, 0.0], 0.0, 10.0)
```

### Example 2: Access Solution at Multiple Times
```eiffel
local
    curve: SOLUTION_CURVE
    times: ARRAY [REAL_64]
    i: INTEGER
do
    curve := result.solution_curve

    -- Sample solution at 100 time points
    from i := 1 until i > 100 loop
        y := curve.interpolate (i * 0.1)
        plot_point (i * 0.1, y)
        i := i + 1
    end
end
```

### Example 3: Ensemble Parameter Sweep with SCOOP
```eiffel
-- Solve same ODE with different parameters concurrently
local
    solver: SIMPLE_ODE
    results: ARRAY [ODE_RESULT]
    p: REAL_64
do
    from p := 0.1 until p > 5.0 by 0.1 loop
        -- Each parameter variation runs concurrently
        create solver.make
        results[...] := solver
            .set_absolute_tolerance (1.0e-8)
            .solve (make_ode_for_parameter (p), y0, 0.0, 10.0)
        -- SCOOP safe: each solver independent, result immutable
    end
end
```

## Status Queries

| Feature | Returns | Purpose |
|---------|---------|---------|
| accepted_steps | INTEGER | How many integration steps succeeded |
| rejected_steps | INTEGER | How many steps failed (retried) |
| function_evaluations | INTEGER | Total derivative function calls |
| is_stiff | BOOLEAN | Stiffness warning indicator |

## Immutability Pattern

ODE_RESULT is immutable:
```eiffel
result := solver.solve (...)

-- Cannot modify result; safe for SCOOP sharing
print (result.y_final[1])  -- OK
print (result.accepted_steps)  -- OK

-- y_final is copy, not reference to internal state
y := result.y_final
y[1] := 99.0  -- Does not affect result
```

## API Consistency

| Pattern | Example | Purpose |
|---------|---------|---------|
| Getter | y_final, t_final, accepted_steps | Query state |
| Setter | set_absolute_tolerance | Configure solver |
| Boolean query | is_stiff | Test property |
| Factory | make, solution_curve | Create objects |
| Builder method | Returns like Current | Chain configuration |

## Summary of Public Classes

**SIMPLE_ODE** (facade entry point)
- make
- set_absolute_tolerance (a_tol: REAL_64): like Current
- set_relative_tolerance (a_tol: REAL_64): like Current
- solve (f, y0, t_start, t_end): ODE_RESULT

**ODE_RESULT** (immutable results)
- y_final: ARRAY [REAL_64]
- t_final: REAL_64
- y_initial: ARRAY [REAL_64]
- accepted_steps: INTEGER
- rejected_steps: INTEGER
- function_evaluations: INTEGER
- is_stiff: BOOLEAN
- solution_curve: SOLUTION_CURVE

**SOLUTION_CURVE** (dense output)
- interpolate (a_t: REAL_64): ARRAY [REAL_64]
- t_start, t_end: REAL_64
- dimension: INTEGER
