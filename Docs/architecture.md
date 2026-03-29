# MTGSpotlight Architecture

## Recommendation

Use `SwiftUI + MVVM` on the client and treat SDUI as a contract between the Vapor backend and the renderer.

This is the best fit for the current project because:

- MVVM is already familiar
- SwiftUI works naturally with Observation-based view state
- SDUI already introduces enough complexity on its own
- a heavier architecture would make learning slower without solving an immediate problem

## Core Idea

The backend decides **what** the screen contains.

The app decides **how** those known components render in a native SwiftUI experience.

That means the app is not a generic web browser for arbitrary JSON. The app will only render a fixed set of supported components. This keeps the system safe, testable, and understandable.

## Responsibilities

### Vapor Backend

- build screen payloads
- decide component ordering and content
- expose endpoints for screen definitions
- optionally enrich data from Scryfall before sending the final client payload

### iOS App

- fetch a screen payload from the backend
- decode it into typed Swift models
- render supported components
- handle loading, error, and retry states
- route user actions through ViewModels
- support multiple explicit SDUI screen contracts when they provide real value

### Scryfall

- source of card images
- source of canonical card metadata when needed

The iOS app should ideally not depend directly on Scryfall for Phase 1. Prefer letting the Vapor backend own external API integration first. That gives the client a simpler contract and avoids pushing third-party API concerns into the UI layer too early.

## Proposed Client Layers

### Presentation

SwiftUI views and screen renderers.

- render state from ViewModels
- stay dumb where possible
- avoid networking logic

### ViewModel

Screen orchestration and action handling.

- call services
- expose loading and error state
- transform DTOs into render-ready state if needed
- interpret component actions
- use SwiftUI Observation (`@Observable`) instead of legacy Combine-based `ObservableObject` state

### Services

Networking and backend communication.

- fetch screen definitions
- send action events if needed later

### Models

Typed payloads and supporting UI models.

- backend DTOs for SDUI payloads
- local enums and structs for supported components

## Initial Flow

1. `HomeView` appears.
2. `HomeViewModel` requests a spotlight screen from a content service.
3. `RemoteSpotlightContentService` requests `GET /screens/deck-spotlight` from the Vapor backend.
4. JSON is decoded into typed models.
5. `ScreenRenderer` loops through components and renders the matching SwiftUI view for each supported type.
6. User actions are routed back to the ViewModel.

The local JSON service still exists for previews and fixture-based tests, but it is no longer the default app path.

## Deck Detail Flow

`deck-detail` is now the second explicit SDUI screen contract in the app.

Current flow:

1. The spotlight screen renders a button with an `openDeck` action.
2. `HomeViewModel` interprets that action and opens a deck-detail route for the selected `deckId`.
3. `DeckDetailViewModel` requests `GET /screens/deck-detail/{deckId}` from Vapor.
4. The detail response is decoded into the same typed screen model used by the spotlight screen.
5. `DeckDetailView` renders the detail screen with `ScreenRenderer`.

This keeps navigation native while still letting the backend own the detail screen content structure.

## Suggested Folder Structure

This is the recommended starting point for the iOS app:

```text
MTGSpotlight/
  Features/
    Home/
      Views/
        DeckDetailView.swift
        HomeView.swift
      ViewModels/
        DeckDetailViewModel.swift
        HomeViewModel.swift
  SDUI/
    Models/
      ScreenModels.swift
    Rendering/
      ScreenRenderer.swift
    Components/
      HeroCardView.swift
      TextSectionView.swift
      CardCarouselSectionView.swift
      ActionButtonSectionView.swift
      CardPreviewView.swift
      SpotlightStatView.swift
    Services/
      SpotlightContentService.swift
  PreviewData/
    deck-detail-izzet-phoenix.json
    deck-spotlight.json
    deck-spotlight-control.json
    deck-spotlight-midrange.json
```

## Why This Structure

- `Features/` keeps product code grouped by use case
- `SDUI/` isolates the server-driven part so it does not leak everywhere
- `Features/Home/` keeps the current MVVM feature code grouped together
- `PreviewData/` allows local rendering and easier iteration before backend integration is complete
- `SDUI/Services/` keeps content loading away from views and ViewModels

## Current Smells

These are the main issues visible after the first Vapor integration:

- the backend-client contract is still brittle, because small naming mismatches can silently drop components during decoding
- the app logs decoding failures in debug builds, but there is no stronger contract validation or diagnostics surfaced to the user
- the base URL strategy is now safer, but still environment-driven and easy to misconfigure across simulator and device runs
- `HomeViewModel` now uses structured logging, but diagnostics are still fairly minimal
- the app now has two SDUI screen contracts, which increases the cost of contract drift if tests and docs fall behind
- deck-detail currently opens as a sheet; whether that should remain a sheet or become push navigation is still a product decision
- previews and fixture-backed tests still rely on bundled JSON, so resource placement must stay aligned with the host app bundle

These are acceptable for the current learning phase, but they should drive the next cleanup steps.

## Navigation

Do not introduce a coordinator layer yet unless navigation becomes complex.

For Phase 1, keep navigation simple and local to the feature. Add a router only when there is a real need, such as:

- multiple screen types
- shared navigation rules
- deep links
- action-driven navigation from SDUI payloads

## Recommended Development Sequence

1. Build one static SwiftUI deck spotlight screen.
2. Replace static data with a local JSON payload.
3. Add a typed SDUI decoder.
4. Add a renderer for a small set of supported components.
5. Replace local JSON with Vapor-backed JSON.
6. Add action handling and expand components only when needed.

This keeps the learning curve shallow and makes each step easy to inspect.

## Current Status

- Phase 1 foundation is complete
- local SDUI rendering is complete
- the app now loads the spotlight screen from Vapor
- the app now also loads deck-detail screens from Vapor
- `openDeck` no longer uses the temporary native bridge; it now opens a backend-driven detail screen
- the client now uses Swift 6.2 project settings with Observation-based view models
- the next useful work is hardening the two screen contracts and improving diagnostics rather than adding more component types immediately
