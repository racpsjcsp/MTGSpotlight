# SDUI Schema

## Goal

The schema should be small, explicit, and versioned by convention from the start.

For Phase 1, support only a few component types. Do not design for every future possibility yet.

## Recommended Payload Shape

```json
{
  "screenId": "deck-spotlight",
  "version": 1,
  "title": "Deck Spotlight",
  "components": [
    {
      "id": "hero-title",
      "type": "text",
      "props": {
        "text": "Izzet Phoenix",
        "style": "title"
      }
    },
    {
      "id": "hero-description",
      "type": "text",
      "props": {
        "text": "A spell-heavy deck focused on recursion and pressure.",
        "style": "body"
      }
    },
    {
      "id": "featured-cards",
      "type": "cardCarousel",
      "props": {
        "title": "Featured Cards",
        "cards": [
          {
            "id": "arc-light-phoenix",
            "name": "Arclight Phoenix",
            "imageUrl": "https://cards.scryfall.io/large/front/...",
            "subtitle": "Creature"
          }
        ]
      }
    },
    {
      "id": "view-deck-button",
      "type": "button",
      "props": {
        "title": "View Deck Details"
      },
      "action": {
        "type": "openDeck",
        "payload": {
          "deckId": "izzet-phoenix"
        }
      }
    }
  ]
}
```

## Top-Level Fields

- `screenId`: identifies the screen contract
- `version`: allows schema evolution
- `title`: optional navigation or analytics label
- `components`: ordered list of renderable UI components

## Supported Component Types For Phase 1

### `text`

Use for titles, subtitles, and descriptions.

Example props:

```json
{
  "text": "Deck Spotlight",
  "style": "title"
}
```

### `image`

Use for a single hero image if needed.

Example props:

```json
{
  "url": "https://...",
  "aspectRatio": "16:9",
  "contentMode": "fill"
}
```

### `cardCarousel`

Use for a horizontally scrollable card list.

Example props:

```json
{
  "title": "Featured Cards",
  "cards": [
    {
      "id": "lightning-bolt",
      "name": "Lightning Bolt",
      "imageUrl": "https://...",
      "subtitle": "Instant"
    }
  ]
}
```

### `button`

Use for a simple CTA.

Example props:

```json
{
  "title": "Open Deck"
}
```

## Action Shape

Actions should also stay small in Phase 1.

```json
{
  "type": "openDeck",
  "payload": {
    "deckId": "izzet-phoenix"
  }
}
```

Recommended first action types:

- `openDeck`
- `openURL`
- `refresh`

## Client Rendering Rules

- unknown component types should fail safely
- malformed props should not crash the app
- unsupported components should render a fallback or be skipped with logging in debug builds

## Schema Evolution Rules

- keep `version`
- prefer additive changes when possible
- avoid changing meanings of existing fields silently
- document every contract change in `Docs/decisions.md`

## Swift Modeling Guidance

Prefer typed decoding over loose dictionaries.

Recommended approach:

- decode a screen DTO
- decode each component using a `type` discriminator
- map each component into a strongly typed enum

Conceptually:

```swift
enum ScreenComponent: Decodable {
    case text(TextProps)
    case image(ImageProps)
    case cardCarousel(CardCarouselProps)
    case button(ButtonProps, ActionDTO?)
}
```

This gives clearer rendering logic and much better testability than `[String: Any]` style parsing.
