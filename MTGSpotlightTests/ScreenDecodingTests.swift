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
        #expect(action == .openDeck(deckID: "izzet-phoenix"))
    }

    @Test func decodesValidDeckDetailPayload() throws {
        let screen = try JSONDecoder().decode(SpotlightScreen.self, from: Self.validDeckDetailJSON())

        #expect(screen.screenID == "deck-detail")
        #expect(screen.version == 1)
        #expect(screen.title == "Izzet Phoenix")
        #expect(screen.components.count == 4)

        guard case let .hero(_, props) = screen.components[0] else {
            Issue.record("Expected first deck detail component to be hero")
            return
        }

        #expect(props.eyebrowTitle == "Deck Detail")
        #expect(props.deckName == "Izzet Phoenix")
        #expect(props.stats.count == 3)
    }

    @Test func decodesDeckDetailRefreshActionPayload() throws {
        let screen = try JSONDecoder().decode(SpotlightScreen.self, from: Self.validDeckDetailJSON())

        guard case let .button(id, props, action) = screen.components[3] else {
            Issue.record("Expected fourth deck detail component to be button")
            return
        }

        #expect(id == "back-to-spotlight")
        #expect(props.title == "Back to Spotlight")
        #expect(action == .refresh)
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

    private static func validDeckDetailJSON() -> Data {
        Data(
        """
        {
          "screenId": "deck-detail",
          "version": 1,
          "title": "Izzet Phoenix",
          "components": [
            {
              "id": "deck-hero",
              "type": "hero",
              "props": {
                "eyebrowTitle": "Deck Detail",
                "deckName": "Izzet Phoenix",
                "tagline": "Spell velocity, recursion, and fast pressure.",
                "stats": [
                  { "id": "colors", "title": "Colors", "value": "Blue / Red" },
                  { "id": "format", "title": "Format", "value": "Pioneer" },
                  { "id": "style", "title": "Style", "value": "Tempo" }
                ]
              }
            },
            {
              "id": "game-plan",
              "type": "text",
              "props": {
                "title": "Game Plan",
                "body": "Trade resources early, fill the graveyard, and turn recursion into pressure."
              }
            },
            {
              "id": "core-cards",
              "type": "cardCarousel",
              "props": {
                "title": "Core Cards",
                "cards": [
                  {
                    "id": "arclight-phoenix",
                    "name": "Arclight Phoenix",
                    "typeLine": "Creature",
                    "manaCost": "3R",
                    "note": "Primary recurring threat.",
                    "theme": "phoenix"
                  },
                  {
                    "id": "treasure-cruise",
                    "name": "Treasure Cruise",
                    "typeLine": "Sorcery",
                    "manaCost": "7U",
                    "note": "Refuels efficiently.",
                    "theme": "cruise"
                  }
                ]
              }
            },
            {
              "id": "back-to-spotlight",
              "type": "button",
              "props": {
                "title": "Back to Spotlight"
              },
              "action": {
                "type": "refresh",
                "payload": {}
              }
            }
          ]
        }
        """.utf8
        )
    }
}
