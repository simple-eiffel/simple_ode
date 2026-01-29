# CLASS DESIGN: simple_ode

## Class Inventory

| Class | Role | Responsibility |
|-------|------|-----------------|
| SIMPLE_ODE | Facade | Entry point, configure solver |
| ODE_SOLVER | Engine | Orchestrate integration, error control |
| RK2_INTEGRATOR | Engine | RK2 (midpoint) integration step |
| RK4_INTEGRATOR | Engine | RK4 integration step |
| RK45_INTEGRATOR | Engine | RK45 with error estimation |
| ODE_STATE | Data | Current y vector, time t |
| ODE_CONFIG | Data | Tolerances, parameters |
| ODE_RESULT | Data | Final state, statistics, solution |
| SOLUTION_CURVE | Data | Dense output with interpolation |

## Facade Design: SIMPLE_ODE

**Purpose:** Single entry point
**Public Interface:**
```eiffel
set_absolute_tolerance (a_tol: REAL_64): like Current
set_relative_tolerance (a_tol: REAL_64): like Current
solve (f: FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]],
                   ARRAY [REAL_64]];
       y0: ARRAY [REAL_64];
       t_start, t_end: REAL_64): ODE_RESULT
```

## Integration Pattern

**SIMPLE_ODE → ODE_SOLVER → {RK2, RK4, RK45}_INTEGRATOR → ODE_RESULT**

Each integrator performs one step:
- RK2_INTEGRATOR: 2 stages (midpoint)
- RK4_INTEGRATOR: 4 stages (Runge-Kutta)
- RK45_INTEGRATOR: 6 stages (embedded pair for error estimation)

## Class Diagram

```
┌──────────────────────────────┐
│      SIMPLE_ODE              │
│      (Facade)                │
├──────────────────────────────┤
│ + set_absolute_tolerance     │
│ + set_relative_tolerance     │
│ + solve: ODE_RESULT          │
└────────────────┬─────────────┘
                 │ uses
                 ▼
    ┌────────────────────────────┐
    │    ODE_SOLVER              │
    │    (Orchestrator)          │
    ├────────────────────────────┤
    │ + integrate_step: ODE_STATE│
    │ + check_error_control      │
    └────┬────────┬────────┬─────┘
         │        │        │ uses
         │        │        │
         ▼        ▼        ▼
    ┌─────────────────────────────┐
    │  INTEGRATOR Hierarchy       │
    │  ├─ RK2_INTEGRATOR (2 stage)│
    │  ├─ RK4_INTEGRATOR (4 stage)│
    │  └─ RK45_INTEGRATOR (6 stg) │
    │      (error estimation)     │
    └──────────┬──────────────────┘
               │ computes
               ▼
    ┌────────────────────────────┐
    │    ODE_RESULT              │
    │    (Immutable)             │
    ├────────────────────────────┤
    │ • final_state: ODE_STATE   │
    │ • solution: SOLUTION_CURVE │
    │ • steps: INTEGER           │
    │ • function_evals: INTEGER  │
    └────────────────────────────┘
```

## Design Decisions

1. **Method dispatch**: Strategy pattern - choose RK2/RK4/RK45 at creation
2. **State representation**: ARRAY [REAL_64] for y vector
3. **Error control**: RK45 embedded pair, step rejected if error > tol
4. **Dense output**: Polynomial interpolation between steps
5. **Callbacks**: FUNCTION or AGENT for f(t, y)

## OOSC2 Compliance

✓ Single Responsibility: Each integrator does one method; solver orchestrates
✓ Open/Closed: Add new integrators without changing ODE_SOLVER
✓ Dependency Inversion: SIMPLE_ODE depends on ODE_SOLVER abstraction

## Eiffel Idioms

- Builder pattern: set_tolerance, set_tolerance chains
- Immutable results: ODE_RESULT cannot change after solve
- Agent-based callbacks: f(t, y) passed as agent
- Functional integration: Each step is pure computation
