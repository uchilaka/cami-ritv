# CAMI: Setup notes

## Rails Version 8 (04/12/2025)

> **R**eact **I**nertiaJS **T**ailwindCSS **V**ite

This iteration of the project was initialized from a [forked template](https://github.com/uchilaka/inertia-rails-template).

## Rails Version 7.2

> **R**eact **T**ailwindCSS **V**ite

Here are the scratch notes when exploring the `rails new` command:

```shell
# Install a required image library dependency via brew
brew install vips

# Setup rails 7
gem install rails --version 7.2

# Setup railsmdb
gem install railsmdb --pre

# Dry-run project setup (with MongoDB)
railsmdb new cami --no-rc --skip-webpack-install --skip-javascript \
 --skip-test --skip-system-test \
 --template ~/Developer/rails-vite-tailwindcss-template/template.rb \
 --react --pretend
 
# Dry-run project setup (with PostgreSQL: supports ActiveStorage, 
#   ActionMailbox & other ActiveRecord dependent features)
#   We've included ActiveStorage for ActionText (WYSIWYG editing).
#   Skipping ActionMailbox until we're ready for email automation.
rails new cami --no-rc --skip-webpack-install --skip-javascript \
 --database postgresql --skip-test --skip-system-test \
 --active-storage --skip-action-mailbox \
 --template ~/Developer/rails-vite-tailwindcss-template/template.rb \
 --react --pretend
 
# Active storage overview: https://guides.rubyonrails.org/active_storage_overview.html
# Action mailbox overview: https://guides.rubyonrails.org/action_mailbox_basics.html
```

## Other guides

- [Modeling](./MODELING.md)
- [Scaffolding](./SCAFFOLDING.md)
