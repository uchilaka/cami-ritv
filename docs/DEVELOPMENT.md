# CAMI: Development guide

- [CAMI: Development guide](#cami-development-guide)
  - [First Time Setup / Getting Started](#first-time-setup--getting-started)
  - [Install the CLI](#install-the-cli)
  - [Working with Render deployments](#working-with-render-deployments)
  - [Managing application secrets](#managing-application-secrets)
    - [Managing `git-crypt` secrets](#managing-git-crypt-secrets)
    - [Working with git worktrees](#working-with-git-worktrees)
    - [Using the `secrets` CLI command](#using-the-secrets-cli-command)
    - [Using the Rails credentials command](#using-the-rails-credentials-command)
    - [Configuring basic auth for `mission_control`](#configuring-basic-auth-for-mission_control)
  - [Testing emails](#testing-emails)
  - [Using NGROK](#using-ngrok)
    - [Update your NGROK token for your app environment](#update-your-ngrok-token-for-your-app-environment)
      - [Instructions for Windows](#instructions-for-windows)
      - [Instructions on macOS](#instructions-on-macos)
  - [Print key file](#print-key-file)
  - [Handling fixture files](#handling-fixture-files)
    - [Sanitizing an existing fixture file](#sanitizing-an-existing-fixture-file)
    - [Converting a JSON fixture file to a YAML fixture file](#converting-a-json-fixture-file-to-a-yaml-fixture-file)

Notes on working with the application in a (local) dev environment.

## First Time Setup / Getting Started

When running the application for the first time, there are a few steps you'll need to complete to properly set up your local environment:

### 1. Discovering Application Commands

You can always find the available CLI commands for the application by running:

```shell
bin/thor -T
```

### 2. Initialize Feature Flags

Initialize the application's feature flags with their default states:

```shell
bin/thor features:init
```

### 3. Run Data Migrations

The application uses data migrations to load essential data (like vendors) into the database. Run the following command to apply these migrations:

```shell
bin/rails data:migrate
```

### 4. Setup Application Webhooks

Set up the required webhooks for the app. Be sure to replace `<vendor>` with the appropriate service provider (we recommend starting with `--vendor notion`):

```shell
bin/thor devkit:setup_webhooks -s notion
```

### 4. Setup Your Admin User

To access the admin application menu, you will need to create or designate a local user as an admin.

1. Complete a standard registration/login flow in the application to create your user account.
2. Open the Rails console (`bin/rails c`) and run the following commands to grant your user the `admin` role:

```ruby
# Find your local user
me = User.find_by_email '<email-address>'

# Make the user an admin
me.add_role :admin
```

Once you have an admin local user, you'll be able to see the admin application menu in the UI.

### 5. Testing with NGROK

For testing features that require a public URL (like webhooks or SSO), you can run the app through an NGROK proxy using:

```shell
bin/thor tunnel:open_all
```

## Install the CLI

Run the following code from the project root:

```shell
bin/thor entrypoint:setup
```

## Setting up your IDE

Review the following setup notes for your respective IDE:
- [RubyMine](./RUBYMINE.md)

## Working with Render deployments 

### Validating blueprints

> See the documentation on validating blurprints: <https://render.com/docs/blueprint-spec#validating-blueprints>

```shell
# Ensure that you've installed render via brew 
brew bundle

# To validate your blueprint, run the following command in your console from the project root:
bin/thor devkit:check-blueprint
```

## Managing application secrets

This application encrypts some sensitive information transparently using a combination of [Rails custom credentials](https://guides.rubyonrails.org/security.html#custom-credentials), `git-crypt` and `GPG`.

### Managing `git-crypt` secrets

The following commands are useful for managing the application secrets. You can also review [this guide](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account) for information on how to setup a GPG key with your GitHub account.

```shell
# To initialize/roll the git-crypt key for your repository, run the following command in your console:
git-crypt keygen config/credentials/git-crypt.key

# To list GPG keys on your system, run the following command in your console:
gpg --list-secret-keys --keyid-format LONG

# To unlock the git-crypt repository with the shared symmetric key, run the following command in your console:
yarn keys:unlock # runs: git-crypt unlock $GITCRYPT_KEY_FILE

# To unlock it with your own GPG key instead (once someone has run add-gpg-user for you), run:
git-crypt unlock

# To lock the git-crypt repository, run the following command in your console:
git-crypt lock

# To list git-crypt encrypted files in your repository, run the following command in your console:
git-crypt status -e

# To add a new GPG user to git-crypt for your repository, run the following command in your console:
git-crypt add-gpg-user USERID

```

### Working with git worktrees

Use `bin/worktree-init` to create a worktree. **A plain `git worktree add` will fail on this repository.**

```shell
# bin/worktree-init <name> [branch] [base-ref]
bin/worktree-init llm-wiki spike/llm-wiki

# Branch defaults to <name>; base-ref defaults to origin's default branch
bin/worktree-init LAR-412 LAR-412/add-widget origin/main
```

Worktrees are created at `../cami-ritv-worktrees/<name>`, as a sibling of the main checkout.

**Why the wrapper is needed.** `git-crypt` stores its symmetric key at `$GIT_DIR/git-crypt/keys/default`. A worktree gets its own `$GIT_DIR` (`.git/worktrees/<name>`) and does *not* inherit that key. Since `.gitattributes` marks the encrypted paths `filter=git-crypt` and `filter.git-crypt.required` is `true`, the checkout hard-fails on the first encrypted file and git rolls the entire worktree back:

```text
git-crypt: Error: Unable to open key file - have you unlocked/initialized this repository yet?
fatal: .env.development: smudge filter git-crypt failed
```

`yarn keys:unlock` cannot repair this after the fact — `git-crypt unlock` refuses to run unless the working tree is already clean, and a worktree created with `--no-checkout` reads as "every file deleted". So `bin/worktree-init` orders the steps the only way that works: register with `--no-checkout`, install the key into the new gitdir (`0600`, in a `0700` directory), then check out. It finishes by confirming a `.env.*` file no longer carries git-crypt's `\0GITCRYPT\0` header, so a silent ciphertext passthrough fails loudly here rather than confusingly at runtime.

The script is idempotent — re-run it on a half-created worktree and it installs whatever is missing.

**Repairing an existing worktree.** Re-run it with the worktree's name and it will adopt that worktree's real path, even if it does not sit at `../cami-ritv-worktrees/<name>` (some older worktrees are nested inside other worktrees). If the working tree holds ciphertext — the state a worktree lands in when it was checked out while the key was missing — it re-smudges just the git-crypt'd paths, which `git checkout` alone will not do, since those files already exist. It refuses if any encrypted path has **staged** changes, rather than discarding them. Unstaged modifications on those paths are expected and are the symptom being fixed: the clean filter re-encrypts ciphertext differently, so every affected file reads as modified.

```shell
bin/worktree-init pr-245-phase2 pr-245-phase2/docker-consistency
```

**Where your key lives.** `GITCRYPT_KEY_FILE` defaults to `config/credentials/git-crypt.key`, resolved against the *main checkout*. If you work in worktrees regularly, point it at a machine-local path outside every checkout instead:

```shell
# ~/.zshrc
export GITCRYPT_KEY_FILE="$HOME/.config/git-crypt/cami-ritv.key" # chmod 600
```

One canonical key would then serve the main checkout and every worktree, it could not be committed or removed by `git clean -xfd`, and `yarn keys:unlock` would start working inside worktrees too.

> ⚠️ **This does not currently take effect** ([LAR-357](https://linear.app/larcity-and-affiliates/issue/LAR-357)). `.env:1` sets `export GITCRYPT_KEY_FILE="config/credentials/git-crypt.key"`, and `.envrc` sources the `.env` files with `set -a` *after* applying its own default — so the tracked value clobbers any shell export. To adopt a machine-local key, that line has to come out of `.env` first, which is a team decision since `.env` is tracked and shared. `.envrc` itself now handles absolute and `~/`-prefixed paths correctly, so it is ready for that change.

### ⚠️ `PROJECT_ROOT` is wrong inside worktrees ([LAR-358](https://linear.app/larcity-and-affiliates/issue/LAR-358))

`.envrc:17` derives it correctly — `git rev-parse --show-toplevel` resolves worktrees, and the comment there says so. But the `.env` files load afterwards and overwrite it:

| File | Sets `PROJECT_ROOT` to |
|---|---|
| `.env.development:31` | `${HOME}/repos/@larcity/cami` — a layout that may not exist on your machine |
| `.env.development.local:46` | a hardcoded absolute path to the **main checkout** |

So in a worktree, anything derived from `PROJECT_ROOT` — compose file paths, key lookups — silently resolves against the main checkout instead. You can see it in `direnv`'s output as `Compose file not found: <main-checkout>/compose.yml` while standing in a worktree.

Two consequences worth knowing:

- Copying `.env.development.local` from the main checkout into a new worktree, as bootstrapping requires, **carries that hardcoded path with it**. Override `PROJECT_ROOT` in the worktree's own `.env.development.local` if anything you run depends on it.
- The fix at `.envrc:17` is effectively dead while the `.env` files set this. Making it authoritative means removing `PROJECT_ROOT` from those files, or re-deriving it after they load.

> Each worktree still ends up with its own copy of the key in its gitdir — that is git-crypt's design, not a choice this script makes. Removing a worktree removes its copy along with the gitdir.

### Finishing a new worktree

`bin/worktree-init` deliberately stops at a decrypted checkout. A worktree shares git history but nothing else, so finish it in this order:

```shell
cd ../cami-ritv-worktrees/<name>

# 1. Trust the toolchain config AT THIS PATH. mise trusts by path, so every new
#    worktree is untrusted — and an untrusted mise.toml breaks PATH badly enough
#    that coreutils (sort, basename, head) stop resolving.
mise trust

# 2. Allow direnv AT THIS PATH, for the same reason. .envrc runs under `set -e`,
#    so if it aborts partway you get a half-built environment rather than an
#    error, which is harder to spot.
direnv allow

# 3. Dependencies — shared history, but not shared installs
bundle install
yarn install
```

Then copy the gitignored files that are not in git and so cannot be checked out: `.env.*.local`, `.env.tpl`, and the Rails credential keys you actually need from `config/credentials/*.key`.

> Copy only the credential keys the worktree needs — `development.key` and `test.key` for ordinary work. There is no reason for `production.key` or `staging.key` to exist in a feature worktree.

Verify the worktree with:

```shell
bundle exec thor -T # loads the full Rails environment and lists Thor tasks
```

If that fails with `InvalidMessage` or `MissingKeys`, a credential key is missing. If it fails with `Gem::LoadError: You have already activated <gem> X, but your Gemfile requires Y`, worktrees on the same Ruby share one gemset and a stray build is shadowing the locked one — uninstall the stray version, keeping the one `bundle show <gem>` reports.

### Using the `secrets` CLI command

```shell
# To edit credentials in your IDE, run the following command in your console:
bin/thor secrets:edit
```

### Using the Rails credentials command

To edit the credentials file for your development environment using the rails credentials scripts
and your command line, run the following code in your console:

```shell
# To view help information about managing application credentials, run the following command in your console:
bin/rails credentials:help

# To view the credentials file for your development environment, run the following command in your console:
VISUAL=nano bin/rails credentials:edit --environment ${RAILS_ENV:-development}
```

### Configuring basic auth for `mission_control`

> Mission Control is a dashboard for Solid Queue jobs.

```shell
RAILS_ENV=development bin/rails mission_control:jobs:authentication:configure
```

## Testing emails

> To enable email testing, set `SEND_EMAILS_ENABLED=yes` in your `.env.local` file.

To test emails in development, you can use the `Mailhog` service. If you are using the RubyMine configurations you will already have a dockerized `Mailhog` server running in debug mode. Otherwise, to start the service, run the following command in your console:

```shell
docker compose up -d mailhog
```

Your test inbox will be available at `http://localhost:8025`.

## Using NGROK

> Be sure to follow [these instructions](https://ngrok.com/docs/getting-started/) to setup `ngrok` for your local environment.

Run `bin/tunnel` to start up your development tunnel. You'll need this when testing features like SSO that require a public URL.

### Update your NGROK token for your app environment

You can obtain your auth token from here: <https://dashboard.ngrok.com/get-started/your-authtoken>.

Once you've obtained your token, ensure you set the value in your `.env.local` file with the `NGROK_AUTH_TOKEN` variable.

#### Instructions for Windows

This guide will walk you through completing the following steps:

- Setting up your auth token
- Installing the `nrgok` CLI ([Chocolatey package manager](https://chocolatey.org/install) required)
- Update your PowerShell session execution policy (to allow running scripts)
- Starting your tunnel

First, to set your token for Windows environment, run the following command from a powershell terminal:

```ps1
# See https://ngrok.com/docs/getting-started/#step-2-connect-your-account
ngrok config add-authtoken ${NGROK_AUTH_TOKEN}
```

Next, you want to make sure you've installed the `ngrok` command. The [NGROK getting started guide](https://ngrok.com/docs/getting-started/) will have updates steps but if you use the [Chocolatey package manager](https://chocolatey.org/install), you can run the following command:

```ps1
choco install ngrok
```

Next, run the following command to setup the required execution policy to run `ps1` scripts:

```ps1
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
```

Next, ensure your powershell profile is setup. This is required for execution policies.

> This powershell script is still in development

```ps1
# Edit your powershell profile config in VSCode
code \\wsl$\Ubuntu-22.04\home\localadmin\repos\@larcity\cami\bin\init-profile.ps1
# Initialize your powershell profile config
powershell.exe -File \\wsl$\Ubuntu-22.04\home\localadmin\repos\@larcity\cami\bin\init-profile.ps1
```

If the script doesn't work, review the contents of the `./cami/bin/init-profile.ps1` file and create the file manually.

Now you should be able to launch your tunnel script from your Windows PowerShell terminal:

```ps1
powershell.exe -File \\wsl$\Ubuntu-22.04\home\localadmin\repos\@larcity\cami\bin\tunnel.ps1
```

#### Instructions on macOS

Follow these steps to setup `ngrok` for your local environment:

- Ensure you have updated your `.envrc` file with the `NGROK_AUTH_TOKEN`. You can get this from KeePass
- Run the following script to export the token to your local `ngrok.yml` config file:

  ```shell
  ngrok config add-authtoken ${NGROK_AUTH_TOKEN}
  ```

- Finally, generate your `config/ngrok.yml` file by running the following command:

  ```shell
  bin/thor tunnel:init
  ```

Now you can open a tunnel to your local environment by running:

```shell
bin/thor tunnel:open_all
```

## Print key file

```shell
bin/thor help secrets:print_key
```

## Handling fixture files

A few helpful commands for handling fixture files.

### Sanitizing an existing fixture file

```shell
# Show help menu for the sanitize command
bin/thor help datakit:sanitize

# Sanitize the fixture file (outputs to the same directory as the fixture)
bin/thor datakit:sanitize --file ./path/to/fixture.yml
```

### Converting a JSON fixture file to a YAML fixture file

You can review [this guide](https://stackoverflow.com/a/67610900) for more tips
on using the `yq` command to transform (fixture) files.

```shell
# Convert the JSON fixture file to a YAML fixture file
yq -p json -o yaml ./path/to/fixture.json > ./path/to/fixture.yml
```
