# Plan: Project Update and Dependency Refresh

This plan covers steps to bring the project up to date with the latest dependencies, configuration changes, and merged PRs.

## 1. Merge Dependabot Pull Requests
Review and merge the outstanding Dependabot PRs.
- **Ruby Gems:** `nokogiri`, `rspec-rails`, `rubocop`, `faraday`, `database_cleaner-active_record`, `phonelib`, `rack-cors`, `selenium-webdriver`, `shoulda-matchers`, `tailwindcss-rails`.
- **NPM Packages:** `eslint`, `vite`, `axios`, `flowbite-react`, `tailwindcss`, `headlessui/react`, `vitejs/plugin-react`.
- **GitHub Actions:** `actions/checkout`, `actions/setup-node`, `actions/cache`.

## 2. Consolidate Dependency Refresh
- Review the existing branch `LAR-306/general-dependency-refresh` or `maint/update-gems`.
- Rebase `main` and execute a clean `bundle update` and `yarn upgrade` to ensure `Gemfile.lock` and `yarn.lock` are fully synced with the latest acceptable versions.

## 3. Verify Toolchain Versions
- Check `.tool-versions` or `mise.toml` to ensure the project uses the latest stable Ruby (e.g. Ruby 3.4.4) and Node versions matching production/Render capabilities.
- Run `bin/thor entrypoint:setup` to ensure the local CLI toolchain is refreshed.

## 4. Run the Linter and Test Suite
- **Ruby:** Run `bundle exec rubocop -a` to apply safe auto-corrections from updated rules.
- **JavaScript:** Run `yarn lint --fix` for the updated ESLint rules.
- **Tests:** Execute `bundle exec rspec` and `yarn test` to ensure no breaking changes from the dependency upgrades.

## 5. Validate Build & Infrastructure
- Re-run `bin/thor devkit:check-blueprint` to validate `render.yaml`.
- Verify the local Docker containers build successfully (`docker compose build`).
- Verify asset compilation succeeds (`bin/rails assets:precompile` / `yarn build`).
