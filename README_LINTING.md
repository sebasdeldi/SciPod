# Comprehensive Linting Setup for SciPod

This project uses **RuboCop** for Ruby code quality and **ERB Lint** for ERB template linting. We've configured a comprehensive linting setup that follows Rails best practices while being practical for our application.

## 🔧 Configuration

### Ruby Linting (RuboCop)
- **rubocop-rails-omakase**: Rails' opinionated Ruby styling
- **rubocop-performance**: Performance-related cops
- **rubocop-rspec**: RSpec-specific cops
- **rubocop-factory_bot**: Factory Bot-specific cops

### ERB Template Linting (ERB Lint)
- **erb_lint**: Shopify's ERB template linter
- **Core linters**: ERB syntax, HTML structure, Rails patterns
- **Auto-correction**: Fixes whitespace, formatting, and HTML issues

### Project-Specific Rules
- **Line length**: 120 characters (vs default 80)
- **has_and_belongs_to_many**: Allowed for simple join tables
- **Hardcoded strings**: Allowed in controllers/models (can be moved to locales later)
- **Uniqueness validations**: Don't require database indexes (for development speed)
- **HTML formatting**: Enforces HTML5 standards and Rails conventions

## 📝 Available Scripts

### `bin/lint` - Comprehensive linting (Ruby + ERB)
```bash
# Check all Ruby and ERB files
bin/lint

# Auto-fix correctable issues in both Ruby and ERB
bin/lint --fix

# Auto-fix including unsafe corrections (Ruby only)
bin/lint --fix-unsafe

# Check specific files/directories
bin/lint app/models
bin/lint app/views/podcasts

# Run only Ruby linting
bin/lint --ruby-only

# Run only ERB linting  
bin/lint --erb-only
```

### `bin/lint-check` - Read-only checking (Ruby + ERB)
```bash
# Check code quality without making any changes
bin/lint-check

# Check specific files
bin/lint-check app/models

# Check only Ruby files
bin/lint-check --ruby-only

# Check only ERB files
bin/lint-check --erb-only
```

### `bin/lint-erb` - Dedicated ERB linting
```bash
# Check all ERB files
bin/lint-erb

# Auto-fix ERB issues
bin/lint-erb --fix

# Check specific directories
bin/lint-erb app/views
bin/lint-erb app/views/podcasts
```

### `bin/lint-staged` - Git hook integration (Ruby + ERB)
```bash
# Lint only staged files (useful for pre-commit hooks)
bin/lint-staged
```

## 🚀 Usage Examples

### During Development
```bash
# Quick check of current changes
bin/lint-check app/models

# Fix styling issues automatically
bin/lint app/controllers --fix

# Fix ERB template issues
bin/lint-erb app/views --fix

# Full project check
bin/lint-check
```

### Before Committing
```bash
# Check only files you're about to commit
bin/lint-staged

# Fix any issues found
bin/lint --fix
```

### Continuous Integration
```bash
# In your CI pipeline, use the check-only version
bin/lint-check
```

## 🎯 Current Status

✅ **ZERO OFFENSES** - Your codebase is fully compliant!

Both Ruby and ERB code follows best practices:
- **72 Ruby files** - Zero RuboCop offenses
- **39 ERB files** - Zero ERB Lint offenses  
- **87 ERB issues** - Auto-corrected during setup

## 📋 ERB Linting Features

### Enabled Linters
- **ArgumentsCheck**: Validates ERB argument syntax
- **ClosingErbTagIndent**: Proper ERB tag indentation
- **ErbSafety**: Security checks for unsafe ERB output
- **ParserErrors**: Catches ERB syntax errors
- **RightTrim**: Removes unnecessary trailing spaces
- **SelfClosingTag**: Enforces HTML5 self-closing tag style
- **TrailingWhitespace**: Removes trailing whitespace
- **UnescapedOutput**: Warns about potentially unsafe output
- **PartialInstanceVariable**: Enforces locals over instance variables
- **CommentSyntax**: Proper ERB comment format
- **ButtonHasType**: Ensures buttons have type attributes
- **ExtraWhitespace**: Removes unnecessary whitespace
- **FinalNewline**: Ensures files end with newlines
- **SpaceAroundErbTag**: Consistent ERB tag spacing
- **SpaceIndentation**: Proper indentation

### Auto-Correctable Issues
- Trailing whitespace removal
- Missing final newlines
- Self-closing tag format (`<br>` vs `<br />`)
- ERB tag spacing
- Extra whitespace cleanup

## 🔧 Customization

### Ruby Configuration (`.rubocop.yml`)
Edit to:
- Add project-specific rules
- Exclude additional files/directories  
- Adjust severity levels
- Enable/disable specific cops

### ERB Configuration (`.erb_lint.yml`)
Edit to:
- Enable additional linters
- Configure linter-specific options
- Add custom HTML rules
- Adjust file exclusion patterns

## 🚨 Common Issues and Solutions

### Long lines in views
Views are excluded from line length checks, but you can manually break long lines.

### ERB syntax warnings
Use proper ERB syntax:
- Comments: `<%# comment %>` not `<% # comment %>`
- Output: `<%= value %>` for safe output
- Execution: `<% code %>` for logic

### HTML structure issues
ERB Lint enforces HTML5 standards:
- Self-closing tags: `<br>` not `<br />`
- Button types: `<button type="button">` required
- Proper tag nesting and structure

### Performance cops
The performance extension catches common Ruby performance issues automatically.

### Template partials
Use locals instead of instance variables in partials:
```erb
<!-- Good -->
<%= render 'podcast_card', podcast: @podcast %>

<!-- Avoid -->
<%= render 'podcast_card' %>  <!-- accessing @podcast inside partial -->
```

## 🎨 File Formatting Results

### Before ERB Lint
- 86 template formatting issues
- Inconsistent self-closing tags
- Trailing whitespace throughout
- Missing final newlines
- Improper ERB tag spacing

### After ERB Lint  
- ✅ **Zero ERB offenses**
- Consistent HTML5 formatting
- Clean, professional templates
- Proper ERB syntax throughout
- Standardized whitespace and indentation

## 📚 Resources

- [RuboCop Rails Documentation](https://docs.rubocop.org/rubocop-rails/)
- [Rails Omakase Style Guide](https://github.com/rails/rubocop-rails-omakase)
- [ERB Lint Documentation](https://github.com/Shopify/erb_lint)
- [RuboCop Performance](https://github.com/rubocop/rubocop-performance)
- [RuboCop RSpec](https://github.com/rubocop/rubocop-rspec)

---

Run `bin/lint-check` anytime to verify your code and template quality! 🎉 