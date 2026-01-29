# DECISIONS: simple_ode

## Decision Log

### D-001: Explicit vs Implicit Methods for MVP
**Question:** Should MVP include stiff ODE solvers?
**Options:**
1. Explicit only (Euler, RK4): Simpler, nonstiff problems
2. Include implicit (BDF): Complex, handles stiff equations

**Decision:** Explicit only for MVP
**Rationale:** Stiff methods significantly more complex; can add in Phase 2
**Implications:** MVP limited to nonstiff/mildly stiff problems
**Reversible:** YES - Phase 2 adds implicit methods

---

### D-002: Error Estimation Strategy
**Question:** How to control step size?
**Options:**
1. Fixed step size: Simple, less accurate
2. Embedded RK pairs (RK45): Good balance
3. Richardson extrapolation: More expensive

**Decision:** Embedded RK45 pair
**Rationale:** Industry standard, provides both solution and error estimate
**Implications:** Need RK4 and RK5 coefficients
**Reversible:** YES - can switch to Richardson if preferred

---

### D-003: Single ODE vs Systems
**Question:** Implement only single equation or full systems?
**Options:**
1. Single scalar ODE: Simpler
2. Systems (vectors): More powerful, handles coupled equations

**Decision:** Systems from start
**Rationale:** Coupled ODEs common (Lorenz, populations); only slightly more complex
**Implications:** Need vector arithmetic, work with ARRAY [REAL_64]
**Reversible:** NO - changing this later painful

---

### D-004: Jacobian Support
**Question:** Should MVP allow user-provided Jacobian?
**Options:**
1. No: Simpler MVP, numerical only
2. Optional callback: Ready for Phase 2 stiff solvers

**Decision:** Optional callback (prepared but unused in Phase 1)
**Rationale:** Design for Phase 2; simple to add now
**Implications:** Feature flag for Jacobian in result, unused until Phase 2
**Reversible:** YES - remove if not needed

---

### D-005: Event Detection
**Question:** Include zero-crossing detection in MVP?
**Options:**
1. No: Too complex for MVP
2. Simple callback: Allows root finding

**Decision:** No event detection in MVP
**Rationale:** Complex, can be deferred; Phase 2 adds callbacks
**Implications:** Deferred to Phase 2
**Reversible:** YES
