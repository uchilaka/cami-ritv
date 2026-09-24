# CAMI: Environments

How this project decides *which environment it is in*, and why a test run can no longer
quietly end up talking to development data or development credentials.

- [The two kinds of variable](#the-two-kinds-of-variable)
- [The rules](#the-rules)
- [File layout](#file-layout)
- [Running the test suite](#running-the-test-suite)
- [How the rules are enforced](#how-the-rules-are-enforced)
- [Troubleshooting](#troubleshooting)

## The two kinds of variable

Environment variables here do one of two jobs, and conflating them is what caused every
cross-environment bug this project has hit:

| | | |
| --- | --- | --- |
| **Selector** | names the environment | `RUBY_ENV`, `RAILS_ENV`, `NODE_ENV` |
| **Payload** | *is* the environment | `RAILS_MASTER_KEY`, `APP_DATABASE_NAME_*`, hosts, ports, URLs |

Cross-targeting is a **payload** problem. Changing a selector after the fact — the classic
`RAILS_ENV=test bundle exec …` from a development shell — swaps one variable and leaves the
rest development-shaped. That is how a test boot ends up holding the development master key.

## The rules

### R1 — One selector, and it comes from outside the repo

`RUBY_ENV` names the environment. No **tracked** file sets it, because a file cannot
define the variable that selects it. It comes from your shell, the deploy platform, or
`.env.local` — which is untracked and loads in phase 1, *before* the selector is used, and
is therefore the one legitimate place for a machine to declare which environment it is.

`.env` is explicitly not that place: it is committed and shared, so a default there would
make every machine claim the same environment. `.envrc` validates `RUBY_ENV` before using
it to build any path.

### R2 — `.env` and `.env.local` hold nothing environment-shaped

Anything that varies per environment — database names, master keys, hosts, ports, URLs —
lives *only* in `.env.<RUBY_ENV>`. `.env` holds what is identical everywhere; `.env.local`
holds machine-local overrides. A cross-environment default in either is exactly how the
wrong environment comes to look right.

Selectors specifically: `.env` may declare **none** of `RAILS_ENV`, `RUBY_ENV`,
`NODE_ENV`. `.env.local` may declare `RUBY_ENV` only (see R1); `RAILS_ENV` and `NODE_ENV`
are declared by `.env.<env>`, per R3.

### R3 — Each `.env.<env>` declares `RAILS_ENV`, and it agrees with the filename

`.env.lab` declares `RAILS_ENV=lab`. Declared rather than derived from `RUBY_ENV` in
`.envrc`, so a single environment can diverge later without rewriting the loader.

### R4 — Every environment has a tracked definition, including test

`.env.test` is tracked and **deliberately unencrypted** (see `.gitattributes`): it holds no
secrets, only the names that make a test run a test run. Under git-crypt, `Dotenv.parse`
returns `{}` on a locked file *without complaining* — the silent-wrong-environment failure
this whole document exists to prevent. Secrets stay in `.env.test.local`, never tracked.

### R5 — Switching environments is an act, not a command prefix

Do not reach for `RAILS_ENV=test <cmd>` from a development shell: that swaps one variable
and leaves the master key and database connection pointing at development. Enter the
environment, or use an entry point that clears what the current one exported and lets the
target chain repopulate it.

`config/environments/test.rb` already loads `.env.test.local`, `.env.test`, `.env`. It
simply cannot correct an inherited value, because Dotenv never overwrites a variable that
is still set — so the variables have to be gone before it runs.

A dedicated entry point for this lands separately; until then, clear the offenders by
hand (see [Running the test suite](#running-the-test-suite)).

### R6 — The runtime corrections stay, as assertions

`config/environments/test.rb` forcing `*_test` database names and dropping an inherited
`RAILS_MASTER_KEY`, `spec/rails_helper.rb` aborting on a non-`_test` database, and
`config/database.yml`'s `_test` defaults all remain. Under R5 they should never fire. They
are kept so that when someone bypasses R5, it is loud rather than silent.

## File layout

| File | Tracked | Encrypted | Holds |
| --- | --- | --- | --- |
| `.env` | yes | no | values identical in every environment |
| `.env.local` | no | — | machine-local overrides |
| `.env.<env>` | yes | yes (git-crypt) | that environment's payload + `RAILS_ENV`/`NODE_ENV` |
| `.env.test` | yes | **no** | test selectors and database names — no secrets |
| `.env.<env>.local` | no | — | secrets and machine-specific values (master keys, DB host/port) |
| `.env*.example` | yes | no | commented templates for the untracked files above |

Load order is set by `.envrc`, in two phases. The environment-specific paths interpolate
`RUBY_ENV`, so they cannot be built until it is known:

1. `.env`, then `.env.local`
2. **validate `RUBY_ENV`** — a missing value is reported as itself, not as an absent file
3. `.env.${RUBY_ENV}`, then `.env.${RUBY_ENV}.local`

Building all four paths up front expands `${RUBY_ENV}` while still empty, silently turning
`.env.${RUBY_ENV}` into `.env.` and skipping it.

## Setting up a fresh clone

The tracked files arrive with the repo. The untracked ones you create from the committed
templates, which are deliberately unencrypted so a clone with no git-crypt key can still
read them:

```shell
cp .env.local.example             .env.local
cp .env.development.local.example .env.development.local
cp .env.test.local.example        .env.test.local
```

`compose.override.yml` is gitignored for the same reason and has the same kind of template.
It is not an `.env` file, but a clone without it runs a different stack than everyone else:

```shell
cp compose.override.yml.example compose.override.yml
```

Then fill in the blanks. Two things are worth knowing first:

- **Leave `RAILS_MASTER_KEY` blank** in both `.local` files if the matching
  `config/credentials/<env>.key` exists. Rails reads the key file when the variable is
  empty, and an exported key takes precedence over *every* environment key file — which is
  how a development key ends up breaking a test boot.
- **`.envrc` will refuse to load** until `RUBY_ENV`, `CONTAINER_REGISTRY_HOST` and
  `CONTAINER_NAME_PREFIX` are set. The first belongs in `.env.local` (R1); the other two
  are in `.env.local.example`.
- **A blank is not a default for Compose.** `${VAR:?...}` rejects an empty value exactly as
  it rejects an unset one, so the blanks you leave in `.env.development.local` —
  `APP_DATABASE_USER`, `APP_DATABASE_PASSWORD` — and in `.env.local` —
  `APP_CONFIG_JWT_SECRET_KEY` — abort every `docker compose` command until they are filled.
  The full list of hard-required names is in [DOCKER_COMPOSE.md](./DOCKER_COMPOSE.md#environment-variables-compose-hard-requires).

Credentials keys (`config/credentials/*.key`) are gitignored and appear in no template.
Fetch them from the vault — see `bin/thor lx-cli:secrets:help`.

## Running the test suite

From a development shell, the inherited environment must be cleared. The variables that
matter are the ones `.env.test.local` and `.env.test` own:

```shell
env -u RAILS_MASTER_KEY RAILS_ENV=test bundle exec rspec
```

`RAILS_MASTER_KEY` is the one that hard-stops the boot, because
`ActiveSupport::EncryptedFile#key` prefers it over `config/credentials/test.key`.
`config/environments/test.rb` now drops an inherited value whenever a test key file exists
to fall back to — so in practice the plain command works too — but CI has no key file and
supplies the key through that variable, which is why the correction is conditional.

For RubyMine, see [RUBYMINE.md](./RUBYMINE.md); the committed run template at
`.ide-configs/Template RSpec.run.xml` presets `RAILS_ENV=test`.

## How the rules are enforced

`spec/environment_isolation_spec.rb` covers the config-level regressions that no unit test
can reach. Every assertion in it has been mutation-tested — put the bug back and the suite
goes red:

| Rule | Guarded by |
| --- | --- |
| R1, R3 | each `.env.<env>` declares a matching `RAILS_ENV` and no `RUBY_ENV` |
| R2 | `.env` / `.env.local` declare no selector at all |
| R1 (ordering) | `.envrc` validates `RUBY_ENV` before interpolating it, and refuses to load without it |
| R2 (payload) | `.env.local` declares no `APP_DATABASE_*` — the role differs per environment, so the connection belongs in `.env.<env>.local` |
| R6 | `config/database.yml` test defaults end in `_test`; the RubyMine template presets `RAILS_ENV=test` and pins no checkout-specific module |

The dotenv convention checks **skip when git-crypt is locked**, so they guard you locally
but not in CI. `.env.test` is the exception and is checked everywhere.

## Troubleshooting

**`ActiveSupport::MessageEncryptor::InvalidMessage` on boot.** A development
`RAILS_MASTER_KEY` is in your environment and Rails is trying to decrypt `test.yml.enc`
with it. Confirm with `env | grep RAILS_MASTER_KEY`; clear it, or set it empty.

**`Could not find command "…"` from `bundle exec thor`.** The Thorfile calls
`require config/environment`, so any boot failure leaves Thor with zero commands loaded and
it reports the command as missing instead of the real error. See the actual exception with:

```shell
RAILS_ENV=test bundle exec ruby -e "require File.expand_path('config/environment', Dir.pwd)"
```

**`Refusing to run the test suite: resolved primary database is '…'`.**
`APP_DATABASE_NAME_PRIMARY` was inherited from your shell. This guard is doing its job —
see R5.

**direnv reports `RUBY_ENV is not set`.** Nothing in the repo sets it, by R1. Export it from
your shell or set it in `.env.local`.
