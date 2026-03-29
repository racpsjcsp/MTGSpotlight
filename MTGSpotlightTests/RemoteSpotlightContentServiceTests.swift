//
//  RemoteSpotlightContentServiceTests.swift
//  MTGSpotlightTests
//
//  Created by Codex on 21/03/26.
//

import Foundation
import Synchronization
import Testing
@testable import MTGSpotlight

@Suite(.serialized)
@MainActor
struct RemoteSpotlightContentServiceTests {
    @Test func fetchDeckSpotlightRequestsVaporEndpointAndDecodesPayload() async throws {
        let testID = URLProtocolStub.registerResponseProvider {
            let response = HTTPURLResponse(
                url: URL(string: "http://127.0.0.1:8080/screens/deck-spotlight")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            return (Self.validScreenJSON(), response)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        configuration.httpAdditionalHeaders = [URLProtocolStub.testIDHeader: testID]

        let service = RemoteSpotlightContentService(
            baseURL: URL(string: "http://127.0.0.1:8080")!,
            session: URLSession(configuration: configuration)
        )

        let screen = try await service.fetchDeckSpotlight()

        #expect(URLProtocolStub.lastRequestURL(for: testID)?.path == "/screens/deck-spotlight")
        #expect(screen.screenID == "deck-spotlight")
        #expect(screen.title == "Deck Spotlight")
        #expect(screen.components.count == 4)

        URLProtocolStub.removeState(for: testID)
    }

    @Test func fetchDeckSpotlightThrowsForNonSuccessStatusCode() async {
        let testID = URLProtocolStub.registerResponseProvider {
            let response = HTTPURLResponse(
                url: URL(string: "http://127.0.0.1:8080/screens/deck-spotlight")!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!

            return (Data(), response)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        configuration.httpAdditionalHeaders = [URLProtocolStub.testIDHeader: testID]

        let service = RemoteSpotlightContentService(
            baseURL: URL(string: "http://127.0.0.1:8080")!,
            session: URLSession(configuration: configuration)
        )

        await #expect(throws: SpotlightContentServiceError.self) {
            try await service.fetchDeckSpotlight()
        }

        URLProtocolStub.removeState(for: testID)
    }

    @Test func fetchDeckDetailRequestsDeckDetailEndpointAndDecodesPayload() async throws {
        let testID = URLProtocolStub.registerResponseProvider {
            let response = HTTPURLResponse(
                url: URL(string: "http://127.0.0.1:8080/screens/deck-detail/izzet-phoenix")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            return (Self.validDeckDetailJSON(), response)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        configuration.httpAdditionalHeaders = [URLProtocolStub.testIDHeader: testID]

        let service = RemoteSpotlightContentService(
            baseURL: URL(string: "http://127.0.0.1:8080")!,
            session: URLSession(configuration: configuration)
        )

        let screen = try await service.fetchDeckDetail(deckID: "izzet-phoenix")

        #expect(URLProtocolStub.lastRequestURL(for: testID)?.path == "/screens/deck-detail/izzet-phoenix")
        #expect(screen.screenID == "deck-detail")
        #expect(screen.title == "Izzet Phoenix")

        URLProtocolStub.removeState(for: testID)
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

    nonisolated private static func validDeckDetailJSON() -> Data {
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
                  { "id": "colors", "title": "Colors", "value": "Blue / Red" }
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

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    static let testIDHeader = "X-Test-ID"

    private struct Entry {
        var responseProvider: (@Sendable () throws -> (Data, URLResponse))
        var lastRequestURL: URL?
    }

    private static let state = Mutex([String: Entry]())

    static func registerResponseProvider(
        _ responseProvider: @escaping @Sendable () throws -> (Data, URLResponse)
    ) -> String {
        let testID = UUID().uuidString

        state.withLock {
            $0[testID] = Entry(responseProvider: responseProvider, lastRequestURL: nil)
        }

        return testID
    }

    static func lastRequestURL(for testID: String) -> URL? {
        state.withLock { $0[testID]?.lastRequestURL }
    }

    static func removeState(for testID: String) {
        _ = state.withLock {
            $0.removeValue(forKey: testID)
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard
            let testID = request.value(forHTTPHeaderField: Self.testIDHeader),
            let entry = Self.state.withLock({ $0[testID] })
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            Self.state.withLock {
                $0[testID]?.lastRequestURL = request.url
            }

            let (data, response) = try entry.responseProvider()
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
