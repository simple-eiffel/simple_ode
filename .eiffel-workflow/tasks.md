# Implementation Tasks: simple_ode

## Task 1: ODE_STATE - Solution State Data Class
**Files:** src/ode_state.e
**Features:** t, y, remaining_time, y_norm

### Acceptance Criteria
- [ ] Creation: make (time, y vector, remaining time)
- [ ] Properties: t (current time), y (state vector ARRAY [REAL_64])
- [ ] remaining_time: How much time left to integrate
- [ ] y_norm: REAL_64 for error control (||y||)
- [ ] Immutable: No modification after creation
- [ ] Preconditions: y not void, y not empty
- [ ] Postconditions: State properly stored
- [ ] Test: Creation, property access, norm calculation

### Implementation Notes
- **State representation:** y is ARRAY [REAL_64], dimension >= 1
- **Norm calculation:** sqrt(sum of y[i]²) for error control in adaptive stepping
- **remaining_time:** Used by solver to determine next step size
- **Immutable:** Safe for passing between concurrent regions

### Dependencies
None (foundation class)

---

## Task 2: ODE_RESULT - Integration Results (Immutable)
**Files:** src/ode_result.e
**Features:** y_final, t_final, y_initial, t_start, accepted_steps, rejected_steps, function_evaluations, is_stiff, solution_curve, dimension, total_energy

### Acceptance Criteria
- [ ] Creation: make_from_solution with all components
- [ ] y_final: ARRAY [REAL_64] (final state)
- [ ] t_final: REAL_64 (time reached)
- [ ] y_initial: ARRAY [REAL_64] (initial state copy)
- [ ] t_start: REAL_64 (starting time)
- [ ] accepted_steps: INTEGER (successful steps)
- [ ] rejected_steps: INTEGER (failed steps, retried)
- [ ] function_evaluations: INTEGER (total f(t,y) calls)
- [ ] is_stiff: BOOLEAN (stiffness warning)
- [ ] solution_curve: SOLUTION_CURVE (dense output)
- [ ] dimension: INTEGER (number of ODEs)
- [ ] total_energy: REAL_64 (KE + PE for Hamiltonian systems)
- [ ] Immutable: No modification after creation
- [ ] Invariants: Bodies not void, stats consistent
- [ ] SCOOP-safe: Immutable for shared access

### Implementation Notes
- **Immutable data class:** Safe for SCOOP sharing
- **Statistics consistency:** function_evals >= accepted_steps * 4 (at least 4 for RK4)
- **Stiff detection:** is_stiff = TRUE if step size shrunk below threshold
- **Energy tracking:** For Hamiltonian systems, energy conservation check
- **Dimension:** y_final.count = y_initial.count

### Dependencies
- Depends on: SOLUTION_CURVE (dense output)

---

## Task 3: SOLUTION_CURVE - Dense Output (Hermite Interpolation)
**Files:** src/solution_curve.e
**Features:** interpolate, t_start, t_end, dimension

### Acceptance Criteria
- [ ] interpolate (a_t: REAL_64): ARRAY [REAL_64]
- [ ] Returns solution at requested time via polynomial interpolation
- [ ] Preconditions: a_t in [t_start, t_end]
- [ ] Postconditions: Result dimension = original dimension
- [ ] Hermite polynomial: Uses RK stage values for accuracy
- [ ] t_start, t_end: Integration bounds
- [ ] dimension: Number of ODEs
- [ ] Test: Interpolation matches solution at step endpoints

### Implementation Notes
- **Hermite interpolation:** Uses k1, k4 from RK45 for interpolation (4th order)
- **Storage:** Stores integration steps with their k values
- **Query:** O(log n) binary search for containing step, then Hermite evaluation
- **Accuracy:** O(h⁴) local error consistent with RK4

### Dependencies
None (data structure)

---

## Task 4: SIMPLE_ODE - Facade Entry Point
**Files:** src/simple_ode.e
**Features:** make, set_absolute_tolerance, set_relative_tolerance, solve

### Acceptance Criteria
- [ ] Creation: make initializes with default tolerances
- [ ] set_absolute_tolerance (a_tol: REAL_64): Returns Current for chaining
- [ ] set_relative_tolerance (a_tol: REAL_64): Returns Current for chaining
- [ ] solve (f, y0, t_start, t_end): ODE_RESULT
- [ ] Preconditions: f not void, y0 not void, increasing time
- [ ] Postconditions: Result not void, dimension preserved
- [ ] Fluent chaining: set_absolute_tolerance.set_relative_tolerance.solve works
- [ ] Test: Facade creation, tolerance setting, solve execution

### Implementation Notes
- **Facade pattern:** Delegates to ODE_SOLVER
- **Default tolerances:** absolute_tol = 1e-8, relative_tol = 1e-6
- **Builder pattern:** set_tolerance returns Current for chaining
- **solve:** Orchestrates ODE_SOLVER.integrate with configured tolerances

### Dependencies
- Depends on: ODE_SOLVER (orchestrator)

---

## Task 5: ODE_SOLVER - Integration Orchestrator
**Files:** src/ode_solver.e
**Features:** integrate, adaptive_step_control, error_control

