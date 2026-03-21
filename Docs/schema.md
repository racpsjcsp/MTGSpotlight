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
      "id": "hero-card",
      "type": "hero",
      "props": {
        "eyebrowTitle": "Magic: The Gathering",
        "deckName": "Izzet Phoenix",
        "tagline": "A spell-heavy deck focused on recursion and pressure.",
        "stats": [
          {
            "id": "colors",
            "title": "Colors",
            "value": "Blue / Red"
          }
        ]
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
            "typeLine": "Creature",
            "manaCost": "3R",
            "note": "Recurring threat.",
            "theme": "phoenix"
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

### `hero`

Use for the top summary block of the spotlight screen.

Example props:

```json
{
  "eyebrowTitle": "Magic: The Gathering",
  "deckName": "Izzet Phoenix",
  "tagline": "Spell-heavy pressure and recursion.",
  "stats": [
    {
      "id": "colors",
      "title": "Colors",
      "value": "Blue / Red"
    }
  ]
}
```

### `text`

Use for section titles and body copy.

Example props:

```json
{
  "title": "Why this deck matters",
  "body": "A spell-heavy strategy built around efficient recursion."
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
      "typeLine": "Instant",
      "manaCost": "R",
      "note": "Efficient interaction.",
      "theme": "axe"
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

- unknown component types should be skipped safely
- malformed props should not crash the app
- unsupported or malformed components should be skipped with logging in debug builds

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
enum SpotlightComponent: Decodable {
    case hero(HeroSectionProps)
    case text(TextSectionProps)
    case cardCarousel(CardCarouselProps)
    case button(ButtonSectionProps, SpotlightAction?)
}
```

This gives clearer rendering logic and much better testability than `[String: Any]` style parsing.
