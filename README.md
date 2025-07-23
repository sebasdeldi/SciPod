# 🎙️ SciPod

**Transform your research papers into engaging podcasts with AI-powered audio generation.**

Podcast AI is a modern web application built with Ruby on Rails that allows users to upload PDF documents and convert them into audio podcasts. Users can discover, search, listen to, and favorite podcasts created by the community.

[![Ruby on Rails](https://img.shields.io/badge/Rails-8.0.2-red.svg)](https://rubyonrails.org/)
[![Ruby](https://img.shields.io/badge/Ruby-3.4-red.svg)](https://www.ruby-lang.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://www.postgresql.org/)
[![RuboCop](https://img.shields.io/badge/RuboCop-✅_Passing-green.svg)](https://rubocop.org/)
[![ERB Lint](https://img.shields.io/badge/ERB_Lint-✅_Passing-green.svg)](https://github.com/Shopify/erb_lint)
[![RSpec](https://img.shields.io/badge/RSpec-Tests-green.svg)](https://rspec.info/)

## 🚀 Features

### 🔐 **User Authentication & Profiles**
- Complete user registration and authentication system
- User profiles with dashboard and statistics
- Password reset and account management

### 📄 **Podcast Creation**
- Upload PDF documents for podcast conversion
- AI-powered metadata extraction and audio generation
- Automatic author and publisher detection
- Intelligent script generation from document content

### 🔍 **Discovery & Search**
- Full-text search across podcasts, authors, and publishers
- Instant search results with debounced input
- Smart search behavior: blank searches show all content (like homepage)
- Search context preservation during interactions
- Filter by popularity and recency
- Browse by authors and publishers

### 🎧 **Listening Experience**
- HTML5 audio player with standard controls
- Track listening progress
- Stream audio directly in browser
- View podcast metadata and content

### ❤️ **Social Features**
- Favorite/unfavorite podcasts with instant Turbo Stream updates
- Search context preservation when favoriting (no disruption to current view)
- View your favorites collection
- Real-time favorite count updates across all views
- See most popular podcasts
- User-generated content discovery

### 📱 **Modern UX**
- Single-Page Application feel with Hotwire (Turbo + Stimulus)
- Instant updates without page reloads
- Smart Turbo Frame navigation (seamless page transitions)
- Context-aware interactions (search state preservation)
- Responsive design for all devices
- Progressive enhancement with graceful fallbacks

## ✨ **Recent Improvements**

### 🔧 **Enhanced Search Experience**
- **Smart Blank Search**: Empty searches now display all podcasts instead of no results
- **Context Preservation**: Search state maintained during favoriting and other interactions
- **Seamless Navigation**: Proper page transitions from search results to podcast details

### ⚡ **Optimized User Interactions**
- **Non-Disruptive Favoriting**: Favorite/unfavorite actions preserve current search view
- **Real-Time Updates**: Instant favorite count updates across all interface elements
- **Turbo Frame Navigation**: Intelligent frame targeting for optimal user experience

### 🎯 **Technical Enhancements**
- **Search Context Passing**: Query parameters preserved through form submissions
- **Conditional Turbo Streams**: Dynamic template rendering based on user context
- **Frame-Aware Links**: Smart navigation that respects Turbo Frame boundaries

## 🛠️ Technology Stack

### **Backend**
- **Ruby 3.4** - Modern Ruby with latest features
- **Rails 8.0.2** - Latest Rails with new defaults
- **PostgreSQL 16** - Robust relational database
- **Sidekiq** - Background job processing
- **Redis** - Caching and job queue

### **Frontend**
- **Hotwire** - Turbo + Stimulus for SPA experience
- **ESBuild** - Fast JavaScript bundling
- **Propshaft** - Modern asset pipeline
- **CSS3** - Custom responsive styling

### **Key Gems**
- **Devise** - Authentication system
- **Active Storage** - File upload handling
- **pg_search** - Full-text search capabilities
- **image_processing** - File processing utilities

### **Development & Quality**
- **RSpec** - Comprehensive testing framework
- **FactoryBot** - Test data generation
- **Capybara** - Integration testing
- **RuboCop** - Ruby code quality and style enforcement
- **ERB Lint** - ERB template linting and formatting
- **dotenv** - Environment variable management

## 📋 Prerequisites

Before setting up the project, ensure you have:

- **Ruby 3.4+** installed ([rbenv](https://github.com/rbenv/rbenv) recommended)
- **Node.js 18+** and **Yarn** for asset compilation
- **PostgreSQL 14+** running locally
- **Redis 6+** for background jobs
- **Git** for version control

### Quick Install (macOS with Homebrew)
```bash
# Install required services
brew install postgresql redis

# Start services
brew services start postgresql
brew services start redis

# Install Ruby version manager (if not already installed)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Install Ruby 3.4
rbenv install 3.4.0
rbenv global 3.4.0
```

## 🚀 Quick Start

### 1. **Clone the Repository**
```bash
git clone https://github.com/yourusername/scipod.git
cd scipod
```

### 2. **Install Dependencies**
```bash
# Install Ruby gems
bundle install

# Install JavaScript packages
yarn install
```

### 3. **Environment Setup**
```bash
# Copy environment template
cp .env.example .env.local

# Edit environment variables
vim .env.local
```

**Required Environment Variables:**
```bash
DATABASE_URL=postgresql://localhost/scipod_development
REDIS_URL=redis://localhost:6379/0
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_here
SIDEKIQ_CONCURRENCY=5
SIDEKIQ_TIMEOUT=30
```

### 4. **Database Setup**
```bash
# Create and setup database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 5. **Start the Application**
```bash
# Start all services (web, sidekiq, assets)
bin/dev

# Or start individually:
# bin/rails server        # Web server on http://localhost:3000
# bundle exec sidekiq     # Background jobs
# yarn build --watch      # Asset compilation
```

### 6. **Visit the Application**
Open [http://localhost:3000](http://localhost:3000) in your browser.

## 📖 Usage Guide

### **Creating Your First Podcast**

1. **Sign Up** - Create a new account or sign in
2. **Create Podcast** - Click "Create Podcast" in the navigation
3. **Upload PDF** - Select your research paper or document
4. **AI Processing** - System automatically extracts metadata, identifies authors/publishers, and generates scripts
5. **Audio Generation** - AI converts content to engaging audio format
6. **Publish** - Your podcast is automatically available for discovery

### **Discovering Content**

- **Search Bar** - Type keywords to find podcasts instantly
- **Browse by Author** - Explore content by specific researchers
- **Browse by Publisher** - Find content from academic institutions
- **Most Popular** - Discover trending and highly-rated content

### **Managing Your Library**

- **My Podcasts** - View and edit your created content
- **Favorites** - Access your bookmarked podcasts
- **Dashboard** - See your stats and recent activity

## 🏗️ Architecture Overview

### **MVC Structure**

```
app/
├── controllers/          # Request handling and business logic
│   ├── podcasts_controller.rb    # Core podcast CRUD operations
│   ├── favorites_controller.rb   # Favoriting system
│   ├── users_controller.rb       # User dashboard and profiles
│   ├── authors_controller.rb     # Author management
│   └── publishers_controller.rb  # Publisher management
├── models/              # Data models and business logic
│   ├── user.rb         # User authentication and relationships
│   ├── podcast.rb      # Core podcast model with search
│   ├── author.rb       # Author model
│   ├── publisher.rb    # Publisher model
│   └── favorite.rb     # User-podcast favoriting join model
├── views/              # Templates and UI components
│   ├── layouts/        # Application layout and navigation
│   ├── podcasts/       # Podcast-related views
│   ├── users/          # User dashboard and profile views
│   └── shared/         # Reusable partials and components
└── javascript/         # Stimulus controllers for interactions
    └── controllers/    # Client-side behavior
```

### **Database Schema**

```sql
users
├── id (primary key)
├── email (unique)
├── encrypted_password
└── devise fields (confirmable, recoverable, etc.)

podcasts
├── id (primary key)
├── title (required, unique)
├── issn (optional)
├── doi (optional, unique)
├── summary (text)
├── script (text)
├── user_id (foreign key)
├── source_file (Active Storage)
├── audio (Active Storage)
└── timestamps

authors
├── id (primary key)
├── name (required, unique)
└── timestamps

publishers
├── id (primary key)
├── name (required, unique)
└── timestamps

favorites (join table)
├── user_id (foreign key)
├── podcast_id (foreign key)
└── unique constraint on [user_id, podcast_id]

# Many-to-many join tables
authors_podcasts
publishers_podcasts
```

### **Key Design Patterns**

- **RESTful Routes** - Standard Rails resource routing
- **Service Objects** - Complex business logic extraction (future)
- **Form Objects** - Complex form handling (future)
- **Decorators** - View-specific model methods
- **Background Jobs** - Asynchronous processing with Sidekiq

## 🧪 Testing

### **Running Tests**

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/podcast_spec.rb
bundle exec rspec spec/controllers/

# Run with coverage
COVERAGE=true bundle exec rspec

# Run system tests (full browser automation)
bundle exec rspec spec/system/
```

### **Test Structure**

```
spec/
├── models/             # Unit tests for models
├── controllers/        # Controller action tests
├── requests/          # HTTP request integration tests
├── system/            # Full browser automation tests
├── factories/         # Test data factories
├── support/           # Test configuration and helpers
└── fixtures/          # Static test data files
```

### **Writing Tests**

```ruby
# Model test example
RSpec.describe Podcast, type: :model do
  let(:podcast) { create(:podcast) }
  
  it 'validates presence of title' do
    expect(podcast).to validate_presence_of(:title)
  end
  
  it 'can be favorited by users' do
    user = create(:user)
    expect { user.favorite!(podcast) }.to change { podcast.favorites_count }.by(1)
  end
end

# Controller test example
RSpec.describe PodcastsController, type: :controller do
  let(:user) { create(:user) }
  before { sign_in user }
  
  describe 'POST #create' do
    it 'creates a new podcast' do
      expect {
        post :create, params: { podcast: attributes_for(:podcast) }
      }.to change(Podcast, :count).by(1)
    end
  end
end
```

## 🔧 Development Workflow

### **Code Quality**

We maintain high code quality standards:

```bash
# Check Ruby and ERB code style and quality
bin/lint-check

# Auto-fix correctable issues
bin/lint --fix

# Run full test suite
bundle exec rspec

# Check test coverage
COVERAGE=true bundle exec rspec
```

### **Linting Commands**

```bash
# Check all files (Ruby + ERB)
bin/lint-check

# Fix Ruby and ERB issues automatically  
bin/lint --fix

# Check only Ruby files
bin/lint-check --ruby-only

# Check only ERB templates
bin/lint-check --erb-only

# ERB-specific linting
bin/lint-erb
```

### **Git Workflow**

```bash
# Feature development
git checkout -b feature/podcast-analytics
git add .
git commit -m "Add podcast analytics dashboard"

# Before pushing - run quality checks
bin/lint-staged
bundle exec rspec

git push origin feature/podcast-analytics
```

### **Database Migrations**

```bash
# Generate migration
bin/rails generate migration AddGenreTopodcasts genre:string

# Review generated migration
vim db/migrate/xxx_add_genre_to_podcasts.rb

# Run migration
bin/rails db:migrate

# Rollback if needed
bin/rails db:rollback
```

## 📦 Deployment

### **Production Setup**

1. **Environment Variables**
```bash
# Required production environment variables
RAILS_ENV=production
SECRET_KEY_BASE=your_production_secret
DATABASE_URL=postgresql://user:pass@host:port/scipod_production
REDIS_URL=redis://your-redis-server:6379/0
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

2. **Asset Compilation**
```bash
# Precompile assets
RAILS_ENV=production bundle exec rails assets:precompile

# Clean old assets
RAILS_ENV=production bundle exec rails assets:clean
```

3. **Database Setup**
```bash
# Run migrations
RAILS_ENV=production bundle exec rails db:migrate

# Seed initial data (optional)
RAILS_ENV=production bundle exec rails db:seed
```

### **Docker Deployment**

```dockerfile
# Dockerfile is included for containerized deployment
docker build -t podcast-ai .
docker run -p 3000:3000 --env-file .env.production podcast-ai
```

### **Heroku Deployment**

```bash
# Create Heroku app
heroku create your-podcast-ai

# Add PostgreSQL and Redis
heroku addons:create heroku-postgresql:mini
heroku addons:create heroku-redis:mini

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate
```

## 🛡️ Security Considerations

- **Authentication** - Secure user authentication with Devise
- **Authorization** - Owner-based access control for podcasts
- **File Upload Security** - Content-type validation and size limits
- **SQL Injection Prevention** - Parameterized queries throughout
- **XSS Protection** - Rails built-in XSS protection enabled
- **CSRF Protection** - Cross-site request forgery protection
- **Secure Headers** - Security headers configured in production

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### **Development Setup**
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes with tests
4. Ensure code quality: `bin/lint-check && bundle exec rspec`
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to your branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### **Code Standards**
- Follow Rails conventions and best practices
- Write comprehensive tests for new features
- Maintain or improve code coverage
- Follow RuboCop style guidelines
- Add RDoc documentation for public methods
- Update README for new features

### **Commit Messages**
```
feat: add podcast analytics dashboard
fix: resolve audio player seeking issue
docs: update API documentation
test: add missing controller specs
refactor: extract search service object
```

## 🐛 Troubleshooting

### **Common Issues**

**Database Connection Error**
```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Restart PostgreSQL
brew services restart postgresql

# Reset database
bin/rails db:drop db:create db:migrate db:seed
```

**Redis Connection Error**
```bash
# Check Redis is running
redis-cli ping

# Start Redis
brew services start redis
```

**Asset Compilation Issues**
```bash
# Clear asset cache
bin/rails assets:clobber

# Reinstall dependencies
rm -rf node_modules && yarn install

# Rebuild assets
yarn build
```

**Test Failures**
```bash
# Reset test database
RAILS_ENV=test bin/rails db:reset

# Clear test cache
bin/rails tmp:clear

# Run specific failing test
bundle exec rspec spec/path/to/failing_spec.rb:line_number
```

### **Performance Optimization**

- Enable query caching: `config.active_record.cache_versioning = true`
- Use database indexes for frequently queried columns
- Implement fragment caching for expensive view rendering
- Use Sidekiq for background processing of large files
- Consider CDN for audio file delivery in production

## 📚 API Documentation

### **RESTful Endpoints**

```
GET    /podcasts              # List all podcasts
POST   /podcasts              # Create new podcast
GET    /podcasts/:id          # Show podcast details
PATCH  /podcasts/:id          # Update podcast
GET    /podcasts/search       # Search podcasts
POST   /podcasts/:id/favorite # Favorite a podcast
DELETE /podcasts/:id/unfavorite # Unfavorite a podcast

GET    /users/:id             # User profile
GET    /users/:id/favorites   # User's favorite podcasts
GET    /users/:id/my_podcasts # User's created podcasts

GET    /authors               # List authors
GET    /authors/:id           # Author details
POST   /authors               # Create author

GET    /publishers            # List publishers  
GET    /publishers/:id        # Publisher details
POST   /publishers            # Create publisher
```

### **Search API**

```bash
# Search podcasts
GET /podcasts/search?q=machine+learning

# Search authors
GET /authors?q=john+doe

# Search publishers
GET /publishers?q=mit+press
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Ruby on Rails** community for the amazing framework
- **Hotwire** team for modern frontend capabilities
- **Devise** maintainers for robust authentication
- **RuboCop** team for code quality tools
- **PostgreSQL** team for the reliable database
- **Sidekiq** creator for excellent background job processing

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/scipod/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/scipod/discussions)
- **Email**: support@podcast-ai.com

---

**Made with ❤️ by the Podcast AI team**

*Transform research into engaging audio content, one podcast at a time.*
