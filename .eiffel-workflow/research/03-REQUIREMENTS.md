# REQUIREMENTS: simple_ode

## Functional Requirements
| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-001 | Solve single ODE dy/dt = f(t,y) | MUST | Solves simple exponential decay correctly |
| FR-002 | Solve system of ODEs (multiple y values) | MUST | Lorenz system solved with correct attractor |
| FR-003 | Implement Euler integration method | MUST | Euler method produces results within 1% of analytical |
| FR-004 | Implement RK2 integration method | MUST | RK2 (midpoint method) converges correctly |
| FR-005 | Implement RK4 integration method | MUST | RK4 is accurate to 5th order, passes test cases |
| FR-006 | Adaptive step size based on error | MUST | Step size adjusts to maintain tolerance |
| FR-007 | Error estimation and control | MUST | Embedded RK pair estimates error < tolerance |
| FR-008 | Return solution at requested time points | MUST | Dense output provides values at arbitrary times |
| FR-009 | Track integration statistics | MUST | Returns step count, failed steps, function evals |
| FR-010 | User-specified tolerance | MUST | absolute_tol and relative_tol parameters work |
| FR-011 | User-provided function derivative | MUST | f(t, y) function passed as callback |
| FR-012 | Stiff ODE detection | SHOULD | Warns if problem may be stiff |
| FR-013 | Jacobian support (optional) | SHOULD | User can provide df/dy for future stiff solvers |
| FR-014 | Event detection (zero-crossing) | SHOULD | Detects and reports state events |

## Non-Functional Requirements
| ID | Requirement | Category | Measure | Target |
|----|-------------|----------|---------|--------|
| NFR-001 | Numerical accuracy | PERFORMANCE | Convergence order | RK4 achieves O(h^5) |
| NFR-002 | Efficiency | PERFORMANCE | Function evaluations | Minimum needed for accuracy |
| NFR-003 | Type-safe API | QUALITY | Contract coverage | 100% verified |
| NFR-004 | SCOOP compatible | CONCURRENCY | Multiple ODEs parallel | Safe for concurrent solving |
| NFR-005 | No external deps | MAINTAINABILITY | External libs | simple_math only |
| NFR-006 | Void-safe | QUALITY | void_safety setting | void_safety="all" |
| NFR-007 | Contract coverage | QUALITY | Contracts per feature | 100% with require/ensure |
| NFR-008 | Test coverage | QUALITY | Test pass rate | 100% pass, 40+ tests |

## Constraints
| ID | Constraint | Type | Immutable? |
|----|------------|------|------------|
| C-001 | Must be void-safe | TECHNICAL | YES |
| C-002 | Must be SCOOP-compatible | TECHNICAL | YES |
| C-003 | Must use simple_math | ECOSYSTEM | YES |
| C-004 | Only simple_* external | ECOSYSTEM | YES |
| C-005 | All public features contracted | QUALITY | YES |
| C-006 | Zero compilation warnings | TECHNICAL | YES |
| C-007 | REAL_64 precision | TECHNICAL | YES |
