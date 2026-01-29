# simple_ode

[Documentation](#documentation) •
[GitHub](https://github.com/simple-eiffel/simple_ode) •
[Issues](https://github.com/simple-eiffel/simple_ode/issues)

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Eiffel 25.02](https://img.shields.io/badge/Eiffel-25.02-purple.svg)
![DBC: Contracts](https://img.shields.io/badge/DBC-Contracts-green.svg)

ODE integration library with RK2 midpoint, RK4 classical, and RK45 Dormand-Prince methods.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.0.0
- 6 tests passing, 100% pass rate
- RK2, RK4, RK45 numerical integration methods
- Design by Contract throughout

## Quick Start

```eiffel
-- Create an ODE solver
local
    l_solver: ODE_SOLVER
    l_result: ODE_RESULT
    l_y0: ARRAY [REAL_64]
do
    create l_solver
    -- Solve dy/dt = -y from t=0 to t=1 with tolerances
    l_result := l_solver.integrate (agent ode_function, l_y0, 0.0, 1.0, 0.001, 0.001)
end
```

See the [User Guide](#documentation) for complete examples.

## Features

- RK2 (Midpoint Method) - O(h³) accuracy
- RK4 (Classical Runge-Kutta) - O(h⁵) accuracy
- RK45 (Dormand-Prince) - Adaptive stepping with error control
- Dense output via solution curve interpolation
- Design by Contract for reliability

## Installation

```eiffel
<!-- Add to your ECF: -->
<library name="simple_ode" location="$SIMPLE_EIFFEL/simple_ode/simple_ode.ecf"/>
```

## License

MIT License - See LICENSE file

## Support

- **GitHub**: https://github.com/simple-eiffel/simple_ode
- **Issues**: https://github.com/simple-eiffel/simple_ode/issues

## Documentation

For complete documentation, examples, and API reference, see the `docs/` directory or visit the project GitHub pages site.
