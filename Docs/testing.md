# Testing Strategy

## Short Answer

Testing is relevant in SDUI. The focus is just different.

The biggest risk is not "does this exact pixel look right." The biggest risk is "does the backend payload still match what the app expects."

## Main Testing Priorities

### 1. Decoding Tests

These should be the first tests added.

Verify that:

- valid payloads decode correctly
- missing required fields fail predictably
- unknown component types are handled safely
- malformed nested props do not crash the app
- both `deck-spotlight` and `deck-detail` payloads stay aligned with the shared screen contract

Why this matters:

- SDUI depends on structured payloads
- contract drift is one of the main failure modes

### 2. ViewModel Tests

Test screen loading behavior and state transitions.

Verify that:

- loading starts and ends correctly
- successful fetches publish renderable state
- failures publish usable error state
- retry behavior works
- actions are interpreted correctly
- Observation-based state updates remain deterministic under Swift 6 actor isolation

### 3. Renderer Tests

Test the mapping between decoded component models and the renderer path.

These do not need to become heavy visual tests immediately. The goal is to prove that:

- `text` components use the text renderer
- `cardCarousel` components use the carousel renderer
- unsupported components follow the fallback rule

### 4. Backend Contract Tests

On the Vapor side, test that the endpoint returns payloads that match the agreed schema.

Verify that:

- required fields are present
- supported component types are emitted correctly
- action payloads follow the expected shape
- field names match the documented contract exactly
- component-level required keys like `id`, `type`, and `props` are always present

## Lower Priority At The Start

### Snapshot Tests

Useful later, not essential on day one.

Add them after the component library stabilizes. Otherwise they become noise while the UI is still changing rapidly.

### Full UI Automation

Keep a small number of UI tests for smoke coverage.

Good early candidates:

- app launches
- spotlight screen loads
- retry path works after a mocked failure

Do not try to cover every server-driven permutation with UI automation.

## Suggested Test Pyramid For This Project

- many decoding tests
- many ViewModel tests
- some backend endpoint tests
- a few renderer or snapshot tests
- very few end-to-end UI tests

## Practical First Test List

Client:

- decode a valid deck spotlight payload
- decode a valid deck detail payload
- reject a payload missing `type`
- ignore or safely fail an unknown component type
- ViewModel publishes loading then loaded state
- ViewModel publishes error state on service failure
- remote content service hits `/screens/deck-spotlight`
- remote content service hits `/screens/deck-detail/:deckId`
- remote content service fails predictably on non-2xx responses
- deck detail ViewModel publishes loading, loaded, and error states
- deck detail `refresh` actions reload the current backend-driven screen
- URL loading stubs do not leak state across concurrently scheduled tests

Backend:

- `GET /screens/deck-spotlight` returns HTTP 200
- `GET /screens/deck-detail/:deckId` returns HTTP 200 for known decks
- response includes `screenId`, `version`, and `components`
- every component includes `id`, `type`, and `props`
- `button` action is emitted at the component level, not inside `props`

## Test Data Guidance

- keep a canonical sample payload in the repo
- reuse it across previewing and tests where practical
- add one intentionally broken payload for negative tests

## Rule Of Thumb

If a change can break the app without changing SwiftUI layout code, it probably deserves a test in this project.

## Current Gap

The current project is already feeling the cost of weak contract enforcement:

- the client can skip malformed components safely
- but that same resilience can hide backend regressions unless tests catch them quickly

That means backend contract tests and shared sample payload validation should now move up in priority.

That is even more important now that the project has two SDUI screen contracts instead of one.

Current status:

- client-side decoding coverage now exists for both `deck-spotlight` and `deck-detail`
- remote service tests now cover both spotlight and deck-detail endpoints
- deck detail loading behavior is covered at the ViewModel level
- bundled payload tests now load resources from the host app bundle, which matches how preview JSON is packaged today
- remote service tests isolate URL protocol stub state per test case to avoid cross-test contamination
