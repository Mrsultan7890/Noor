# Contributing to Noor App

First off, thank you for considering contributing to Noor! 🌙

## How Can I Contribute?

### Reporting Bugs
- Use GitHub Issues
- Include detailed steps to reproduce
- Include screenshots if applicable
- Mention your device and OS version

### Suggesting Features
- Open a GitHub Issue with [Feature Request] tag
- Explain the feature and its benefits
- Provide mockups if possible

### Code Contributions

#### Setup Development Environment
```bash
# Clone the repo
git clone https://github.com/yourusername/noor.git
cd noor

# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run the app
flutter run
```

#### Coding Standards
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features
- Run `flutter analyze` before committing

#### Commit Messages
- Use clear, descriptive messages
- Start with a verb (Add, Fix, Update, etc.)
- Reference issue numbers when applicable

Example:
```
Add Hadith collection feature (#123)
Fix notification scheduling bug (#124)
Update Quran API integration (#125)
```

#### Pull Request Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

#### PR Guidelines
- Link related issues
- Describe changes in detail
- Include screenshots/videos for UI changes
- Ensure all tests pass
- Update documentation if needed

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

## Code of Conduct

### Our Standards
- Be respectful and inclusive
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or insulting comments
- Publishing others' private information
- Any unprofessional conduct

## Questions?

Feel free to open an issue with the [Question] tag.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**جزاک اللہ خیرا** - May Allah reward you for your contribution!