### Acceptance Criteria
- [ ] integrate (f, y0, t_start, t_end, atol, rtol): ODE_RESULT
- [ ] Orchestrates RK45 adaptive stepping
- [ ] Main loop: while t < t_end: rk45_step, check error, adjust dt, store step
- [ ] Adaptive stepping: Increase dt if error < tol/2, decrease if error > tol
- [ ] Step rejection: If error > tol, halve dt and retry
- [ ] Dense output: Build SOLUTION_CURVE from integrated steps
- [ ] Statistics: Track accepted_steps, rejected_steps, function_evals
- [ ] Stiffness detection: Flag if dt becomes too small (< 1e-10)
- [ ] Preconditions: f not void, y0 not void, positive tolerances
- [ ] Postconditions: t_final >= t_end (within tolerance)
- [ ] Test: Integration of exponential decay, Lorenz system

### Implementation Notes
- **Adaptive algorithm:**
  1. Estimate dt = sqrt(atol + rtol * ||y||) / ||RHS||
  2. Do rk45_step with dt
  3. Estimate error via RK4-RK5 pair
  4. If error <= tol: accept step, increase dt (1.2x)
  5. If error > tol: reject step, decrease dt (0.5x), retry
- **Step size bounds:** dt_min = 1e-10, dt_max = (t_end - t) / 2
- **Statistics:** RK45 costs 6 function evals per step
- **Stiffness:** is_stiff = TRUE if min_dt_used < 1e-10

### Dependencies
- Depends on: RK45_INTEGRATOR (step executor)
- Depends on: ODE_STATE (state representation)
- Depends on: SOLUTION_CURVE (dense output builder)
- Depends on: ODE_RESULT (result container)

---

## Task 6: RK2_INTEGRATOR - 2-Stage Runge-Kutta (Midpoint Method)
**Files:** src/rk2_integrator.e
**Features:** rk2_step

### Acceptance Criteria
- [ ] rk2_step (f, t, y, dt): TUPLE [y_new: ARRAY [REAL_64]; error: REAL_64]
- [ ] RK2 midpoint method:
  - k1 = f(t, y)
  - k2 = f(t + dt/2, y + dt*k1/2)
  - y_new = y + dt*k2
- [ ] Convergence order: O(h³) local, O(h²) global
- [ ] Error estimation: Via Richardson extrapolation or embedded formula
- [ ] Preconditions: f not void, y not void, dt > 0
- [ ] Postconditions: y_new dimension = y dimension, error >= 0
- [ ] Test: RK2 convergence on test problem

### Implementation Notes
- **2 stages:** Minimal for adaptive control
- **Midpoint formula:** More accurate than Euler
- **Error estimate:** Compare RK2 with Euler (Euler is O(h)) or internal formula
- **Storage:** Temporary arrays for k1, intermediate state

### Dependencies
- Depends on: simple_math (for any special functions)

---

## Task 7: RK4_INTEGRATOR - 4-Stage Runge-Kutta (Standard Method)
**Files:** src/rk4_integrator.e
**Features:** rk4_step

### Acceptance Criteria
- [ ] rk4_step (f, t, y, dt): TUPLE [y_new: ARRAY [REAL_64]; error: REAL_64]
- [ ] RK4 classic method:
  - k1 = f(t, y)
  - k2 = f(t + dt/2, y + dt*k1/2)
  - k3 = f(t + dt/2, y + dt*k2/2)
  - k4 = f(t + dt, y + dt*k3)
  - y_new = y + dt*(k1 + 2*k2 + 2*k3 + k4)/6
- [ ] Convergence order: O(h⁵) local, O(h⁴) global
- [ ] Error estimation: Local truncation error < 1e-4 * dt
- [ ] Preconditions: f not void, y not void, dt > 0
- [ ] Postconditions: y_new dimension = y dimension, error >= 0
- [ ] Test: RK4 convergence on test problem, Lorenz system

### Implementation Notes
- **4 stages:** Industry standard, good balance
- **Butcher tableau coefficients:** 1/2, 1/2, 1, then weights 1/6, 1/3, 1/3, 1/6
- **Error bound:** Based on O(h⁵) local truncation error
- **Temporary arrays:** k1, k2, k3, k4, intermediate states

### Dependencies
- Depends on: simple_math (for any special functions)

---

## Task 8: RK45_INTEGRATOR - 6-Stage Runge-Kutta with Error Estimation
**Files:** src/rk45_integrator.e
**Features:** rk45_step

### Acceptance Criteria
- [ ] rk45_step (f, t, y, dt): TUPLE [y_rk4: ARRAY [REAL_64]; y_rk5: ARRAY [REAL_64]; error: REAL_64]
- [ ] Dormand-Prince 6-stage method (DOPRI45)
- [ ] 6 stages (k1, k2, k3, k4, k5, k6)
- [ ] RK4 approximation from first 5 stages (5th order)
- [ ] RK5 approximation from all 6 stages (4th order as error estimate)
- [ ] Error = ||y_rk4 - y_rk5||
- [ ] Convergence order: RK4 is O(h⁵) local, O(h⁴) global
- [ ] Error estimation: error / (atol + rtol * ||y||) < 1 means acceptable
- [ ] Preconditions: f not void, y not void, dt > 0
- [ ] Postconditions: Both y arrays not void, error >= 0
- [ ] Test: RK45 convergence, error estimation accuracy

