# Contributing to Leonardo AI Universal

First off, thank you for considering contributing to Leonardo AI Universal! 🎉

## 🤝 Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Respect differing viewpoints and experiences

## 🚀 Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/officialerictm/LEO7.git
   cd LEO7
   ```

2. **Create a new branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the coding standards below
   - Add tests for new functionality
   - Update documentation as needed

4. **Test your changes**
   ```bash
   ./assembly/build.sh
   ./leonardo.sh --debug
   ```

5. **Submit a Pull Request**
   - Provide a clear description of the changes
   - Reference any related issues
   - Ensure all tests pass

## 📝 Coding Standards

### Shell Script Guidelines

1. **Use Bash 4.0+ features**
   ```bash
   # Good: Associative arrays
   declare -A my_map=()
   
   # Good: Proper array handling
   arr=("one" "two" "three")
   for item in "${arr[@]}"; do
       echo "$item"
   done
   ```

2. **Follow the component structure**
   ```bash
   #!/usr/bin/env bash
   # ==============================================================================
   # Leonardo AI Universal - Component Name
   # ==============================================================================
   # Description: Brief description
   # Version: 7.0.0
   # Dependencies: list, of, dependencies
   # ==============================================================================
   ```

3. **Use consistent naming**
   - Functions: `snake_case`
   - Constants: `LEONARDO_UPPER_CASE`
   - Local variables: `lower_case`

4. **Error handling**
   ```bash
   # Always check command success
   if ! command_that_might_fail; then
       log_message "ERROR" "Command failed"
       return 1
   fi
   ```

5. **Logging**
   ```bash
   # Use the logging system
   log_message "INFO" "Starting operation..."
   log_message "ERROR" "Something went wrong"
   log_message "DEBUG" "Variable value: $var"
   ```

### Documentation

- Keep README.md up to date
- Document all public functions
- Add examples for complex features
- Update the manifest when adding components

## 🏗️ Architecture

Leonardo uses a modular assembly system:

```
src/
├── core/           # Core functionality
├── modules/        # Deployment modules
├── ui/            # User interface
└── models/        # Model management
```

When adding new components:
1. Place them in the appropriate directory
2. Add to `assembly/manifest.yaml`
3. Define proper dependencies
4. Run the build script to test

## 🧪 Testing

- Test on multiple platforms (Linux, macOS, Windows via WSL)
- Test with minimal permissions
- Test offline functionality
- Verify no traces are left on host systems

## 📦 Submitting Changes

### Commit Messages

Follow the conventional commits format:
```
feat: add new model support for Llama 3.1
fix: resolve USB detection on macOS Sonoma
docs: update installation instructions
chore: update dependencies
```

### Pull Request Process

1. Update the README.md with details of changes if needed
2. Update the version numbers if applicable
3. The PR will be merged once you have approval from maintainers

## 🎯 What We're Looking For

- **Bug fixes** - Always welcome!
- **New deployment targets** - Extend Leonardo to new platforms
- **Model support** - Add support for new AI models
- **UI improvements** - Make Leonardo even more user-friendly
- **Performance optimizations** - Make it faster and more efficient
- **Security enhancements** - Make it even more paranoid

## 🙋 Questions?

Feel free to:
- Open an issue for questions
- Join our Discord community
- Email the maintainers

Thank you for helping make Leonardo AI Universal better! 🚀
