# MTGSpotlight Architecture

## Recommendation

Use `SwiftUI + MVVM` on the client and treat SDUI as a contract between the Vapor backend and the renderer.

This is the best fit for the current project because:

- MVVM is already familiar
- SwiftUI works naturally with observable view state
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

### Services

Networking and backend communication.

- fetch screen definitions
- send action events if needed later

### Models

Typed payloads and supporting UI models.

- backend DTOs for SDUI payloads
- local enums and structs for supported components

## Initial Flow

1. `DeckSpotlightView` appears.
2. `DeckSpotlightViewModel` requests a screen from the backend.
3. `ScreenService` calls the Vapor endpoint.
4. JSON is decoded into typed models.
5. `ScreenRenderer` loops through components and renders the matching SwiftUI view for each supported type.
6. User actions are routed back to the ViewModel.

## Suggested Folder Structure

This is the recommended starting point for the iOS app:

```text
MTGSpotlight/
  App/
    MTGSpotlightApp.swift
  Features/
    DeckSpotlight/
      Views/
        DeckSpotlightView.swift
      ViewModels/
        DeckSpotlightViewModel.swift
      Models/
        DeckSpotlightScreen.swift
  SDUI/
    Models/
      ScreenDTO.swift
      ComponentDTO.swift
      ActionDTO.swift
    Rendering/
      ScreenRenderer.swift
      ComponentRenderer.swift
    Components/
      TextBlockView.swift
      HeroImageView.swift
      CardCarouselView.swift
      CTAButtonView.swift
  Services/
    API/
      APIClient.swift
      ScreenService.swift
  Shared/
    UI/
    Utilities/
  PreviewData/
    deck-spotlight-screen.json
```

## Why This Structure

- `Features/` keeps product code grouped by use case
- `SDUI/` isolates the server-driven part so it does not leak everywhere
- `Services/` keeps networking away from views
- `PreviewData/` allows local rendering and easier iteration before backend integration is complete

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