### Implementation Notes
- **Dormand-Prince coefficients:** Standard tableau from literature
- **6 stages:** Expensive but critical for error control
- **Error pair:** RK4 (5th order) used as solution, RK5 (4th order) for error estimate
- **Butcher tableau:** Pre-compute and store as constants
- **Temporary arrays:** k1-k6, intermediate states

### Implementation Strategy
```eiffel
-- Stage 1: k1 = f(t, y)
-- Stage 2: k2 = f(t + c2*dt, y + a21*dt*k1)
-- ...
-- Stage 6: k6 = f(t + c6*dt, y + a61*dt*k1 + ... + a65*dt*k5)

-- RK4: y_rk4 = y + dt*(b1*k1 + ... + b5*k5)
-- RK5: y_rk5 = y + dt*(b'1*k1 + ... + b'6*k6)
-- error = ||y_rk4 - y_rk5||
```

### Dependencies
- Depends on: simple_math (for any special functions)

---

## Task 9: Dense Output Integration (SOLUTION_CURVE Builder in ODE_SOLVER)
**Files:** src/ode_solver.e (extended)
**Features:** Build solution_curve from integration steps

### Acceptance Criteria
- [ ] After each accepted step: Store t, y, k values for interpolation
- [ ] SOLUTION_CURVE constructor: Takes list of stored steps
- [ ] interpolate method: Hermite polynomial evaluation
- [ ] Accuracy: O(h⁴) consistent with RK4
- [ ] Test: Dense output at arbitrary times matches RK4 integration

### Implementation Notes
- **Storage:** Each accepted step stores (t, y, k1, k4) for Hermite
- **Hermite formula:** y(t + θ*dt) = y + θ*dt*k1 + θ²*dt²*(3-2θ)*k1 + θ²*(θ-1)*dt²*k4
- **Lookup:** Binary search on t values to find containing step
- **Query complexity:** O(log n) search + O(1) evaluation

### Dependencies
- Part of: ODE_SOLVER task

---

## Task 10: ECF Configuration and Test Framework
**Files:** simple_ode.ecf, test/test_app.e, test/test_exponential.e, test/test_lorenz.e

### Acceptance Criteria
- [ ] ECF file: void_safety="all", concurrency=scoop, simple_math dependency
- [ ] Test targets: main (library) and test (test suite)
- [ ] Test runner: test_app.e orchestrates all tests
- [ ] Skeletal tests: test_exponential.e, test_lorenz.e (from Phase 1)
- [ ] Compilation: Zero warnings
- [ ] Test execution: All skeletal tests pass (100% pass rate)
- [ ] Simple smoke tests: exponential decay, Lorenz attractor shape

### Implementation Notes
- **Exponential test:** dy/dt = -y, y(0) = 1, check y(t) ≈ exp(-t)
- **Lorenz test:** 3D system, verify attractor forms correctly
- **ECF targets:** simple_ode (library), simple_ode_tests (test)
- **Dependencies:** base, testing from ISE; simple_math for special functions

### Dependencies
- Depends on: All other classes (integration point)

---

## Task Dependency Graph

```
ODE_STATE (Task 1) → ODE_RESULT (Task 2) → SOLUTION_CURVE (Task 3)
                            ↑
                        ODE_SOLVER (Task 5)
                            ↑
                    SIMPLE_ODE (Task 4)
                            ↓
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
    RK2_INTEGRATOR    RK4_INTEGRATOR     RK45_INTEGRATOR
    (Task 6)          (Task 7)           (Task 8)
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ↓
                  Dense Output Builder
                     (Task 9 - in Task 5)
                            ↓
                    ECF & Tests
                    (Task 10)
```

## Task Execution Order (Recommended)

1. **Foundation (parallel):**
   - Task 1: ODE_STATE
   - Task 2: ODE_RESULT
   - Task 3: SOLUTION_CURVE

2. **Integrators (parallel after Tasks 1-2):**
   - Task 6: RK2_INTEGRATOR
   - Task 7: RK4_INTEGRATOR
   - Task 8: RK45_INTEGRATOR

3. **Orchestration (depends on Tasks 1-3, 6-8):**
   - Task 5: ODE_SOLVER (main integration loop)

4. **Entry point (depends on Task 5):**
   - Task 4: SIMPLE_ODE

5. **Dense output (part of Task 5):**
   - Task 9: Dense output builder

6. **Integration & testing (final):**
   - Task 10: ECF & Tests

## Total Task Count: 10
- State/Result classes: 3
- Integrator classes: 3
- Orchestration: 1
- Entry point: 1
- Integration: 2

**Estimated complexity:** HIGH (4th-order accurate adaptive methods)
**Critical algorithms:** RK45 embedded pair, adaptive stepping, error control
**Success factors:** Accurate Butcher tableau, careful error estimation, extensive testing
