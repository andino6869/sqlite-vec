# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
`sqlite-vec` is a vector search SQLite extension written in pure C that enables storing and querying float, int8, and binary vectors in `vec0` virtual tables. It's designed to be extremely small, fast, and run anywhere SQLite runs.

## Build System & Development Commands

### Core Build Commands
```bash
# Build all targets (loadable extension, static library, CLI)
make all

# Build individual targets
make loadable    # Creates dist/vec0.{so,dylib,dll}
make static      # Creates dist/libsqlite_vec0.a and dist/sqlite-vec.h
make cli         # Creates dist/sqlite3 with sqlite-vec built-in

# Clean build artifacts  
make clean
```

### Testing Commands
```bash
# Run basic SQLite test
make test

# Run Python test suite (requires loadable extension)
make test-loadable

# Run unit tests
make test-unit

# Watch mode for tests during development
make test-loadable-watch

# Update test snapshots
make test-loadable-snapshot-update
```

### Code Quality
```bash
# Format code (uses clang-format for C, black for Python)
make format

# Lint code
make lint
```

### WASM Build
```bash
# Build WebAssembly version
make wasm  # Creates dist/.wasm/sqlite3.mjs and sqlite3.wasm
```

### Documentation Site
```bash
# Development server for documentation
make site-dev

# Build documentation site  
make site-build
```

## Architecture Overview

### Core Components
- **sqlite-vec.c**: Main extension implementation (~15K+ lines of C)
- **sqlite-vec.h**: Public API header (generated from sqlite-vec.h.tmpl)
- **vec0 virtual table**: Primary interface for vector operations

### Key Directories
- **examples/**: Language-specific usage examples (Python, Node.js, Go, Rust, etc.)
- **tests/**: Comprehensive test suite using pytest with snapshot testing
- **site/**: VitePress documentation site
- **bindings/**: Language bindings for Python, Go, Rust
- **benchmarks/**: Performance benchmarks and profiling tools

### Virtual Table System
The `vec0` virtual table uses a sophisticated shadow table system:
- `xyz_chunks`: Chunk metadata with validity bitmaps
- `xyz_rowids`: Rowid to chunk mappings  
- `xyz_vector_chunksNN`: Vector data storage
- `xyz_auxiliary`: Non-vector auxiliary columns
- `xyz_metadata*`: Metadata column storage

### Query Processing
Uses custom `idxStr` encoding for query plan optimization:
- Header character indicates query type (fullscan='1', point='2', KNN='3')
- 4-character blocks describe constraint types and parameters
- Supports KNN queries, point lookups, partition filtering, and metadata constraints

## Development Environment

### Dependencies
- **C Compiler**: GCC or Clang with C99 support
- **Python**: 3.12+ for testing (uses pytest, numpy, syrupy)
- **Build Tools**: Make, ar (archiver)
- **Optional**: emscripten for WASM builds, Node.js for documentation

### Platform-Specific Notes
- **SIMD**: Automatically enables AVX (x86_64) or NEON (ARM64) optimizations
- **macOS**: Use `USE_BREW_SQLITE=1` to link against Homebrew SQLite
- **Extensions**: Built as .so (Linux), .dylib (macOS), .dll (Windows)

### Testing Strategy
- Unit tests in C (`tests/test-unit.c`)
- Integration tests in Python (`tests/test-*.py`) 
- Snapshot testing for regression detection
- Fuzz testing infrastructure in `tests/fuzz/`
- Correctness verification with `tests/correctness/`

## Key Files
- **VERSION**: Version number used for releases
- **ARCHITECTURE.md**: Detailed internal architecture documentation
- **reference.yaml**: API reference data
- **sqlite-dist.toml**: Distribution configuration