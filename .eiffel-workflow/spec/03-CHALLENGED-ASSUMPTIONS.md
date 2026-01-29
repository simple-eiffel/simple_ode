# CHALLENGED ASSUMPTIONS: simple_ode

## Assumptions Challenged

### A-001: Explicit Methods Sufficient for Phase 1
**Challenge:** Will users immediately need stiff solvers?
**Evidence for:** Most educational/scientific problems are nonstiff; stiff handling complex; MVP scope clear
**Evidence against:** Some real applications (chemical kinetics) are inherently stiff
**Verdict:** VALID - Phase 1 explicit only; Phase 2 adds implicit methods
**Action:** Clear documentation of nonstiff-only scope; Phase 2 roadmap

### A-002: RK45 Embedded Pair Is Best Error Control
**Challenge:** Could we use Richardson extrapolation or other methods?
**Evidence for:** RK45 is industry standard; proven, efficient, simple
**Evidence against:** Richardson extrapolation more accurate but expensive
**Verdict:** VALID - RK45 balance of accuracy and efficiency
**Action:** Implement RK45 as specified; defer alternatives to Phase 2

### A-003: Dense Output Always Needed
**Challenge:** Is dense output important for MVP? Could defer?
**Evidence for:** Users often want solution at arbitrary times; low overhead
**Evidence against:** Adds complexity; basic solver could skip interpolation
**Verdict:** MODIFY - Dense output is Phase 1; essential for practical use
**Action:** Include polynomial interpolation in SOLUTION_CURVE

### A-004: No Stiff Detection Needed
**Challenge:** Should Phase 1 warn users about stiff problems?
**Evidence for:** Stiff detection simple (monitor step size); prevents silent failure
**Evidence against:** Adds code; not MVP-critical
**Verdict:** MODIFY - Add simple stiffness indicator (too-small steps) in Phase 1
**Action:** ODE_RESULT includes stiffness warning if dt < tolerance * small_threshold

### A-005: simple_math Provides All Needed Functions
**Challenge:** Are sqrt, sin, cos available in simple_math?
**Evidence for:** Standard mathematical library should have them
**Evidence against:** Possible gaps if simple_math incomplete
**Verdict:** NEEDS_VALIDATION - Early integration gate required
**Action:** Verify simple_math before Phase 1 implementation

### A-006: Systems from Start (Not Single Scalar)
**Challenge:** Could MVP simplify to scalar ODE only?
**Evidence for:** Simplifies implementation; systems common later
**Evidence against:** Systems barely more complex; Lorenz system (3D) is benchmark
**Verdict:** VALID - Systems from start; no scalar-only implementation
**Action:** Use ARRAY [REAL_64] for all y vectors

### A-007: Function Callback Via Agent
**Challenge:** Should we support other callback mechanisms?
**Evidence for:** Eiffel agents are standard pattern; flexible
**Evidence against:** Could also use function pointers (less Eiffel-like)
**Verdict:** VALID - Agent-based callbacks standard in Eiffel
**Action:** f(t, y) as FUNCTION [ANY, TUPLE [REAL_64, ARRAY [REAL_64]], ARRAY [REAL_64]]

## Requirements Questioned

### FR-006: Adaptive Step Size Control
**Requirement:** Step size adjusts to maintain tolerance
**Challenge:** What tolerance? absolute? relative? mixed?
**Verdict:** CLARIFY - Use mixed: error < atol + rtol * ||y||
**Action:** Both absolute_tol and relative_tol parameters required

### FR-008: Dense Output at Arbitrary Times
**Requirement:** Solution available at requested time points
**Challenge:** What happens if requested time > final time? Before start?
**Verdict:** MODIFY - Dense output only within integrated range
**Action:** Contract enforces t_requested ∈ [t_start, t_end]

### FR-009: Integration Statistics
**Requirement:** Track steps, failed steps, function evals
**Challenge:** Which metrics matter most?
**Verdict:** CLARIFY - Include: accepted_steps, rejected_steps, function_evals
**Action:** ODE_RESULT includes all three metrics

## Missing Requirements Identified

| ID | Missing Requirement | How Discovered |
|----|---------------------|-----------------|
| FR-015 | Step size limits (dt_min, dt_max) | Prevent divergence or infinite steps |
| FR-016 | Maximum total steps allowed | Catch infinite loops gracefully |
| FR-017 | Normalization tolerance for error control | Prevent division by tiny ||y|| |
| FR-018 | Option to use fixed step size (no adaptation) | Useful for comparison/testing |
| FR-019 | Interpolation order control | Allow lower-order interpolation for speed |

**Decisions:**
- FR-015, 016: ADD to Phase 1 (essential safeguards)
- FR-017: ADD to Phase 1 (fix numerical issues)
- FR-018: DEFERRED to Phase 2 (optional feature)
- FR-019: DEFERRED to Phase 2 (optimization)

## Design Constraints Validated

| Constraint | Valid? | Notes |
|-----------|--------|-------|
| Explicit methods only | YES | Sufficient for nonstiff MVP |
| RK45 embedded pair | YES | Industry standard, proven |
| Systems architecture | YES | ARRAY [REAL_64] flexible |
| simple_math dependency | NEEDS_GATE | sqrt, sin, cos availability |
| SCOOP compatibility | YES | Independent solvers, immutable results |
| void_safety="all" | YES | No null issues with care |

## Revised Scope (Post-Challenge)

### Phase 1 Final Scope
✓ Explicit methods: RK2, RK4, RK45
✓ Adaptive stepping with RK45 error control
✓ Dense output with polynomial interpolation
✓ Mixed tolerance: absolute + relative
✓ Step size limits and safeguards
✓ System of ODEs (ARRAY [REAL_64])
✓ Integration statistics
✓ Simple stiffness warning
✗ Implicit methods (Phase 2)
✗ Event detection (Phase 2)
✗ Jacobian callbacks (Phase 2)
✗ Fixed step size option (Phase 2)

### Testing Strategy
- Unit: RK2/RK4/RK45 stage computation
- Integration: Convergence on Euler, Lorenz systems
- Adaptive: Step size control maintains tolerance
- Scenario: Exponential decay, Lorenz attractor, coupled ODEs
- Adversarial: Stiff detection, extreme tolerances, edge times
