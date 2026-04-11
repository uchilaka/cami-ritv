---
name: fixup-worktree
description: Synchronizes a newly created git worktree with the main project repository. Use when the user types "/fixup-worktree", "fixup worktree", or asks to sync/configure a new worktree.
---

# Fixup Worktree

This skill automates the synchronization of a newly created git worktree with the main project environment. Because new git worktrees do not inherit uncommitted or ignored configuration files (like `.env` files or decrypted credentials), this skill copies those files from the main worktree and runs necessary setup commands.

## Workflow

When invoked, perform the following steps sequentially to ensure the current worktree is fully configured:

1.  **Identify Main Worktree:**
    Run `git worktree list` to find the path to the main repository (typically the one tagged `[main]`).

2.  **Copy Environment Variables:**
    Copy any missing `.env` files and the `.envrc` file from the main worktree to the current worktree.
    Example: `cp -vn /path/to/main/.env* . 2>/dev/null || true`

3.  **Allow Direnv (If present):**
    If `.envrc` was copied, run `direnv allow .` to authorize it.

4.  **Copy Credentials & Keys:**
    Copy all files in `config/credentials/` (including `.key` and `.yml.enc` files) from the main worktree to the current worktree's `config/credentials/` directory.
    Example: `cp -vn /path/to/main/config/credentials/* config/credentials/ 2>/dev/null || true`

5.  **Unlock Git-Crypt (If applicable):**
    If the project uses `git-crypt` (e.g., you see `.gitattributes` indicating git-crypt or commands like `yarn keys:unlock` in `package.json`), unlock the repository.
    *   Find the key in the main worktree's git directory: `ls -la /path/to/main/.git/git-crypt/keys`
    *   Unlock using the appropriate key file. If a script like `yarn keys:unlock` exists, you may need to export `GITCRYPT_KEY_FILE=/path/to/main/.git/git-crypt/keys/default` before running it.

6.  **Dependency Management:**
    *   If a `yarn.lock` or `package.json` exists, run `yarn install --silent`.
    *   If `mise.toml` or `.tool-versions` is present, run `mise trust` to authorize the tool versions for the new directory.

7.  **Smoke Test:**
    Run a project-specific smoke test to ensure everything is configured. For example, if `bin/thor` is present, run `bin/thor -T`. If `bin/rails` is present, run `bin/rails about`.

## Troubleshooting

-   **Missing Keys:** If `git-crypt` fails to unlock, ensure you are referencing the key from the *main* `.git` directory, not the `.git` file in the current worktree.
-   **Thor/Rails Errors:** If the smoke test fails, check if the `.env` files contain invalid characters (sometimes caused by missing line endings when concatenating files) or if ruby dependencies are missing (try `bundle install`).
