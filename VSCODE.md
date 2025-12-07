# VS Code Development Setup for R

This document describes how to set up VS Code for iterating on R source code.

## Quick Start

```bash
# One-time setup (generates config.h for intellisense)
just intree-configure

# After editing files
just make          # or Cmd+Shift+B in VS Code

# Test your changes
just run           # launches R REPL
just eval "1 + 1"  # run expression
```

## Available Commands

| Command | Description |
|---------|-------------|
| `just intree-configure` | Configure in-tree (run once) |
| `just make` | Build R (incremental, rebuilds only changed files) |
| `just make-component <dir>` | Build specific directory (e.g., `src/main`) |
| `just run` | Run in-tree R with `--vanilla` |
| `just eval "<expr>"` | Evaluate R expression |
| `just intree-clean` | Clean build artifacts (keeps config) |
| `just intree-distclean` | Full clean (need to reconfigure) |

## VS Code Tasks

Press `Cmd+Shift+B` (default build) or `Cmd+Shift+P` → "Tasks: Run Task":

- **Build R** - Default build task, runs `just make`
- **Build Component** - Build a specific directory from a list
- **Configure (in-tree)** - Run initial configure
- **Run R** - Launch R REPL
- **Clean** - Clean build artifacts

## C/C++ Intellisense

The `.vscode/c_cpp_properties.json` is pre-configured with:

- Include paths for `src/include`, `src/main`, `src/nmath`, etc.
- Homebrew paths for macOS dependencies
- Defines: `HAVE_CONFIG_H`, `R_NO_REMAP`, `STRICT_R_HEADERS`

After running `just intree-configure`, intellisense will work because `src/include/config.h` is generated in-place.

## Workflow Example

1. Open VS Code in the R source directory
2. Run `just intree-configure` (first time only)
3. Edit a C file, e.g., `src/main/main.c`
4. Press `Cmd+Shift+B` to rebuild
5. Run `just run` to test changes

Incremental builds are fast (~0.2s for single file changes).

## Configure Options

The in-tree configure uses these options for fast iteration:

```
--disable-site-config          # Ignore site configs
--enable-fast-config           # Skip X11/cairo/tcltk/java/NLS checks
--without-recommended-packages # Skip MASS, lattice, etc.
--disable-html-docs            # Skip documentation build
```

To customize, edit `intree-configure` in the justfile.

## Troubleshooting

**Intellisense not working?**
- Ensure `src/include/config.h` exists (run `just intree-configure`)
- Reload VS Code window (`Cmd+Shift+P` → "Developer: Reload Window")

**Build errors after pulling changes?**
- Run `just intree-distclean && just intree-configure`

**Want to build without unity files?**
- `just make UNITY_BUILD=no`
