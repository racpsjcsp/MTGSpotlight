# SDUI Schema

## Goal

The schema should be small, explicit, and versioned by convention from the start.

For the current phase, support only a few component types across a small number of named screen contracts. Do not design for every future possibility yet.

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

This base shape is shared by both:

- `deck-spotlight`
- `deck-detail`

Current backend routes:

- `GET /screens/deck-spotlight`
- `GET /screens/deck-detail/{deckId}`

## Top-Level Fields

- `screenId`: identifies the screen contract
- `version`: allows schema evolution
- `title`: optional navigation or analytics label
- `components`: ordered list of renderable UI components

Current supported `screenId` values:

- `deck-spotlight`
- `deck-detail`

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

The same supported component set is currently reused by both screen contracts.

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
- supported components are expected to include their required keys exactly as documented
- a component missing `id`, `type`, or valid `props` should be considered a backend contract bug
- `screenId` determines which backend endpoint produced the screen, but rendering still depends on the shared component contract

## Schema Evolution Rules

- keep `version`
- prefer additive changes when possible
- avoid changing meanings of existing fields silently
- document every contract change in `Docs/decisions.md`
- treat type changes for existing fields as breaking changes

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

## Integration Note

The current client is intentionally strict about the contract:

- `version` is an `Int`
- every component requires `id` and `type`
- `button` actions are decoded from the component level, not from `props`
- `deck-spotlight` and `deck-detail` both decode into the same typed screen model
- actions are interpreted through a typed client enum rather than raw string switching in the ViewModel

This strictness is deliberate. It makes integration failures visible early while the schema is still small enough to control.
