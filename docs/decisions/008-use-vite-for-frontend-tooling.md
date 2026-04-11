# 008. Use Vite for Frontend Tooling

## Status
Accepted

## Context
Rails provides tools like Sprockets, Webpacker (deprecated), and importmaps. However, for a heavy React/Inertia.js frontend, we need a fast, modern build tool that supports Hot Module Replacement (HMR), TypeScript, and fast builds.

## Decision
Use Vite (via the `vite_rails` gem) to manage frontend assets, build processes, and local development.

### Implementation Details
1. **Configuration**: Managed via `vite.config.ts` and `config/vite.json`.
2. **Integration**: `vite_rails` helpers are used in application layouts to inject scripts and styles.
3. **Development**: Run `bin/vite dev` or `bin/dev` (Procfile) to start the Vite development server with HMR.
4. **Production**: Vite compiles and minifies assets into the `public/vite` directory during the build step.

## Consequences

### Positive
- **Speed**: Extremely fast cold server start and instant HMR during development.
- **Ecosystem**: Direct access to the massive Vite plugin ecosystem (React, Tailwind, etc.).
- **TypeScript**: Out-of-the-box support for TypeScript compilation.

### Negative
- Replaces standard Rails asset pipeline defaults, requiring a slight paradigm shift.
- Node.js dependency is required for the build process (though standard for React).

## Related Decisions
- [006. Use Inertia.js with React for Frontend](./006-use-inertia-react-for-frontend.md)

## Notes
- Added: 2026-03-21