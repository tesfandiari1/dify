# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- API (Python): `cd api && poetry run pytest` (full tests)
- API (Python): `cd api && poetry run pytest tests/unit_tests/path/to/test.py -v` (single test)
- Web (TypeScript): `cd web && pnpm lint` (lint check)
- Web (TypeScript): `cd web && pnpm test` (run tests)
- Web (TypeScript): `cd web && pnpm dev` (development server)
- Docker: `cd docker && docker compose up -d` (run full stack)

## Code Style Guidelines
- Python: Use strong typing with mypy, add type annotations to all function params and returns
- Python: Follow PEP 8 conventions for naming (snake_case for functions/variables, PascalCase for classes)
- TypeScript: Use ES6+ features, functional patterns, and strict typing
- TypeScript: Use single quotes for strings, 2-space indentation
- Error handling: Use proper exception handling with descriptive error messages
- Imports: Group imports logically (std lib, 3rd party, local), sort them alphabetically
- Documentation: Add docstrings to functions/classes, particularly for public APIs
- Testing: Write unit tests for new functionality, follow existing test patterns