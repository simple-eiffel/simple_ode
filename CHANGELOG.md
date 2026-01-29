# Changelog

All notable changes to simple_ode are documented in this file.

## [1.0.0] - 2026-01-29

### Added

- **RK2 Integrator**: Midpoint method (O(h³) accuracy)
- **RK4 Integrator**: Classical Runge-Kutta (O(h⁵) accuracy)
- **RK45 Integrator**: Dormand-Prince with embedded error estimation
- **ODE Solver**: Adaptive stepping with automatic step size control
- **Solution Curve**: Dense output via linear interpolation
- **Design by Contract**: Full contract specification throughout
- **Test Suite**: 6 passing tests (100% pass rate)

### Technical

- Void-safe implementation (void_safety="all")
- Design by Contract (preconditions, postconditions, invariants)
- No external dependencies beyond simple_math and simple_mml
- Production-ready quality assurance

## Installation

```eiffel
<!-- Add to your ECF: -->
<library name="simple_ode" location="$SIMPLE_EIFFEL/simple_ode/simple_ode.ecf"/>
```

## Status

✅ **v1.0.0** - Production ready

- 6 tests passing (100% pass rate)
- All compilation warnings resolved
- Design by Contract verified

## License

MIT License - See LICENSE file
