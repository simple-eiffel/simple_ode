# DOMAIN MODEL: simple_ode

## Domain Concepts

### Concept: ODE Derivative Function
**Definition:** f(t, y) = dy/dt, user-provided callback
**Attributes:** t (time), y (state vector)
**Behaviors:** Evaluate derivative at point
**Will become:** FUNCTION_CALLBACK or AGENT

### Concept: ODE State
**Definition:** Current values of dependent variables y = [y₁, y₂, ..., yₙ]
**Attributes:** Time t, state vector y, accuracy tolerance
**Behaviors:** Store state, compute norm
**Will become:** ODE_STATE

### Concept: Integration Step
**Definition:** One advance from t → t + dt using RK method
**Attributes:** Initial state, step size, error estimate
**Behaviors:** Perform RK2/RK4/RK45, estimate error
**Will become:** INTEGRATOR (RK2_INTEGRATOR, RK4_INTEGRATOR, RK45_INTEGRATOR)

### Concept: Solution Curve
**Definition:** Dense output providing solution at arbitrary times
**Attributes:** Integration points with polynomial interpolation
**Behaviors:** Query solution at requested time
**Will become:** ODE_SOLUTION

### Concept: Solver Configuration
**Definition:** Tolerances, method choice, callbacks
**Attributes:** absolute_tol, relative_tol, max_iterations
**Behaviors:** Validate parameters, apply constraints
**Will become:** ODE_CONFIG or builder pattern in SIMPLE_ODE

### Concept: Solver Result
**Definition:** Immutable result from integration
**Attributes:** Final state, statistics (steps, function evals), solution curve
**Behaviors:** Query results, check success
**Will become:** ODE_RESULT

## Concept Relationships

```
ODE Derivative Function (f) ──────────┐
                                      ▼
         ┌─────────────────────────────────────────┐
         │         ODE Solver Engine               │
         │  (SIMPLE_ODE or SIMPLE_ODE_RK45)        │
         └────────────────┬────────────────────────┘
                          │
              ┌───────────┼───────────┐
              ▼           ▼           ▼
         ODE_CONFIG  Initial_State  Tolerance

         ┌───────────────────────────────────┐
         │  INTEGRATOR (RK2/RK4/RK45)        │
         │  ├─ RK2_INTEGRATOR                │
         │  ├─ RK4_INTEGRATOR                │
         │  └─ RK45_INTEGRATOR               │
         │      (with error estimation)      │
         └───────────────┬───────────────────┘
                         │ performs
                         ▼
         ┌──────────────────────────┐
         │     ODE_RESULT           │
         │  ├─ solution curve       │
         │  ├─ step statistics      │
         │  └─ final state          │
         └──────────────────────────┘
```

## Domain Rules

| Rule | Enforcement |
|------|------------|
| Tolerance bounds | absolute_tol > 0, relative_tol > 0 |
| RK4 order | Must use 4 stages exactly |
| RK45 pair | Must have RK4 and RK5 coefficients |
| Step size bounds | dt > 0, dt_min <= dt <= dt_max |
| Error control | step accepted if error < tolerance |
| Monotone time | t must increase monotonically |

## Phase 1 Scope

**Included:**
- SIMPLE_ODE facade (entry point)
- ODE_SOLVER engine with RK2, RK4, RK45 methods
- Adaptive stepping (RK45 error control)
- Dense output (polynomial interpolation)
- Statistics tracking (steps, failed steps, function evals)
- Systems of ODEs (ARRAY [REAL_64])
- User-provided f(t, y) as agent

**Deferred to Phase 2:**
- Implicit methods (BDF, Radau)
- Stiff detection
- Jacobian callbacks
- Event detection
