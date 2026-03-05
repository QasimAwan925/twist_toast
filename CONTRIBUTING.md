# Contributing to twist_toast

Thank you for considering contributing to **twist_toast**!

## How to Contribute

### Reporting Bugs

- Open an issue describing the bug, steps to reproduce, and your environment (Flutter/Dart version).
- Include a minimal code sample if possible.

### Suggesting Features

- Open an issue with a clear description of the feature and use case.
- Check existing issues first to avoid duplicates.

### Pull Requests

1. **Fork** the repository and create a branch from `main`.
2. **Make changes** — follow existing code style and run:
   ```bash
   flutter analyze
   flutter test
   ```
3. **Update** `CHANGELOG.md` under an `[Unreleased]` section.
4. **Submit** a PR with a clear description of the change.
5. Ensure CI passes (if applicable).

### Code Style

- Use `dart format .` before committing.
- Prefer `const` constructors where possible.
- Add tests for new behaviour.
- Keep the example app working and up to date.

### Running Tests

```bash
cd twist_toast
flutter pub get
flutter test
```

### Running the Example

```bash
cd example
flutter pub get
flutter run
```

---

By contributing, you agree that your contributions will be licensed under the project's MIT License.
