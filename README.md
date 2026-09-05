# jiashu

A Go mobile application project.

## Features

- Feature 1
- Feature 2
- Feature 3

## Prerequisites

- Go 1.21 or later
- Mobile development environment (Android SDK/iOS Xcode)
- Git

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yangwenjie008/jiashu.git
   cd jiashu
   ```

2. Install dependencies:
   ```bash
   go mod tidy
   ```

3. Build the project:
   ```bash
   make build
   ```

## Usage

### Development

```bash
# Run tests
make test

# Run linter
make lint

# Build for development
make dev
```

### Mobile Build

```bash
# Build for Android
make android

# Build for iOS
make ios
```

## Project Structure

```
jiashu/
├── cmd/            # Application entry points
├── pkg/            # Public packages
├── internal/       # Private packages
├── api/            # API definitions
├── configs/        # Configuration files
├── scripts/        # Build and utility scripts
├── docs/           # Documentation
├── tests/          # Test files
├── Makefile        # Build automation
└── go.mod          # Go module definition
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

- Project Link: https://github.com/yangwenjie008/jiashu
- Issues: https://github.com/yangwenjie008/jiashu/issues
