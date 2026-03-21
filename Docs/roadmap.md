# Roadmap

## Phase 1: Foundation

- define project vision and architecture
- define the first SDUI schema
- build one static deck spotlight screen in SwiftUI
- create preview JSON for local rendering

Exit criteria:

- one screen exists in native SwiftUI
- the screen is simple enough to compare against a future SDUI version

## Phase 2: Local SDUI Rendering

- create decodable screen models
- load screen JSON from a local file
- render `text`, `cardCarousel`, and `button`
- add loading and error states in the ViewModel

Exit criteria:

- the app renders one full screen from local JSON
- unsupported data does not crash the app

## Phase 3: Vapor Integration

- create a Vapor endpoint that serves the screen payload
- move data source ownership to the backend
- optionally have Vapor fetch card information from Scryfall

Exit criteria:

- the app loads the spotlight screen from the backend
- the contract between backend and app is documented and stable

## Phase 4: Actions And Navigation

- handle button actions from the SDUI payload
- add a minimal routing strategy if needed
- support at least one navigation-related action

Exit criteria:

- action payloads trigger predictable app behavior

## Phase 5: Hardening

- add stronger contract tests
- add more error handling
- improve logging and diagnostics
- expand component set only where there is a real use case

Exit criteria:

- the app is resilient to bad payloads
- the contract is protected by tests on both client and backend

## Guardrails

- do not add components without a concrete screen use case
- do not make the schema generic too early
- do not let third-party API concerns spread through the UI layer
- keep each phase shippable and understandable on its own
