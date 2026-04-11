# 006. Use Inertia.js with React for Frontend

## Status
Accepted

## Context
We need a seamless way to build a modern, single-page application (SPA) experience while maintaining the productivity and routing capabilities of a classic Ruby on Rails monolith. Building a separate API and SPA introduces complexity in state management, routing duplication, and CORS configuration.

## Decision
Use Inertia.js with React 19+ as our frontend framework.

### Implementation Details
1. **Routing**: Handled strictly by Rails router (`config/routes.rb`). No client-side routing (e.g., React Router) is necessary.
2. **Controllers**: Rails controllers return Inertia responses instead of HTML or JSON.
   ```ruby
   def index
     render inertia: 'Dashboard/Index', props: {
       user: current_user.as_json
     }
   end
   ```
3. **Frontend Components**: React components map directly to Rails controller actions.
4. **Styling**: Tailwind CSS and Flowbite are integrated directly into the React components.

## Consequences

### Positive
- **Productivity**: Eliminates the need to build and maintain a separate REST/GraphQL API purely for the frontend.
- **Simplicity**: No complex client-side state management (like Redux) needed for data fetching.
- **Monolith Benefits**: Keeps the frontend and backend in a single repository with shared deployment.

### Negative
- Tightly couples the React frontend to the Rails backend.
- Learning curve for developers used to traditional separated SPA architectures.

## Related Decisions
- [008. Use Vite for Frontend Tooling](./008-use-vite-for-frontend-tooling.md)

## Notes
- Added: 2026-03-21