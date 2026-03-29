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

### Decision: Make Vapor The Default App Content Source

Reason:

- the project reached the point where the real learning value comes from the backend-client loop
- keeping local JSON as the default path would hide contract issues for too long
- local payloads are still useful for previews and targeted tests

Consequence:

- `HomeViewModel` now loads from a remote content service by default
- local JSON remains in the project as preview and fixture support, not as the primary runtime path
- environment configuration now matters for simulator and device runs

### Decision: Keep The Schema Strict Even When Integration Is Painful

Reason:

- temporary mismatches already showed how easy it is for the backend and app to drift
- weakly typed compromises like changing version numbers to `Double` reduce contract clarity
- schema friction is useful feedback while the contract is still small

Consequence:

- keep `version` as `Int`
- prefer fixing backend payloads to match the documented contract instead of making the client more permissive by default
- document future contract changes explicitly before adjusting both sides

### Decision: Fail Clearly On Device When The API Base URL Is Missing

Reason:

- `127.0.0.1` is a good simulator default but a bad physical-device default
- silent localhost failures on device make backend integration harder to debug than it needs to be
- environment configuration errors should surface as configuration issues, not vague networking failures

Consequence:

- simulator runs can still default to `http://127.0.0.1:8080`
- device runs now require explicit API base URL configuration
- logging moved from temporary `print` statements to structured logging in the ViewModel

### Decision: Add `deck-detail` As A Second Explicit SDUI Contract

Reason:

- deck content in MTG changes often enough that backend-owned detail presentation is valuable
- the project had already proven the basic SDUI loop on the spotlight screen
- keeping deck detail native would duplicate content decisions that now belong on the backend

Consequence:

- the app now supports two named screen contracts: `deck-spotlight` and `deck-detail`
- `openDeck` triggers a second backend fetch rather than building a detail screen locally
- navigation stays native, but content structure for both screens is backend-driven
- tests and docs must now treat `deck-detail` as a first-class contract

### Decision: Decode Actions Into A Typed Enum On The Client

Reason:

- raw action strings made the contract easier to drift and harder to reason about
- the app only supports a small allowlist of actions, so the model should reflect that explicitly
- typed actions make tests and ViewModel handling more precise

Consequence:

- the client now decodes actions into explicit cases like `openDeck`, `openURL`, and `refresh`
- unsupported action types are still tolerated, but they are surfaced as an unsupported enum case rather than staying as raw strings
- action handling logic now relies more on the compiler and less on string comparisons

## 2026-03-29

### Decision: Move The Client To Swift 6.2 And Observation

Reason:

- the project already targets iOS 26.2 and uses Main Actor default isolation
- `ObservableObject` and `@StateObject` were leaving the app on a legacy state-management path
- the review pass surfaced fragile manual bindings that go away with modern Observation

Consequence:

- `HomeViewModel` and `DeckDetailViewModel` now use `@Observable`
- the views own their models with `@State` and bind through `@Bindable`
- the project now builds with Swift 6.2 settings, which also makes actor-isolation issues surface earlier

### Decision: Keep Test Fixtures Aligned With Actual Bundling Behavior

Reason:

- bundled payload tests were loading resources from the test bundle even though the JSON files are packaged in the host app bundle
- the wrong bundle hid a mismatch between the tests and the app's real runtime resource layout

Consequence:

- bundled payload tests now load preview JSON from `Bundle.main`
- deck-detail fixture coverage now exercises `fetchDeckDetail(deckID:)` directly rather than reusing the spotlight path

### Decision: Isolate URLProtocol Stub State Per Test Case

Reason:

- Swift Testing can schedule tests in ways that exposed response leakage between remote service tests
- a single global stub handler caused one test to consume another test's mocked payload

Consequence:

- remote service tests now register stub handlers per test case
- request capture is keyed per test, so expectations no longer depend on global mutable state
- the suite remains deterministic even as Swift 6 concurrency and test scheduling become stricter
