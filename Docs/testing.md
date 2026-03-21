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
- reject a payload missing `type`
- ignore or safely fail an unknown component type
- ViewModel publishes loading then loaded state
- ViewModel publishes error state on service failure

Backend:

- `GET /screens/deck-spotlight` returns HTTP 200
- response includes `screenId`, `version`, and `components`
- `cardCarousel` payload includes cards with image URLs

## Test Data Guidance

- keep a canonical sample payload in the repo
- reuse it across previewing and tests where practical
- add one intentionally broken payload for negative tests

## Rule Of Thumb

If a change can break the app without changing SwiftUI layout code, it probably deserves a test in this project.
