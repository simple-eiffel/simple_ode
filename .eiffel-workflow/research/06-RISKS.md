# RISKS: simple_ode

## Risk Register

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|------------|--------|------------|
| RISK-001 | Accuracy degradation in long runs | LOW | HIGH | Extensive testing, energy/invariant tracking |
| RISK-002 | Users need stiff solvers (MVP doesn't have) | MEDIUM | MEDIUM | Clear documentation of nonstiff-only scope |
| RISK-003 | Complexity of RK45 implementation | MEDIUM | MEDIUM | Reference multiple sources, thorough testing |
| RISK-004 | Performance with very high-dimensional systems | MEDIUM | LOW | 100+ variable systems should work adequately |

## Technical Risks

### RISK-001: Numerical Error Accumulation
**Description:** Truncation + rounding errors may grow unboundedly in long simulations
**Likelihood:** LOW
**Impact:** HIGH (solution diverges)
**Indicators:** Energy conservation violated > 1%; oscillations grow
**Mitigation:** RK4 is proven method; error control; recommend smaller tolerances
**Contingency:** Phase 2 adds higher-order methods or geometric integrators

### RISK-002: Stiff Problem Detection Failure
**Description:** Library used on stiff problem without user realizing; solution incorrect
**Likelihood:** MEDIUM
**Impact:** MEDIUM (silent failure)
**Indicators:** Very small steps required; convergence very slow
**Mitigation:** Document nonstiff-only scope clearly; Phase 1 avoids implicit methods
**Contingency:** Phase 2 adds stiff solvers; can post-hoc add diagnostic

### RISK-003: Dense Output Interpolation Accuracy
**Description:** Interpolation between RK steps may not maintain expected accuracy
**Likelihood:** MEDIUM
**Impact:** MEDIUM (inconsistent behavior)
**Indicators:** Interpolated values far from actual solutions
**Mitigation:** Use polynomial interpolation from RK literature; extensive testing
**Contingency:** Phase 2 improves interpolation formula

## Resource Risks

### RISK-004: Scope Creep to Stiff Methods
**Description:** Users request implicit methods, pushing MVP timeline
**Likelihood:** HIGH
**Impact:** MEDIUM (scope expansion)
**Mitigation:** Explicit MVP scope; Phase 2 roadmap documented
**Contingency:** Defer stiff methods to Phase 2 with clear timeline
