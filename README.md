# CAMI

> **R**eact **I**nertiaJS **T**ailwindCSS **V**ite

## ENV variables

## Future work 

- [ ] Implement dark mode switcher: https://flowbite.com/docs/customize/dark-mode/#dark-mode-switcher
- [ ] Implement a Simple Form config (with Flowbite): https://github.com/heartcombo/simple_form?tab=readme-ov-file#installation
- [ ] Evaluate if using the `cssbundling-rails` gem is needed for asset fingerprinting support in stylesheets: https://github.com/rails/cssbundling-rails?tab=readme-ov-file#how-does-this-compare-to-tailwindcss-rails-and-dartsass-rails
- [ ] Migrate Dart SASS 3.0 breaking changes
  - [ ] `@import` and global built-in functions: https://sass-lang.com/documentation/breaking-changes/import/
  - [ ] `unquote` and other global built-in functions are deprecated and will be removed in Dart Sass 3.0.0.
    Use `string.unquote` instead.