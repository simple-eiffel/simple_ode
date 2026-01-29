# RECOMMENDATION: simple_ode

## Executive Summary
simple_ode should be built as a contract-verified ODE solver library focusing on explicit Runge-Kutta methods for nonstiff problems. It fills the critical gap of type-safe differential equation solving in Eiffel, enabling scientific computing without FFI. Phase 2 will add implicit methods for stiff problems.

## Recommendation
**Action:** BUILD
**Confidence:** HIGH

## Rationale
1. **Ecosystem gap:** No ODE solver in Eiffel; scientists use Python/SciPy instead
2. **Well-established domain:** RK methods are proven, well-documented, implementable
3. **Reasonable MVP scope:** Explicit methods sufficient for many applications
4. **Contract opportunity:** Can formally verify accuracy bounds
5. **SCOOP advantage:** Enable ensemble solving of parameter variations concurrently

## Proposed Approach

### Phase 1 (MVP) - 2-3 months
- **Core methods:**
  - Euler integration
  - RK2 (midpoint method)
  - RK4 Runge-Kutta
  - Embedded RK45 pair for error estimation
- **Features:**
  - Single and systems of ODEs
  - Adaptive step size control
  - Tolerance-based error checking
  - Dense output (interpolation)
  - Integration statistics
- **Quality:**
  - 40+ tests (100% pass rate)
  - Full contract coverage
  - Reference problem validation (Lorenz, exponential decay)

### Phase 2 (Full) - Future
- Backward Differentiation Formulas (BDF) for stiff problems
- Rosenbrock methods
- Jacobian-based solvers
- Event detection (zero-crossing)
- Higher-order RK methods (RK78)

## Key Features
1. **Contract-Verified Accuracy** - Preconditions specify tolerance; postconditions guarantee precision
2. **Pure Eiffel Implementation** - No FFI to C; transparent algorithms
3. **Lightweight & Focused** - RK methods without heavy machinery
4. **Ensemble Ready** - Design for concurrent parameter variation studies
5. **Educational Value** - Clear code for learning ODE solving

## Success Criteria
- Lorenz system solver achieves expected attractor
- Exponential decay problem accurate to 6 decimal places over 100 steps
- 40+ tests passing (100% pass rate)
- Zero compilation warnings
- Documented algorithms

## Dependencies
| Library | Purpose | simple_* Preferred |
|---------|---------|-------------------|
| simple_math | sqrt for RK coefficients | YES |
| simple_mml | Future: model invariants | YES (Phase 2) |

## Next Steps
1. Run `/eiffel.spec` to create formal specification
2. Run `/eiffel.intent` to refine intent
3. Execute Eiffel Spec Kit workflow (Phases 1-7)
4. Target Q2 2026 completion

## Open Questions
- How tolerant should adaptive stepping be (absolute vs relative)? → Both, user-specified
- Should Phase 1 include event detection? → NO, Phase 2
- Max system size for Phase 1? → 100+ variables, recommend < 1000
