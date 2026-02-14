# Rails 8 + Vite/React Application

## Overview
A Rails 8 application with Vite-powered React frontend (Inertia.js), PostgreSQL database, and Devise authentication. Originally configured for Docker/local development with git-crypt encrypted credentials.

## Current State
- Running in Replit development environment
- Rails serves on port 5000, Vite dev server runs as a background process
- Database: PostgreSQL (Replit built-in)
- All migrations applied successfully

## Architecture
- **Backend**: Rails 8.0.2, Ruby 3.2.2
- **Frontend**: Vite 6.x, React, Inertia.js, TypeScript
- **CSS**: DartSass + Tailwind CSS (asset pipeline)
- **Auth**: Devise with JWT + OmniAuth (Google)
- **Database**: PostgreSQL with Solid Queue
- **Package Managers**: Bundler (Ruby), Yarn (JS)

## Key Replit Adaptations
Since git-crypt encrypted credentials are not accessible in Replit, all credential access points have been wrapped with `rescue` blocks that fall back to environment variables or safe defaults. Modified files:
- `config/database.yml` - Uses ENV vars only, no credentials fallback
- `config/initializers/dotenv.rb` - Credentials access wrapped in rescue
- `config/initializers/devise.rb` - ENV fallbacks for mailer sender and JWT secret
- `config/initializers/omniauth.rb` - Credentials access wrapped in rescue
- `config/initializers/brevo.rb` - Credentials access wrapped in rescue
- `config/environments/development.rb` - SMTP settings use ENV with rescue fallbacks
- `lib/virtual_office_manager.rb` - All credentials access wrapped in rescue
- `config/initializers/web_console.rb` - Uses VirtualOfficeManager (now safe)

## Environment Variables
Set in development environment:
- `APP_DATABASE_HOST`, `APP_DATABASE_PORT`, `APP_DATABASE_USER`, `APP_DATABASE_PASSWORD` - DB connection
- `DEVISE_JWT_SECRET_KEY` - JWT token secret
- Standard Rails vars via `.env.development`: PORT, RAILS_ENV, PAYPAL_*, ZOHO_*, etc.

## Workflow
- **Start application**: Runs `npx vite dev` (background) + `bundle exec rails s -b 0.0.0.0 -p 5000`

## Recent Changes (2026-02-13)
- Initial Replit setup and import
- Configured all credential fallbacks for running without git-crypt
- Database created and all migrations applied
- Vite config updated with `allowedHosts: true` for Replit proxy
- Host authorization cleared in development for Replit compatibility
