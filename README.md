# CAMI (**R**eact **I**nertiaJS **T**ailwindCSS **V**ite)

## System Requirements

- Ruby: `3.4.4`
- Mise: [mise.dev](https://mise.jdx.dev/getting-started.html)
- Brew (only for macOS/Linux users): <https://brew.sh/>
- Yarn v4+: [yarnpkg.com](https://yarnpkg.com/)

## Homework

- [ ] [Session storage caveat(s) with devise-jwt](https://github.com/waiting-for-dev/devise-jwt?tab=readme-ov-file#session-storage-caveat)
- [ ] [Tailwind dark mode guide](https://v3.tailwindcss.com/docs/dark-mode)
- [ ] [Flowbite dark mode guide](https://flowbite.com/docs/customize/dark-mode/)

## ENV variables

Environment variables for the application are utilized as follows:

- `.env.<environment>` is transparently encrypted for the relevant environments if commited to source control. You will need to set the local path for the Gitcrypt key file to `GITCRYPT_KEY_FILE` and run `yarn keys:unlock` to decrypt all transparently encrypted files maintained in the source code.
- Rails credentials (encrypted) stored in the `config/credentials/{environment}.yml.enc` files. You will need to set the `RAILS_MASTER_KEY` for these to be decrypted successfully in non-development environments.
- Direct environment variables (e.g. `RAILS_ENV`)

## Setting up the app

> Ensure you've met all the system requirements before proceeding!

### 1. Setup OS dependencies

> Skip this step unless you're in one of these environments: `development`, `lab` or `test`

Make sure `export RAILS_ENV=<environment>` is set for your environment in your `~/.zshrc` file or wherever your ENV setup goes.

```shell
# Be sure to turn on the tap(s) first!
brew tap protonpass/tap

# Now you can install OS dependencies
brew bundle --file="Brewfile.$RAILS_ENV"
```

### 2. Install project dependencies

> Ensure you've followed the setup instructions for your OS to install and activate mise: <https://mise.jdx.dev/getting-started.html>

```shell
# Use pre-compiled mise dependencies (optional)
mise settings ruby.compile=false

# Ensure dependencies required by postgresql are installed for your OS (if running on metal)
open https://github.com/mise-plugins/mise-postgres

# Install mise-managed dependencies
mise install

# Ensure you have the right version of bundler available
gem install bundler:2.6.7

# Check to ensure direnv is installed
which direnv

# Trust the .envrc file (you only need to do this once for the project on your system - until the file is changed)
direnv allow

# Make sure libpq is in your path
export PATH="/usr/local/opt/libpq/bin:$PATH"

# Install gem dependencies
bundle install

# Install frontend dependencies
yarn install
```

### 3. Set up `git-crypt`

Setup `git-crypt.key` for the project at `./config/credentials/`. This file must be available in your local environment. You can find this file in the Proton Pass vault (search: "git-crypt").

Alternatively, you can follow [the new GPG user setup guide](./docs/NEW_GPG_USER.md) to set up your profile in the repository's git-crypt.

Once you have the file setup, run `yarn keys:unlock` to decrypt the repository's encrypted files.

### 4. Set `RAILS_MASTER_KEY` for your environment

> Avoid using the encrypted credentials other than in the environments explicitly listed in the table below. In other environments, implement/use `ENV` variables to set secrets instead.

You can get the environment master keys from the Proton Pass vault (search for "Environment variables (<environment>)"). **The master key for `staging` and `lab` environments are identical**.

Alternatively, you can follow the Rails convention for maintaining credentials in the open - if doing so, the credentials will be encrypted in a `./config/credentials/<environment>.yml.enc` file and the master key can be set in a corresponding credentials file. Reference the following table for the corresponding master key value for your environment.

| Environment        | Master key file name                      |
| ------------------ | ----------------------------------------- |
| `development`      | `./config/credentials/development.key`    |
| ------------------ | ----------------------------------------- |
| `lab`              | `./config/credentials/lab.key`            |
| ------------------ | ----------------------------------------- |
| `test`             | `./config/credentials/test.key`           |

### 5. Run the CLI setup command

> To ensure you haven't already completed this step, run `which lx-cli` to see if the LarCity CLI is already installed on your system.

```shell
# Setup the lx-cli command
bin/thor lx-cli:setup

# View the command catalog
lx-cli -T
```

### 6. Provision managed secrets

```shell
lx-cli env-setup
```

### 6. Set up the database

> Only complete this step if you are running the app database via the mise PostgreSQL service.

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

# Contributing

Please refer to the [CONTRIBUTING.md](./docs/CONTRIBUTING.md) file for contribution guidelines.

## Known issues

- [ ] SSL certificate verification fails on macOS (OpenSSL 3.6 + Ruby 3.4) due to CRL check <https://github.com/rails/rails/issues/55886>

## Future work

- [ ] Review legacy notes on performance testing Rails apps: <https://guides.rubyonrails.org/v3.1.1/performance_testing.html>
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
- [ ] Explore [repository custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions) for CoPilot
