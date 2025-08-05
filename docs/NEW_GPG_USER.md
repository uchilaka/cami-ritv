# CAMI: Set up a new GPG User

> Ensure you have the GPG library installed: `brew info gnupg`

## 1. Check for your GPG key

```shell
gpg --list-secret-keys --keyid-format=long
```

## 2. Generate a GPG key (optional)

If you have not generated a GPG key, you can generate one following [this guide](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key).

## 3. Export your GPG public key

Once you've identified the GPG key for your user, you can export a public key for that user to send to someone with repo permissions (and `config/credentials/git-crypt.key` available on their machine) to add your GPG user to the repository. 

```shell
# Output your GPG key in armor format (your machine)
gpg --armor --export GPG_USER_ID
```

## 4. Import the GPG public key for your new user

As the collaborator with project access as well as the `credentials/git-crypt.key` file available, run the following command after downloading the new user's `.asc` public key file (in armor format).

```shell
# Import a GPG key (their machine)
gpg --import ~/Downloads/path-to-new-user.asc
```

Note the user ID in the terminal output from successfully importing the GPG public key - you'll need it in the next step to add this user to the project.

## 5. Add the GPG user to `git-crypt`

```shell
git crypt add-gpg-user --trusted GPG_USER_ID
```

