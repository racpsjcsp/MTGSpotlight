# Decisions Log

## 2026-03-19

### Decision: Start with SwiftUI + MVVM

Reason:

- familiar architecture
- good fit for SwiftUI
- easier to learn SDUI without extra architectural overhead

Consequence:

- keep Views focused on rendering
- keep ViewModels responsible for loading and actions
- postpone more complex patterns unless the app proves they are needed

### Decision: Keep SDUI Scope Small

Reason:

- the project is also a learning exercise
- a small component catalog is easier to reason about and test

Consequence:

- Phase 1 supports only a few components
- new components should be added only when a screen requires them

### Decision: Prefer Vapor As The Owner Of Third-Party Integration

Reason:

- the app should depend on a stable internal contract
- Scryfall-specific concerns are better isolated on the backend

Consequence:

- prefer the client talking to Vapor, not directly to Scryfall, in the initial architecture
- backend can reshape third-party data into the app schema

### Decision: Prioritize Contract Tests Over Heavy UI Tests

Reason:

- the most likely failures are schema and state issues
- visual details will change often early in the project

Consequence:

- start with decoding and ViewModel tests
- keep UI automation and snapshots limited until the component set settles

## 2026-03-21

### Decision: Skip Unsupported Or Malformed Components

Reason:

- one bad component should not blank the entire screen
- this keeps SDUI demos and future backend integration more resilient
- debug logging is enough for early diagnosis during development

Consequence:

- `SpotlightScreen` decodes the screen shell even when one component fails
- unsupported or malformed components are dropped from the render list
- decoding tests must verify skip behavior instead of whole-screen failure
