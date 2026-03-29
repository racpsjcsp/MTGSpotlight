//
//  BundledSpotlightPayloadTests.swift
//  MTGSpotlightTests
//
//  Created by Rafael Plinio on 21/03/26.
//

import Foundation
import Testing
@testable import MTGSpotlight

@MainActor
struct BundledSpotlightPayloadTests {
    @Test func bundledPayloadDecodes() async throws {
        let bundle = Bundle.main
        let service = LocalSpotlightContentService(bundle: bundle)

        let screen = try await service.fetchDeckSpotlight()

        #expect(!screen.screenID.isEmpty)
        #expect(screen.version == 1)
        #expect(!screen.title.isEmpty)
        #expect(!screen.components.isEmpty)
    }

    @Test func bundledDeckDetailPayloadDecodes() async throws {
        let service = LocalSpotlightContentService(bundle: .main)

        let screen = try await service.fetchDeckDetail(deckID: "izzet-phoenix")

        #expect(screen.screenID == "deck-detail")
        #expect(screen.version == 1)
        #expect(screen.title == "Izzet Phoenix")
        #expect(!screen.components.isEmpty)
    }
}
