# CAMI

> **R**eact **I**nertiaJS **T**ailwindCSS **V**ite

## ENV variables

Environment variables for the application are utilized as follows:

- `.env.{environment}.local` files (transparently encrypted for development environments)
- Rails credentials (encrypted) stored in the `config/credentials/{environment}.yml.enc` files
- Direct environment variables (e.g. `RAILS_ENV`)

## Setting up the app

### 1. Get the `config/credentials/git-crypt.key` file

This file must be available in your local environment. You can acquire this file from a team member or from the secrets vault (KeepassXC/Bitwarden).

### 2. Unlock the encrypted files

Run `yarn keys:unlock` to unlock the encrypted files.

## Running the app

## Future work

- [ ] Implement dark mode switcher: <https://flowbite.com/docs/customize/dark-mode/#dark-mode-switcher>
- [ ] Implement a Simple Form config (with Flowbite): <https://github.com/heartcombo/simple_form?tab=readme-ov-file#installation>
- [ ] Evaluate if using the `cssbundling-rails` gem is needed for asset fingerprinting support in stylesheets: <https://github.com/rails/cssbundling-rails?tab=readme-ov-file#how-does-this-compare-to-tailwindcss-rails-and-dartsass-rails>
- [ ] Migrate Dart SASS 3.0 breaking changes
  - [ ] `@import` and global built-in functions: <https://sass-lang.com/documentation/breaking-changes/import/>
  - [ ] `unquote` and other global built-in functions are deprecated and will be removed in Dart Sass 3.0.0.
    Use `string.unquote` instead.
- [ ] Review propshaft as an asset pipeline (alt to currently configured `sprocket-rails`) - [recommended by the 37Signals team](https://github.com/rails/mission_control-jobs?tab=readme-ov-file#api-only-apps-or-apps-using-vite_rails-and-other-asset-pipelines-outside-rails) as compatible with mission control for `vite_rails`/API-only apps: <https://github.com/rails/propshaft>
- [ ] Troubleshooting Ruby LSP (server keeps failing in VSCode/Windsurf): <https://shopify.github.io/ruby-lsp/troubleshooting.html>
