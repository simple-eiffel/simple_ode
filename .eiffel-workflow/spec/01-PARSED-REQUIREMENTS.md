# PARSED REQUIREMENTS: simple_ode

## Problem Summary
Contract-verified ODE solver for single and systems of ordinary differential equations. Provides explicit Runge-Kutta methods (RK2, RK4, RK45) with adaptive step-size control via embedded error estimation. Designed for scientific computing and parameter variation studies.

## Scope

### In Scope
- Single ODE: dy/dt = f(t, y)
- Systems of ODEs: dy/dt = f(t, y) with y ∈ ℝⁿ
- Explicit integration: Euler, RK2, RK4, RK45
- Adaptive stepping via embedded RK45 pair
- Error estimation and tolerance control
- Dense output (solution at arbitrary time points)
- Integration statistics (steps, function evals)
- SCOOP-compatible for ensemble solving

### Out of Scope
- Implicit methods (BDF, Radau) - Phase 2
- Stiff ODE detection (Phase 2)
- Event detection/root finding (Phase 2)
- Jacobian-based methods - Phase 2
- DAE (differential-algebraic equations)

## Functional Requirements
| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-001 | Solve single ODE dy/dt = f(t,y) | MUST | Simple exponential decay correct |
| FR-002 | Solve system of ODEs (multiple y) | MUST | Lorenz system solved, attractor correct |
| FR-003 | Implement Euler method | MUST | Euler converges to analytical solution |
| FR-004 | Implement RK2 (midpoint method) | MUST | RK2 convergence correct |
| FR-005 | Implement RK4 integration | MUST | RK4 accurate to 5th order |
| FR-006 | Adaptive step size control | MUST | Step size adjusts to maintain tolerance |
| FR-007 | Error estimation | MUST | RK45 pair estimates error < tolerance |
| FR-008 | Dense output | MUST | Solution at arbitrary requested times |
| FR-009 | Track statistics | MUST | Returns step count, failed steps, function evals |
| FR-010 | User-specified tolerance | MUST | absolute_tol and relative_tol parameters |
| FR-011 | User-provided function | MUST | f(t, y) passed as callback |
| FR-012 | Stiff detection | SHOULD | Warns if problem may be stiff (Phase 2) |
| FR-013 | Jacobian support | SHOULD | Optional df/dy for Phase 2 stiff solvers |
| FR-014 | Event detection | SHOULD | Zero-crossing detection (Phase 2) |

## Non-Functional Requirements
| ID | Requirement | Category | Measure | Target |
|----|-------------|----------|---------|--------|
| NFR-001 | Numerical accuracy | PERFORMANCE | Convergence order | RK4 achieves O(h⁵) |
| NFR-002 | Efficiency | PERFORMANCE | Function evals | Minimum for accuracy |
| NFR-003 | Type-safe API | QUALITY | Contracts | 100% verified |
| NFR-004 | SCOOP compatible | CONCURRENCY | Multiple ODEs parallel | Safe concurrent solving |
| NFR-005 | No external deps | MAINTAINABILITY | External libs | simple_math only |
| NFR-006 | Void-safe | QUALITY | void_safety | void_safety="all" |
| NFR-007 | Contract coverage | QUALITY | Contracts | 100% require/ensure |
| NFR-008 | Test coverage | QUALITY | Pass rate | 100% pass, 40+ tests |

## Constraints
| ID | Constraint | Type |
|----|------------|------|
| C-001 | Must be void-safe | TECHNICAL |
| C-002 | Must be SCOOP-compatible | TECHNICAL |
| C-003 | Must use simple_math | ECOSYSTEM |
| C-004 | Only simple_* external | ECOSYSTEM |
| C-005 | All public features contracted | QUALITY |
| C-006 | Zero compilation warnings | TECHNICAL |
| C-007 | REAL_64 precision | TECHNICAL |

## Decisions Already Made
| ID | Decision | Rationale | From |
|----|----------|-----------|------|
| D-001 | Explicit methods Phase 1 | Simpler than implicit; sufficient for nonstiff | research/04 |
| D-002 | RK45 embedded pair | Industry standard, provides error estimate | research/04 |
| D-003 | Systems from start | Coupled ODEs common; only slightly more complex | research/04 |
| D-004 | Optional Jacobian callback | Prepared for Phase 2; simple to add now | research/04 |
| D-005 | No event detection Phase 1 | Deferred for simplicity | research/04 |

## Innovations to Implement
| ID | Innovation | Design Impact |
|----|------------|---------------|
| I-001 | Contract-verified accuracy | Postconditions verify error bounds |
| I-002 | Pure Eiffel RK implementation | Transparent, maintainable, no FFI |
| I-003 | Lightweight vs SUNDIALS | Fast startup, focused, easy to understand |
| I-004 | SCOOP-ready ensemble | Each solver independent, concurrent safe |

## Risks to Address
| ID | Risk | Mitigation |
|----|------|-----------|
| RISK-001 | Error accumulation | Extensive testing, energy tracking |
| RISK-002 | Stiff problem blindness | Clear documentation, Phase 2 detection |
| RISK-003 | RK45 implementation complexity | Reference multiple sources |
| RISK-004 | Performance on high-dim systems | Target < 100 variables Phase 1 |

## Use Cases

### UC-001: Exponential Decay
**Actor:** Student solving dy/dt = -y, y(0) = 1
**Main Flow:** Create solver, set f(t,y)=-y, integrate to t=1
**Postcondition:** y(1) ≈ 0.368

### UC-002: Lorenz System
**Actor:** Researcher exploring chaotic dynamics
**Main Flow:** 3D system (x,y,z), integrate 10000 steps
**Postcondition:** Attractor forms correctly

### UC-003: Ensemble Parameter Sweep
**Actor:** ML engineer fitting 1000 parameter variations
**Main Flow:** Concurrent SCOOP solvers each with different parameters
**Postcondition:** Results in parallel, safe aggregation
