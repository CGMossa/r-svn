# R Source Architecture

This document outlines the architecture of the R interpreter, describing the minimal core, optional components, and how they fit together.

## Overview

R is structured as a layered system:

```default
┌─────────────────────────────────────────────────────────────────┐
│                     Frontend Binaries                           │
│                  (R.bin, Rscript, libR.so)                      │
├─────────────────────────────────────────────────────────────────┤
│                    Base Packages                                │
│    (base, stats, graphics, grDevices, utils, methods, ...)      │
├─────────────────────────────────────────────────────────────────┤
│                  Loadable Modules                               │
│              (internet, lapack, X11)                            │
├─────────────────────────────────────────────────────────────────┤
│                    Core Interpreter                             │
│                     (src/main/)                                 │
├──────────────────┬──────────────────┬───────────────────────────┤
│  Platform Layer  │   Math Library   │   Applied Statistics      │
│   (src/unix/)    │   (src/nmath/)   │      (src/appl/)          │
├──────────────────┴──────────────────┴───────────────────────────┤
│                    Extra Libraries                              │
│            (tre, xdr, tzone, intl, blas)                        │
└─────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```default
src/
├── include/          # Public and internal headers
├── extra/            # Support libraries
├── nmath/            # Statistical math library
├── appl/             # Applied statistics routines
├── unix/             # Unix platform layer
├── gnuwin32/         # Windows platform layer
├── main/             # Core interpreter (~141K lines)
├── modules/          # Dynamically loaded modules
├── library/          # Base R packages
└── scripts/          # Shell scripts (R, Rscript wrappers)
```

---

## 1. Minimal Core (Required)

### 1.1 Core Interpreter (`src/main/`)

The heart of R. Contains ~108 C source files implementing:

#### Parser & Evaluator

| File | Purpose |
|------|---------|
| `gram.y` | YACC grammar defining R syntax |
| `gram.c` | Generated parser |
| `eval.c` | Core evaluation engine, bytecode interpreter |
| `builtin.c` | Built-in primitive functions |

#### Memory & Object System

| File | Purpose |
|------|---------|
| `memory.c` | Garbage collector, SEXP allocation |
| `duplicate.c` | Object copying/duplication |
| `attrib.c` | Attribute handling |
| `names.c` | Symbol table management |

#### Data Types

| File | Purpose |
|------|---------|
| `arithmetic.c` | Numeric operations |
| `array.c` | Arrays and matrices |
| `character.c` | Strings |
| `complex.c` | Complex numbers |
| `list.c` | Lists and pairlists |
| `coerce.c` | Type coercion |
| `subscript.c` | Indexing (`[`, `[[`) |
| `subassign.c` | Assignment indexing (`[<-`, `[[<-`) |

#### Environment & Control Flow

| File | Purpose |
|------|---------|
| `envir.c` | Environments and namespaces |
| `context.c` | Execution context stack |
| `errors.c` | Error/warning handling |
| `objects.c` | S3/S4 method dispatch |

#### I/O & Serialization

| File | Purpose |
|------|---------|
| `connections.c` | File/URL/text connections |
| `scan.c` | Reading data |
| `source.c` | Source file processing |
| `serialize.c` | RDS format serialization |
| `saveload.c` | .RData save/load |

#### Dynamic Loading

| File | Purpose |
|------|---------|
| `Rdynload.c` | DLL/shared library loading |
| `registration.c` | Native symbol registration |

#### Entry Points

| File | Purpose |
|------|---------|
| `main.c` | R executable entry point |
| `Rmain.c` | Calls `Rf_initialize_R()` + `Rf_mainloop()` |
| `startup.c` | Initialization sequence |

**Produces:** Object files linked into `R.bin` or `libR.so`

### 1.2 Platform Layer (`src/unix/` or `src/gnuwin32/`)

Platform-specific implementations:

| File | Purpose |
|------|---------|
| `system.c` | `Rf_initialize_R()`, system setup |
| `sys-unix.c` | Unix system calls |
| `sys-std.c` | Standard utilities (files, signals) |
| `dynload.c` | `dlopen`/`dlsym` wrapper |
| `Rscript.c` | Rscript binary source |
| `Rembedded.c` | Embedding API |

**Produces:** `libunix.a`, `Rscript` binary

### 1.3 Math Library (`src/nmath/`)

Statistical distributions and special functions (~131 files):

- **Distributions:** Normal, Beta, Gamma, t, F, Chi-square, Binomial, Poisson, etc.
- **Density/CDF/Quantile:** `d*`, `p*`, `q*`, `r*` functions
- **Special Functions:** Gamma, Beta, Bessel, Polygamma
- **RNG:** Random number generation

**Produces:** `libnmath.a`

Also builds standalone library in `nmath/standalone/` for external use.

### 1.4 Applied Statistics (`src/appl/`)

Numerical routines (mostly Fortran):

| File | Purpose |
|------|---------|
| `dqrdc.f`, `dqrsl.f` | QR decomposition |
| `dsvdc.f` | SVD |
| `dpofa.f`, `dposl.f` | Cholesky decomposition |
| `integrate.c` | Numerical integration |
| `optim.c` | General optimization |
| `uncmin.c` | Unconstrained minimization |
| `lbfgsb.c` | L-BFGS-B algorithm |

**Produces:** `libappl.a`

### 1.5 Extra Libraries (`src/extra/`)

Required support libraries:

| Directory | Purpose | Output |
|-----------|---------|--------|
| `tre/` | Regular expressions (grep, gsub) | `libtre.a` |
| `xdr/` | External Data Representation | `libxdr.a` |
| `tzone/` | Timezone database | `libtz.a` |
| `intl/` | GNU gettext (i18n) | `libintl.a` |
| `blas/` | Basic Linear Algebra | `libRblas.{a,so}` |

---

## 2. Optional Components

### 2.1 Loadable Modules (`src/modules/`)

Dynamically loaded at runtime via `dlopen()`:

#### Internet Module (`internet/`)

```
internet.c     - HTTP/FTP protocols
libcurl.c      - curl integration
Rhttpd.c       - Built-in HTTP server
sock.c         - Socket operations
```

**Provides:** `download.file()`, `url()`, `socketConnection()`
**Output:** `internet.so`

#### LAPACK Module (`lapack/`)

```default
Lapack.c           - LAPACK interface (53KB)
dlapack.f          - Fortran LAPACK routines (5MB+)
accelerateLapack.c - macOS Accelerate integration
```

**Provides:** `solve()`, `eigen()`, `qr()`, `svd()`, `chol()`
**Output:** `lapack.so`

#### X11 Module (`X11/`)

X11 graphics device for Unix/Linux.
**Output:** `R_X11.so`

### 2.2 Experimental (`src/extra/rust_test/`)

Rust integration test files. Built only with `--enable-rust`.

---

## 3. Base Packages (`src/library/`)

### Mandatory Base Packages

| Package | Purpose |
|---------|---------|
| `base` | Core language: operators, control flow, basic I/O |
| `stats` | Statistical functions, distributions, models |
| `graphics` | Base plotting system |
| `grDevices` | Graphics devices (PDF, PNG, etc.) |
| `utils` | Utilities: help, install.packages, etc. |
| `methods` | S4 object system |
| `datasets` | Example datasets |
| `compiler` | Bytecode compiler |
| `grid` | Grid graphics system |
| `tools` | Package development tools |
| `splines` | Spline functions |
| `stats4` | S4 statistics classes |
| `parallel` | Parallel computation |
| `tcltk` | Tcl/Tk interface |
| `translations` | Message translations |

### Optional Recommended Packages (`Recommended/`)

Bundled but not strictly required: Matrix, MASS, lattice, nlme, etc.

---

## 4. Frontend Binaries

### R.bin (Main Executable)

- **Entry:** `src/main/Rmain.c`
- **Flow:** `main()` → `Rf_initialize_R()` → `Rf_mainloop()`
- **Links:** All core libraries + modules

### Rscript

- **Entry:** `src/unix/Rscript.c`
- **Purpose:** Non-interactive script execution
- **Usage:** `#!/usr/bin/env Rscript` shebang support

### libR.so (Shared Library)

- **Configure:** `--enable-R-shlib`
- **Purpose:** Embed R in other applications
- **API:** `Rf_initEmbeddedR()`, `Rf_endEmbeddedR()`

### libR.a (Static Library)

- **Purpose:** Static linking
- **Contains:** All `*.o` from main + unix + appl + nmath

---

## 5. Headers (`src/include/`)

### Public API (for packages)

| Header | Purpose |
|--------|---------|
| `R.h` | Main include for packages |
| `Rinternals.h` | SEXP types, accessor macros |
| `R_ext/*.h` | Extension APIs |

### Internal API

| Header | Purpose |
|--------|---------|
| `Defn.h` | Internal structures (USE_RINTERNALS) |
| `Internal.h` | Internal function declarations |
| `Parse.h` | Parser interface |
| `IOStuff.h` | I/O structures |

---

## 6. Build Flow

```
1. configure          → Generate Makefiles, config.h
2. src/extra/         → Build support libraries
3. src/nmath/         → Build math library
4. src/appl/          → Build applied stats
5. src/unix/          → Build platform layer
6. src/main/          → Build core interpreter
7. src/modules/       → Build loadable modules
8. src/library/       → Build/install base packages
9. Link R.bin         → Final executable
```

### Minimal Build

To build a minimal R without optional features:

```bash
./configure \
    --without-recommended-packages \
    --without-x \
    --disable-java \
    --without-tcltk \
    --without-libcurl
```

This produces an R that can:

- Parse and evaluate R code
- Perform statistical computations
- Read/write files
- Load packages

But lacks:

- X11 graphics
- Network downloads
- Tcl/Tk GUI
- Java integration

---

## 7. Key Architectural Patterns

### SEXP: The Universal Data Type

All R objects are `SEXP` (pointer to `SEXPREC` structure):

- Tagged union with type field
- Reference counting + mark-and-sweep GC
- Attributes stored as pairlist

### Evaluation Model

```
R Expression → Parser → AST (SEXP) → Evaluator → Result (SEXP)
                            ↓
                      Bytecode Compiler
                            ↓
                      Bytecode Interpreter
```

### Module Loading

- Modules are `.so` files loaded via `dlopen()`
- Packages register native routines via `R_registerRoutines()`
- Symbol lookup through registration tables (not `dlsym()` directly)

### Lazy Loading

- Package code compiled to bytecode
- Stored as serialized RDS files
- Loaded on first access

---

## 8. Compiler Support

R supports multiple compilers for different source types:

| Extension | Compiler | Purpose |
|-----------|----------|---------|
| `.c` | CC (gcc/clang) | C sources |
| `.cc`, `.cpp` | CXX (g++/clang++) | C++ sources |
| `.f`, `.f90` | FC (gfortran) | Fortran sources |
| `.m` | OBJC (clang) | Objective-C sources |
| `.rs` | RUSTC (rustc) | Rust sources |

Rust support (experimental) allows:

- Compiling `.rs` files to object files
- Linking Rust code into R packages
- Using Rust's safety guarantees in native code

---

## 9. What's Truly Essential?

### Absolute Minimum for R Evaluation

1. `src/main/` - Parser, evaluator, memory management
2. `src/unix/` (or gnuwin32) - Platform initialization
3. `src/extra/tre/` - Regular expressions (heavily used)
4. `src/library/base/` - Core language functions

### Required for Useful R

Add:

- `src/nmath/` - Statistical functions
- `src/appl/` - Optimization, linear algebra basics
- `src/library/stats/` - Statistical analysis
- `src/modules/lapack/` - Full linear algebra

### Full R Experience

Add:

- All base packages
- `src/modules/internet/` - Network access
- `src/modules/X11/` - Graphics (Unix)
- Recommended packages

---

## 10. File Count Summary

| Component | C Files | Fortran Files | Lines of Code |
|-----------|---------|---------------|---------------|
| src/main/ | ~100 | 0 | ~141,000 |
| src/unix/ | ~15 | 0 | ~15,000 |
| src/nmath/ | ~130 | 0 | ~25,000 |
| src/appl/ | ~10 | ~30 | ~20,000 |
| src/extra/ | ~50 | 0 | ~30,000 |
| src/modules/ | ~20 | ~10 | ~15,000 |
| **Total** | **~325** | **~40** | **~246,000** |

Plus R code in `src/library/` (~200,000 lines across all base packages).
