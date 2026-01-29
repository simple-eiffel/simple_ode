# LANDSCAPE: simple_ode

## Existing Solutions

### SUNDIALS (SUite of Nonlinear and DIfferential/ALgebraic Solvers)
| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY (comprehensive ODE/DAE solver suite) |
| Platform | C with Fortran, Python, Julia bindings |
| URL | https://computing.llnl.gov/projects/sundials |
| GitHub | https://github.com/LLNL/sundials |
| Maturity | MATURE (active development, 2023 SIAM/ACM Prize winner) |
| License | BSD-3-Clause |

**Strengths:**
- Industry standard (LLNL/DOE)
- Handles stiff and nonstiff ODEs
- Variable-order variable-step multistep methods
- Adams-Moulton for nonstiff (order 1-12)
- BDF (Backward Differentiation Formulas) for stiff (order 1-5)
- Excellent error control and adaptive stepping
- Large community, published research

**Weaknesses:**
- Complex C codebase (not lightweight)
- FFI binding required for Eiffel
- No type-safe contracts
- Steep learning curve
- Over-engineered for simple use cases

**Relevance:** 85% - Excellent technical reference for algorithms, methods, and error handling strategies

---

### CVODE (part of SUNDIALS)
| Aspect | Assessment |
|--------|------------|
| Type | COMPONENT (ODE solver from SUNDIALS) |
| Platform | C (part of SUNDIALS suite) |
| URL | https://help.scilab.org/docs/2026.0.0/en_US/cvode.html |
| Maturity | MATURE |
| License | BSD-3-Clause |

**Strengths:**
- Proven algorithms for stiff/nonstiff
- Variable order methods
- Dense output capabilities
- Event detection support

**Weaknesses:**
- Part of large suite (overhead for simple problems)
- C-only

**Relevance:** 80% - Reference implementation for ODE methods

---

### SciPy's ODE Solvers
| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY (Python scientific computing) |
| Platform | Python (Fortran/C backend) |
| URL | https://docs.scipy.org/doc/scipy/tutorial/optimize.html |
| Maturity | MATURE |
| License | BSD |

**Strengths:**
- Python convenience
- `scipy.integrate.solve_ivp` modern API
- Support for stiff solvers (BDF, Radau)
- Nonstiff solvers (RK45, RK23, DOP853)
- Event detection
- Well-documented

**Weaknesses:**
- Python-specific
- Less control than direct SUNDIALS
- Not strongly typed

**Relevance:** 70% - Good reference for high-level API design

---

### scikit-SUNDAE (Python SUNDIALS bindings)
| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY (Python bindings to SUNDIALS) |
| Platform | Python |
| URL | https://pypi.org/project/scikit-sundae/ |
| GitHub | https://github.com/bmcage/odes |
| Maturity | ACTIVE |
| License | Open source |

**Strengths:**
- Direct access to CVODE and IDA solvers
- Python convenience with SUNDIALS power
- Active development

**Weaknesses:**
- Python-only
- Still not type-safe

**Relevance:** 75% - Shows pattern for wrapping SUNDIALS effectively

---

### ODES scikit for SciPy
| Aspect | Assessment |
|--------|------------|
| Type | LIBRARY (ODE/DAE extension for SciPy) |
| Platform | Python |
| URL | https://github.com/bmcage/odes |
| Maturity | ACTIVE |
| License | BSD |

**Strengths:**
- BDF for stiff (CVODE from SUNDIALS)
- Adams-Moulton for nonstiff
- IDA for differential-algebraic equations
- Good documentation

**Weaknesses:**
- Python-specific
- No contract system

**Relevance:** 70% - Reference for method organization

---

## Eiffel Ecosystem Check

### ISE Libraries
- `base`: ARRAY, LIST (no ODE utilities)
- `math`: sqrt, sin, cos (basic functions)
- No ODE solver in ISE

### simple_* Libraries
- `simple_math`: Will provide sqrt, trig - WILL DEPEND
- `simple_linalg`: Will provide linear solvers (future dependency for Jacobians)
- **GAP:** No ODE library in Eiffel ecosystem

### Gobo Libraries
- No ODE library in Gobo

### Gap Analysis
**Critical Gap:** Eiffel has NO type-safe ODE solver. All ODE work requires:
1. FFI to C (SUNDIALS, GSL)
2. Manual implementation
3. Using SciPy/MATLAB from external process

**Opportunity:** simple_ode fills unique niche: lightweight, contract-verified, pure Eiffel ODE solver optimized for scientific computing.

---

## Comparison Matrix
| Feature | SUNDIALS | SciPy | CVODE | Our Need |
|---------|----------|-------|-------|----------|
| Explicit RK methods | ✓ | ✓ | ✓ | MUST |
| Adaptive step size | ✓ | ✓ | ✓ | MUST |
| Error tolerance control | ✓ | ✓ | ✓ | MUST |
| Stiff solvers | ✓ | ✓ | ✓ | SHOULD |
| Event detection | ✓ | ✓ | ✓ | SHOULD |
| Type-safe contracts | ✗ | ✗ | ✗ | MUST |
| Lightweight | ✗ | ✗ | ✗ | MUST |
| Pure Eiffel | ✗ | ✗ | ✗ | MUST |
| SCOOP compatible | ✗ | ✗ | ✗ | MUST |

---

## Patterns Identified
| Pattern | Seen In | Adopt? |
|---------|---------|--------|
| Initial value problem (IVP) structure | All | YES |
| Embedded RK pairs for error estimation | CVODE, SciPy | YES |
| Dense output (interpolation) | CVODE, SciPy | YES |
| Event detection via root finding | CVODE, SciPy | YES (Phase 2) |
| Jacobian for stiff methods | CVODE, SUNDIALS | YES (Phase 2) |
| Result object pattern | SciPy | YES |

---

## Build vs Buy vs Adapt
| Option | Effort | Risk | Fit |
|--------|--------|------|-----|
| BUILD | MEDIUM | LOW | 90% - Well-established algorithms, clear scope |
| ADAPT | HIGH | HIGH | 40% - Would need extensive FFI, lose type safety |
| ABANDON | NONE | N/A | 0% - Leaves critical scientific gap |

**Initial Recommendation:** BUILD

**Rationale:** ODE solving is a solved problem with published algorithms (RK4, RK45, Adams-Moulton). Scope is manageable for MVP. SUNDIALS is excellent reference but overkill for Eiffel. Building allows:
1. Pure Eiffel implementation (no FFI)
2. Type-safe contracts on all methods
3. SCOOP compatibility for parallel ensemble runs
4. Lightweight and focused API
5. Educational value

---

## References
- SUNDIALS: https://computing.llnl.gov/projects/sundials
- SUNDIALS GitHub: https://github.com/LLNL/sundials
- CVODE documentation: https://help.scilab.org/docs/2026.0.0/en_US/cvode.html
- SciPy optimize: https://docs.scipy.org/doc/scipy/tutorial/optimize.html
- scikit-SUNDAE: https://pypi.org/project/scikit-sundae/
- ODES scikit: https://github.com/bmcage/odes
- Numerical ODE textbooks: standard references (Butcher, Hairer & Wanner)
