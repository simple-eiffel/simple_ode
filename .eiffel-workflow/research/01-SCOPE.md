# SCOPE: simple_ode

## Problem Statement
In one sentence: Provide a type-safe, contract-based library for solving Ordinary Differential Equations (ODEs) with multiple integration methods and accuracy guarantees.

What's wrong today: Solving ODEs in Eiffel requires manual implementation of integration methods or external C libraries. No standard library provides verified, type-safe ODE solving with contract guarantees. Scientists lose Eiffel's DBC benefits when they must resort to external tools.

Who experiences this: Scientists modeling dynamical systems, engineers simulating differential equations, researchers in physics/chemistry/biology, computational biologists.

Impact of not solving: Eiffel becomes impractical for ODE-heavy scientific work; researchers choose Python/MATLAB/Julia instead; educational use in scientific computing is lost.

## Target Users
| User Type | Needs | Pain Level |
|-----------|-------|------------|
| Scientific researcher | Solve systems of ODEs (lorenz, pendulum, chemical reactions) | HIGH |
| Biologist | Population dynamics, pharmacokinetics modeling | HIGH |
| Physicist | Differential equation simulations | HIGH |
| Control engineer | State-space systems, feedback control | MEDIUM |
| Educator | Teach ODE solving with verified contracts | MEDIUM |

## Success Criteria
| Level | Criterion | Measure |
|-------|-----------|---------|
| MVP | Single ODE solving | dy/dt = f(t,y) with RK4 works for stiff/non-stiff |
| MVP | Multiple ODEs (systems) | Lorenz system, coupled equations |
| MVP | Error control | Absolute error < tolerance over full integration interval |
| Full | Stiff ODE handling | Implicit methods (backward Euler, Rosenbrock) |
| Full | Adaptive step size | Step doubling, embedded Runge-Kutta pairs |
| Full | Event detection | Zero-crossing detection, constraint handling |

## Scope Boundaries
### In Scope (MUST)
- Explicit Runge-Kutta methods (Euler, RK2, RK4)
- System of ODEs (dy/dt = f(t, y_vector))
- Initial value problems (IVP)
- Adaptive step-size control
- Error tolerance-based integration
- Embedded RK pairs for error estimation (RK45, RK78)
- Contract verification on all operations
- SCOOP compatibility

### In Scope (SHOULD)
- Stiff ODE solvers (backward Euler, Rosenbrock methods)
- Event detection (zero-crossing, root finding)
- Dense output (interpolation at intermediate points)
- Jacobian specification for stiff solvers
- Step size history and integration statistics

### Out of Scope
- Partial differential equations (PDEs) → different problem class
- Delay differential equations (DDEs) → future simple_dde
- Stochastic differential equations (SDEs) → future simple_sde
- Boundary value problems (BVP) → future simple_bvp
- Symbolic equation manipulation → separate library
- Automatic differentiation → belongs in simple_autodiff

### Deferred to Future
- Stiff methods → Phase 2
- Event detection → Phase 2
- Dense output → Phase 2
- Sensitivity analysis → Phase 3
- Parallel ODE systems → Phase 3

## Constraints
| Type | Constraint |
|------|------------|
| Technical | Must be void-safe (void_safety="all") |
| Technical | Must be SCOOP-compatible |
| Technical | Numerical accuracy: error < tolerance over full interval |
| Technical | Use simple_math for sqrt and trig |
| Ecosystem | Must prefer simple_* over ISE libraries |
| Performance | Handle systems with 100+ variables efficiently |
| API | Full Design by Contract with require/ensure/invariant |

## Assumptions to Validate
| ID | Assumption | Risk if False |
|----|------------|---------------|
| A-1 | ODE solving is needed in Eiffel scientific community | Medium - could be niche use case |
| A-2 | RK4 and adaptive RK45 sufficient for MVP | Low - can add more methods iteratively |
| A-3 | REAL_64 precision adequate (vs extended precision) | Low - can use simple_decimal for coefficients |
| A-4 | Embedded RK pairs available in literature | Very low - well-established methods |
| A-5 | simple_math provides necessary functions | Low - can implement if needed |

## Research Questions
- What ODE libraries exist in other languages (SciPy, Boost, SUNDIALS)?
- How do they structure error control and adaptive stepping?
- What Eiffel resources exist for numerical methods?
- Are there existing Eiffel ODE implementations?
- What performance characteristics are expected?
- How do production libraries handle stiff equations?
- What are standard embedded RK pair coefficients?
