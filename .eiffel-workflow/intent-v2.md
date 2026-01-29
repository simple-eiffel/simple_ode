# Intent: simple_ode

## What
A production-grade ordinary differential equation (ODE) solver for Eiffel supporting multiple Runge-Kutta methods (RK2, RK4, RK45) with adaptive stepping, error control, and dense output via Hermite interpolation.

## Why
Eiffel lacks native ODE solving capability. Scientific computing, physics simulation, and control systems require robust numerical integration. simple_ode provides Design-by-Contract verified Runge-Kutta methods with adaptive error control suitable for systems up to 100+ dimensions.

## Users
- Scientific computing researchers
- Control systems engineers
- Physics simulation developers
- Educators teaching numerical methods
- Computational biology/chemistry applications

## Acceptance Criteria
- [ ] RK2 (2-stage) implementation with O(h³) local error
- [ ] RK4 (4-stage) implementation with O(h⁵) local error
- [ ] RK45 (6-stage Dormand-Prince) with embedded error estimation
- [ ] Adaptive stepping: dt increases on low error, decreases on high error
- [ ] Step rejection and retry for error > tolerance
- [ ] Dense output via Hermite interpolation (O(h⁴) accuracy)
- [ ] Support for systems up to 100+ dimensions
- [ ] Stiffness detection (dt < 1e-10 threshold)
- [ ] 100% Design by Contract coverage
- [ ] All tests passing (100% pass rate)

## Out of Scope
- Implicit methods (stiff ODE solvers)
- BDF (Backward Differentiation Formula)
- Multistep methods beyond RK
- Event detection/discontinuities (Phase 2+)
- Parallel integration (single-threaded Phase 1)
- GPU acceleration

## Dependencies

| Need | Library | Justification |
|------|---------|---------------|
| Square root, exp, sin, cos | simple_math | Essential for special functions |
| Data structures | ISE base | Fundamental types only |
| Testing framework | ISE testing | EQA_TEST_SET for unit tests |

**MML Decision:** YES-Required

Rationale: ODE_SOLVER maintains ARRAYED_LIST of integration steps. SOLUTION_CURVE stores solution history. Frame conditions using MML model queries verify:
- Monotone accepted_steps increase
- Dimension preservation through integration
- Time progression (t_start ≤ t ≤ t_end)

## Technical Constraints
- **void_safety="all"**: All potential null pointers handled
- **SCOOP compatible**: ODE_RESULT immutable for concurrent access
- **No external C bindings**: Pure Eiffel implementation
- **Non-stiff systems Phase 1**: Implicit methods deferred to Phase 2

## Gaps Identified (Potential simple_* Libraries)

| Gap | Current Workaround | Proposed simple_* |
|-----|-------------------|-------------------|
| Implicit BDF methods | Not implemented (Phase 2+) | simple_implicit_ode |
| Parametric curves | Manual step storage | simple_curves |
| Matrix operations | Not needed Phase 1 | simple_matrix |

**Recommendation:** After shipping Phase 1, consider simple_implicit_ode for stiff systems (chemical kinetics, electronics).

## Phase Scope
**Phase 1 MVP:** 10 classes, RK2/RK4/RK45, adaptive stepping, dense output
**Phase 2:** Implicit methods (BDF), event detection, mesh refinement
**Phase 3+:** GPU acceleration, parallel multi-scale methods

## Integrator Comparison

| Method | Stages | Order | Cost/Step | Best For |
|--------|--------|-------|-----------|----------|
| RK2 | 2 | O(h³) local | 2 f-evals | Testing, simple problems |
| RK4 | 4 | O(h⁵) local | 4 f-evals | Standard use, production |
| RK45 | 6 | O(h⁵) local, O(h⁴) error | 6 f-evals | Adaptive, varying accuracy |

## Success Metrics
- Implementation passes all 10 task acceptance criteria
- Convergence verified on exponential decay, Lorenz system
- Adaptive stepping reduces steps by 50%+ vs fixed-step RK4
- Dense output interpolation accurate to O(h⁴)
- No external library dependencies beyond simple_math and ISE base
