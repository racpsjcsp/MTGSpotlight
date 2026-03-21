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

    @Test(arguments: [
        "deck-spotlight",
        "deck-spotlight-control",
        "deck-spotlight-midrange"
    ])
    func bundledPayloadDecodes(resourceName: String) throws {
        let bundle = Bundle(for: TestBundleMarker.self)
        let service = LocalSpotlightContentService(bundle: bundle)

        let screen = try service.fetchScreen(named: resourceName)

        #expect(!screen.screenID.isEmpty)
        #expect(screen.version == 1)
        #expect(!screen.title.isEmpty)
        #expect(!screen.components.isEmpty)
    }
}

private final class TestBundleMarker {}
