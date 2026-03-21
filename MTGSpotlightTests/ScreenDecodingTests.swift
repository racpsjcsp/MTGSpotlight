//
//  ScreenDecodingTests.swift
//  MTGSpotlightTests
//
//  Created by Rafael Plinio on 21/03/26.
//

import Foundation
import Testing
@testable import MTGSpotlight

@MainActor
struct ScreenDecodingTests {

    @Test func decodesValidScreenPayload() throws {
        let screen = try JSONDecoder().decode(SpotlightScreen.self, from: Self.validScreenJSON())

        #expect(screen.screenID == "deck-spotlight")
        #expect(screen.version == 1)
        #expect(screen.title == "Deck Spotlight")
        #expect(screen.components.count == 4)

        guard case let .hero(_, props) = screen.components[0] else {
            Issue.record("Expected first component to be hero")
            return
        }

        #expect(props.deckName == "Izzet Phoenix")
        #expect(props.stats.count == 3)
    }

    @Test func decodesButtonActionPayload() throws {
        let screen = try JSONDecoder().decode(SpotlightScreen.self, from: Self.validScreenJSON())

        guard case let .button(id, props, action) = screen.components[3] else {
            Issue.record("Expected fourth component to be button")
            return
        }

        #expect(id == "view-deck-button")
        #expect(props.title == "View Deck Details")
        #expect(action?.type == "openDeck")
        #expect(action?.payload["deckId"] == "izzet-phoenix")
    }

    @Test func skipsUnknownComponentTypeAndKeepsScreenDecodable() throws {
        let screen = try JSONDecoder().decode(SpotlightScreen.self, from: Self.unknownComponentJSON())

        #expect(screen.screenID == "deck-spotlight")
        #expect(screen.components.isEmpty)
    }

    @Test func skipsComponentWhenTypeIsMissing() throws {
        let screen = try JSONDecoder().decode(SpotlightScreen.self, from: Self.missingTypeJSON())

        #expect(screen.screenID == "deck-spotlight")
        #expect(screen.components.isEmpty)
    }

    @Test func skipsComponentWhenPropsAreMalformed() throws {
        let screen = try JSONDecoder().decode(SpotlightScreen.self, from: Self.malformedPropsJSON())

        #expect(screen.screenID == "deck-spotlight")
        #expect(screen.components.isEmpty)
    }

    private static func validScreenJSON() -> Data {
        Data(
        """
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
                "tagline": "Spell velocity, graveyard recursion, and fast pressure.",
                "stats": [
                  { "id": "colors", "title": "Colors", "value": "Blue / Red" },
                  { "id": "format", "title": "Format", "value": "Pioneer" },
                  { "id": "style", "title": "Style", "value": "Tempo" }
                ]
              }
            },
            {
              "id": "deck-summary",
              "type": "text",
              "props": {
                "title": "Why this deck matters",
                "body": "A spell-heavy strategy."
              }
            },
            {
              "id": "featured-cards",
              "type": "cardCarousel",
              "props": {
                "title": "Featured cards",
                "cards": [
                  {
                    "id": "arclight-phoenix",
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
        """.utf8
        )
    }

    private static func unknownComponentJSON() -> Data {
        Data(
        """
        {
          "screenId": "deck-spotlight",
          "version": 1,
          "title": "Deck Spotlight",
          "components": [
            {
              "id": "unknown-component",
              "type": "video",
              "props": {
                "title": "Unsupported"
              }
            }
          ]
        }
        """.utf8
        )
    }

    private static func missingTypeJSON() -> Data {
        Data(
        """
        {
          "screenId": "deck-spotlight",
          "version": 1,
          "title": "Deck Spotlight",
          "components": [
            {
              "id": "broken-component",
              "props": {
                "title": "Missing type"
              }
            }
          ]
        }
        """.utf8
        )
    }

    private static func malformedPropsJSON() -> Data {
        Data(
        """
        {
          "screenId": "deck-spotlight",
          "version": 1,
          "title": "Deck Spotlight",
          "components": [
            {
              "id": "broken-button",
              "type": "button",
              "props": {
                "label": "Wrong key"
              }
            }
          ]
        }
        """.utf8
        )
    }
}
