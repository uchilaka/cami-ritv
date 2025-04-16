# CAMI: InertiaJS Guide

This is a minimal installation of [Ruby on Rails](https://github.com/rails/rails), [Vite](https://github.com/vitejs/vite), and [InertiaJS](https://github.com/inertiajs/inertia-rails). (It also uses the [Tailwind Play CDN](https://github.com/tailwindlabs/tailwindcss) for some simple styling).

This iteration of the project was initialized from a [forked template](https://github.com/uchilaka/inertia-rails-template). If you'd like to take a look around to see how everything is working, I'd recommend checking out the following files:

- `app/frontend/pages/Dashboard.tsx`: The React component being rendered by the `/` route
- `app/controllers/dashboard_controller.rb`: The controller that handled rendering the root page
- `app/frontend/components/Layout.tsx`: The React component providing the "magic" layout similar to Rails's application layout
- `app/frontend/entrypoints/application.tsx`: The Vite entrypoint that handles initializing InertiaJS

## Running the app

To run locally:

```shell
bundle install
npm install
foreman -f Procfile.dev
```

## Resources

- [InertiaJS Rails Guide](https://inertia-rails.dev/guide/)
