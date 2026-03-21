//
//  RemoteSpotlightContentServiceTests.swift
//  MTGSpotlightTests
//
//  Created by Codex on 21/03/26.
//

import Foundation
import Testing
@testable import MTGSpotlight

@MainActor
struct RemoteSpotlightContentServiceTests {
    @Test func fetchDeckSpotlightRequestsVaporEndpointAndDecodesPayload() async throws {
        URLProtocolStub.responseProvider = {
            let response = HTTPURLResponse(
                url: URL(string: "http://127.0.0.1:8080/screens/deck-spotlight")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            return (Self.validScreenJSON(), response)
        }

        defer { URLProtocolStub.responseProvider = nil }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]

        let service = RemoteSpotlightContentService(
            baseURL: URL(string: "http://127.0.0.1:8080")!,
            session: URLSession(configuration: configuration)
        )

        let screen = try await service.fetchDeckSpotlight()

        #expect(URLProtocolStub.lastRequestURL?.path == "/screens/deck-spotlight")
        #expect(screen.screenID == "deck-spotlight")
        #expect(screen.title == "Deck Spotlight")
        #expect(screen.components.count == 4)
    }

    @Test func fetchDeckSpotlightThrowsForNonSuccessStatusCode() async {
        URLProtocolStub.responseProvider = {
            let response = HTTPURLResponse(
                url: URL(string: "http://127.0.0.1:8080/screens/deck-spotlight")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!

            return (Data(), response)
        }

        defer { URLProtocolStub.responseProvider = nil }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]

        let service = RemoteSpotlightContentService(
            baseURL: URL(string: "http://127.0.0.1:8080")!,
            session: URLSession(configuration: configuration)
        )

        await #expect(throws: SpotlightContentServiceError.self) {
            try await service.fetchDeckSpotlight()
        }
    }

    nonisolated private static func validScreenJSON() -> Data {
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
                  { "id": "colors", "title": "Colors", "value": "Blue / Red" }
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
}

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    static var responseProvider: (@Sendable () throws -> (Data, URLResponse))?
    static var lastRequestURL: URL?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lastRequestURL = request.url

        do {
            guard let responseProvider = Self.responseProvider else {
                throw URLError(.badServerResponse)
            }

            let (data, response) = try responseProvider()
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
