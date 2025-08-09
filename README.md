# CAMI (**R**eact **I**nertiaJS **T**ailwindCSS **V**ite)

## System Requirements

- Ruby: 3.4
- Mise: [mise.dev](https://mise.jdx.dev/)
- Brew (only for macOS/Linux users): <https://brew.sh/>
- Yarn v4+: [yarnpkg.com](https://yarnpkg.com/)

## Homework

- [ ] [Session storage caveat(s) with devise-jwt](https://github.com/waiting-for-dev/devise-jwt?tab=readme-ov-file#session-storage-caveat)
- [ ] [Tailwind dark mode guide](https://v3.tailwindcss.com/docs/dark-mode)
- [ ] [Flowbite dark mode guide](https://flowbite.com/docs/customize/dark-mode/)

## ENV variables

Environment variables for the application are utilized as follows:

- `.env.development` is transparently encrypted for development environments
- Rails credentials (encrypted) stored in the `config/credentials/{environment}.yml.enc` files
- Direct environment variables (e.g. `RAILS_ENV`)

## Setting up the app

### 1. Set up the `config/credentials/git-crypt.key` file

This file must be available in your local environment. You can acquire this file from a team member or from the secrets vault (KeepassXC/Bitwarden).

Alternatively, you can follow [the new GPG user setup guide](./docs/NEW_GPG_USER.md) to set up your git-crypt for the repository.

### 2. Unlock the encrypted files

Run `git crypt unlock` to unlock the encrypted files.

### 3. Install dependencies

```shell
# Install brew system dependencies
brew bundle

# Ensure dependencies required by postgresql are installed for your OS (if running on metal)
open https://github.com/mise-plugins/mise-postgres

# Install NPM dependencies
yarn install

# Install mise system dependencies
mise install
```

### 4. Setup direnv

> Review the direnv setup guide: <https://direnv.net/#basic-installation>

Ensure you have `direnv` configured in your shell. This will automatically load the environment variables from `.envrc` when you enter the project directory.

Direnv should be installed as a dependency when you run `mise install`. You may need to install the `direnv` plugin for mise.

### 5. Set up the database

> Only complete this step if you are running the app database via the mise service.

```shell
.mise/services/postgresql/bin/initialize
```

## Running the app

### 1. Start the database service

#### Running the database on metal (via mise)

```shell
.mise/services/postgresql/bin/start
```

#### Running the database in Docker

When running the database in Docker, you will need to ensure you have the right application configurations in place. You can use the `.env.development.local` file to override the following `ENV` variables (the `.env.development` file contains the defaults and in included in the repository - you will need GPG access via `git-crypt` to decrypt it):

- `APP_DATABASE_HOST` (default: `localhost`)
- `APP_DATABASE_USER`
- `APP_DATABASE_PASSWORD`
- `APP_DATABASE_PORT`

```shell
docker compose up -d app-store && docker compose logs -f app-store --since 5m
```

## Future work

- [ ] Google Workspace IAM Identity Provider for AWS: <https://docs.aws.amazon.com/singlesignon/latest/userguide/gs-gwp.html>
- [ ] Implement dark mode switcher: <https://flowbite.com/docs/customize/dark-mode/#dark-mode-switcher>
- [ ] Implement a Simple Form config (with Flowbite): <https://github.com/heartcombo/simple_form?tab=readme-ov-file#installation>
- [ ] Evaluate if using the `cssbundling-rails` gem is needed for asset fingerprinting support in stylesheets: <https://github.com/rails/cssbundling-rails?tab=readme-ov-file#how-does-this-compare-to-tailwindcss-rails-and-dartsass-rails>
- [ ] Migrate Dart SASS 3.0 breaking changes
  - [ ] `@import` and global built-in functions: <https://sass-lang.com/documentation/breaking-changes/import/>
  - [ ] `unquote` and other global built-in functions are deprecated and will be removed in Dart Sass 3.0.0.
    Use `string.unquote` instead.
- [ ] Review propshaft as an asset pipeline (alt to currently configured `sprocket-rails`) - [recommended by the 37Signals team](https://github.com/rails/mission_control-jobs?tab=readme-ov-file#api-only-apps-or-apps-using-vite_rails-and-other-asset-pipelines-outside-rails) as compatible with mission control for `vite_rails`/API-only apps: <https://github.com/rails/propshaft>
- [ ] Troubleshooting Ruby LSP (server keeps failing in VSCode/Windsurf): <https://shopify.github.io/ruby-lsp/troubleshooting.html>
