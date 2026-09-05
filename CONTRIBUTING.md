# Contributing to jiashu

Thank you for your interest in contributing to jiashu! This document provides guidelines and information for contributors.

## Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in the [Issues](https://github.com/yangwenjie008/jiashu/issues).
2. If not, create a new issue with a clear title and description.
3. Include steps to reproduce the bug.
4. Provide your environment details (OS, Go version, etc.).

### Suggesting Enhancements

1. Check if the enhancement has already been suggested in the [Issues](https://github.com/yangwenjie008/jiashu/issues).
2. If not, create a new issue with a clear title and description.
3. Explain why this enhancement would be useful.

### Pull Requests

1. Fork the repository.
2. Create a new branch from `main` for your changes.
3. Make your changes following the coding standards.
4. Write or update tests as needed.
5. Ensure all tests pass.
6. Submit a pull request with a clear description.

## Development Setup

### Prerequisites

- Go 1.21 or later
- Git
- Make (optional)

### Getting Started

1. Clone your fork:
   ```bash
   git clone https://github.com/your-username/jiashu.git
   cd jiashu
   ```

2. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/yangwenjie008/jiashu.git
   ```

3. Install dependencies:
   ```bash
   go mod tidy
   ```

4. Create a branch for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Coding Standards

### Go Code

- Follow the [Effective Go](https://golang.org/doc/effective_go.html) guidelines.
- Use `gofmt` to format your code.
- Use `go vet` to check for common mistakes.
- Write meaningful comments.
- Keep functions small and focused.

### Commit Messages

- Use the present tense ("Add feature" not "Added feature").
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...").
- Keep the first line under 72 characters.
- Reference issues and pull requests when relevant.

### Testing

- Write unit tests for new functionality.
- Ensure all tests pass before submitting a pull request.
- Aim for good test coverage.

## Code Review Process

1. All submissions require review before merging.
2. Maintainers will review your pull request and may request changes.
3. Once approved, your changes will be merged.

## Community

- Join our [Discussions](https://github.com/yangwenjie008/jiashu/discussions) for questions and ideas.
- Follow us on [Twitter](https://twitter.com/your-twitter-handle) for updates.

## License

By contributing to jiashu, you agree that your contributions will be licensed under the [MIT License](LICENSE).

## Questions?

If you have any questions, feel free to ask in the [Issues](https://github.com/yangwenjie008/jiashu/issues).
